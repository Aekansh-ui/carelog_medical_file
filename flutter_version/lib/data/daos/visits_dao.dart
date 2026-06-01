import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../../models/query_results.dart';

part 'visits_dao.g.dart';

/// Mirrors `../carelog/src/db/visitsRepository.ts`.
@DriftAccessor(tables: [Visits, Attachments, Reminders, Members])
class VisitsDao extends DatabaseAccessor<AppDatabase> with _$VisitsDaoMixin {
  VisitsDao(super.db);
  static const _uuid = Uuid();

  String get _now => DateTime.now().toUtc().toIso8601String();

  /// Inserts a visit; the DAO stamps `id`/`created_at`/`updated_at`.
  Future<Visit> create(VisitsCompanion input) async {
    final id = _uuid.v4();
    await into(visits).insert(input.copyWith(
      id: Value(id),
      createdAt: Value(_now),
      updatedAt: Value(_now),
    ));
    return (select(visits)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateVisit(String id, VisitsCompanion patch) async {
    await (update(visits)..where((t) => t.id.equals(id)))
        .write(patch.copyWith(updatedAt: Value(_now)));
  }

  /// Deletes a visit (attachments + reminders cascade via FK) and returns the
  /// attachment file refs so the caller can purge them from disk.
  Future<List<FileRef>> deleteVisit(String id) async {
    final atts =
        await (select(attachments)..where((t) => t.visitId.equals(id))).get();
    final refs = atts.map((a) => FileRef(a.filePath, a.thumbnailPath)).toList();
    await (delete(visits)..where((t) => t.id.equals(id))).go();
    return refs;
  }

  Future<Visit?> findById(String id) =>
      (select(visits)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Visit>> findRecent(int limit) => (select(visits)
        ..orderBy([(t) => OrderingTerm.desc(t.visitDate)])
        ..limit(limit))
      .get();

  Future<List<Visit>> findRecentForMember(String memberId, int limit) =>
      (select(visits)
            ..where((t) => t.memberId.equals(memberId))
            ..orderBy([(t) => OrderingTerm.desc(t.visitDate)])
            ..limit(limit))
          .get();

  Future<List<Visit>> findBySpeciality(String specialityId,
      {String? memberId}) {
    final q = select(visits)..where((t) => t.specialityId.equals(specialityId));
    if (memberId != null) q.where((t) => t.memberId.equals(memberId));
    q.orderBy([(t) => OrderingTerm.desc(t.visitDate)]);
    return q.get();
  }

  // --- Search ---------------------------------------------------------------

  /// Full-text search across doctor/clinic/symptoms/diagnosis/notes, joined to
  /// the member (for the result badge). Falls back to LIKE if FTS5 is absent.
  Future<List<VisitWithMember>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    try {
      final rows = await customSelect(
        'SELECT v.*, m.name AS member_name, m.color AS member_color '
        'FROM visits_fts f JOIN visits v ON v.rowid = f.rowid '
        'LEFT JOIN members m ON v.member_id = m.id '
        'WHERE visits_fts MATCH ? ORDER BY rank',
        variables: [Variable.withString(_ftsQuery(trimmed))],
        readsFrom: {visits, members},
      ).get();
      return rows.map(_mapVisitWithMember).toList();
    } catch (_) {
      return _searchLike(trimmed);
    }
  }

  String _ftsQuery(String q) {
    final cleaned = q.replaceAll(RegExp(r'[^\w\s]'), ' ').trim();
    if (cleaned.isEmpty) return q;
    return cleaned.split(RegExp(r'\s+')).map((t) => '$t*').join(' ');
  }

  Future<List<VisitWithMember>> _searchLike(String q) async {
    final rows = await customSelect(
      'SELECT v.*, m.name AS member_name, m.color AS member_color FROM visits v '
      'LEFT JOIN members m ON v.member_id = m.id '
      'WHERE v.doctor_name LIKE ?1 OR v.clinic_name LIKE ?1 OR v.symptoms LIKE ?1 '
      'OR v.diagnosis LIKE ?1 OR v.notes LIKE ?1 ORDER BY v.visit_date DESC',
      variables: [Variable.withString('%$q%')],
      readsFrom: {visits, members},
    ).get();
    return rows.map(_mapVisitWithMember).toList();
  }

  VisitWithMember _mapVisitWithMember(QueryRow row) => VisitWithMember(
        visit: visits.map(row.data),
        memberName: row.read<String?>('member_name'),
        memberColor: row.read<String?>('member_color'),
      );

  // --- Aggregations (Reports) ----------------------------------------------

  Future<int> countAll() async {
    final c = visits.id.count();
    final row = await (selectOnly(visits)..addColumns([c])).getSingle();
    return row.read(c) ?? 0;
  }

  Future<int> countByMember(String memberId) async {
    final c = visits.id.count();
    final row = await (selectOnly(visits)
          ..addColumns([c])
          ..where(visits.memberId.equals(memberId)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  Future<Map<String, int>> countsBySpeciality() async {
    final c = visits.id.count();
    final rows = await (selectOnly(visits)
          ..addColumns([visits.specialityId, c])
          ..groupBy([visits.specialityId]))
        .get();
    return {
      for (final r in rows) r.read(visits.specialityId)!: r.read(c) ?? 0,
    };
  }

  Future<Map<String, int>> countsByBodyPart() async {
    final c = visits.id.count();
    final rows = await (selectOnly(visits)
          ..addColumns([visits.bodyPartId, c])
          ..groupBy([visits.bodyPartId]))
        .get();
    return {
      for (final r in rows) r.read(visits.bodyPartId)!: r.read(c) ?? 0,
    };
  }
}
