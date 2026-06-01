import { BodyPartId } from '../constants/bodyParts';
import { SpecialityId } from '../constants/specialities';
import { Attachment } from './Attachment';

export interface Visit {
  id: string;                       // UUID v4
  member_id: string;                // owning family member (UUID)
  body_part_id: BodyPartId;
  speciality_id: SpecialityId;
  custom_speciality?: string;       // Only when speciality_id === 'OTHER'
  visit_date: string;               // YYYY-MM-DD
  follow_up_date?: string;          // YYYY-MM-DD
  doctor_name?: string;
  clinic_name?: string;
  clinic_phone?: string;
  doctor_fees?: number;
  currency: string;                 // Default: 'INR'
  symptoms?: string;
  diagnosis?: string;
  notes?: string;
  created_at: string;               // ISO 8601
  updated_at: string;               // ISO 8601
  attachments?: Attachment[];       // Populated via JOIN in repository
}

export type CreateVisitInput = Omit<Visit, 'id' | 'created_at' | 'updated_at' | 'attachments'>;
export type UpdateVisitInput = Partial<CreateVisitInput>;

export interface VisitDraft {
  id: string;
  form_data: string;                // JSON.stringify(Partial<CreateVisitInput>)
  created_at: string;
  updated_at: string;
}
