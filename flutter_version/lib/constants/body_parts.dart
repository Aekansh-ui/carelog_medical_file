import 'package:flutter/material.dart';

/// Body-part catalog ported from `../carelog/src/constants/bodyParts.ts`.
/// `id` strings are persisted on visits, so they must match the RN app exactly.
/// Icons are the nearest built-in Material `Icons.*` to the RN MDI names
/// (the MDI reference is noted in a comment per row — see PRD §2 icon note).
class BodyPart {
  final String id;
  final String label;
  final IconData icon;
  final String description;

  const BodyPart({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });
}

const List<BodyPart> kBodyParts = [
  BodyPart(
    id: 'HEAD_BRAIN',
    label: 'Head & Brain',
    icon: Icons.psychology_outlined, // mdi: head-cog-outline
    description: 'Eyes, ears, nose, throat, brain',
  ),
  BodyPart(
    id: 'CHEST_HEART',
    label: 'Chest & Heart',
    icon: Icons.monitor_heart_outlined, // mdi: heart-pulse
    description: 'Heart, lungs, chest wall',
  ),
  BodyPart(
    id: 'ABDOMEN',
    label: 'Abdomen',
    icon: Icons.lunch_dining_outlined, // mdi: stomach
    description: 'Stomach, liver, kidneys',
  ),
  BodyPart(
    id: 'BACK_SPINE',
    label: 'Back & Spine',
    icon: Icons.airline_seat_recline_normal, // mdi: human-handsdown
    description: 'Cervical, lumbar, sacral',
  ),
  BodyPart(
    id: 'ARMS_HANDS',
    label: 'Arms & Hands',
    icon: Icons.fitness_center, // mdi: arm-flex-outline
    description: 'Shoulder, elbow, wrist, fingers',
  ),
  BodyPart(
    id: 'LEGS_FEET',
    label: 'Legs & Feet',
    icon: Icons.directions_walk, // mdi: shoe-print
    description: 'Hip, knee, ankle, foot',
  ),
  BodyPart(
    id: 'SKIN',
    label: 'Skin',
    icon: Icons.healing, // mdi: hand-back-right-outline
    description: 'Rashes, infections, wounds',
  ),
  BodyPart(
    id: 'GENERAL',
    label: 'General / Whole Body',
    icon: Icons.accessibility_new, // mdi: human
    description: 'Fever, fatigue, allergies',
  ),
];

/// Lookup by id, or null if unknown.
BodyPart? bodyPartById(String id) {
  for (final bp in kBodyParts) {
    if (bp.id == id) return bp;
  }
  return null;
}
