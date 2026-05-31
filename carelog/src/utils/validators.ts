import { CreateVisitInput } from '@src/types/Visit';
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
