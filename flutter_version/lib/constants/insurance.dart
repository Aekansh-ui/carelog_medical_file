import 'package:flutter/material.dart';

// Re-export the expiry helpers so insurance UI can import them from one place
// (the day-diff math itself lives in utils/date_utils.dart).
export '../utils/date_utils.dart' show ExpiryStatus, ExpiryInfo, getExpiryStatus;

/// Insurance plan-type catalog ported from `../carelog/src/constants/insurance.ts`.
/// `id` strings are persisted on policies — keep identical to the RN app.
class PlanTypeOption {
  final String id;
  final String label;
  final IconData icon;
  const PlanTypeOption(this.id, this.label, this.icon);
}

const List<PlanTypeOption> kPlanTypes = [
  PlanTypeOption('PERSONAL', 'Personal', Icons.person), // mdi: account
  PlanTypeOption('FAMILY_FLOATER', 'Family Floater', Icons.groups), // mdi: account-group
  PlanTypeOption('CORPORATE', 'Corporate', Icons.business), // mdi: office-building
  PlanTypeOption('OTHER', 'Other', Icons.shield_outlined), // mdi: shield-outline
];

PlanTypeOption? planTypeById(String id) {
  for (final p in kPlanTypes) {
    if (p.id == id) return p;
  }
  return null;
}

/// A policy is flagged "expiring soon" when valid_until is within this many days.
const int kInsuranceExpirySoonDays = 30;
