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
