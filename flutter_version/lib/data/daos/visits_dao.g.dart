// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visits_dao.dart';

// ignore_for_file: type=lint
mixin _$VisitsDaoMixin on DatabaseAccessor<AppDatabase> {
  $MembersTable get members => attachedDatabase.members;
  $VisitsTable get visits => attachedDatabase.visits;
  $AttachmentsTable get attachments => attachedDatabase.attachments;
  $RemindersTable get reminders => attachedDatabase.reminders;
  VisitsDaoManager get managers => VisitsDaoManager(this);
}

class VisitsDaoManager {
  final _$VisitsDaoMixin _db;
  VisitsDaoManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db.attachedDatabase, _db.members);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db.attachedDatabase, _db.visits);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db.attachedDatabase, _db.attachments);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
}
