import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/query_results.dart';
import 'database_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class InsuranceState {
  final List<PolicyWithDocCount> policies;
  final String? currentMemberId;
  final InsurancePolicy? currentPolicy;

  const InsuranceState(
      {this.policies = const [],
      this.currentMemberId,
      this.currentPolicy});

  InsuranceState copyWith({
    List<PolicyWithDocCount>? policies,
    String? currentMemberId,
    InsurancePolicy? currentPolicy,
  }) =>
      InsuranceState(
        policies: policies ?? this.policies,
        currentMemberId: currentMemberId ?? this.currentMemberId,
        currentPolicy: currentPolicy ?? this.currentPolicy,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class InsuranceNotifier extends Notifier<InsuranceState> {
  @override
  InsuranceState build() => const InsuranceState();

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> loadForMember(String memberId) async {
    final policies = await _db.insuranceDao.findByMember(memberId);
    state = InsuranceState(policies: policies, currentMemberId: memberId);
  }

  Future<InsurancePolicy> createPolicy(InsurancePoliciesCompanion input) async {
    final policy = await _db.insuranceDao.create(input);
    // Refresh list if we're viewing this member's policies.
    if (state.currentMemberId == input.memberId.value) {
      await loadForMember(input.memberId.value);
    }
    return policy;
  }

  Future<void> loadById(String id) async {
    final policy = await _db.insuranceDao.findById(id);
    state = InsuranceState(
      policies: state.policies,
      currentMemberId: state.currentMemberId,
      currentPolicy: policy,
    );
  }

  Future<void> updatePolicy(String id, InsurancePoliciesCompanion patch) async {
    await _db.insuranceDao.updatePolicy(id, patch);
    if (state.currentMemberId != null) {
      await loadForMember(state.currentMemberId!);
    }
    // Refresh detail view if this policy is currently open.
    if (state.currentPolicy?.id == id) await loadById(id);
  }

  /// Cascade-deletes a policy and all its documents. Returns [FileRef]s for
  /// disk cleanup via [fileService].
  Future<List<FileRef>> deletePolicy(String id) async {
    final refs = await _db.insuranceDao.deletePolicy(id);
    if (state.currentMemberId != null) {
      await loadForMember(state.currentMemberId!);
    }
    return refs;
  }

  Future<InsurancePolicy?> findById(String id) =>
      _db.insuranceDao.findById(id);

  Future<int> countByMember(String memberId) =>
      _db.insuranceDao.countByMember(memberId);

  // --- Documents -------------------------------------------------------------

  Future<InsuranceDocument> addDocument(InsuranceDocumentsCompanion input) =>
      _db.insuranceDao.addDocument(input);

  Future<List<InsuranceDocument>> loadDocuments(String policyId) =>
      _db.insuranceDao.findDocuments(policyId);

  Future<FileRef?> deleteDocument(String id) =>
      _db.insuranceDao.deleteDocument(id);
}

final insuranceProvider =
    NotifierProvider<InsuranceNotifier, InsuranceState>(InsuranceNotifier.new);
