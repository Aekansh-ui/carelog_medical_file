import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/members.dart' show kDefaultSelfMemberId;
import 'daos/visits_dao.dart';
import 'daos/attachments_dao.dart';
import 'daos/reminders_dao.dart';
import 'daos/members_dao.dart';
import 'daos/insurance_dao.dart';

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Tables — column names and constraints mirror the RN schema exactly
// (`../carelog/src/db/database.ts`, migrations 1–4). Every multi-word column is
// explicitly `.named(...)` so the SQL matches regardless of drift defaults.
// Table order matters for FK creation: referenced tables come first.
// ---------------------------------------------------------------------------

class Members extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get relationship => text().withDefault(const Constant('OTHER'))();
  TextColumn get dateOfBirth => text().named('date_of_birth').nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get color => text().withDefault(const Constant('#1A6B8A'))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get bodyPartId => text().named('body_part_id')();
  TextColumn get specialityId => text().named('speciality_id')();
  TextColumn get customSpeciality => text().named('custom_speciality').nullable()();
  TextColumn get visitDate => text().named('visit_date')();
  TextColumn get followUpDate => text().named('follow_up_date').nullable()();
  TextColumn get doctorName => text().named('doctor_name').nullable()();
  TextColumn get clinicName => text().named('clinic_name').nullable()();
  TextColumn get clinicPhone => text().named('clinic_phone').nullable()();
  RealColumn get doctorFees => real().named('doctor_fees').nullable()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get symptoms => text().nullable()();
  TextColumn get diagnosis => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get memberId =>
      text().named('member_id').nullable().references(Members, #id)();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text()
      .named('visit_id')
      .references(Visits, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get filePath => text().named('file_path')();
  TextColumn get fileName => text().named('file_name')();
  TextColumn get mimeType => text().named('mime_type')();
  IntColumn get sizeBytes => integer().named('size_bytes')();
  TextColumn get thumbnailPath => text().named('thumbnail_path').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  // CHECK(type IN (...)) mirrors the RN schema — table-level to avoid the
  // self-referential column check lint.
  @override
  List<String> get customConstraints =>
      ["CHECK (type IN ('prescription', 'medicine', 'bill', 'report'))"];
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text()
      .named('visit_id')
      .references(Visits, #id, onDelete: KeyAction.cascade)();
  TextColumn get followUpDate => text().named('follow_up_date')();
  TextColumn get notificationIdD1 =>
      text().named('notification_id_d1').nullable()();
  TextColumn get notificationIdD0 =>
      text().named('notification_id_d0').nullable()();
  IntColumn get isActive =>
      integer().named('is_active').withDefault(const Constant(1))();
  TextColumn get rescheduledAt => text().named('rescheduled_at').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class VisitDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get formData => text().named('form_data')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class InsurancePolicies extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text().named('member_id').references(Members, #id)();
  TextColumn get insurerName => text().named('insurer_name')();
  TextColumn get planType =>
      text().named('plan_type').withDefault(const Constant('PERSONAL'))();
  TextColumn get policyNumber => text().named('policy_number').nullable()();
  TextColumn get policyHolder => text().named('policy_holder').nullable()();
  RealColumn get sumInsured => real().named('sum_insured').nullable()();
  RealColumn get premium => real().nullable()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get validFrom => text().named('valid_from').nullable()();
  TextColumn get validUntil => text().named('valid_until').nullable()();
  TextColumn get helplinePhone => text().named('helpline_phone').nullable()();
  TextColumn get agentName => text().named('agent_name').nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class InsuranceDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get policyId => text()
      .named('policy_id')
      .references(InsurancePolicies, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text().named('file_path')();
  TextColumn get fileName => text().named('file_name')();
  TextColumn get mimeType => text().named('mime_type')();
  IntColumn get sizeBytes => integer().named('size_bytes')();
  TextColumn get thumbnailPath => text().named('thumbnail_path').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Members,
    Visits,
    Attachments,
    Reminders,
    VisitDrafts,
    InsurancePolicies,
    InsuranceDocuments,
  ],
  daos: [VisitsDao, AttachmentsDao, RemindersDao, MembersDao, InsuranceDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests — pass `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Mirror RN: enforce FK constraints (needed for cascade deletes).
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
          await _createFts();
          await _seedSelfMember();
        },
      );

  Future<void> _createIndexes() async {
    const stmts = [
      'CREATE INDEX IF NOT EXISTS idx_visits_body_part     ON visits(body_part_id)',
      'CREATE INDEX IF NOT EXISTS idx_visits_speciality    ON visits(speciality_id)',
      'CREATE INDEX IF NOT EXISTS idx_visits_visit_date    ON visits(visit_date DESC)',
      'CREATE INDEX IF NOT EXISTS idx_visits_member        ON visits(member_id)',
      'CREATE INDEX IF NOT EXISTS idx_attachments_visit_id ON attachments(visit_id)',
      'CREATE INDEX IF NOT EXISTS idx_reminders_follow_up  ON reminders(follow_up_date)',
      'CREATE INDEX IF NOT EXISTS idx_insurance_member      ON insurance_policies(member_id)',
      'CREATE INDEX IF NOT EXISTS idx_insurance_valid_until ON insurance_policies(valid_until)',
      'CREATE INDEX IF NOT EXISTS idx_insurance_docs_policy ON insurance_documents(policy_id)',
    ];
    for (final s in stmts) {
      await customStatement(s);
    }
  }

  /// FTS5 over the searchable visit columns, kept in sync by triggers — ported
  /// from RN migration 2. If FTS5 is unavailable, [VisitsDao.search] falls back
  /// to a LIKE query, so this is best-effort.
  Future<void> _createFts() async {
    try {
      await customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS visits_fts USING fts5(
          id UNINDEXED, doctor_name, clinic_name, symptoms, diagnosis, notes,
          content='visits', content_rowid='rowid'
        )''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS visits_ai AFTER INSERT ON visits BEGIN
          INSERT INTO visits_fts(rowid, id, doctor_name, clinic_name, symptoms, diagnosis, notes)
          VALUES (new.rowid, new.id, new.doctor_name, new.clinic_name, new.symptoms, new.diagnosis, new.notes);
        END''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS visits_ad AFTER DELETE ON visits BEGIN
          INSERT INTO visits_fts(visits_fts, rowid, id, doctor_name, clinic_name, symptoms, diagnosis, notes)
          VALUES ('delete', old.rowid, old.id, old.doctor_name, old.clinic_name, old.symptoms, old.diagnosis, old.notes);
        END''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS visits_au AFTER UPDATE ON visits BEGIN
          INSERT INTO visits_fts(visits_fts, rowid, id, doctor_name, clinic_name, symptoms, diagnosis, notes)
          VALUES ('delete', old.rowid, old.id, old.doctor_name, old.clinic_name, old.symptoms, old.diagnosis, old.notes);
          INSERT INTO visits_fts(rowid, id, doctor_name, clinic_name, symptoms, diagnosis, notes)
          VALUES (new.rowid, new.id, new.doctor_name, new.clinic_name, new.symptoms, new.diagnosis, new.notes);
        END''');
    } catch (_) {
      // FTS5 not compiled into this sqlite build — search degrades to LIKE.
    }
  }

  /// Seeds the always-present, undeletable "Self" member (RN migration 3).
  Future<void> _seedSelfMember() async {
    await customStatement(
      "INSERT OR IGNORE INTO members (id, name, relationship, color, created_at, updated_at) "
      "VALUES (?, 'Self', 'SELF', '#1A6B8A', '2026-06-01T00:00:00.000Z', '2026-06-01T00:00:00.000Z')",
      [kDefaultSelfMemberId],
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'CareLog.db'));
    return NativeDatabase.createInBackground(file);
  });
}
