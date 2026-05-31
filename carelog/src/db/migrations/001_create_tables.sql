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
