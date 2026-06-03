// Port of `../carelog/src/utils/validators.ts` — visit + insurance form rules.

bool _isValidDate(String date) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) return false;
  try {
    DateTime.parse(date);
    return true;
  } catch (_) {
    return false;
  }
}

bool _isValidPhone(String phone) =>
    RegExp(r'^[+\d\s\-()\[\]]{7,}$').hasMatch(phone.trim());

List<String> validateVisitForm({
  required String? visitDate,
  required String? bodyPartId,
  required String? specialityId,
  String? followUpDate,
  String? clinicPhone,
  double? doctorFees,
}) {
  final errors = <String>[];

  if (visitDate == null || visitDate.isEmpty) {
    errors.add('Visit date is required');
  } else if (!_isValidDate(visitDate)) {
    errors.add('Visit date must be in YYYY-MM-DD format');
  }

  if (followUpDate != null &&
      followUpDate.isNotEmpty &&
      !_isValidDate(followUpDate)) {
    errors.add('Follow-up date must be in YYYY-MM-DD format');
  }

  if (bodyPartId == null || bodyPartId.isEmpty) {
    errors.add('Body part is required');
  }
  if (specialityId == null || specialityId.isEmpty) {
    errors.add('Speciality is required');
  }

  if (clinicPhone != null &&
      clinicPhone.isNotEmpty &&
      !_isValidPhone(clinicPhone)) {
    errors.add('Clinic phone number is invalid');
  }
  if (doctorFees != null && doctorFees < 0) {
    errors.add('Doctor fees cannot be negative');
  }

  return errors;
}

List<String> validateInsuranceForm({
  required String? insurerName,
  String? validFrom,
  String? validUntil,
  String? helplinePhone,
  double? sumInsured,
  double? premium,
}) {
  final errors = <String>[];

  if (insurerName == null || insurerName.trim().isEmpty) {
    errors.add('Insurer name is required');
  }
  if (validFrom != null && validFrom.isNotEmpty && !_isValidDate(validFrom)) {
    errors.add('Valid-from date must be in YYYY-MM-DD format');
  }
  if (validUntil != null &&
      validUntil.isNotEmpty &&
      !_isValidDate(validUntil)) {
    errors.add('Valid-until date must be in YYYY-MM-DD format');
  }
  if (validFrom != null &&
      validUntil != null &&
      validFrom.isNotEmpty &&
      validUntil.isNotEmpty &&
      _isValidDate(validFrom) &&
      _isValidDate(validUntil) &&
      validUntil.compareTo(validFrom) < 0) {
    errors.add('Valid-until date cannot be before the valid-from date');
  }
  if (helplinePhone != null &&
      helplinePhone.isNotEmpty &&
      !_isValidPhone(helplinePhone)) {
    errors.add('Helpline phone number is invalid');
  }
  if (sumInsured != null && sumInsured < 0) {
    errors.add('Sum insured cannot be negative');
  }
  if (premium != null && premium < 0) {
    errors.add('Premium cannot be negative');
  }

  return errors;
}
