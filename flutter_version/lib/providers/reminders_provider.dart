import 'package:drift/drift.dart' show Value, Variable, QueryRow;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/query_results.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart' as du;
import 'database_provider.dart';
import 'settings_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class RemindersState {
  final List<ReminderWithVisit> upcoming;
  final List<ReminderWithVisit> past;

  const RemindersState({
    this.upcoming = const [],
    this.past = const [],
  });

  RemindersState copyWith({
    List<ReminderWithVisit>? upcoming,
    List<ReminderWithVisit>? past,
  }) =>
      RemindersState(
        upcoming: upcoming ?? this.upcoming,
        past: past ?? this.past,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class RemindersNotifier extends Notifier<RemindersState> {
  @override
  RemindersState build() => const RemindersState();

  AppDatabase get _db => ref.read(databaseProvider);

  // ── Queries ──────────────────────────────────────────────────────────────

  Future<void> load() async {
    final upcoming = await _fetchUpcoming();
    final past = await _fetchPast();
    state = RemindersState(upcoming: upcoming, past: past);
  }

  Future<List<ReminderWithVisit>> _fetchUpcoming() async {
    final today = du.today();
    final rows = await _db.customSelect(
      'SELECT r.*, v.doctor_name, v.speciality_id, v.body_part_id, '
      'm.name AS member_name, m.color AS member_color '
      'FROM reminders r '
      'JOIN visits v ON r.visit_id = v.id '
      'LEFT JOIN members m ON v.member_id = m.id '
      'WHERE r.follow_up_date >= ? AND r.is_active = 1 '
      'ORDER BY r.follow_up_date ASC',
      variables: [Variable.withString(today)],
      readsFrom: {_db.reminders, _db.visits, _db.members},
    ).get();
    return rows.map<ReminderWithVisit>(_mapRow).toList();
  }

  Future<List<ReminderWithVisit>> _fetchPast() async {
    final today = du.today();
    final rows = await _db.customSelect(
      'SELECT r.*, v.doctor_name, v.speciality_id, v.body_part_id, '
      'm.name AS member_name, m.color AS member_color '
      'FROM reminders r '
      'JOIN visits v ON r.visit_id = v.id '
      'LEFT JOIN members m ON v.member_id = m.id '
      'WHERE r.follow_up_date < ? OR r.is_active = 0 '
      'ORDER BY r.follow_up_date DESC',
      variables: [Variable.withString(today)],
      readsFrom: {_db.reminders, _db.visits, _db.members},
    ).get();
    return rows.map<ReminderWithVisit>(_mapRow).toList();
  }

  ReminderWithVisit _mapRow(QueryRow row) => ReminderWithVisit(
        reminder: _db.reminders.map(row.data),
        doctorName: row.read<String?>('doctor_name'),
        specialityId: row.read<String?>('speciality_id'),
        bodyPartId: row.read<String?>('body_part_id'),
        memberName: row.read<String?>('member_name'),
        memberColor: row.read<String?>('member_color'),
      );

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Creates a reminder row and schedules D-1/D-0 notifications if the user
  /// has notifications enabled. Updates the stored notification IDs on the row.
  Future<void> createReminder(String visitId, String followUpDate) async {
    final reminder = await _db.remindersDao.create(visitId, followUpDate);

    final settings = ref.read(settingsProvider);
    if (settings.notificationsEnabled) {
      final ids = await notificationService.scheduleFollowUp(
        visitId: visitId,
        followUpDate: followUpDate,
        reminderTime: settings.reminderTime,
      );
      if (ids.d1Id.isNotEmpty || ids.d0Id.isNotEmpty) {
        await _db.remindersDao.updateReminder(
          reminder.id,
          RemindersCompanion(
            notificationIdD1: Value(ids.d1Id.isEmpty ? null : ids.d1Id),
            notificationIdD0: Value(ids.d0Id.isEmpty ? null : ids.d0Id),
          ),
        );
      }
    }

    await load();
  }

  /// Updates the follow-up date on both the visit and the reminder, cancels
  /// old notifications and schedules fresh ones.
  Future<void> reschedule(
      String reminderId, String visitId, String newDate) async {
    final rwv = state.upcoming
        .where((r) => r.reminder.id == reminderId)
        .firstOrNull;
    final reminder = rwv?.reminder;

    if (reminder != null) {
      await notificationService.cancelNotifications(
        reminder.notificationIdD1 ?? '',
        reminder.notificationIdD0 ?? '',
      );
    }

    // Update visit's follow_up_date
    await _db.visitsDao.updateVisit(
        visitId, VisitsCompanion(followUpDate: Value(newDate)));

    // Schedule new notifications
    String d1Id = '';
    String d0Id = '';
    final settings = ref.read(settingsProvider);
    if (settings.notificationsEnabled) {
      final ids = await notificationService.scheduleFollowUp(
        visitId: visitId,
        followUpDate: newDate,
        reminderTime: settings.reminderTime,
      );
      d1Id = ids.d1Id;
      d0Id = ids.d0Id;
    }

    // Write new date + notification IDs + rescheduled_at to reminder row
    await _db.remindersDao.updateReminder(
      reminderId,
      RemindersCompanion(
        followUpDate: Value(newDate),
        notificationIdD1: Value(d1Id.isEmpty ? null : d1Id),
        notificationIdD0: Value(d0Id.isEmpty ? null : d0Id),
        rescheduledAt:
            Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );

    await load();
  }

  /// Marks a reminder inactive ("done"). Does not cancel notifications.
  Future<void> deactivate(String id) async {
    await _db.remindersDao.setActive(id, false);
    await load();
  }

  /// Deletes a reminder and cancels its scheduled notifications.
  Future<void> deleteReminder(String id) async {
    final rwv = [
      ...state.upcoming,
      ...state.past,
    ].where((r) => r.reminder.id == id).firstOrNull;
    if (rwv != null) {
      await notificationService.cancelNotifications(
        rwv.reminder.notificationIdD1 ?? '',
        rwv.reminder.notificationIdD0 ?? '',
      );
    }
    await _db.remindersDao.deleteReminder(id);
    await load();
  }

  /// Reschedules all active reminders to the new [reminderTime] (HH:MM).
  /// Called from Settings when the reminder time changes.
  Future<void> rescheduleAll(String reminderTime) async {
    await load();
    for (final rwv in state.upcoming) {
      final r = rwv.reminder;
      await notificationService.cancelNotifications(
        r.notificationIdD1 ?? '',
        r.notificationIdD0 ?? '',
      );
      final ids = await notificationService.scheduleFollowUp(
        visitId: r.visitId,
        followUpDate: r.followUpDate,
        reminderTime: reminderTime,
      );
      await _db.remindersDao.updateReminder(
        r.id,
        RemindersCompanion(
          notificationIdD1: Value(ids.d1Id.isEmpty ? null : ids.d1Id),
          notificationIdD0: Value(ids.d0Id.isEmpty ? null : ids.d0Id),
        ),
      );
    }
    await load();
  }

  /// Cancels ALL scheduled notifications (called on Delete-All from Settings).
  Future<void> cancelAllNotifications() => notificationService.cancelAll();

  Future<Reminder?> findByVisit(String visitId) =>
      _db.remindersDao.findByVisit(visitId);
}

final remindersProvider =
    NotifierProvider<RemindersNotifier, RemindersState>(RemindersNotifier.new);
