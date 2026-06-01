import { getDb } from './database';
import { Attachment, CreateAttachmentInput } from '../types/Attachment';
import uuid from 'react-native-uuid';

export const attachmentsRepository = {

  create(input: CreateAttachmentInput): Attachment {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO attachments
        (id, visit_id, type, file_path, file_name, mime_type, size_bytes, thumbnail_path, created_at)
       VALUES (?,?,?,?,?,?,?,?,?)`,
      [
        id,
        input.visit_id,
        input.type,
        input.file_path,
        input.file_name,
        input.mime_type,
        input.size_bytes,
        input.thumbnail_path ?? null,
        now,
      ]
    );
    return { ...input, id, created_at: now };
  },

  findByVisitId(visitId: string): Attachment[] {
    return getDb().getAllSync<Attachment>(
      'SELECT * FROM attachments WHERE visit_id = ? ORDER BY created_at ASC',
      [visitId]
    );
  },

  findByType(type: string): Attachment[] {
    return getDb().getAllSync<Attachment>(
      `SELECT a.*, v.doctor_name, v.visit_date, v.speciality_id,
              m.name AS member_name, m.color AS member_color
         FROM attachments a
         JOIN visits v ON a.visit_id = v.id
         LEFT JOIN members m ON v.member_id = m.id
        WHERE a.type = ?
        ORDER BY a.created_at DESC`,
      [type]
    );
  },

  findAll(): Attachment[] {
    return getDb().getAllSync<Attachment>(
      `SELECT a.*, v.doctor_name, v.visit_date, v.speciality_id,
              m.name AS member_name, m.color AS member_color
         FROM attachments a
         JOIN visits v ON a.visit_id = v.id
         LEFT JOIN members m ON v.member_id = m.id
        ORDER BY a.created_at DESC`
    );
  },

  delete(id: string): void {
    getDb().runSync('DELETE FROM attachments WHERE id = ?', [id]);
  },
};
