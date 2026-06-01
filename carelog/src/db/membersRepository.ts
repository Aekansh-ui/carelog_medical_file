import { getDb } from './database';
import { Member, CreateMemberInput, UpdateMemberInput, FamilySummary } from '../types/Member';
import uuid from 'react-native-uuid';

export const membersRepository = {

  create(input: CreateMemberInput): Member {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO members (id, name, relationship, date_of_birth, gender, color, created_at, updated_at)
       VALUES (?,?,?,?,?,?,?,?)`,
      [id, input.name, input.relationship, input.date_of_birth ?? null,
       input.gender ?? null, input.color, now, now]
    );
    return { ...input, id, created_at: now, updated_at: now };
  },

  update(id: string, input: UpdateMemberInput): void {
    const db = getDb();
    const now = new Date().toISOString();
    const fields = Object.keys(input).map(k => `${k} = ?`).join(', ');
    db.runSync(
      `UPDATE members SET ${fields}, updated_at = ? WHERE id = ?`,
      [...Object.values(input), now, id]
    );
  },

  // Cascade delete: member → their visits (+ attachments & reminders) and
  // their insurance policies (+ insurance documents).
  delete(id: string): void {
    const db = getDb();
    db.execSync('BEGIN');
    try {
      db.runSync(
        `DELETE FROM attachments WHERE visit_id IN (SELECT id FROM visits WHERE member_id = ?)`,
        [id]
      );
      db.runSync(
        `DELETE FROM reminders WHERE visit_id IN (SELECT id FROM visits WHERE member_id = ?)`,
        [id]
      );
      db.runSync(
        `DELETE FROM insurance_documents WHERE policy_id IN (SELECT id FROM insurance_policies WHERE member_id = ?)`,
        [id]
      );
      db.runSync(`DELETE FROM insurance_policies WHERE member_id = ?`, [id]);
      db.runSync(`DELETE FROM visits   WHERE member_id = ?`, [id]);
      db.runSync(`DELETE FROM members  WHERE id = ?`, [id]);
      db.execSync('COMMIT');
    } catch (e) {
      db.execSync('ROLLBACK');
      throw e;
    }
  },

  findById(id: string): Member | null {
    return getDb().getFirstSync<Member>('SELECT * FROM members WHERE id = ?', [id]);
  },

  // Members + per-member stats for the Family Home dashboard.
  findAllWithStats(): Member[] {
    const today = new Date().toISOString().split('T')[0];
    return getDb().getAllSync<Member>(
      `SELECT m.*,
              (SELECT COUNT(*) FROM visits v WHERE v.member_id = m.id) AS visit_count,
              (SELECT MAX(v.visit_date) FROM visits v WHERE v.member_id = m.id) AS last_visit_date,
              (SELECT MIN(v.follow_up_date) FROM visits v
                 WHERE v.member_id = m.id AND v.follow_up_date >= ?) AS next_follow_up
         FROM members m
        ORDER BY (m.relationship = 'SELF') DESC, m.created_at ASC`,
      [today]
    );
  },

  getFamilySummary(): FamilySummary {
    const db = getDb();
    const today = new Date().toISOString().split('T')[0];
    const totals = db.getFirstSync<{ members: number; visits: number }>(
      `SELECT (SELECT COUNT(*) FROM members) AS members,
              (SELECT COUNT(*) FROM visits)  AS visits`
    );
    const upcoming = db.getAllSync<FamilySummary['upcomingFollowUps'][number]>(
      `SELECT v.id AS visit_id, v.member_id, m.name AS member_name, m.color AS member_color,
              v.speciality_id, v.doctor_name, v.follow_up_date
         FROM visits v JOIN members m ON v.member_id = m.id
        WHERE v.follow_up_date >= ?
        ORDER BY v.follow_up_date ASC`,
      [today]
    );
    return {
      totalMembers: totals?.members ?? 0,
      totalVisits:  totals?.visits  ?? 0,
      upcomingFollowUps: upcoming,
    };
  },
};
