import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/query_results.dart';
import '../services/notification_service.dart';
import 'database_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class VisitsState {
  final List<Visit> recentVisits;
  final List<Visit> listVisits;
  final Visit? currentVisit;
  final List<VisitWithMember> searchResults;
  final List<AttachmentWithVisit> recentAttachments;

  const VisitsState({
    this.recentVisits = const [],
    this.listVisits = const [],
    this.recentAttachments = const [],
    this.currentVisit,
    this.searchResults = const [],
  });

  VisitsState copyWith({
    List<Visit>? recentVisits,
    List<Visit>? listVisits,
    List<VisitWithMember>? searchResults,
    List<AttachmentWithVisit>? recentAttachments,
  }) =>
      VisitsState(
        recentVisits: recentVisits ?? this.recentVisits,
        listVisits: listVisits ?? this.listVisits,
        currentVisit: currentVisit, // preserved; use explicit builders to clear
        searchResults: searchResults ?? this.searchResults,
        recentAttachments: recentAttachments ?? this.recentAttachments,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class VisitsNotifier extends Notifier<VisitsState> {
  @override
  VisitsState build() => const VisitsState();

  AppDatabase get _db => ref.read(databaseProvider);

  // --- Queries ---------------------------------------------------------------

  Future<void> loadRecent(int limit) async {
    final visits = await _db.visitsDao.findRecent(limit);
    state = state.copyWith(recentVisits: visits);
  }

  Future<void> loadRecentForMember(String memberId, int limit) async {
    final visits = await _db.visitsDao.findRecentForMember(memberId, limit);
    state = state.copyWith(recentVisits: visits);
  }

  Future<void> loadBySpeciality(String specialityId, {String? memberId}) async {
    final visits =
        await _db.visitsDao.findBySpeciality(specialityId, memberId: memberId);
    state = state.copyWith(listVisits: visits);
  }

  Future<void> loadById(String id) async {
    final visit = await _db.visitsDao.findById(id);
    state = VisitsState(
      recentVisits: state.recentVisits,
      listVisits: state.listVisits,
      currentVisit: visit,
      searchResults: state.searchResults,
    );
  }

  // --- Mutations ------------------------------------------------------------

  Future<Visit> createVisit(VisitsCompanion input) async {
    final visit = await _db.visitsDao.create(input);
    // Refresh the member-scoped recent list so Member Home updates on pop.
    final memberId = input.memberId.present ? input.memberId.value : null;
    if (memberId != null) {
      await loadRecentForMember(memberId, 5);
    }
    return visit;
  }

  Future<void> updateVisit(String id, VisitsCompanion patch) async {
    await _db.visitsDao.updateVisit(id, patch);
    await loadById(id);
  }

  /// Deletes the visit (cascade removes attachments + reminders via FK),
  /// cancels any scheduled notifications, and returns the attachment [FileRef]s
  /// so the caller can delete the files from disk via [fileService].
  Future<List<FileRef>> deleteVisit(String id) async {
    // Grab reminder notification IDs before the cascade wipes them.
    final reminder = await _db.remindersDao.findByVisit(id);
    if (reminder != null) {
      await notificationService.cancelNotifications(
        reminder.notificationIdD1 ?? '',
        reminder.notificationIdD0 ?? '',
      );
    }
    final refs = await _db.visitsDao.deleteVisit(id);
    // Clear selected visit; list/recent must be reloaded by the calling screen.
    state = VisitsState(
      recentVisits: state.recentVisits,
      listVisits: state.listVisits,
      // currentVisit cleared
      searchResults: state.searchResults,
    );
    return refs;
  }

  // --- Reports attachments (joined) -----------------------------------------

  Future<void> loadRecentAttachments(int limit) async {
    final rows = await _db.customSelect(
      'SELECT a.*, v.visit_date, v.doctor_name, v.speciality_id, '
      'm.name AS member_name, m.color AS member_color '
      'FROM attachments a '
      'JOIN visits v ON a.visit_id = v.id '
      'LEFT JOIN members m ON v.member_id = m.id '
      'ORDER BY a.created_at DESC LIMIT ?',
      variables: [Variable.withInt(limit)],
      readsFrom: {_db.attachments, _db.visits, _db.members},
    ).get();
    final mapped = rows
        .map<AttachmentWithVisit>((row) => AttachmentWithVisit(
              attachment: _db.attachments.map(row.data),
              visitId: row.read<String?>('visit_id'),
              visitDate: row.read<String?>('visit_date'),
              doctorName: row.read<String?>('doctor_name'),
              specialityId: row.read<String?>('speciality_id'),
              memberName: row.read<String?>('member_name'),
              memberColor: row.read<String?>('member_color'),
            ))
        .toList();
    state = state.copyWith(recentAttachments: mapped);
  }

  // --- Search ---------------------------------------------------------------

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }
    final results = await _db.visitsDao.search(query);
    state = state.copyWith(searchResults: results);
  }

  void clearSearch() => state = state.copyWith(searchResults: []);

  // --- Aggregations (on-demand, not cached in state) -------------------------

  Future<int> countAll() => _db.visitsDao.countAll();
  Future<int> countByMember(String memberId) =>
      _db.visitsDao.countByMember(memberId);
  Future<Map<String, int>> countsBySpeciality({String? memberId}) =>
      _db.visitsDao.countsBySpeciality(memberId: memberId);
  Future<Map<String, int>> countsByBodyPart() =>
      _db.visitsDao.countsByBodyPart();

  // --- Attachments (delegated) -----------------------------------------------

  Future<Attachment> addAttachment(AttachmentsCompanion input) =>
      _db.attachmentsDao.add(input);

  Future<List<Attachment>> loadAttachments(String visitId) =>
      _db.attachmentsDao.findByVisit(visitId);

  Future<FileRef?> deleteAttachment(String id) =>
      _db.attachmentsDao.deleteAttachment(id);

  Future<List<Attachment>> recentAttachments(int limit) =>
      _db.attachmentsDao.recent(limit);
}

final visitsProvider =
    NotifierProvider<VisitsNotifier, VisitsState>(VisitsNotifier.new);
