import { getDb } from './database';
import {
  InsurancePolicy,
  CreateInsuranceInput,
  UpdateInsuranceInput,
  InsuranceDocument,
  CreateInsuranceDocumentInput,
} from '../types/Insurance';
import uuid from 'react-native-uuid';

export const insuranceRepository = {

  // ── Policies ──────────────────────────────────────────────────────────────

  create(input: CreateInsuranceInput): InsurancePolicy {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO insurance_policies
        (id, member_id, insurer_name, plan_type, policy_number, policy_holder,
         sum_insured, premium, currency, valid_from, valid_until,
         helpline_phone, agent_name, notes, created_at, updated_at)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        id,
        input.member_id,
        input.insurer_name,
        input.plan_type,
        input.policy_number ?? null,
        input.policy_holder ?? null,
        input.sum_insured ?? null,
        input.premium ?? null,
        input.currency ?? 'INR',
        input.valid_from ?? null,
        input.valid_until ?? null,
        input.helpline_phone ?? null,
        input.agent_name ?? null,
        input.notes ?? null,
        now,
        now,
      ]
    );
    return { ...input, id, created_at: now, updated_at: now };
  },

  update(id: string, input: UpdateInsuranceInput): void {
    const db = getDb();
    const now = new Date().toISOString();
    const fields = Object.keys(input).map(k => `${k} = ?`).join(', ');
    db.runSync(
      `UPDATE insurance_policies SET ${fields}, updated_at = ? WHERE id = ?`,
      [...Object.values(input), now, id]
    );
  },

  // Returns the file paths (originals + thumbnails) of the deleted policy's
  // documents so the caller can remove them from disk, then deletes the
  // policy and its document rows in a single transaction.
  delete(id: string): { filePath: string; thumbnailPath?: string }[] {
    const db = getDb();
    const docs = db.getAllSync<{ file_path: string; thumbnail_path?: string }>(
      'SELECT file_path, thumbnail_path FROM insurance_documents WHERE policy_id = ?',
      [id]
    );
    db.execSync('BEGIN');
    try {
      db.runSync('DELETE FROM insurance_documents WHERE policy_id = ?', [id]);
      db.runSync('DELETE FROM insurance_policies WHERE id = ?', [id]);
      db.execSync('COMMIT');
    } catch (e) {
      db.execSync('ROLLBACK');
      throw e;
    }
    return docs.map(d => ({ filePath: d.file_path, thumbnailPath: d.thumbnail_path ?? undefined }));
  },

  findById(id: string): InsurancePolicy | null {
    return getDb().getFirstSync<InsurancePolicy>(
      'SELECT * FROM insurance_policies WHERE id = ?',
      [id]
    );
  },

  // Policies for a member, each with its attached-document count, soonest expiry first.
  findByMember(memberId: string): InsurancePolicy[] {
    return getDb().getAllSync<InsurancePolicy>(
      `SELECT p.*,
              (SELECT COUNT(*) FROM insurance_documents d WHERE d.policy_id = p.id) AS document_count
         FROM insurance_policies p
        WHERE p.member_id = ?
        ORDER BY (p.valid_until IS NULL), p.valid_until ASC, p.created_at DESC`,
      [memberId]
    );
  },

  countByMember(memberId: string): number {
    const row = getDb().getFirstSync<{ count: number }>(
      'SELECT COUNT(*) as count FROM insurance_policies WHERE member_id = ?',
      [memberId]
    );
    return row?.count ?? 0;
  },

  // ── Documents ─────────────────────────────────────────────────────────────

  addDocument(input: CreateInsuranceDocumentInput): InsuranceDocument {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO insurance_documents
        (id, policy_id, file_path, file_name, mime_type, size_bytes, thumbnail_path, created_at)
       VALUES (?,?,?,?,?,?,?,?)`,
      [id, input.policy_id, input.file_path, input.file_name,
       input.mime_type, input.size_bytes, input.thumbnail_path ?? null, now]
    );
    return { ...input, id, created_at: now };
  },

  findDocuments(policyId: string): InsuranceDocument[] {
    return getDb().getAllSync<InsuranceDocument>(
      'SELECT * FROM insurance_documents WHERE policy_id = ? ORDER BY created_at ASC',
      [policyId]
    );
  },

  deleteDocument(id: string): void {
    getDb().runSync('DELETE FROM insurance_documents WHERE id = ?', [id]);
  },
};
