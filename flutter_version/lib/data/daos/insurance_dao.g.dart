// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insurance_dao.dart';

// ignore_for_file: type=lint
mixin _$InsuranceDaoMixin on DatabaseAccessor<AppDatabase> {
  $MembersTable get members => attachedDatabase.members;
  $InsurancePoliciesTable get insurancePolicies =>
      attachedDatabase.insurancePolicies;
  $InsuranceDocumentsTable get insuranceDocuments =>
      attachedDatabase.insuranceDocuments;
  InsuranceDaoManager get managers => InsuranceDaoManager(this);
}

class InsuranceDaoManager {
  final _$InsuranceDaoMixin _db;
  InsuranceDaoManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db.attachedDatabase, _db.members);
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
