import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../../models/query_results.dart';

part 'insurance_dao.g.dart';

/// Mirrors `../carelog/src/db/insuranceRepository.ts`.
@DriftAccessor(tables: [InsurancePolicies, InsuranceDocuments])
class InsuranceDao extends DatabaseAccessor<AppDatabase>
    with _$InsuranceDaoMixin {
  InsuranceDao(super.db);
  static const _uuid = Uuid();

  String get _now => DateTime.now().toUtc().toIso8601String();

  Future<InsurancePolicy> create(InsurancePoliciesCompanion input) async {
    final id = _uuid.v4();
    await into(insurancePolicies).insert(input.copyWith(
      id: Value(id),
      createdAt: Value(_now),
      updatedAt: Value(_now),
    ));
    return (select(insurancePolicies)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<void> updatePolicy(String id, InsurancePoliciesCompanion patch) async {
    await (update(insurancePolicies)..where((t) => t.id.equals(id)))
        .write(patch.copyWith(updatedAt: Value(_now)));
  }

  /// Deletes a policy (+documents cascade) inside a transaction; returns the
  /// document file refs for disk cleanup.
  Future<List<FileRef>> deletePolicy(String id) {
    return transaction(() async {
      final docs = await (select(insuranceDocuments)
            ..where((t) => t.policyId.equals(id)))
          .get();
      final refs =
          docs.map((d) => FileRef(d.filePath, d.thumbnailPath)).toList();
      await (delete(insurancePolicies)..where((t) => t.id.equals(id))).go();
      return refs;
    });
  }

  Future<InsurancePolicy?> findById(String id) =>
      (select(insurancePolicies)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Policies for a member with their document counts, soonest-expiry first
  /// (NULL expiry dates last).
  Future<List<PolicyWithDocCount>> findByMember(String memberId) async {
    final rows = await customSelect(
      'SELECT p.*, '
      '(SELECT COUNT(*) FROM insurance_documents d WHERE d.policy_id = p.id) AS document_count '
      'FROM insurance_policies p WHERE p.member_id = ? '
      'ORDER BY (p.valid_until IS NULL), p.valid_until ASC',
      variables: [Variable.withString(memberId)],
      readsFrom: {insurancePolicies, insuranceDocuments},
    ).get();
    return rows
        .map((r) => PolicyWithDocCount(
              policy: insurancePolicies.map(r.data),
              documentCount: r.read<int>('document_count'),
            ))
        .toList();
  }

  Future<int> countByMember(String memberId) async {
    final c = insurancePolicies.id.count();
    final row = await (selectOnly(insurancePolicies)
          ..addColumns([c])
          ..where(insurancePolicies.memberId.equals(memberId)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  // --- Documents ------------------------------------------------------------

  Future<InsuranceDocument> addDocument(
      InsuranceDocumentsCompanion input) async {
    final id = _uuid.v4();
    await into(insuranceDocuments).insert(input.copyWith(
      id: Value(id),
      createdAt: Value(_now),
    ));
    return (select(insuranceDocuments)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<List<InsuranceDocument>> findDocuments(String policyId) =>
      (select(insuranceDocuments)
            ..where((t) => t.policyId.equals(policyId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<FileRef?> deleteDocument(String id) async {
    final d = await (select(insuranceDocuments)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (d == null) return null;
    await (delete(insuranceDocuments)..where((t) => t.id.equals(id))).go();
    return FileRef(d.filePath, d.thumbnailPath);
  }
}
