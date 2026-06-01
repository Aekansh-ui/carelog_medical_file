import AsyncStorage from '@react-native-async-storage/async-storage';
import { visitsRepository } from './visitsRepository';
import { remindersRepository } from './remindersRepository';
import { membersRepository } from './membersRepository';
import { insuranceRepository } from './insuranceRepository';
import { getDb } from './database';
import { CreateVisitInput } from '../types/Visit';
import { DEFAULT_SELF_MEMBER_ID } from '../constants/members';

const SEED_KEY = '@CareLog_seeded_v1';
const FAMILY_SEED_KEY = '@CareLog_seeded_family_v1';
const INSURANCE_SEED_KEY = '@CareLog_seeded_insurance_v1';

const MOCK_VISITS: CreateVisitInput[] = [
  {
    member_id: DEFAULT_SELF_MEMBER_ID,
    body_part_id: 'HEAD_BRAIN',
    speciality_id: 'ENT',
    visit_date: '2026-04-10',
    follow_up_date: '2026-06-15',
    doctor_name: 'Dr. Priya Sharma',
    clinic_name: 'Sharma ENT Clinic',
    clinic_phone: '9981234567',
    doctor_fees: 500,
    currency: 'INR',
    symptoms: 'Blocked nose, difficulty hearing in right ear, mild throat irritation for 2 weeks.',
    diagnosis: 'Allergic Rhinitis with mild Eustachian tube dysfunction.',
    notes: 'Avoid cold beverages. Steam inhalation twice daily.',
  },
  {
    member_id: DEFAULT_SELF_MEMBER_ID,
    body_part_id: 'CHEST_HEART',
    speciality_id: 'CARDIOLOGY',
    visit_date: '2026-03-22',
    follow_up_date: '2026-06-22',
    doctor_name: 'Dr. Ramesh Gupta',
    clinic_name: 'Gupta Heart Care Centre',
    clinic_phone: '9977654321',
    doctor_fees: 1200,
    currency: 'INR',
    symptoms: 'Mild chest discomfort on exertion, occasional palpitations, breathlessness climbing stairs.',
    diagnosis: 'Hypertensive Heart Disease Stage 1. ECG: normal sinus rhythm.',
    notes: 'Continue Amlodipine 5mg OD. Reduce salt intake. Walk 30 min daily.',
  },
  {
    member_id: DEFAULT_SELF_MEMBER_ID,
    body_part_id: 'ABDOMEN',
    speciality_id: 'GASTRO',
    visit_date: '2026-02-14',
    follow_up_date: undefined,
    doctor_name: 'Dr. Anita Patel',
    clinic_name: 'City Gastro Hospital',
    clinic_phone: '9833221100',
    doctor_fees: 800,
    currency: 'INR',
    symptoms: 'Acidity, burning sensation after meals, irregular bowel movements.',
    diagnosis: 'GERD (Gastroesophageal Reflux Disease). H. pylori negative.',
    notes: 'Take Pantoprazole 40mg before breakfast. Avoid spicy food and late-night meals.',
  },
  {
    member_id: DEFAULT_SELF_MEMBER_ID,
    body_part_id: 'LEGS_FEET',
    speciality_id: 'ORTHO',
    visit_date: '2026-01-30',
    follow_up_date: '2026-07-10',
    doctor_name: 'Dr. Suresh Mehta',
    clinic_name: 'Mehta Orthopaedic Clinic',
    clinic_phone: '9765432109',
    doctor_fees: 700,
    currency: 'INR',
    symptoms: 'Right knee pain worsening over 3 months, swelling after prolonged walking.',
    diagnosis: 'Early Osteoarthritis of right knee. X-ray: mild joint space narrowing.',
    notes: 'Physiotherapy 3x/week. Knee cap brace. Avoid squatting.',
  },
  {
    member_id: DEFAULT_SELF_MEMBER_ID,
    body_part_id: 'GENERAL',
    speciality_id: 'ENDOCRINOLOGY',
    visit_date: '2025-12-05',
    follow_up_date: undefined,
    doctor_name: 'Dr. Kavita Joshi',
    clinic_name: 'Apollo Endocrine Clinic',
    clinic_phone: '9654321098',
    doctor_fees: 1500,
    currency: 'INR',
    symptoms: 'Unexplained weight gain, fatigue, hair loss, cold intolerance for 3 months.',
    diagnosis: 'Hypothyroidism. TSH: 8.4 mIU/L (elevated). Free T4: low.',
    notes: 'Thyroxine 50mcg OD empty stomach. Recheck TSH in 6 weeks.',
  },
];

export async function seedIfNeeded(): Promise<void> {
  const seeded = await AsyncStorage.getItem(SEED_KEY);
  if (seeded) return;

  for (const visitInput of MOCK_VISITS) {
    visitsRepository.create(visitInput);
  }

  // Seed a reminder for the ENT follow-up
  const ent = visitsRepository.findRecent(10).find(v => v.speciality_id === 'ENT');
  if (ent?.follow_up_date) {
    remindersRepository.create(ent.id, ent.follow_up_date);
  }

  // Seed a reminder for the Cardiology follow-up
  const cardio = visitsRepository.findRecent(10).find(v => v.speciality_id === 'CARDIOLOGY');
  if (cardio?.follow_up_date) {
    remindersRepository.create(cardio.id, cardio.follow_up_date);
  }

  await AsyncStorage.setItem(SEED_KEY, 'true');
}

