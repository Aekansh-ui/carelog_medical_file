export type BodyPartId =
  | 'HEAD_BRAIN'
  | 'CHEST_HEART'
  | 'ABDOMEN'
  | 'BACK_SPINE'
  | 'ARMS_HANDS'
  | 'LEGS_FEET'
  | 'SKIN'
  | 'GENERAL';

export interface BodyPart {
  id: BodyPartId;
  label: string;
  icon: string;           // MaterialCommunityIcons name
  description: string;    // Sub-label shown on card
  svgRegionId: string;    // Matches SVG path id for highlight
}

export const BODY_PARTS: BodyPart[] = [
  { id: 'HEAD_BRAIN',  label: 'Head & Brain',         icon: 'head-cog-outline',       description: 'Eyes, ears, nose, throat, brain', svgRegionId: 'region-head'    },
  { id: 'CHEST_HEART', label: 'Chest & Heart',        icon: 'heart-pulse',            description: 'Heart, lungs, chest wall',        svgRegionId: 'region-chest'   },
  { id: 'ABDOMEN',     label: 'Abdomen',              icon: 'stomach',                description: 'Stomach, liver, kidneys',         svgRegionId: 'region-abdomen' },
  { id: 'BACK_SPINE',  label: 'Back & Spine',         icon: 'human-handsdown',        description: 'Cervical, lumbar, sacral',        svgRegionId: 'region-back'    },
  { id: 'ARMS_HANDS',  label: 'Arms & Hands',         icon: 'arm-flex-outline',       description: 'Shoulder, elbow, wrist, fingers', svgRegionId: 'region-arms'    },
  { id: 'LEGS_FEET',   label: 'Legs & Feet',          icon: 'shoe-print',             description: 'Hip, knee, ankle, foot',          svgRegionId: 'region-legs'    },
  { id: 'SKIN',        label: 'Skin',                 icon: 'hand-back-right-outline', description: 'Rashes, infections, wounds',      svgRegionId: 'region-skin'    },
  { id: 'GENERAL',     label: 'General / Whole Body', icon: 'human',                  description: 'Fever, fatigue, allergies',       svgRegionId: 'region-general' },
];
