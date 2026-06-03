import 'package:drift/drift.dart' show Value, Variable;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/members.dart' show kDefaultSelfMemberId;
import '../data/database.dart';

const _seedKey = '@CareLog_seeded_v1';
const _familySeedKey = '@CareLog_seeded_family_v1';
const _insuranceSeedKey = '@CareLog_seeded_insurance_v1';

// ---------------------------------------------------------------------------
// seedIfNeeded — 5 Self visits + 2 reminders
// ---------------------------------------------------------------------------

Future<void> seedIfNeeded(AppDatabase db) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_seedKey) == true) return;

  final mockVisits = <VisitsCompanion>[
    VisitsCompanion(
      memberId: const Value(kDefaultSelfMemberId),
      bodyPartId: const Value('HEAD_BRAIN'),
      specialityId: const Value('ENT'),
      visitDate: const Value('2026-04-10'),
      followUpDate: const Value('2026-06-15'),
      doctorName: const Value('Dr. Priya Sharma'),
      clinicName: const Value('Sharma ENT Clinic'),
      clinicPhone: const Value('9981234567'),
      doctorFees: const Value(500),
      currency: const Value('INR'),
      symptoms: const Value(
          'Blocked nose, difficulty hearing in right ear, mild throat irritation for 2 weeks.'),
      diagnosis: const Value(
          'Allergic Rhinitis with mild Eustachian tube dysfunction.'),
      notes: const Value('Avoid cold beverages. Steam inhalation twice daily.'),
    ),
    VisitsCompanion(
      memberId: const Value(kDefaultSelfMemberId),
      bodyPartId: const Value('CHEST_HEART'),
      specialityId: const Value('CARDIOLOGY'),
      visitDate: const Value('2026-03-22'),
      followUpDate: const Value('2026-06-22'),
      doctorName: const Value('Dr. Ramesh Gupta'),
      clinicName: const Value('Gupta Heart Care Centre'),
      clinicPhone: const Value('9977654321'),
      doctorFees: const Value(1200),
      currency: const Value('INR'),
      symptoms: const Value(
          'Mild chest discomfort on exertion, occasional palpitations, breathlessness climbing stairs.'),
      diagnosis: const Value(
          'Hypertensive Heart Disease Stage 1. ECG: normal sinus rhythm.'),
      notes: const Value(
          'Continue Amlodipine 5mg OD. Reduce salt intake. Walk 30 min daily.'),
    ),
    VisitsCompanion(
      memberId: const Value(kDefaultSelfMemberId),
      bodyPartId: const Value('ABDOMEN'),
      specialityId: const Value('GASTRO'),
      visitDate: const Value('2026-02-14'),
      doctorName: const Value('Dr. Anita Patel'),
      clinicName: const Value('City Gastro Hospital'),
      clinicPhone: const Value('9833221100'),
      doctorFees: const Value(800),
      currency: const Value('INR'),
      symptoms: const Value(
          'Acidity, burning sensation after meals, irregular bowel movements.'),
      diagnosis: const Value(
          'GERD (Gastroesophageal Reflux Disease). H. pylori negative.'),
      notes: const Value(
          'Take Pantoprazole 40mg before breakfast. Avoid spicy food and late-night meals.'),
    ),
    VisitsCompanion(
      memberId: const Value(kDefaultSelfMemberId),
      bodyPartId: const Value('LEGS_FEET'),
      specialityId: const Value('ORTHO'),
      visitDate: const Value('2026-01-30'),
      followUpDate: const Value('2026-07-10'),
      doctorName: const Value('Dr. Suresh Mehta'),
      clinicName: const Value('Mehta Orthopaedic Clinic'),
      clinicPhone: const Value('9765432109'),
      doctorFees: const Value(700),
      currency: const Value('INR'),
      symptoms: const Value(
          'Right knee pain worsening over 3 months, swelling after prolonged walking.'),
      diagnosis: const Value(
          'Early Osteoarthritis of right knee. X-ray: mild joint space narrowing.'),
      notes: const Value(
          'Physiotherapy 3x/week. Knee cap brace. Avoid squatting.'),
    ),
    VisitsCompanion(
      memberId: const Value(kDefaultSelfMemberId),
      bodyPartId: const Value('GENERAL'),
      specialityId: const Value('ENDOCRINOLOGY'),
      visitDate: const Value('2025-12-05'),
      doctorName: const Value('Dr. Kavita Joshi'),
      clinicName: const Value('Apollo Endocrine Clinic'),
      clinicPhone: const Value('9654321098'),
      doctorFees: const Value(1500),
      currency: const Value('INR'),
      symptoms: const Value(
          'Unexplained weight gain, fatigue, hair loss, cold intolerance for 3 months.'),
      diagnosis: const Value(
          'Hypothyroidism. TSH: 8.4 mIU/L (elevated). Free T4: low.'),
      notes: const Value(
          'Thyroxine 50mcg OD empty stomach. Recheck TSH in 6 weeks.'),
    ),
  ];

  for (final input in mockVisits) {
    await db.visitsDao.create(input);
  }

  // Reminders for ENT and Cardiology follow-ups
  final recent = await db.visitsDao.findRecent(10);
  final ent = recent.where((v) => v.specialityId == 'ENT').firstOrNull;
  if (ent?.followUpDate != null) {
    await db.remindersDao.create(ent!.id, ent.followUpDate!);
  }
  final cardio =
      recent.where((v) => v.specialityId == 'CARDIOLOGY').firstOrNull;
  if (cardio?.followUpDate != null) {
    await db.remindersDao.create(cardio!.id, cardio.followUpDate!);
  }

  await prefs.setBool(_seedKey, true);
}

