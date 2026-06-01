import * as SQLite from 'expo-sqlite';

let db: SQLite.SQLiteDatabase | null = null;

export function getDb(): SQLite.SQLiteDatabase {
  if (!db) {
    db = SQLite.openDatabaseSync('CareLog.db');
  }
  return db;
}

const MIGRATIONS: { version: number; sql: string }[] = [
  {
    version: 1,
    sql: `
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version   INTEGER PRIMARY KEY,
        applied_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS visits (
        id                TEXT PRIMARY KEY,
        body_part_id      TEXT NOT NULL,
        speciality_id     TEXT NOT NULL,
        custom_speciality TEXT,
        visit_date        TEXT NOT NULL,
        follow_up_date    TEXT,
        doctor_name       TEXT,
        clinic_name       TEXT,
        clinic_phone      TEXT,
        doctor_fees       REAL,
        currency          TEXT NOT NULL DEFAULT 'INR',
        symptoms          TEXT,
        diagnosis         TEXT,
        notes             TEXT,
        created_at        TEXT NOT NULL,
        updated_at        TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS attachments (
        id             TEXT PRIMARY KEY,
        visit_id       TEXT NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
        type           TEXT NOT NULL CHECK(type IN ('prescription','medicine','bill','report')),
        file_path      TEXT NOT NULL,
        file_name      TEXT NOT NULL,
        mime_type      TEXT NOT NULL,
        size_bytes     INTEGER NOT NULL,
        thumbnail_path TEXT,
        created_at     TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS reminders (
        id                  TEXT PRIMARY KEY,
        visit_id            TEXT NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
        follow_up_date      TEXT NOT NULL,
        notification_id_d1  TEXT,
        notification_id_d0  TEXT,
        is_active           INTEGER NOT NULL DEFAULT 1,
        rescheduled_at      TEXT,
        created_at          TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS visit_drafts (
        id          TEXT PRIMARY KEY,
        form_data   TEXT NOT NULL,
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL
      );

      CREATE INDEX IF NOT EXISTS idx_visits_body_part     ON visits(body_part_id);
      CREATE INDEX IF NOT EXISTS idx_visits_speciality    ON visits(speciality_id);
      CREATE INDEX IF NOT EXISTS idx_visits_visit_date    ON visits(visit_date DESC);
      CREATE INDEX IF NOT EXISTS idx_attachments_visit_id ON attachments(visit_id);
      CREATE INDEX IF NOT EXISTS idx_reminders_follow_up  ON reminders(follow_up_date);
    `,
  },
  {
    version: 2,
    sql: `
      CREATE VIRTUAL TABLE IF NOT EXISTS visits_fts USING fts5(
        id        UNINDEXED,
        doctor_name,
        clinic_name,
        symptoms,
        diagnosis,
        notes,
        content='visits',
        content_rowid='rowid'
      );

      CREATE TRIGGER IF NOT EXISTS visits_ai AFTER INSERT ON visits BEGIN
        INSERT INTO visits_fts(rowid, id, doctor_name, clinic_name, symptoms, diagnosis, notes)
        VALUES (new.rowid, new.id, new.doctor_name, new.clinic_name, new.symptoms, new.diagnosis, new.notes);
      END;

      CREATE TRIGGER IF NOT EXISTS visits_ad AFTER DELETE ON visits BEGIN
        INSERT INTO visits_fts(visits_fts, rowid, id, doctor_name, clinic_name, symptoms, diagnosis, notes)
        VALUES ('delete', old.rowid, old.id, old.doctor_name, old.clinic_name, old.symptoms, old.diagnosis, old.notes);
      END;

      CREATE TRIGGER IF NOT EXISTS visits_au AFTER UPDATE ON visits BEGIN
        INSERT INTO visits_fts(visits_fts, rowid, id, doctor_name, clinic_name, symptoms, diagnosis, notes)
        VALUES ('delete', old.rowid, old.id, old.doctor_name, old.clinic_name, old.symptoms, old.diagnosis, old.notes);
        INSERT INTO visits_fts(rowid, id, doctor_name, clinic_name, symptoms, diagnosis, notes)
        VALUES (new.rowid, new.id, new.doctor_name, new.clinic_name, new.symptoms, new.diagnosis, new.notes);
      END;
    `,
  },
  {
    version: 3,
    sql: `
      CREATE TABLE IF NOT EXISTS members (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        relationship  TEXT NOT NULL DEFAULT 'OTHER',
        date_of_birth TEXT,
        gender        TEXT,
        color         TEXT NOT NULL DEFAULT '#1A6B8A',
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL
      );

      ALTER TABLE visits ADD COLUMN member_id TEXT REFERENCES members(id);

      CREATE INDEX IF NOT EXISTS idx_visits_member ON visits(member_id);

      INSERT OR IGNORE INTO members (id, name, relationship, color, created_at, updated_at)
      VALUES (
        '11111111-1111-1111-1111-111111111111',
        'Self', 'SELF', '#1A6B8A',
        '2026-06-01T00:00:00.000Z', '2026-06-01T00:00:00.000Z'
      );

      UPDATE visits
         SET member_id = '11111111-1111-1111-1111-111111111111'
       WHERE member_id IS NULL;
    `,
  },
  {
    version: 4,
    sql: `
      CREATE TABLE IF NOT EXISTS insurance_policies (
        id              TEXT PRIMARY KEY,
        member_id       TEXT NOT NULL REFERENCES members(id),
        insurer_name    TEXT NOT NULL,
        plan_type       TEXT NOT NULL DEFAULT 'PERSONAL',
        policy_number   TEXT,
        policy_holder   TEXT,
        sum_insured     REAL,
        premium         REAL,
        currency        TEXT NOT NULL DEFAULT 'INR',
        valid_from      TEXT,
        valid_until     TEXT,
        helpline_phone  TEXT,
        agent_name      TEXT,
        notes           TEXT,
        created_at      TEXT NOT NULL,
        updated_at      TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS insurance_documents (
        id             TEXT PRIMARY KEY,
        policy_id      TEXT NOT NULL REFERENCES insurance_policies(id) ON DELETE CASCADE,
        file_path      TEXT NOT NULL,
        file_name      TEXT NOT NULL,
        mime_type      TEXT NOT NULL,
        size_bytes     INTEGER NOT NULL,
        thumbnail_path TEXT,
        created_at     TEXT NOT NULL
      );

      CREATE INDEX IF NOT EXISTS idx_insurance_member      ON insurance_policies(member_id);
      CREATE INDEX IF NOT EXISTS idx_insurance_valid_until ON insurance_policies(valid_until);
      CREATE INDEX IF NOT EXISTS idx_insurance_docs_policy ON insurance_documents(policy_id);
    `,
  },
];

export async function initDatabase(): Promise<void> {
  const database = getDb();

  // Enable WAL mode and foreign keys
  database.execSync('PRAGMA journal_mode = WAL;');
  database.execSync('PRAGMA foreign_keys = ON;');

  // Bootstrap schema_migrations table before running migrations
  database.execSync(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version    INTEGER PRIMARY KEY,
      applied_at TEXT NOT NULL
    );
  `);

  for (const migration of MIGRATIONS) {
    const existing = database.getFirstSync<{ version: number }>(
      'SELECT version FROM schema_migrations WHERE version = ?',
      [migration.version]
    );
    if (!existing) {
      database.execSync(migration.sql);
      database.runSync(
        'INSERT INTO schema_migrations (version, applied_at) VALUES (?, ?)',
        [migration.version, new Date().toISOString()]
      );
    }
  }
}
