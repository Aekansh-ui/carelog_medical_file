import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../../utils/date_utils.dart' as du;

part 'reminders_dao.g.dart';

/// Mirrors `../carelog/src/db/remindersRepository.ts`.
@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);
  static const _uuid = Uuid();

  Future<Reminder> create(String visitId, String followUpDate) async {
    final id = _uuid.v4();
    await into(reminders).insert(RemindersCompanion.insert(
      id: id,
      visitId: visitId,
      followUpDate: followUpDate,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    ));
    return (select(reminders)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Active reminders dated today or later, soonest first.
  Future<List<Reminder>> findUpcoming() {
    final t = du.today();
    return (select(reminders)
          ..where((r) => r.isActive.equals(1) & r.followUpDate.isBiggerOrEqualValue(t))
          ..orderBy([(r) => OrderingTerm.asc(r.followUpDate)]))
        .get();
  }

  Future<Reminder?> findByVisit(String visitId) => (select(reminders)
        ..where((r) => r.visitId.equals(visitId))
        ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<void> setActive(String id, bool active) async {
    await (update(reminders)..where((r) => r.id.equals(id)))
        .write(RemindersCompanion(isActive: Value(active ? 1 : 0)));
  }

  Future<void> updateReminder(String id, RemindersCompanion patch) async {
    await (update(reminders)..where((r) => r.id.equals(id))).write(patch);
  }

  Future<void> deleteReminder(String id) async {
    await (delete(reminders)..where((r) => r.id.equals(id))).go();
  }

  Future<void> deleteByVisit(String visitId) async {
    await (delete(reminders)..where((r) => r.visitId.equals(visitId))).go();
  }
}
