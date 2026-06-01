import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../../models/query_results.dart';
import '../../utils/date_utils.dart' as du;

part 'members_dao.g.dart';

/// Mirrors `../carelog/src/db/membersRepository.ts`.
@DriftAccessor(tables: [
  Members,
  Visits,
  Attachments,
  Reminders,
  InsurancePolicies,
  InsuranceDocuments,
])
class MembersDao extends DatabaseAccessor<AppDatabase> with _$MembersDaoMixin {
  MembersDao(super.db);
  static const _uuid = Uuid();

  String get _now => DateTime.now().toUtc().toIso8601String();

  Future<Member> create(MembersCompanion input) async {
    final id = _uuid.v4();
    await into(members).insert(input.copyWith(
      id: Value(id),
      createdAt: Value(_now),
      updatedAt: Value(_now),
    ));
    return (select(members)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateMember(String id, MembersCompanion patch) async {
    await (update(members)..where((t) => t.id.equals(id)))
        .write(patch.copyWith(updatedAt: Value(_now)));
  }

  /// Cascade delete: member → their visits (+attachments & reminders) and their
  /// insurance policies (+documents), in an explicit transaction matching the
  /// RN repository. Returns every file ref for disk cleanup.
  Future<List<FileRef>> deleteMember(String id) {
    return transaction(() async {
      final attRows = await customSelect(
        'SELECT file_path, thumbnail_path FROM attachments '
        'WHERE visit_id IN (SELECT id FROM visits WHERE member_id = ?)',
        variables: [Variable.withString(id)],
        readsFrom: {attachments, visits},
      ).get();
      final docRows = await customSelect(
        'SELECT file_path, thumbnail_path FROM insurance_documents '
        'WHERE policy_id IN (SELECT id FROM insurance_policies WHERE member_id = ?)',
        variables: [Variable.withString(id)],
        readsFrom: {insuranceDocuments, insurancePolicies},
      ).get();

      await customStatement(
          'DELETE FROM attachments WHERE visit_id IN (SELECT id FROM visits WHERE member_id = ?)',
          [id]);
      await customStatement(
          'DELETE FROM reminders WHERE visit_id IN (SELECT id FROM visits WHERE member_id = ?)',
          [id]);
      await customStatement(
          'DELETE FROM insurance_documents WHERE policy_id IN (SELECT id FROM insurance_policies WHERE member_id = ?)',
          [id]);
      await customStatement(
          'DELETE FROM insurance_policies WHERE member_id = ?', [id]);
      await customStatement('DELETE FROM visits WHERE member_id = ?', [id]);
      await customStatement('DELETE FROM members WHERE id = ?', [id]);

      return [...attRows, ...docRows]
          .map((r) =>
              FileRef(r.read<String>('file_path'), r.read<String?>('thumbnail_path')))
          .toList();
    });
  }

  Future<Member?> findById(String id) =>
      (select(members)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Members + per-member stats for the Family Home dashboard (Self pinned first).
  Future<List<MemberWithStats>> findAllWithStats() async {
    final t = du.today();
    final rows = await customSelect(
      'SELECT m.*, '
      '(SELECT COUNT(*) FROM visits v WHERE v.member_id = m.id) AS visit_count, '
      '(SELECT MAX(v.visit_date) FROM visits v WHERE v.member_id = m.id) AS last_visit_date, '
      "(SELECT MIN(v.follow_up_date) FROM visits v WHERE v.member_id = m.id AND v.follow_up_date >= ?) AS next_follow_up "
      'FROM members m '
      "ORDER BY (m.relationship = 'SELF') DESC, m.created_at ASC",
      variables: [Variable.withString(t)],
      readsFrom: {members, visits},
    ).get();
    return rows
        .map((r) => MemberWithStats(
              member: members.map(r.data),
              visitCount: r.read<int>('visit_count'),
              lastVisitDate: r.read<String?>('last_visit_date'),
              nextFollowUp: r.read<String?>('next_follow_up'),
            ))
        .toList();
  }

  Future<FamilySummary> getFamilySummary() async {
    final t = du.today();
    final totals = await customSelect(
      'SELECT (SELECT COUNT(*) FROM members) AS members, '
      '(SELECT COUNT(*) FROM visits) AS visits',
      readsFrom: {members, visits},
    ).getSingle();
    final upcoming = await customSelect(
      'SELECT v.id AS visit_id, v.member_id, m.name AS member_name, '
      'm.color AS member_color, v.speciality_id, v.doctor_name, v.follow_up_date '
      'FROM visits v JOIN members m ON v.member_id = m.id '
      'WHERE v.follow_up_date >= ? ORDER BY v.follow_up_date ASC',
      variables: [Variable.withString(t)],
      readsFrom: {visits, members},
    ).get();
    return FamilySummary(
      totalMembers: totals.read<int>('members'),
      totalVisits: totals.read<int>('visits'),
      upcomingFollowUps: upcoming
          .map((r) => UpcomingFollowUp(
                visitId: r.read<String>('visit_id'),
                memberId: r.read<String>('member_id'),
                memberName: r.read<String>('member_name'),
                memberColor: r.read<String?>('member_color'),
                specialityId: r.read<String>('speciality_id'),
                doctorName: r.read<String?>('doctor_name'),
                followUpDate: r.read<String>('follow_up_date'),
              ))
          .toList(),
    );
  }
}
