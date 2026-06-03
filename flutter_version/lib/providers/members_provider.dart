import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/members.dart' show kMemberColorHex, kDefaultSelfMemberId;
import '../data/database.dart';
import '../models/query_results.dart';
import 'database_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class MembersState {
  final List<MemberWithStats> members;
  final FamilySummary? summary;

  const MembersState({this.members = const [], this.summary});

  MembersState copyWith({
    List<MemberWithStats>? members,
    FamilySummary? summary,
  }) =>
      MembersState(
        members: members ?? this.members,
        summary: summary ?? this.summary,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class MembersNotifier extends Notifier<MembersState> {
  @override
  MembersState build() => const MembersState();

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> loadMembers() async {
    final members = await _db.membersDao.findAllWithStats();
    state = state.copyWith(members: members);
  }

  Future<void> loadSummary() async {
    final summary = await _db.membersDao.getFamilySummary();
    state = MembersState(members: state.members, summary: summary);
  }

  /// Returns the [MemberWithStats] for [id] from the current in-memory list,
  /// or null if not loaded or not found.
  MemberWithStats? getMemberWithStats(String id) {
    try {
      return state.members.firstWhere((m) => m.member.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns the plain [Member] for [id] from the current list, or null.
  Member? getMember(String id) => getMemberWithStats(id)?.member;

  /// Creates a new member. The color is auto-assigned from [kMemberColorHex]
  /// by creation order if not explicitly set in [input].
  Future<Member> createMember(MembersCompanion input) async {
    final colorHex = (input.color.present && input.color.value.isNotEmpty)
        ? input.color.value
        : kMemberColorHex[state.members.length % kMemberColorHex.length];
    final member =
        await _db.membersDao.create(input.copyWith(color: Value(colorHex)));
    await loadMembers();
    return member;
  }

  Future<void> updateMember(String id, MembersCompanion patch) async {
    await _db.membersDao.updateMember(id, patch);
    await loadMembers();
  }

  /// Cascade-deletes a member and all their data (visits, attachments,
  /// reminders, insurance). Returns [FileRef]s for disk cleanup.
  /// Will throw if called on the fixed Self member.
  Future<List<FileRef>> deleteMember(String id) async {
    assert(id != kDefaultSelfMemberId, 'Self member cannot be deleted');
    final refs = await _db.membersDao.deleteMember(id);
    await loadMembers();
    return refs;
  }

  /// Direct DB lookup — used by screens that may need a member not yet
  /// loaded into state.
  Future<Member?> findById(String id) => _db.membersDao.findById(id);
}

final membersProvider =
    NotifierProvider<MembersNotifier, MembersState>(MembersNotifier.new);