export async function seedFamilyIfNeeded(): Promise<void> {
  const seeded = await AsyncStorage.getItem(FAMILY_SEED_KEY);
  if (seeded) return;

  const priya = membersRepository.create({
    name: 'Priya',
    relationship: 'SPOUSE',
    date_of_birth: '1988-07-20',
    gender: 'FEMALE',
    color: '#2E9E6B',
  });

  const aarav = membersRepository.create({
    name: 'Aarav',
    relationship: 'CHILD',
    date_of_birth: '2018-04-12',
    gender: 'MALE',
    color: '#E67E22',
  });

  const sita = membersRepository.create({
    name: 'Sita',
    relationship: 'PARENT',
    date_of_birth: '1955-09-10',
    gender: 'FEMALE',
    color: '#8E44AD',
  });

  // Priya: Gynaecology visit with a future follow-up → also create a reminder
  const priyaVisit = visitsRepository.create({
    member_id: priya.id,
    body_part_id: 'GENERAL',
    speciality_id: 'GYNAECOLOGY',
    visit_date: '2026-05-10',
    follow_up_date: '2026-08-15',
    doctor_name: 'Dr. Meena Nair',
    clinic_name: "Nair Women's Clinic",
    clinic_phone: '9871234560',
    doctor_fees: 600,
    currency: 'INR',
    symptoms: 'Irregular cycles for 2 months, mild pelvic discomfort.',
    diagnosis: 'PCOD — mild. Hormonal panel ordered.',
    notes: 'Lifestyle modification advised. Follow up in 3 months.',
  });
  remindersRepository.create(priyaVisit.id, priyaVisit.follow_up_date!);

  // Aarav: General medicine visit
  visitsRepository.create({
    member_id: aarav.id,
    body_part_id: 'GENERAL',
    speciality_id: 'GENERAL_MEDICINE',
    visit_date: '2026-04-22',
    doctor_name: 'Dr. Sanjay Pillai',
    clinic_name: 'Little Stars Paediatrics',
    clinic_phone: '9812345670',
    doctor_fees: 400,
    currency: 'INR',
    symptoms: 'Mild fever (100.4°F), runny nose, cough for 3 days.',
    diagnosis: 'Viral URTI. Self-limiting.',
    notes: 'Paracetamol syrup SOS. Rest and fluids. No antibiotics needed.',
  });

  // Sita: Cardiology visit with upcoming follow-up
  const sitaVisit = visitsRepository.create({
    member_id: sita.id,
    body_part_id: 'CHEST_HEART',
    speciality_id: 'CARDIOLOGY',
    visit_date: '2026-03-08',
    follow_up_date: '2026-06-20',
    doctor_name: 'Dr. Rakesh Bose',
    clinic_name: 'Bose Cardiac Centre',
    clinic_phone: '9900011122',
    doctor_fees: 1000,
    currency: 'INR',
    symptoms: 'Shortness of breath on climbing stairs. Occasional dizziness.',
    diagnosis: 'Stable Angina. Echo: mild LV hypertrophy.',
    notes: 'Telmisartan 40mg OD continued. Low-sodium diet. Avoid strenuous activity.',
  });
  remindersRepository.create(sitaVisit.id, sitaVisit.follow_up_date!);

  await AsyncStorage.setItem(FAMILY_SEED_KEY, 'true');
}

export async function seedInsuranceIfNeeded(): Promise<void> {
  const seeded = await AsyncStorage.getItem(INSURANCE_SEED_KEY);
  if (seeded) return;

  // A personal health policy for the always-present "Self" member.
  insuranceRepository.create({
    member_id: DEFAULT_SELF_MEMBER_ID,
    insurer_name: 'Star Health Insurance',
    plan_type: 'PERSONAL',
    policy_number: 'SH-2024-887341',
    policy_holder: 'Self',
    sum_insured: 500000,
    premium: 12500,
    currency: 'INR',
    valid_from: '2026-01-01',
    valid_until: '2026-12-31',
    helpline_phone: '18004252255',
    agent_name: 'Rohit Verma',
    notes: 'Cashless at network hospitals. Cataract sub-limit ₹40,000.',
  });

  // A family floater on the first non-Self member, if the family seed ran.
  const otherMember = getDb().getFirstSync<{ id: string }>(
    `SELECT id FROM members WHERE id != ? ORDER BY created_at ASC LIMIT 1`,
    [DEFAULT_SELF_MEMBER_ID]
  );
  if (otherMember) {
    insuranceRepository.create({
      member_id: otherMember.id,
      insurer_name: 'HDFC ERGO',
      plan_type: 'FAMILY_FLOATER',
      policy_number: 'HE-FLT-556210',
      sum_insured: 1000000,
      premium: 28000,
      currency: 'INR',
      valid_from: '2026-04-01',
      valid_until: '2027-03-31',
      helpline_phone: '18002700700',
      notes: 'Floater shared across all family members.',
    });
  }

  await AsyncStorage.setItem(INSURANCE_SEED_KEY, 'true');
}
