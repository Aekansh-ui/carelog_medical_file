export type PlanType = 'PERSONAL' | 'FAMILY_FLOATER' | 'CORPORATE' | 'OTHER';

export const PLAN_TYPES: { id: PlanType; label: string; icon: string }[] = [
  { id: 'PERSONAL',       label: 'Personal',       icon: 'account'         },
  { id: 'FAMILY_FLOATER', label: 'Family Floater', icon: 'account-group'   },
  { id: 'CORPORATE',      label: 'Corporate',      icon: 'office-building' },
  { id: 'OTHER',          label: 'Other',          icon: 'shield-outline'  },
];

// A policy is flagged "expiring soon" when valid_until is within this many days.
export const INSURANCE_EXPIRY_SOON_DAYS = 30;
