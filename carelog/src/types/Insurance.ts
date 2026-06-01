import { PlanType } from '../constants/insurance';

export interface InsurancePolicy {
  id: string;                       // UUID v4
  member_id: string;                // owning family member (UUID)
  insurer_name: string;             // required
  plan_type: PlanType;
  policy_number?: string;
  policy_holder?: string;           // name on the policy (may differ from member)
  sum_insured?: number;             // coverage amount
  premium?: number;
  currency: string;                 // Default: 'INR'
  valid_from?: string;              // YYYY-MM-DD
  valid_until?: string;             // YYYY-MM-DD (expiry)
  helpline_phone?: string;          // insurer / TPA helpline
  agent_name?: string;
  notes?: string;
  created_at: string;               // ISO 8601
  updated_at: string;               // ISO 8601

  // Computed/joined (populated by insuranceRepository.findByMember):
  document_count?: number;
}

export type CreateInsuranceInput =
  Omit<InsurancePolicy, 'id' | 'created_at' | 'updated_at' | 'document_count'>;
export type UpdateInsuranceInput = Partial<CreateInsuranceInput>;

export interface InsuranceDocument {
  id: string;                       // UUID v4
  policy_id: string;
  file_path: string;                // Absolute path in app document directory
  file_name: string;
  mime_type: string;                // image/jpeg | image/png | application/pdf
  size_bytes: number;
  thumbnail_path?: string;          // Compressed thumbnail for images
  created_at: string;
}

export type CreateInsuranceDocumentInput = Omit<InsuranceDocument, 'id' | 'created_at'>;
