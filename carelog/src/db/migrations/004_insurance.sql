-- Per-member insurance policies. A member may own several policies
-- (personal + corporate + family floater, etc.) — one-to-many.
CREATE TABLE IF NOT EXISTS insurance_policies (
  id              TEXT PRIMARY KEY,
  member_id       TEXT NOT NULL REFERENCES members(id),
  insurer_name    TEXT NOT NULL,
  plan_type       TEXT NOT NULL DEFAULT 'PERSONAL',  -- PERSONAL | FAMILY_FLOATER | CORPORATE | OTHER
  policy_number   TEXT,
  policy_holder   TEXT,
  sum_insured     REAL,
  premium         REAL,
  currency        TEXT NOT NULL DEFAULT 'INR',
  valid_from      TEXT,                              -- YYYY-MM-DD
  valid_until     TEXT,                              -- YYYY-MM-DD
  helpline_phone  TEXT,
  agent_name      TEXT,
  notes           TEXT,
  created_at      TEXT NOT NULL,
  updated_at      TEXT NOT NULL
);

-- Scanned card images / policy PDFs attached to a policy.
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
