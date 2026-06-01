import { getDb } from './database';
import { Reminder } from '../types/Reminder';
import uuid from 'react-native-uuid';

export const remindersRepository = {

  create(visitId: string, followUpDate: string): Reminder {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO reminders (id, visit_id, follow_up_date, is_active, created_at)
       VALUES (?,?,?,1,?)`,
      [id, visitId, followUpDate, now]
    );
    return { id, visit_id: visitId, follow_up_date: followUpDate, is_active: true, created_at: now };
  },

  updateNotificationIds(id: string, d1Id: string, d0Id: string): void {
    getDb().runSync(
      'UPDATE reminders SET notification_id_d1 = ?, notification_id_d0 = ? WHERE id = ?',
      [d1Id, d0Id, id]
    );
  },

  findByVisitId(visitId: string): Reminder | null {
    return getDb().getFirstSync<Reminder>(
      `SELECT r.*, v.doctor_name, v.speciality_id, v.body_part_id,
              m.name AS member_name, m.color AS member_color
         FROM reminders r
         JOIN visits v ON r.visit_id = v.id
         LEFT JOIN members m ON v.member_id = m.id
        WHERE r.visit_id = ?`,
      [visitId]
    );
  },

  findUpcoming(): Reminder[] {
    const today = new Date().toISOString().split('T')[0];
    return getDb().getAllSync<Reminder>(
      `SELECT r.*, v.doctor_name, v.speciality_id, v.body_part_id,
              m.name AS member_name, m.color AS member_color
         FROM reminders r
         JOIN visits v ON r.visit_id = v.id
         LEFT JOIN members m ON v.member_id = m.id
        WHERE r.follow_up_date >= ? AND r.is_active = 1
        ORDER BY r.follow_up_date ASC`,
      [today]
    );
  },

  findPast(): Reminder[] {
    const today = new Date().toISOString().split('T')[0];
    return getDb().getAllSync<Reminder>(
      `SELECT r.*, v.doctor_name, v.speciality_id, v.body_part_id,
              m.name AS member_name, m.color AS member_color
         FROM reminders r
         JOIN visits v ON r.visit_id = v.id
         LEFT JOIN members m ON v.member_id = m.id
        WHERE r.follow_up_date < ? OR r.is_active = 0
        ORDER BY r.follow_up_date DESC`,
      [today]
    );
  },

  deactivate(id: string): void {
    getDb().runSync('UPDATE reminders SET is_active = 0 WHERE id = ?', [id]);
  },

  delete(id: string): void {
    getDb().runSync('DELETE FROM reminders WHERE id = ?', [id]);
  },
};
