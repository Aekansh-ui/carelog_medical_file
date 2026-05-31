import AsyncStorage from '@react-native-async-storage/async-storage';
import { visitsRepository } from './visitsRepository';
import { remindersRepository } from './remindersRepository';
import { CreateVisitInput } from '../types/Visit';

const SEED_KEY = '@CareLog_seeded_v1';

const MOCK_VISITS: CreateVisitInput[] = [
  {
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