// ---------------------------------------------------------------------------
// seedFamilyIfNeeded — 3 members + 4 visits + 3 reminders
// ---------------------------------------------------------------------------

Future<void> seedFamilyIfNeeded(AppDatabase db) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_familySeedKey) == true) return;

  final priya = await db.membersDao.create(MembersCompanion(
    name: const Value('Priya'),
    relationship: const Value('SPOUSE'),
    dateOfBirth: const Value('1988-07-20'),
    gender: const Value('FEMALE'),
    color: const Value('#2E9E6B'),
  ));

  final aarav = await db.membersDao.create(MembersCompanion(
    name: const Value('Aarav'),
    relationship: const Value('CHILD'),
    dateOfBirth: const Value('2018-04-12'),
    gender: const Value('MALE'),
    color: const Value('#E67E22'),
  ));

  final sita = await db.membersDao.create(MembersCompanion(
    name: const Value('Sita'),
    relationship: const Value('PARENT'),
    dateOfBirth: const Value('1955-09-10'),
    gender: const Value('FEMALE'),
    color: const Value('#8E44AD'),
  ));

  // Priya: Gynaecology visit + reminder
  final priyaVisit = await db.visitsDao.create(VisitsCompanion(
    memberId: Value(priya.id),
    bodyPartId: const Value('GENERAL'),
    specialityId: const Value('GYNAECOLOGY'),
    visitDate: const Value('2026-05-10'),
    followUpDate: const Value('2026-08-15'),
    doctorName: const Value('Dr. Meena Nair'),
    clinicName: const Value("Nair Women's Clinic"),
    clinicPhone: const Value('9871234560'),
    doctorFees: const Value(600),
    currency: const Value('INR'),
    symptoms: const Value(
        'Irregular cycles for 2 months, mild pelvic discomfort.'),
    diagnosis: const Value('PCOD — mild. Hormonal panel ordered.'),
    notes: const Value(
        'Lifestyle modification advised. Follow up in 3 months.'),
  ));
  await db.remindersDao.create(priyaVisit.id, priyaVisit.followUpDate!);

  // Aarav: General medicine
  await db.visitsDao.create(VisitsCompanion(
    memberId: Value(aarav.id),
    bodyPartId: const Value('GENERAL'),
    specialityId: const Value('GENERAL_MEDICINE'),
    visitDate: const Value('2026-04-22'),
    doctorName: const Value('Dr. Sanjay Pillai'),
    clinicName: const Value('Little Stars Paediatrics'),
    clinicPhone: const Value('9812345670'),
    doctorFees: const Value(400),
    currency: const Value('INR'),
    symptoms: const Value(
        'Mild fever (100.4°F), runny nose, cough for 3 days.'),
    diagnosis: const Value('Viral URTI. Self-limiting.'),
    notes: const Value(
        'Paracetamol syrup SOS. Rest and fluids. No antibiotics needed.'),
  ));

  // Sita: Cardiology + reminder
  final sitaVisit = await db.visitsDao.create(VisitsCompanion(
    memberId: Value(sita.id),
    bodyPartId: const Value('CHEST_HEART'),
    specialityId: const Value('CARDIOLOGY'),
    visitDate: const Value('2026-03-08'),
    followUpDate: const Value('2026-06-20'),
    doctorName: const Value('Dr. Rakesh Bose'),
    clinicName: const Value('Bose Cardiac Centre'),
    clinicPhone: const Value('9900011122'),
    doctorFees: const Value(1000),
    currency: const Value('INR'),
    symptoms: const Value(
        'Shortness of breath on climbing stairs. Occasional dizziness.'),
    diagnosis: const Value('Stable Angina. Echo: mild LV hypertrophy.'),
    notes: const Value(
        'Telmisartan 40mg OD continued. Low-sodium diet. Avoid strenuous activity.'),
  ));
  await db.remindersDao.create(sitaVisit.id, sitaVisit.followUpDate!);

  await prefs.setBool(_familySeedKey, true);
}

