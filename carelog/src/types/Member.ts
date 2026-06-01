import { RelationshipType, Gender } from '../constants/members';

export interface Member {
  id: string;                   // UUID v4
  name: string;
  relationship: RelationshipType;
  date_of_birth?: string;       // YYYY-MM-DD (age computed client-side via computeAge)
  gender?: Gender;
  color: string;                // avatar color (hex)
  created_at: string;           // ISO 8601
  updated_at: string;           // ISO 8601

  // Computed/joined for dashboard (populated by membersRepository.findAllWithStats):
  visit_count?: number;
  next_follow_up?: string | null;    // earliest upcoming follow_up_date among member's visits
  last_visit_date?: string | null;
}

export type CreateMemberInput =
  Omit<Member, 'id' | 'created_at' | 'updated_at' | 'visit_count' | 'next_follow_up' | 'last_visit_date'>;
export type UpdateMemberInput = Partial<CreateMemberInput>;

export interface FamilySummary {
  totalMembers: number;
  totalVisits: number;
  upcomingFollowUps: {
    visit_id: string;
    member_id: string;
    member_name: string;
    member_color: string;
    speciality_id: string;
    doctor_name?: string;
    follow_up_date: string;
  }[];
}
