import { getDb } from './database';
import { Visit, CreateVisitInput, UpdateVisitInput } from '../types/Visit';
import uuid from 'react-native-uuid';

export const visitsRepository = {

  create(input: CreateVisitInput): Visit {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO visits
        (id, body_part_id, speciality_id, custom_speciality, visit_date, follow_up_date,
         doctor_name, clinic_name, clinic_phone, doctor_fees, currency,
         symptoms, diagnosis, notes, created_at, updated_at)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        id,
        input.body_part_id,
        input.speciality_id,
        input.custom_speciality ?? null,
        input.visit_date,
        input.follow_up_date ?? null,
        input.doctor_name ?? null,
        input.clinic_name ?? null,
        input.clinic_phone ?? null,
        input.doctor_fees ?? null,
        input.currency ?? 'INR',
        input.symptoms ?? null,
        input.diagnosis ?? null,
        input.notes ?? null,
        now,
        now,
      ]
    );
    return { ...input, id, created_at: now, updated_at: now };
  },

  update(id: string, input: UpdateVisitInput): void {
    const db = getDb();
    const now = new Date().toISOString();
    const fields = Object.keys(input)
      .map(k => `${k} = ?`)
      .join(', ');
    const values = [...Object.values(input), now, id];
    db.runSync(`UPDATE visits SET ${fields}, updated_at = ? WHERE id = ?`, values);
  },

  delete(id: string): void {
    getDb().runSync('DELETE FROM visits WHERE id = ?', [id]);
  },

  findById(id: string): Visit | null {
    return getDb().getFirstSync<Visit>(
      'SELECT * FROM visits WHERE id = ?',
      [id]
    );
  },

  findBySpeciality(bodyPartId: string, specialityId: string): Visit[] {
    return getDb().getAllSync<Visit>(
      `SELECT * FROM visits
       WHERE body_part_id = ? AND speciality_id = ?
       ORDER BY visit_date DESC`,
      [bodyPartId, specialityId]
    );
  },

  findRecent(limit = 5): Visit[] {
    return getDb().getAllSync<Visit>(
      'SELECT * FROM visits ORDER BY visit_date DESC LIMIT ?',
      [limit]
    );
  },

  countBySpeciality(specialityId: string): number {
    const row = getDb().getFirstSync<{ count: number }>(
      'SELECT COUNT(*) as count FROM visits WHERE speciality_id = ?',
      [specialityId]
    );
    return row?.count ?? 0;
  },

  search(query: string): Visit[] {
    return getDb().getAllSync<Visit>(
      `SELECT v.* FROM visits v
       JOIN visits_fts fts ON v.id = fts.id
       WHERE visits_fts MATCH ?
       ORDER BY rank`,
      [query + '*']
    );
  },

  getAutocompleteDoctors(partial: string): string[] {
    const rows = getDb().getAllSync<{ doctor_name: string }>(
      `SELECT DISTINCT doctor_name FROM visits
       WHERE doctor_name LIKE ? AND doctor_name IS NOT NULL
       LIMIT 10`,
      [`%${partial}%`]
    );
    return rows.map(r => r.doctor_name);
  },

  getAutocompleteClinics(partial: string): string[] {
    const rows = getDb().getAllSync<{ clinic_name: string }>(
      `SELECT DISTINCT clinic_name FROM visits
       WHERE clinic_name LIKE ? AND clinic_name IS NOT NULL
       LIMIT 10`,
      [`%${partial}%`]
    );
    return rows.map(r => r.clinic_name);
  },
};
