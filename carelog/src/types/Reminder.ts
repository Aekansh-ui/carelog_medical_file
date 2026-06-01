export interface Reminder {
  id: string;
  visit_id: string;
  follow_up_date: string;           // YYYY-MM-DD
  notification_id_d1?: string;      // OS notification id (D-1 alert)
  notification_id_d0?: string;      // OS notification id (D-day alert)
  is_active: boolean;
  rescheduled_at?: string;
  created_at: string;
  // Joined from visits table:
  doctor_name?: string;
  speciality_id?: string;
  body_part_id?: string;
  // Joined from members table:
  member_name?: string;
  member_color?: string;
}
