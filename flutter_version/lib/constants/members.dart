import 'package:flutter/material.dart';

/// Member catalog ported from `../carelog/src/constants/members.ts`.
/// Relationship / gender `id` strings are persisted on members — keep identical.

/// A relationship option (id persisted, label + icon for display).
class RelationshipOption {
  final String id;
  final String label;
  final IconData icon;
  const RelationshipOption(this.id, this.label, this.icon);
}

const List<RelationshipOption> kRelationships = [
  RelationshipOption('SELF', 'Self', Icons.person), // mdi: account
  RelationshipOption('SPOUSE', 'Spouse', Icons.favorite), // mdi: account-heart
  RelationshipOption('CHILD', 'Child', Icons.child_care), // mdi: baby-face-outline
  RelationshipOption('PARENT', 'Parent', Icons.supervisor_account), // mdi: account-supervisor
  RelationshipOption('SIBLING', 'Sibling', Icons.people), // mdi: account-multiple
  RelationshipOption('OTHER', 'Other', Icons.person_outline), // mdi: account-question
];

RelationshipOption? relationshipById(String id) {
  for (final r in kRelationships) {
    if (r.id == id) return r;
  }
  return null;
}

/// A gender option (id persisted).
class GenderOption {
  final String id;
  final String label;
  const GenderOption(this.id, this.label);
}

const List<GenderOption> kGenders = [
  GenderOption('MALE', 'Male'),
  GenderOption('FEMALE', 'Female'),
  GenderOption('OTHER', 'Other'),
];

/// Avatar colour palette — one assigned per member, cycled by creation order.
const List<Color> kMemberColors = [
  Color(0xFF1A6B8A),
  Color(0xFF2E9E6B),
  Color(0xFFE67E22),
  Color(0xFF8E44AD),
  Color(0xFFC0392B),
  Color(0xFF16A085),
  Color(0xFFD35400),
  Color(0xFF2C3E50),
];

/// Hex form of [kMemberColors] (members.color is stored as a `#RRGGBB` string).
const List<String> kMemberColorHex = [
  '#1A6B8A',
  '#2E9E6B',
  '#E67E22',
  '#8E44AD',
  '#C0392B',
  '#16A085',
  '#D35400',
  '#2C3E50',
];

/// Fixed id for the auto-created default member (seeded on first DB create).
const String kDefaultSelfMemberId = '11111111-1111-1111-1111-111111111111';

/// Parses a `#RRGGBB` (or `#AARRGGBB`) string into a [Color]. Falls back to the
/// brand primary for malformed input.
Color colorFromHex(String hex) {
  var h = hex.replaceFirst('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  final value = int.tryParse(h, radix: 16);
  return value == null ? const Color(0xFF1A6B8A) : Color(value);
}
