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

-- Add owning member to visits (nullable so existing rows survive ALTER).
ALTER TABLE visits ADD COLUMN member_id TEXT REFERENCES members(id);

CREATE INDEX IF NOT EXISTS idx_visits_member ON visits(member_id);

-- Auto-create the default "Self" member with a fixed well-known id.
INSERT OR IGNORE INTO members (id, name, relationship, color, created_at, updated_at)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'Self', 'SELF', '#1A6B8A',
  '2026-06-01T00:00:00.000Z', '2026-06-01T00:00:00.000Z'
);

-- Backfill all pre-existing visits to the default "Self" member.
UPDATE visits
   SET member_id = '11111111-1111-1111-1111-111111111111'
 WHERE member_id IS NULL;
