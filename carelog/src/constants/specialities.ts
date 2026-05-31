export type SpecialityId =
  | 'GENERAL_MEDICINE' | 'ENT'            | 'NEUROLOGY'    | 'DENTISTRY'
  | 'CARDIOLOGY'       | 'PULMONOLOGY'    | 'GASTRO'       | 'NEPHROLOGY'
  | 'ORTHO'            | 'DERMATOLOGY'    | 'OPHTHALMOLOGY'| 'GYNAECOLOGY'
  | 'UROLOGY'          | 'ENDOCRINOLOGY'  | 'PSYCHIATRY'   | 'OTHER';

export interface Speciality {
  id: SpecialityId;
  label: string;
  icon: string;           // MaterialCommunityIcons name
  shortLabel: string;     // Used in chips / badges
  color: string;          // Hex: accent color for card
}

export const SPECIALITIES: Speciality[] = [
  { id: 'GENERAL_MEDICINE', label: 'General Medicine', shortLabel: 'GP',      icon: 'stethoscope',              color: '#2196F3' },
  { id: 'ENT',              label: 'ENT',              shortLabel: 'ENT',     icon: 'ear-hearing',              color: '#9C27B0' },
  { id: 'NEUROLOGY',        label: 'Neurology',        shortLabel: 'Neuro',   icon: 'brain',                    color: '#673AB7' },
  { id: 'DENTISTRY',        label: 'Dentistry',        shortLabel: 'Dental',  icon: 'tooth-outline',            color: '#00BCD4' },
  { id: 'CARDIOLOGY',       label: 'Cardiology',       shortLabel: 'Cardio',  icon: 'heart-pulse',              color: '#F44336' },
  { id: 'PULMONOLOGY',      label: 'Pulmonology',      shortLabel: 'Pulmo',   icon: 'lungs',                    color: '#03A9F4' },
  { id: 'GASTRO',           label: 'Gastroenterology', shortLabel: 'Gastro',  icon: 'stomach',                  color: '#FF9800' },
  { id: 'NEPHROLOGY',       label: 'Nephrology',       shortLabel: 'Nephro',  icon: 'water-outline',            color: '#009688' },
  { id: 'ORTHO',            label: 'Orthopaedics',     shortLabel: 'Ortho',   icon: 'bone',                     color: '#795548' },
  { id: 'DERMATOLOGY',      label: 'Dermatology',      shortLabel: 'Derma',   icon: 'hand-back-right-outline',  color: '#FF5722' },
  { id: 'OPHTHALMOLOGY',    label: 'Ophthalmology',    shortLabel: 'Eye',     icon: 'eye-outline',              color: '#607D8B' },
  { id: 'GYNAECOLOGY',      label: 'Gynaecology',      shortLabel: 'Gynae',   icon: 'human-female',             color: '#E91E63' },
  { id: 'UROLOGY',          label: 'Urology',          shortLabel: 'Urology', icon: 'water',                    color: '#3F51B5' },
  { id: 'ENDOCRINOLOGY',    label: 'Endocrinology',    shortLabel: 'Endo',    icon: 'needle',                   color: '#8BC34A' },
  { id: 'PSYCHIATRY',       label: 'Psychiatry',       shortLabel: 'Psych',   icon: 'head-heart-outline',       color: '#FFC107' },
  { id: 'OTHER',            label: 'Other / Custom',   shortLabel: 'Other',   icon: 'plus-circle-outline',      color: '#9E9E9E' },
];
