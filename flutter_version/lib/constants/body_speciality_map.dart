import 'specialities.dart';

/// Body-part → speciality mapping, ported verbatim from
/// `../carelog/src/constants/bodySpecialityMap.ts`. Drives the speciality
/// select screen (mapped specialities first, then "Other / Custom").
const Map<String, List<String>> kBodySpecialityMap = {
  'HEAD_BRAIN': [
    'NEUROLOGY',
    'ENT',
    'OPHTHALMOLOGY',
    'DENTISTRY',
    'PSYCHIATRY',
    'GENERAL_MEDICINE',
  ],
  'CHEST_HEART': ['CARDIOLOGY', 'PULMONOLOGY', 'GENERAL_MEDICINE'],
  'ABDOMEN': [
    'GASTRO',
    'NEPHROLOGY',
    'GYNAECOLOGY',
    'UROLOGY',
    'ENDOCRINOLOGY',
    'GENERAL_MEDICINE',
  ],
  'BACK_SPINE': ['ORTHO', 'NEUROLOGY', 'GENERAL_MEDICINE'],
  'ARMS_HANDS': ['ORTHO', 'DERMATOLOGY', 'GENERAL_MEDICINE'],
  'LEGS_FEET': ['ORTHO', 'DERMATOLOGY', 'GENERAL_MEDICINE'],
  'SKIN': ['DERMATOLOGY', 'GENERAL_MEDICINE'],
  'GENERAL': ['GENERAL_MEDICINE', 'ENDOCRINOLOGY', 'PSYCHIATRY', 'OTHER'],
};

/// Specialities suggested for a body part, in display order. Unknown ids and
/// any unmatched speciality ids are skipped; "Other / Custom" is always
/// appended last if not already present.
List<Speciality> specialitiesForBodyPart(String bodyPartId) {
  final ids = List<String>.from(kBodySpecialityMap[bodyPartId] ?? const []);
  if (!ids.contains('OTHER')) ids.add('OTHER');
  final out = <Speciality>[];
  for (final id in ids) {
    final s = specialityById(id);
    if (s != null) out.add(s);
  }
  return out;
}