// ---------------------------------------------------------------------------
// seedInsuranceIfNeeded — 2 policies
// ---------------------------------------------------------------------------

Future<void> seedInsuranceIfNeeded(AppDatabase db) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_insuranceSeedKey) == true) return;

  await db.insuranceDao.create(InsurancePoliciesCompanion(
    memberId: const Value(kDefaultSelfMemberId),
    insurerName: const Value('Star Health Insurance'),
    planType: const Value('PERSONAL'),
    policyNumber: const Value('SH-2024-887341'),
    policyHolder: const Value('Self'),
    sumInsured: const Value(500000),
    premium: const Value(12500),
    currency: const Value('INR'),
    validFrom: const Value('2026-01-01'),
    validUntil: const Value('2026-12-31'),
    helplinePhone: const Value('18004252255'),
    agentName: const Value('Rohit Verma'),
    notes: const Value(
        'Cashless at network hospitals. Cataract sub-limit ₹40,000.'),
  ));

  // Family floater on the first non-Self member (if family seed ran)
  final otherMember = await db.customSelect(
    'SELECT id FROM members WHERE id != ? ORDER BY created_at ASC LIMIT 1',
    variables: [Variable.withString(kDefaultSelfMemberId)],
    readsFrom: {db.members},
  ).getSingleOrNull();

  if (otherMember != null) {
    final otherId = otherMember.read<String>('id');
    await db.insuranceDao.create(InsurancePoliciesCompanion(
      memberId: Value(otherId),
      insurerName: const Value('HDFC ERGO'),
      planType: const Value('FAMILY_FLOATER'),
      policyNumber: const Value('HE-FLT-556210'),
      sumInsured: const Value(1000000),
      premium: const Value(28000),
      currency: const Value('INR'),
      validFrom: const Value('2026-04-01'),
      validUntil: const Value('2027-03-31'),
      helplinePhone: const Value('18002700700'),
      notes: const Value('Floater shared across all family members.'),
    ));
  }

  await prefs.setBool(_insuranceSeedKey, true);
}
