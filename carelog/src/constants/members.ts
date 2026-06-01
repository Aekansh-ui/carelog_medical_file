export type RelationshipType = 'SELF' | 'SPOUSE' | 'CHILD' | 'PARENT' | 'SIBLING' | 'OTHER';
export type Gender = 'MALE' | 'FEMALE' | 'OTHER';

export const RELATIONSHIPS: { id: RelationshipType; label: string; icon: string }[] = [
  { id: 'SELF',    label: 'Self',    icon: 'account'             },
  { id: 'SPOUSE',  label: 'Spouse',  icon: 'account-heart'       },
  { id: 'CHILD',   label: 'Child',   icon: 'baby-face-outline'   },
  { id: 'PARENT',  label: 'Parent',  icon: 'account-supervisor'  },
  { id: 'SIBLING', label: 'Sibling', icon: 'account-multiple'    },
  { id: 'OTHER',   label: 'Other',   icon: 'account-question'    },
];

export const GENDERS: { id: Gender; label: string }[] = [
  { id: 'MALE',   label: 'Male'   },
  { id: 'FEMALE', label: 'Female' },
  { id: 'OTHER',  label: 'Other'  },
];

// Avatar color palette — one is assigned per member (cycled by creation order).
export const MEMBER_COLORS = [
  '#1A6B8A', '#2E9E6B', '#E67E22', '#8E44AD',
  '#C0392B', '#16A085', '#D35400', '#2C3E50',
];

// Fixed id for the auto-created default member (created by migration 003).
export const DEFAULT_SELF_MEMBER_ID = '11111111-1111-1111-1111-111111111111';
