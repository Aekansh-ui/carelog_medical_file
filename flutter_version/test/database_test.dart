// Narrow drift imports so matcher's `isNull`/`isNotNull` aren't shadowed by
// drift's column expressions of the same name.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';

import 'package:carelog/constants/members.dart';
import 'package:carelog/data/database.dart';

/// Host-side smoke test of the Drift data layer against real SQLite
/// (in-memory). Mirrors the Python smoke test used on the RN app. The sqlite3
/// native library is provided automatically by `flutter test` (native assets).
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  // Helpers ------------------------------------------------------------------
  VisitsCompanion visit({
    required String memberId,
    String bodyPart = 'GENERAL',
    String speciality = 'ENT',
    String date = '2026-04-10',
    String? followUp,
    String? doctor,
    String? diagnosis,
  }) =>
      VisitsCompanion(
        memberId: Value(memberId),
        bodyPartId: Value(bodyPart),
        specialityId: Value(speciality),
        visitDate: Value(date),
        followUpDate: Value.absentIfNull(followUp),
        doctorName: Value.absentIfNull(doctor),
        diagnosis: Value.absentIfNull(diagnosis),
      );

  test('migration seeds the undeletable Self member', () async {
    final self = await db.membersDao.findById(kDefaultSelfMemberId);
    expect(self, isNotNull);
    expect(self!.name, 'Self');
    expect(self.relationship, 'SELF');
  });

  test('foreign keys are enforced', () async {
    final row = await db
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(row.data.values.first, 1);
  });

  test('visit create / find / update / cascade delete', () async {
    final v = await db.visitsDao.create(visit(
      memberId: kDefaultSelfMemberId,
      doctor: 'Dr. Priya Sharma',
      diagnosis: 'Allergic Rhinitis',
      followUp: '2026-12-31',
    ));
    expect(v.id, isNotEmpty);
    expect(v.currency, 'INR'); // default applied

    // attachment + reminder hang off the visit
    await db.attachmentsDao.add(AttachmentsCompanion(
      visitId: Value(v.id),
      type: const Value('prescription'),
      filePath: Value('/x/att.jpg'),
      fileName: const Value('att.jpg'),
      mimeType: const Value('image/jpeg'),
      sizeBytes: const Value(1024),
      thumbnailPath: const Value('/x/att_thumb.jpg'),
    ));
    await db.remindersDao.create(v.id, '2026-12-31');

    await db.visitsDao
        .updateVisit(v.id, const VisitsCompanion(clinicName: Value('Clinic A')));
    expect((await db.visitsDao.findById(v.id))!.clinicName, 'Clinic A');

    // delete returns the attachment file refs; cascade removes att + reminder
    final refs = await db.visitsDao.deleteVisit(v.id);
    expect(refs.single.filePath, '/x/att.jpg');
    expect(refs.single.thumbnailPath, '/x/att_thumb.jpg');
    expect(await db.visitsDao.findById(v.id), isNull);
    expect(await db.attachmentsDao.findByVisit(v.id), isEmpty);
    expect(await db.remindersDao.findByVisit(v.id), isNull);
  });

  test('search matches across fields and joins the member', () async {
    await db.visitsDao.create(visit(
      memberId: kDefaultSelfMemberId,
      doctor: 'Dr. Priya Sharma',
      diagnosis: 'Allergic Rhinitis',
    ));
    final byDiagnosis = await db.visitsDao.search('Rhinitis');
    expect(byDiagnosis, hasLength(1));
    expect(byDiagnosis.single.memberName, 'Self');

    final byDoctor = await db.visitsDao.search('Priya');
    expect(byDoctor, hasLength(1));

    expect(await db.visitsDao.search('Nonexistent'), isEmpty);
  });

  test('reminders: only active + future are upcoming', () async {
    final v = await db.visitsDao.create(visit(memberId: kDefaultSelfMemberId));
    final r = await db.remindersDao.create(v.id, '2026-12-31');
    await db.remindersDao.create(v.id, '2020-01-01'); // past → excluded
    final upcoming = await db.remindersDao.findUpcoming();
    expect(upcoming.map((e) => e.followUpDate), ['2026-12-31']);

    await db.remindersDao.setActive(r.id, false);
    expect(await db.remindersDao.findUpcoming(), isEmpty);
  });

  test('findAllWithStats + family summary', () async {
    final priya = await db.membersDao.create(MembersCompanion(
      name: const Value('Priya'),
      relationship: const Value('SPOUSE'),
      color: const Value('#2E9E6B'),
    ));
    await db.visitsDao.create(visit(memberId: kDefaultSelfMemberId, date: '2026-05-01'));
    await db.visitsDao.create(visit(
      memberId: priya.id,
      date: '2026-05-10',
      followUp: '2026-12-31',
    ));

    final stats = await db.membersDao.findAllWithStats();
    expect(stats.first.member.relationship, 'SELF'); // Self pinned first
    final priyaStats = stats.firstWhere((s) => s.member.id == priya.id);
    expect(priyaStats.visitCount, 1);
    expect(priyaStats.lastVisitDate, '2026-05-10');
    expect(priyaStats.nextFollowUp, '2026-12-31');

    final summary = await db.membersDao.getFamilySummary();
    expect(summary.totalMembers, 2);
    expect(summary.totalVisits, 2);
    expect(summary.upcomingFollowUps.single.memberName, 'Priya');
  });

  test('insurance: doc count, expiry ordering, cascade delete', () async {
    InsurancePoliciesCompanion pol(String insurer, String? until) =>
        InsurancePoliciesCompanion(
          memberId: const Value(kDefaultSelfMemberId),
          insurerName: Value(insurer),
          validUntil: Value.absentIfNull(until),
        );

    final later = await db.insuranceDao.create(pol('Later', '2026-12-31'));
    await db.insuranceDao.create(pol('NoExpiry', null));
    final sooner = await db.insuranceDao.create(pol('Sooner', '2026-07-01'));

    // two docs on the "Sooner" policy
    for (var i = 0; i < 2; i++) {
      await db.insuranceDao.addDocument(InsuranceDocumentsCompanion(
        policyId: Value(sooner.id),
        filePath: Value('/d/$i.pdf'),
        fileName: Value('$i.pdf'),
        mimeType: const Value('application/pdf'),
        sizeBytes: const Value(2048),
      ));
    }

    final list = await db.insuranceDao.findByMember(kDefaultSelfMemberId);
    expect(list.map((p) => p.policy.insurerName), ['Sooner', 'Later', 'NoExpiry']);
    expect(list.first.documentCount, 2);
    expect(await db.insuranceDao.countByMember(kDefaultSelfMemberId), 3);

    // deletePolicy returns doc refs + cascades documents away
    final refs = await db.insuranceDao.deletePolicy(sooner.id);
    expect(refs.map((r) => r.filePath), containsAll(['/d/0.pdf', '/d/1.pdf']));
    expect(await db.insuranceDao.findDocuments(sooner.id), isEmpty);
    expect(await db.insuranceDao.countByMember(kDefaultSelfMemberId), 2);

    expect(later.insurerName, 'Later'); // sanity on the returned row
  });

  test('member delete cascades visits, attachments, reminders, insurance', () async {
    final priya = await db.membersDao.create(
        MembersCompanion(name: const Value('Priya'), relationship: const Value('SPOUSE')));
    final v = await db.visitsDao.create(visit(memberId: priya.id, followUp: '2026-12-31'));
    await db.attachmentsDao.add(AttachmentsCompanion(
      visitId: Value(v.id),
      type: const Value('bill'),
      filePath: const Value('/a/bill.jpg'),
      fileName: const Value('bill.jpg'),
      mimeType: const Value('image/jpeg'),
      sizeBytes: const Value(500),
    ));
    await db.remindersDao.create(v.id, '2026-12-31');
    final policy = await db.insuranceDao.create(InsurancePoliciesCompanion(
      memberId: Value(priya.id),
      insurerName: const Value('Star'),
    ));
    await db.insuranceDao.addDocument(InsuranceDocumentsCompanion(
      policyId: Value(policy.id),
      filePath: const Value('/a/card.jpg'),
      fileName: const Value('card.jpg'),
      mimeType: const Value('image/jpeg'),
      sizeBytes: const Value(500),
    ));

    final refs = await db.membersDao.deleteMember(priya.id);
    expect(refs.map((r) => r.filePath), containsAll(['/a/bill.jpg', '/a/card.jpg']));

    expect(await db.membersDao.findById(priya.id), isNull);
    expect(await db.visitsDao.findById(v.id), isNull);
    expect(await db.insuranceDao.findByMember(priya.id), isEmpty);
    expect(await db.visitsDao.countAll(), 0);
    // Self is untouched
    expect(await db.membersDao.findById(kDefaultSelfMemberId), isNotNull);
  });

  test('attachment type CHECK constraint rejects bad values', () async {
    final v = await db.visitsDao.create(visit(memberId: kDefaultSelfMemberId));
    expect(
      () => db.attachmentsDao.add(AttachmentsCompanion(
        visitId: Value(v.id),
        type: const Value('not_a_valid_type'),
        filePath: const Value('/x.jpg'),
        fileName: const Value('x.jpg'),
        mimeType: const Value('image/jpeg'),
        sizeBytes: const Value(1),
      )),
      throwsA(isA<Exception>()),
    );
  });
}
