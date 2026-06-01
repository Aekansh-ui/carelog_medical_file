// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_dao.dart';

// ignore_for_file: type=lint
mixin _$MembersDaoMixin on DatabaseAccessor<AppDatabase> {
  $MembersTable get members => attachedDatabase.members;
  $VisitsTable get visits => attachedDatabase.visits;
  $AttachmentsTable get attachments => attachedDatabase.attachments;
  $RemindersTable get reminders => attachedDatabase.reminders;
  $InsurancePoliciesTable get insurancePolicies =>
      attachedDatabase.insurancePolicies;
  $InsuranceDocumentsTable get insuranceDocuments =>
      attachedDatabase.insuranceDocuments;
  MembersDaoManager get managers => MembersDaoManager(this);
}

class MembersDaoManager {
  final _$MembersDaoMixin _db;
  MembersDaoManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db.attachedDatabase, _db.members);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db.attachedDatabase, _db.visits);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db.attachedDatabase, _db.attachments);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
  $$InsurancePoliciesTableTableManager get insurancePolicies =>
      $$InsurancePoliciesTableTableManager(
        _db.attachedDatabase,
        _db.insurancePolicies,
      );
  $$InsuranceDocumentsTableTableManager get insuranceDocuments =>
      $$InsuranceDocumentsTableTableManager(
        _db.attachedDatabase,
        _db.insuranceDocuments,
      );
}
