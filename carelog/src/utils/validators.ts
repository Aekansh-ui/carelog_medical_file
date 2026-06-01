import { CreateVisitInput } from '@src/types/Visit';
import { CreateInsuranceInput } from '@src/types/Insurance';
import { AttachmentType, ATTACHMENT_LIMITS } from '@src/types/Attachment';

export function isValidDate(dateStr: string): boolean {
  return /^\d{4}-\d{2}-\d{2}$/.test(dateStr);
}

export function isValidPhone(phone: string): boolean {
  return /^[0-9+\-\s]{7,15}$/.test(phone.trim());
}

/**
 * Validates a visit creation/edit form.
 * Returns an array of human-readable error strings (empty = valid).
 */
export function validateVisitForm(form: Partial<CreateVisitInput>): string[] {
  const errors: string[] = [];

  if (!form.visit_date) {
    errors.push('Visit date is required');
  } else if (!isValidDate(form.visit_date)) {
    errors.push('Visit date must be in YYYY-MM-DD format');
  }

  if (form.follow_up_date && !isValidDate(form.follow_up_date)) {
    errors.push('Follow-up date must be in YYYY-MM-DD format');
  }

  if (!form.body_part_id) {
    errors.push('Body part is required');
  }

  if (!form.speciality_id) {
    errors.push('Speciality is required');
  }

  if (form.clinic_phone && !isValidPhone(form.clinic_phone)) {
    errors.push('Clinic phone number is invalid');
  }

  if (form.doctor_fees != null && form.doctor_fees < 0) {
    errors.push('Doctor fees cannot be negative');
  }

  return errors;
}

/** @deprecated Use validateVisitForm */
export const validateVisitInput = validateVisitForm;

/**
 * Validates an insurance policy creation/edit form.
 * Returns an array of human-readable error strings (empty = valid).
 */
export function validateInsuranceForm(form: Partial<CreateInsuranceInput>): string[] {
  const errors: string[] = [];

  if (!form.insurer_name || !form.insurer_name.trim()) {
    errors.push('Insurer name is required');
  }

  if (form.valid_from && !isValidDate(form.valid_from)) {
    errors.push('Valid-from date must be in YYYY-MM-DD format');
  }

  if (form.valid_until && !isValidDate(form.valid_until)) {
    errors.push('Valid-until date must be in YYYY-MM-DD format');
  }

  if (
    form.valid_from && form.valid_until &&
    isValidDate(form.valid_from) && isValidDate(form.valid_until) &&
    form.valid_until < form.valid_from
  ) {
    errors.push('Valid-until date cannot be before the valid-from date');
  }

  if (form.helpline_phone && !isValidPhone(form.helpline_phone)) {
    errors.push('Helpline phone number is invalid');
  }

  if (form.sum_insured != null && form.sum_insured < 0) {
    errors.push('Sum insured cannot be negative');
  }

  if (form.premium != null && form.premium < 0) {
    errors.push('Premium cannot be negative');
  }

  return errors;
}

/**
 * Returns true if the file size is within the allowed limit for the given
 * attachment type. Use before saving to give the user an early error.
 */
export function validateFileSize(bytes: number, type: AttachmentType): boolean {
  return bytes <= ATTACHMENT_LIMITS[type].maxSizeBytes;
}

/**
 * Returns a human-readable error string when the file is too large, or null
 * when the size is acceptable. Convenience wrapper around validateFileSize.
 */
export function fileSizeError(bytes: number, type: AttachmentType): string | null {
  if (validateFileSize(bytes, type)) return null;
  const limitMB = ATTACHMENT_LIMITS[type].maxSizeBytes / (1024 * 1024);
  return `File exceeds the ${limitMB} MB limit for ${type} attachments`;
}
