import 'package:flutter/material.dart';

/// Speciality catalog ported from `../carelog/src/constants/specialities.ts`.
/// `id` strings are persisted on visits — keep them identical to the RN app.
/// Colours are copied exactly; icons are the nearest built-in Material `Icons.*`
/// to the RN MDI names (noted per row).
class Speciality {
  final String id;
  final String label;
  final String shortLabel;
  final IconData icon;
  final Color color;

  const Speciality({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.color,
  });
}

const List<Speciality> kSpecialities = [
  Speciality(
    id: 'GENERAL_MEDICINE',
    label: 'General Medicine',
    shortLabel: 'GP',
    icon: Icons.medical_services_outlined, // mdi: stethoscope
    color: Color(0xFF2196F3),
  ),
  Speciality(
    id: 'ENT',
    label: 'ENT',
    shortLabel: 'ENT',
    icon: Icons.hearing, // mdi: ear-hearing
    color: Color(0xFF9C27B0),
  ),
  Speciality(
    id: 'NEUROLOGY',
    label: 'Neurology',
    shortLabel: 'Neuro',
    icon: Icons.psychology, // mdi: brain
    color: Color(0xFF673AB7),
  ),
  Speciality(
    id: 'DENTISTRY',
    label: 'Dentistry',
    shortLabel: 'Dental',
    icon: Icons.sentiment_satisfied_outlined, // mdi: tooth-outline (no built-in tooth)
    color: Color(0xFF00BCD4),
  ),
  Speciality(
    id: 'CARDIOLOGY',
    label: 'Cardiology',
    shortLabel: 'Cardio',
    icon: Icons.monitor_heart, // mdi: heart-pulse
    color: Color(0xFFF44336),
  ),
  Speciality(
    id: 'PULMONOLOGY',
    label: 'Pulmonology',
    shortLabel: 'Pulmo',
    icon: Icons.air, // mdi: lungs
    color: Color(0xFF03A9F4),
  ),
  Speciality(
    id: 'GASTRO',
    label: 'Gastroenterology',
    shortLabel: 'Gastro',
    icon: Icons.lunch_dining, // mdi: stomach
    color: Color(0xFFFF9800),
  ),
  Speciality(
    id: 'NEPHROLOGY',
    label: 'Nephrology',
    shortLabel: 'Nephro',
    icon: Icons.water_drop_outlined, // mdi: water-outline
    color: Color(0xFF009688),
  ),
  Speciality(
    id: 'ORTHO',
    label: 'Orthopaedics',
    shortLabel: 'Ortho',
    icon: Icons.personal_injury_outlined, // mdi: bone
    color: Color(0xFF795548),
  ),
  Speciality(
    id: 'DERMATOLOGY',
    label: 'Dermatology',
    shortLabel: 'Derma',
    icon: Icons.healing, // mdi: hand-back-right-outline
    color: Color(0xFFFF5722),
  ),
  Speciality(
    id: 'OPHTHALMOLOGY',
    label: 'Ophthalmology',
    shortLabel: 'Eye',
    icon: Icons.visibility_outlined, // mdi: eye-outline
    color: Color(0xFF607D8B),
  ),
  Speciality(
    id: 'GYNAECOLOGY',
    label: 'Gynaecology',
    shortLabel: 'Gynae',
    icon: Icons.pregnant_woman, // mdi: human-female
    color: Color(0xFFE91E63),
  ),
  Speciality(
    id: 'UROLOGY',
    label: 'Urology',
    shortLabel: 'Urology',
    icon: Icons.water_drop, // mdi: water
    color: Color(0xFF3F51B5),
  ),
  Speciality(
    id: 'ENDOCRINOLOGY',
    label: 'Endocrinology',
    shortLabel: 'Endo',
    icon: Icons.vaccines, // mdi: needle
    color: Color(0xFF8BC34A),
  ),
  Speciality(
    id: 'PSYCHIATRY',
    label: 'Psychiatry',
    shortLabel: 'Psych',
    icon: Icons.psychology_alt, // mdi: head-heart-outline
    color: Color(0xFFFFC107),
  ),
  Speciality(
    id: 'OTHER',
    label: 'Other / Custom',
    shortLabel: 'Other',
    icon: Icons.add_circle_outline, // mdi: plus-circle-outline
    color: Color(0xFF9E9E9E),
  ),
];

/// Lookup by id, or null if unknown.
Speciality? specialityById(String id) {
  for (final s in kSpecialities) {
    if (s.id == id) return s;
  }
  return null;
}
