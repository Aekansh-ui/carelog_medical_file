# CareLog — Offline Prototype PRD
**Version:** 1.1-family  
**Status:** Active  
**Date:** 2026-06-01  
**Scope:** Offline-only full working prototype with mock data and navigation  
**Environment:** Expo SDK 51 + React Native 0.74 + TypeScript  
**Intended Consumer:** Agentic AI development tool (Cursor / Claude / Copilot Workspace)  

**Changelog**
- **v1.1-family (2026-06-01):** Added multi-member (family) support. The app now manages health records for multiple family members. A new Family Home dashboard lists all members; tapping a member drills into that member's existing body-map → speciality → visit flow. See **[Section 14: Family Functionality Extension](#14-family-functionality-extension)** for the complete spec. All v1.0 sections below remain valid; Section 14 documents the additive changes (new `members` table, `member_id` foreign key on `visits`, new screens, new repository/store, migration & seed updates).
- **v1.0-offline (2026-05-31):** Initial offline prototype (single patient).

---

## AGENT BOOTSTRAP INSTRUCTIONS

> Read this section first before generating any code.

```
GOAL:
  Build a full offline working prototype of CareLog — a patient health record app.
  All screens must be navigable. Data is stored in SQLite on-device (expo-sqlite).
  Mock seed data must be pre-loaded so every screen shows realistic content on first launch.

BUILD ORDER (strictly follow this sequence):
  1. Project scaffold + dependencies (package.json, app.json, tsconfig.json)
  2. Constants (enums: body parts, specialities, mapping table)
  3. TypeScript types
  4. Database layer (schema, migrations, seed data, repositories)
  5. Zustand stores (consume repository functions)
  6. Navigation structure (Expo Router, tab bar, stack navigators)
  7. Shared UI components (reusable, no screen logic)
  8. Screen components (consume stores, no direct DB calls)
  9. App entry point wiring

RULES:
  - No network calls. No fetch(). No cloud APIs.
  - No authentication or login screen.
  - All data reads/writes go through repository functions only; screens must not query SQLite directly.
  - Stores are the only bridge between screens and repositories.
  - Use mock seed data (defined in Section 9) — insert on first launch only (check a "seeded" flag in AsyncStorage).
  - Every screen must render without crashing even with zero records.
  - Navigation must work bidirectionally (back buttons, tab switching).
```

---

## TABLE OF CONTENTS

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Constants and Enums](#4-constants-and-enums)
5. [TypeScript Types](#5-typescript-types)
6. [Database Layer](#6-database-layer)
7. [State Management](#7-state-management)
8. [Navigation Architecture](#8-navigation-architecture)
9. [Mock Seed Data](#9-mock-seed-data)
10. [Screen Specifications](#10-screen-specifications)
    - 10.1 [Home Screen — Body Part Selection](#101-home-screen--body-part-selection)
    - 10.2 [Speciality Selection Screen](#102-speciality-selection-screen)
    - 10.3 [Visit List Screen](#103-visit-list-screen)
    - 10.4 [Visit Entry Screen](#104-visit-entry-screen)
    - 10.5 [Visit Detail Screen](#105-visit-detail-screen)
    - 10.6 [Reports Hub Screen](#106-reports-hub-screen)
    - 10.7 [Reminders Screen](#107-reminders-screen)
    - 10.8 [Settings Screen](#108-settings-screen)
    - 10.9 [Global Search Screen](#109-global-search-screen)
11. [Shared UI Components](#11-shared-ui-components)
12. [Design System](#12-design-system)
13. [Acceptance Criteria](#13-acceptance-criteria)
14. [Family Functionality Extension (v1.1)](#14-family-functionality-extension)
    - 14.1 [Overview & Navigation Model](#141-overview--navigation-model)
    - 14.2 [Constants](#142-constants)
    - 14.3 [TypeScript Types](#143-typescript-types)
    - 14.4 [Database Changes](#144-database-changes)
    - 14.5 [Repositories](#145-repositories)
    - 14.6 [State Management](#146-state-management)
    - 14.7 [Navigation Changes](#147-navigation-changes)
    - 14.8 [Screen Specifications](#148-screen-specifications)
    - 14.9 [Seed Data Changes](#149-seed-data-changes)
    - 14.10 [Acceptance Criteria (Family)](#1410-acceptance-criteria-family)

---

## 1. Project Overview

CareLog lets patients store and retrieve all doctor visit data. Navigation is structured in two layers:

1. **Body Part** (Home screen — tappable illustrated body map)
2. **Speciality** (e.g., ENT, Cardiology, Neurology)

Within each visit users store: symptoms, doctor details, clinic phone, visit date, follow-up date, doctor fees, prescription images, medicine images, bills, medical reports, diagnosis, and notes.

**Prototype Goal:** Every screen is navigable, every list shows realistic mock data, and all create/edit/delete operations persist to local SQLite.

---

## 2. Tech Stack

```json
{
  "runtime": "Expo SDK 51",
  "framework": "React Native 0.74",
  "language": "TypeScript 5.x",
  "navigation": "Expo Router 3.x (file-based)",
  "state": "Zustand 4.x",
  "database": "expo-sqlite 14.x",
  "ui_library": "React Native Paper 5.x",
  "icons": "expo-vector-icons (MaterialCommunityIcons)",
  "image_picker": "expo-image-picker 15.x",
  "camera": "expo-camera 15.x",
  "document_picker": "expo-document-picker 12.x",
  "image_manipulator": "expo-image-manipulator 12.x",
  "notifications": "expo-notifications 0.28.x",
  "async_storage": "@react-native-async-storage/async-storage 1.x",
  "uuid": "react-native-uuid 2.x",
  "date_formatting": "date-fns 3.x",
  "pdf_viewer": "react-native-pdf 6.x",
  "pdf_export": "react-native-html-to-pdf 0.12.x"
}
```

### package.json dependencies

```json
{
  "dependencies": {
    "expo": "~51.0.0",
    "expo-router": "~3.5.0",
    "react": "18.2.0",
    "react-native": "0.74.5",
    "typescript": "^5.3.0",
    "react-native-paper": "^5.12.0",
    "react-native-safe-area-context": "4.10.5",
    "react-native-screens": "3.31.1",
    "zustand": "^4.5.0",
    "expo-sqlite": "~14.0.0",
    "@react-native-async-storage/async-storage": "1.23.1",
    "expo-image-picker": "~15.0.0",
    "expo-camera": "~15.0.0",
    "expo-document-picker": "~12.0.0",
    "expo-image-manipulator": "~12.0.0",
    "expo-notifications": "~0.28.0",
    "expo-file-system": "~17.0.0",
    "expo-vector-icons": "^14.0.0",
    "react-native-uuid": "^2.0.0",
    "date-fns": "^3.6.0",
    "react-native-pdf": "^6.7.0",
    "react-native-html-to-pdf": "^0.12.0",
    "@expo/vector-icons": "^14.0.0"
  }
}
```

### app.json (key fields)

```json
{
  "expo": {
    "name": "CareLog",
    "slug": "CareLog",
    "scheme": "CareLog",
    "version": "1.0.0",
    "platforms": ["ios", "android"],
    "plugins": [
      "expo-router",
      "expo-sqlite",
      [
        "expo-image-picker",
        { "photosPermission": "CareLog needs photo access to attach prescription and report images." }
      ],
      [
        "expo-camera",
        { "cameraPermission": "CareLog needs camera access to photograph prescriptions and bills." }
      ],
      [
        "expo-notifications",
        { "icon": "./assets/notification-icon.png", "color": "#1A6B8A" }
      ]
    ],
    "android": {
      "package": "com.CareLog.app",
      "permissions": ["CAMERA", "READ_MEDIA_IMAGES", "POST_NOTIFICATIONS"]
    },
    "ios": {
      "bundleIdentifier": "com.CareLog.app",
      "infoPlist": {
        "NSCameraUsageDescription": "CareLog needs camera access to photograph prescriptions.",
        "NSPhotoLibraryUsageDescription": "CareLog needs photo library access to attach images."
      }
    }
  }
}
```

---

## 3. Project Structure

```
CareLog/
├── app/                          # Expo Router screens (file = route)
│   ├── _layout.tsx               # Root layout: PaperProvider + NavigationContainer
│   ├── (tabs)/
│   │   ├── _layout.tsx           # Bottom tab navigator (4 tabs)
│   │   ├── index.tsx             # Tab 1: Home (Body Map)
│   │   ├── reports.tsx           # Tab 2: Reports Hub
│   │   ├── reminders.tsx         # Tab 3: Reminders
│   │   └── settings.tsx          # Tab 4: Settings
│   ├── speciality/
│   │   └── [bodyPartId].tsx      # Speciality grid for selected body part
│   ├── visits/
│   │   ├── [specialityId].tsx    # Visit list for body part + speciality
│   │   ├── new.tsx               # New visit entry form
│   │   ├── edit/
│   │   │   └── [visitId].tsx     # Edit existing visit
│   │   └── [visitId].tsx         # Visit detail view
│   └── search.tsx                # Global search
│
├── src/
│   ├── constants/
│   │   ├── bodyParts.ts
│   │   ├── specialities.ts
│   │   └── bodySpecialityMap.ts
│   │
│   ├── types/
│   │   ├── Visit.ts
│   │   ├── Attachment.ts
│   │   ├── Reminder.ts
│   │   └── index.ts
│   │
│   ├── db/
│   │   ├── database.ts           # DB init, open connection, run migrations
│   │   ├── migrations/
│   │   │   ├── 001_create_tables.sql
│   │   │   └── 002_create_fts.sql
│   │   ├── seed.ts               # Mock seed data insertion
│   │   ├── visitsRepository.ts
│   │   ├── attachmentsRepository.ts
│   │   └── remindersRepository.ts
│   │
│   ├── store/
│   │   ├── visitsStore.ts
│   │   ├── remindersStore.ts
│   │   └── settingsStore.ts
│   │
│   ├── services/
│   │   ├── notificationService.ts
│   │   ├── fileService.ts
│   │   └── exportService.ts
│   │
│   ├── components/
│   │   ├── BodyMap/
│   │   │   ├── BodyMapSVG.tsx
│   │   │   └── BodyRegionOverlay.tsx
│   │   ├── VisitCard.tsx
│   │   ├── SpecialityCard.tsx
│   │   ├── AttachmentThumbnail.tsx
│   │   ├── AttachmentGrid.tsx
│   │   ├── ReminderCard.tsx
│   │   ├── EmptyState.tsx
│   │   └── SectionHeader.tsx
│   │
│   └── utils/
│       ├── dateUtils.ts
│       ├── formatters.ts
│       └── validators.ts
│
├── assets/
│   ├── body-front.svg
│   ├── body-back.svg
│   └── notification-icon.png
│
├── app.json
├── package.json
├── tsconfig.json
└── babel.config.js
```

---

## 4. Constants and Enums

### src/constants/bodyParts.ts

```typescript
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
  { id: 'HEAD_BRAIN',   label: 'Head & Brain',        icon: 'head-cog-outline',      description: 'Eyes, ears, nose, throat, brain', svgRegionId: 'region-head'   },
  { id: 'CHEST_HEART',  label: 'Chest & Heart',       icon: 'heart-pulse',           description: 'Heart, lungs, chest wall',         svgRegionId: 'region-chest'  },
  { id: 'ABDOMEN',      label: 'Abdomen',             icon: 'stomach',               description: 'Stomach, liver, kidneys',          svgRegionId: 'region-abdomen'},
  { id: 'BACK_SPINE',   label: 'Back & Spine',        icon: 'human-handsdown',       description: 'Cervical, lumbar, sacral',         svgRegionId: 'region-back'   },
  { id: 'ARMS_HANDS',   label: 'Arms & Hands',        icon: 'arm-flex-outline',      description: 'Shoulder, elbow, wrist, fingers',  svgRegionId: 'region-arms'   },
  { id: 'LEGS_FEET',    label: 'Legs & Feet',         icon: 'shoe-print',            description: 'Hip, knee, ankle, foot',           svgRegionId: 'region-legs'   },
  { id: 'SKIN',         label: 'Skin',                icon: 'hand-back-right-outline',description: 'Rashes, infections, wounds',       svgRegionId: 'region-skin'   },
  { id: 'GENERAL',      label: 'General / Whole Body',icon: 'human',                 description: 'Fever, fatigue, allergies',        svgRegionId: 'region-general'},
];
```

### src/constants/specialities.ts

```typescript
export type SpecialityId =
  | 'GENERAL_MEDICINE' | 'ENT'       | 'NEUROLOGY'  | 'DENTISTRY'
  | 'CARDIOLOGY'       | 'PULMONOLOGY'| 'GASTRO'     | 'NEPHROLOGY'
  | 'ORTHO'            | 'DERMATOLOGY'| 'OPHTHALMOLOGY'| 'GYNAECOLOGY'
  | 'UROLOGY'          | 'ENDOCRINOLOGY'| 'PSYCHIATRY'| 'OTHER';

export interface Speciality {
  id: SpecialityId;
  label: string;
  icon: string;           // MaterialCommunityIcons name
  shortLabel: string;     // Used in chips / badges
  color: string;          // Hex: accent color for card
}

export const SPECIALITIES: Speciality[] = [
  { id: 'GENERAL_MEDICINE', label: 'General Medicine',     shortLabel: 'GP',     icon: 'stethoscope',             color: '#2196F3' },
  { id: 'ENT',              label: 'ENT',                  shortLabel: 'ENT',    icon: 'ear-hearing',             color: '#9C27B0' },
  { id: 'NEUROLOGY',        label: 'Neurology',            shortLabel: 'Neuro',  icon: 'brain',                   color: '#673AB7' },
  { id: 'DENTISTRY',        label: 'Dentistry',            shortLabel: 'Dental', icon: 'tooth-outline',           color: '#00BCD4' },
  { id: 'CARDIOLOGY',       label: 'Cardiology',           shortLabel: 'Cardio', icon: 'heart-pulse',             color: '#F44336' },
  { id: 'PULMONOLOGY',      label: 'Pulmonology',          shortLabel: 'Pulmo',  icon: 'lungs',                   color: '#03A9F4' },
  { id: 'GASTRO',           label: 'Gastroenterology',     shortLabel: 'Gastro', icon: 'stomach',                 color: '#FF9800' },
  { id: 'NEPHROLOGY',       label: 'Nephrology',           shortLabel: 'Nephro', icon: 'water-outline',           color: '#009688' },
  { id: 'ORTHO',            label: 'Orthopaedics',         shortLabel: 'Ortho',  icon: 'bone',                    color: '#795548' },
  { id: 'DERMATOLOGY',      label: 'Dermatology',          shortLabel: 'Derma',  icon: 'hand-back-right-outline', color: '#FF5722' },
  { id: 'OPHTHALMOLOGY',    label: 'Ophthalmology',        shortLabel: 'Eye',    icon: 'eye-outline',             color: '#607D8B' },
  { id: 'GYNAECOLOGY',      label: 'Gynaecology',          shortLabel: 'Gynae',  icon: 'human-female',            color: '#E91E63' },
  { id: 'UROLOGY',          label: 'Urology',              shortLabel: 'Urology',icon: 'water',                   color: '#3F51B5' },
  { id: 'ENDOCRINOLOGY',    label: 'Endocrinology',        shortLabel: 'Endo',   icon: 'needle',                  color: '#8BC34A' },
  { id: 'PSYCHIATRY',       label: 'Psychiatry',           shortLabel: 'Psych',  icon: 'head-heart-outline',      color: '#FFC107' },
  { id: 'OTHER',            label: 'Other / Custom',       shortLabel: 'Other',  icon: 'plus-circle-outline',     color: '#9E9E9E' },
];
```

### src/constants/bodySpecialityMap.ts

```typescript
import { BodyPartId } from './bodyParts';
import { SpecialityId } from './specialities';

export const BODY_SPECIALITY_MAP: Record<BodyPartId, SpecialityId[]> = {
  HEAD_BRAIN:  ['NEUROLOGY', 'ENT', 'OPHTHALMOLOGY', 'DENTISTRY', 'PSYCHIATRY', 'GENERAL_MEDICINE'],
  CHEST_HEART: ['CARDIOLOGY', 'PULMONOLOGY', 'GENERAL_MEDICINE'],
  ABDOMEN:     ['GASTRO', 'NEPHROLOGY', 'GYNAECOLOGY', 'UROLOGY', 'ENDOCRINOLOGY', 'GENERAL_MEDICINE'],
  BACK_SPINE:  ['ORTHO', 'NEUROLOGY', 'GENERAL_MEDICINE'],
  ARMS_HANDS:  ['ORTHO', 'DERMATOLOGY', 'GENERAL_MEDICINE'],
  LEGS_FEET:   ['ORTHO', 'DERMATOLOGY', 'GENERAL_MEDICINE'],
  SKIN:        ['DERMATOLOGY', 'GENERAL_MEDICINE'],
  GENERAL:     ['GENERAL_MEDICINE', 'ENDOCRINOLOGY', 'PSYCHIATRY', 'OTHER'],
};
```

---

## 5. TypeScript Types

### src/types/Visit.ts

```typescript
import { BodyPartId } from '../constants/bodyParts';
import { SpecialityId } from '../constants/specialities';
import { Attachment } from './Attachment';

export interface Visit {
  id: string;                       // UUID v4
  body_part_id: BodyPartId;
  speciality_id: SpecialityId;
  custom_speciality?: string;       // Only when speciality_id === 'OTHER'
  visit_date: string;               // YYYY-MM-DD
  follow_up_date?: string;          // YYYY-MM-DD
  doctor_name?: string;
  clinic_name?: string;
  clinic_phone?: string;
  doctor_fees?: number;
  currency: string;                 // Default: 'INR'
  symptoms?: string;
  diagnosis?: string;
  notes?: string;
  created_at: string;               // ISO 8601
  updated_at: string;               // ISO 8601
  attachments?: Attachment[];       // Populated via JOIN in repository
}

export type CreateVisitInput = Omit<Visit, 'id' | 'created_at' | 'updated_at' | 'attachments'>;
export type UpdateVisitInput = Partial<CreateVisitInput>;

export interface VisitDraft {
  id: string;
  form_data: string;                // JSON.stringify(Partial<CreateVisitInput>)
  created_at: string;
  updated_at: string;
}
```

### src/types/Attachment.ts

```typescript
export type AttachmentType = 'prescription' | 'medicine' | 'bill' | 'report';
export type MimeType = 'image/jpeg' | 'image/png' | 'application/pdf';

export interface Attachment {
  id: string;                       // UUID v4
  visit_id: string;
  type: AttachmentType;
  file_path: string;                // Absolute path in app document directory
  file_name: string;
  mime_type: MimeType;
  size_bytes: number;
  thumbnail_path?: string;          // Compressed thumbnail for images
  created_at: string;
}

export type CreateAttachmentInput = Omit<Attachment, 'id' | 'created_at'>;

export const ATTACHMENT_LIMITS: Record<AttachmentType, { maxFiles: number; maxSizeBytes: number }> = {
  prescription: { maxFiles: 5,  maxSizeBytes: 10 * 1024 * 1024 },
  medicine:     { maxFiles: 10, maxSizeBytes: 10 * 1024 * 1024 },
  bill:         { maxFiles: 5,  maxSizeBytes: 10 * 1024 * 1024 },
  report:       { maxFiles: 10, maxSizeBytes: 20 * 1024 * 1024 },
};
```

### src/types/Reminder.ts

```typescript
export interface Reminder {
  id: string;
  visit_id: string;
  follow_up_date: string;           // YYYY-MM-DD
  notification_id_d1?: string;      // OS notification id (D-1 alert)
  notification_id_d0?: string;      // OS notification id (D-day alert)
  is_active: boolean;
  rescheduled_at?: string;
  created_at: string;
  // Joined from visits table:
  doctor_name?: string;
  speciality_id?: string;
  body_part_id?: string;
}
```

---

## 6. Database Layer

### 6.1 Migration: 001_create_tables.sql

```sql
CREATE TABLE IF NOT EXISTS schema_migrations (
  version   INTEGER PRIMARY KEY,
  applied_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS visits (
  id                TEXT PRIMARY KEY,
  body_part_id      TEXT NOT NULL,
  speciality_id     TEXT NOT NULL,
  custom_speciality TEXT,
  visit_date        TEXT NOT NULL,
  follow_up_date    TEXT,
  doctor_name       TEXT,
  clinic_name       TEXT,
  clinic_phone      TEXT,
  doctor_fees       REAL,
  currency          TEXT NOT NULL DEFAULT 'INR',
  symptoms          TEXT,
  diagnosis         TEXT,
  notes             TEXT,
  created_at        TEXT NOT NULL,
  updated_at        TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS attachments (
  id             TEXT PRIMARY KEY,
  visit_id       TEXT NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
  type           TEXT NOT NULL CHECK(type IN ('prescription','medicine','bill','report')),
  file_path      TEXT NOT NULL,
  file_name      TEXT NOT NULL,
  mime_type      TEXT NOT NULL,
  size_bytes     INTEGER NOT NULL,
  thumbnail_path TEXT,
  created_at     TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS reminders (
  id                  TEXT PRIMARY KEY,
  visit_id            TEXT NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
  follow_up_date      TEXT NOT NULL,
  notification_id_d1  TEXT,
  notification_id_d0  TEXT,
  is_active           INTEGER NOT NULL DEFAULT 1,
  rescheduled_at      TEXT,
  created_at          TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS visit_drafts (
  id          TEXT PRIMARY KEY,
  form_data   TEXT NOT NULL,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_visits_body_part     ON visits(body_part_id);
CREATE INDEX IF NOT EXISTS idx_visits_speciality    ON visits(speciality_id);
CREATE INDEX IF NOT EXISTS idx_visits_visit_date    ON visits(visit_date DESC);
CREATE INDEX IF NOT EXISTS idx_attachments_visit_id ON attachments(visit_id);
CREATE INDEX IF NOT EXISTS idx_reminders_follow_up  ON reminders(follow_up_date);
```

### 6.2 Migration: 002_create_fts.sql

```sql
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
```

### 6.3 database.ts — Initialisation

```typescript
// src/db/database.ts
import * as SQLite from 'expo-sqlite';

let db: SQLite.SQLiteDatabase | null = null;

export function getDb(): SQLite.SQLiteDatabase {
  if (!db) {
    db = SQLite.openDatabaseSync('CareLog.db');
  }
  return db;
}

const MIGRATIONS = [
  { version: 1, file: require('./migrations/001_create_tables.sql') },
  { version: 2, file: require('./migrations/002_create_fts.sql') },
];

export async function initDatabase(): Promise<void> {
  const database = getDb();

  // Enable WAL mode and foreign keys
  database.execSync('PRAGMA journal_mode = WAL;');
  database.execSync('PRAGMA foreign_keys = ON;');

  // Bootstrap schema_migrations table before running migrations
  database.execSync(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version    INTEGER PRIMARY KEY,
      applied_at TEXT NOT NULL
    );
  `);

  for (const migration of MIGRATIONS) {
    const existing = database.getFirstSync<{ version: number }>(
      'SELECT version FROM schema_migrations WHERE version = ?',
      [migration.version]
    );
    if (!existing) {
      database.execSync(migration.file);
      database.runSync(
        'INSERT INTO schema_migrations (version, applied_at) VALUES (?, ?)',
        [migration.version, new Date().toISOString()]
      );
    }
  }
}
```

### 6.4 visitsRepository.ts

```typescript
// src/db/visitsRepository.ts
import { getDb } from './database';
import { Visit, CreateVisitInput, UpdateVisitInput } from '../types/Visit';
import uuid from 'react-native-uuid';

export const visitsRepository = {

  create(input: CreateVisitInput): Visit {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO visits
        (id, body_part_id, speciality_id, custom_speciality, visit_date, follow_up_date,
         doctor_name, clinic_name, clinic_phone, doctor_fees, currency,
         symptoms, diagnosis, notes, created_at, updated_at)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [id, input.body_part_id, input.speciality_id, input.custom_speciality ?? null,
       input.visit_date, input.follow_up_date ?? null,
       input.doctor_name ?? null, input.clinic_name ?? null, input.clinic_phone ?? null,
       input.doctor_fees ?? null, input.currency ?? 'INR',
       input.symptoms ?? null, input.diagnosis ?? null, input.notes ?? null,
       now, now]
    );
    return { ...input, id, created_at: now, updated_at: now };
  },

  update(id: string, input: UpdateVisitInput): void {
    const db = getDb();
    const now = new Date().toISOString();
    const fields = Object.keys(input)
      .map(k => `${k} = ?`)
      .join(', ');
    const values = [...Object.values(input), now, id];
    db.runSync(`UPDATE visits SET ${fields}, updated_at = ? WHERE id = ?`, values);
  },

  delete(id: string): void {
    getDb().runSync('DELETE FROM visits WHERE id = ?', [id]);
  },

  findById(id: string): Visit | null {
    return getDb().getFirstSync<Visit>(
      'SELECT * FROM visits WHERE id = ?', [id]
    );
  },

  findBySpeciality(bodyPartId: string, specialityId: string): Visit[] {
    return getDb().getAllSync<Visit>(
      `SELECT * FROM visits
       WHERE body_part_id = ? AND speciality_id = ?
       ORDER BY visit_date DESC`,
      [bodyPartId, specialityId]
    );
  },

  findRecent(limit = 5): Visit[] {
    return getDb().getAllSync<Visit>(
      'SELECT * FROM visits ORDER BY visit_date DESC LIMIT ?', [limit]
    );
  },

  countBySpeciality(specialityId: string): number {
    const row = getDb().getFirstSync<{ count: number }>(
      'SELECT COUNT(*) as count FROM visits WHERE speciality_id = ?', [specialityId]
    );
    return row?.count ?? 0;
  },

  search(query: string): Visit[] {
    return getDb().getAllSync<Visit>(
      `SELECT v.* FROM visits v
       JOIN visits_fts fts ON v.id = fts.id
       WHERE visits_fts MATCH ?
       ORDER BY rank`,
      [query + '*']
    );
  },

  getAutocompleteDoctors(partial: string): string[] {
    const rows = getDb().getAllSync<{ doctor_name: string }>(
      `SELECT DISTINCT doctor_name FROM visits
       WHERE doctor_name LIKE ? AND doctor_name IS NOT NULL
       LIMIT 10`,
      [`%${partial}%`]
    );
    return rows.map(r => r.doctor_name);
  },

  getAutocompleteClinics(partial: string): string[] {
    const rows = getDb().getAllSync<{ clinic_name: string }>(
      `SELECT DISTINCT clinic_name FROM visits
       WHERE clinic_name LIKE ? AND clinic_name IS NOT NULL
       LIMIT 10`,
      [`%${partial}%`]
    );
    return rows.map(r => r.clinic_name);
  },
};
```

### 6.5 attachmentsRepository.ts

```typescript
// src/db/attachmentsRepository.ts
import { getDb } from './database';
import { Attachment, CreateAttachmentInput } from '../types/Attachment';
import uuid from 'react-native-uuid';

export const attachmentsRepository = {

  create(input: CreateAttachmentInput): Attachment {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO attachments
        (id, visit_id, type, file_path, file_name, mime_type, size_bytes, thumbnail_path, created_at)
       VALUES (?,?,?,?,?,?,?,?,?)`,
      [id, input.visit_id, input.type, input.file_path, input.file_name,
       input.mime_type, input.size_bytes, input.thumbnail_path ?? null, now]
    );
    return { ...input, id, created_at: now };
  },

  findByVisitId(visitId: string): Attachment[] {
    return getDb().getAllSync<Attachment>(
      'SELECT * FROM attachments WHERE visit_id = ? ORDER BY created_at ASC', [visitId]
    );
  },

  findByType(type: string): Attachment[] {
    return getDb().getAllSync<Attachment>(
      `SELECT a.*, v.doctor_name, v.visit_date, v.speciality_id
       FROM attachments a JOIN visits v ON a.visit_id = v.id
       WHERE a.type = ? ORDER BY a.created_at DESC`,
      [type]
    );
  },

  findAll(): Attachment[] {
    return getDb().getAllSync<Attachment>(
      `SELECT a.*, v.doctor_name, v.visit_date, v.speciality_id
       FROM attachments a JOIN visits v ON a.visit_id = v.id
       ORDER BY a.created_at DESC`
    );
  },

  delete(id: string): void {
    getDb().runSync('DELETE FROM attachments WHERE id = ?', [id]);
  },
};
```

### 6.6 remindersRepository.ts

```typescript
// src/db/remindersRepository.ts
import { getDb } from './database';
import { Reminder } from '../types/Reminder';
import uuid from 'react-native-uuid';

export const remindersRepository = {

  create(visitId: string, followUpDate: string): Reminder {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO reminders (id, visit_id, follow_up_date, is_active, created_at)
       VALUES (?,?,?,1,?)`,
      [id, visitId, followUpDate, now]
    );
    return { id, visit_id: visitId, follow_up_date: followUpDate, is_active: true, created_at: now };
  },

  updateNotificationIds(id: string, d1Id: string, d0Id: string): void {
    getDb().runSync(
      'UPDATE reminders SET notification_id_d1 = ?, notification_id_d0 = ? WHERE id = ?',
      [d1Id, d0Id, id]
    );
  },

  findByVisitId(visitId: string): Reminder | null {
    return getDb().getFirstSync<Reminder>(
      'SELECT r.*, v.doctor_name, v.speciality_id, v.body_part_id FROM reminders r JOIN visits v ON r.visit_id = v.id WHERE r.visit_id = ?',
      [visitId]
    );
  },

  findUpcoming(): Reminder[] {
    const today = new Date().toISOString().split('T')[0];
    return getDb().getAllSync<Reminder>(
      `SELECT r.*, v.doctor_name, v.speciality_id, v.body_part_id
       FROM reminders r JOIN visits v ON r.visit_id = v.id
       WHERE r.follow_up_date >= ? AND r.is_active = 1
       ORDER BY r.follow_up_date ASC`,
      [today]
    );
  },

  findPast(): Reminder[] {
    const today = new Date().toISOString().split('T')[0];
    return getDb().getAllSync<Reminder>(
      `SELECT r.*, v.doctor_name, v.speciality_id, v.body_part_id
       FROM reminders r JOIN visits v ON r.visit_id = v.id
       WHERE r.follow_up_date < ? OR r.is_active = 0
       ORDER BY r.follow_up_date DESC`,
      [today]
    );
  },

  deactivate(id: string): void {
    getDb().runSync('UPDATE reminders SET is_active = 0 WHERE id = ?', [id]);
  },

  delete(id: string): void {
    getDb().runSync('DELETE FROM reminders WHERE id = ?', [id]);
  },
};
```

---

## 7. State Management

### 7.1 visitsStore.ts

```typescript
// src/store/visitsStore.ts
import { create } from 'zustand';
import { Visit, CreateVisitInput, UpdateVisitInput } from '../types/Visit';
import { visitsRepository } from '../db/visitsRepository';

interface VisitsState {
  // Data
  recentVisits: Visit[];
  currentSpecialityVisits: Visit[];
  selectedVisit: Visit | null;
  searchResults: Visit[];
  isLoading: boolean;

  // Actions
  loadRecentVisits: () => void;
  loadVisitsBySpeciality: (bodyPartId: string, specialityId: string) => void;
  loadVisitById: (id: string) => void;
  createVisit: (input: CreateVisitInput) => Visit;
  updateVisit: (id: string, input: UpdateVisitInput) => void;
  deleteVisit: (id: string) => void;
  searchVisits: (query: string) => void;
  clearSearch: () => void;
  getSpecialityCount: (specialityId: string) => number;
  getAutocompleteDoctors: (partial: string) => string[];
  getAutocompleteClinics: (partial: string) => string[];
}

export const useVisitsStore = create<VisitsState>((set, get) => ({
  recentVisits: [],
  currentSpecialityVisits: [],
  selectedVisit: null,
  searchResults: [],
  isLoading: false,

  loadRecentVisits: () => {
    const visits = visitsRepository.findRecent(5);
    set({ recentVisits: visits });
  },

  loadVisitsBySpeciality: (bodyPartId, specialityId) => {
    set({ isLoading: true });
    const visits = visitsRepository.findBySpeciality(bodyPartId, specialityId);
    set({ currentSpecialityVisits: visits, isLoading: false });
  },

  loadVisitById: (id) => {
    const visit = visitsRepository.findById(id);
    set({ selectedVisit: visit });
  },

  createVisit: (input) => {
    const visit = visitsRepository.create(input);
    get().loadRecentVisits();
    return visit;
  },

  updateVisit: (id, input) => {
    visitsRepository.update(id, input);
    get().loadVisitById(id);
  },

  deleteVisit: (id) => {
    visitsRepository.delete(id);
    get().loadRecentVisits();
    set({ selectedVisit: null });
  },

  searchVisits: (query) => {
    if (!query.trim()) { set({ searchResults: [] }); return; }
    const results = visitsRepository.search(query);
    set({ searchResults: results });
  },

  clearSearch: () => set({ searchResults: [] }),

  getSpecialityCount: (specialityId) =>
    visitsRepository.countBySpeciality(specialityId),

  getAutocompleteDoctors: (partial) =>
    visitsRepository.getAutocompleteDoctors(partial),

  getAutocompleteClinics: (partial) =>
    visitsRepository.getAutocompleteClinics(partial),
}));
```

### 7.2 remindersStore.ts

```typescript
// src/store/remindersStore.ts
import { create } from 'zustand';
import { Reminder } from '../types/Reminder';
import { remindersRepository } from '../db/remindersRepository';
import { notificationService } from '../services/notificationService';

interface RemindersState {
  upcoming: Reminder[];
  past: Reminder[];
  load: () => void;
  createReminder: (visitId: string, followUpDate: string) => Promise<void>;
  deactivate: (id: string) => void;
  deleteReminder: (id: string) => void;
}

export const useRemindersStore = create<RemindersState>((set, get) => ({
  upcoming: [],
  past: [],

  load: () => {
    set({
      upcoming: remindersRepository.findUpcoming(),
      past: remindersRepository.findPast(),
    });
  },

  createReminder: async (visitId, followUpDate) => {
    const reminder = remindersRepository.create(visitId, followUpDate);
    const { d1Id, d0Id } = await notificationService.scheduleFollowUp(visitId, followUpDate);
    remindersRepository.updateNotificationIds(reminder.id, d1Id, d0Id);
    get().load();
  },

  deactivate: (id) => {
    remindersRepository.deactivate(id);
    get().load();
  },

  deleteReminder: (id) => {
    remindersRepository.delete(id);
    get().load();
  },
}));
```

### 7.3 settingsStore.ts

```typescript
// src/store/settingsStore.ts
import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface SettingsState {
  currency: string;
  notificationsEnabled: boolean;
  reminderTime: string;           // HH:MM (24hr), default '09:00'
  appLockEnabled: boolean;
  isLoaded: boolean;
  load: () => Promise<void>;
  set: (key: string, value: unknown) => Promise<void>;
}

const STORAGE_KEY = '@CareLog_settings';

export const useSettingsStore = create<SettingsState>((setState) => ({
  currency: 'INR',
  notificationsEnabled: true,
  reminderTime: '09:00',
  appLockEnabled: false,
  isLoaded: false,

  load: async () => {
    const raw = await AsyncStorage.getItem(STORAGE_KEY);
    if (raw) {
      const saved = JSON.parse(raw);
      setState({ ...saved, isLoaded: true });
    } else {
      setState({ isLoaded: true });
    }
  },

  set: async (key, value) => {
    setState((prev) => {
      const updated = { ...prev, [key]: value };
      AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
      return updated;
    });
  },
}));
```

---

## 8. Navigation Architecture

### 8.1 Root Layout — app/_layout.tsx

```typescript
// app/_layout.tsx
import { useEffect } from 'react';
import { Stack } from 'expo-router';
import { PaperProvider, MD3LightTheme } from 'react-native-paper';
import { initDatabase } from '../src/db/database';
import { seedIfNeeded } from '../src/db/seed';
import { useSettingsStore } from '../src/store/settingsStore';

const theme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    primary: '#1A6B8A',
    secondary: '#2E9E6B',
    tertiary: '#E67E22',
  },
};

export default function RootLayout() {
  const loadSettings = useSettingsStore(s => s.load);

  useEffect(() => {
    (async () => {
      await initDatabase();
      await seedIfNeeded();
      await loadSettings();
    })();
  }, []);

  return (
    <PaperProvider theme={theme}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="speciality/[bodyPartId]" options={{ title: 'Select Speciality' }} />
        <Stack.Screen name="visits/[specialityId]" options={{ title: 'Visits' }} />
        <Stack.Screen name="visits/[visitId]" options={{ title: 'Visit Detail' }} />
        <Stack.Screen name="visits/new" options={{ title: 'Add Visit', presentation: 'modal' }} />
        <Stack.Screen name="visits/edit/[visitId]" options={{ title: 'Edit Visit', presentation: 'modal' }} />
        <Stack.Screen name="search" options={{ title: 'Search' }} />
      </Stack>
    </PaperProvider>
  );
}
```

### 8.2 Tab Layout — app/(tabs)/_layout.tsx

```typescript
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useTheme } from 'react-native-paper';

export default function TabLayout() {
  const theme = useTheme();

  return (
    <Tabs screenOptions={{
      tabBarActiveTintColor: theme.colors.primary,
      tabBarInactiveTintColor: '#9E9E9E',
      tabBarStyle: { backgroundColor: '#FFFFFF', borderTopColor: '#E0E0E0' },
      headerStyle: { backgroundColor: theme.colors.primary },
      headerTintColor: '#FFFFFF',
    }}>
      <Tabs.Screen name="index"     options={{ title: 'Home',      tabBarIcon: ({ color }) => <MaterialCommunityIcons name="home-heart"          size={24} color={color} /> }} />
      <Tabs.Screen name="reports"   options={{ title: 'Reports',   tabBarIcon: ({ color }) => <MaterialCommunityIcons name="folder-multiple-image" size={24} color={color} /> }} />
      <Tabs.Screen name="reminders" options={{ title: 'Reminders', tabBarIcon: ({ color }) => <MaterialCommunityIcons name="bell-outline"         size={24} color={color} /> }} />
      <Tabs.Screen name="settings"  options={{ title: 'Settings',  tabBarIcon: ({ color }) => <MaterialCommunityIcons name="cog-outline"          size={24} color={color} /> }} />
    </Tabs>
  );
}
```

### 8.3 Route → Screen Mapping

| File Path | Route | Screen |
|---|---|---|
| `app/(tabs)/index.tsx` | `/` | Home — Body Part Selection |
| `app/(tabs)/reports.tsx` | `/reports` | Reports Hub |
| `app/(tabs)/reminders.tsx` | `/reminders` | Reminders |
| `app/(tabs)/settings.tsx` | `/settings` | Settings |
| `app/speciality/[bodyPartId].tsx` | `/speciality/:bodyPartId` | Speciality Selection |
| `app/visits/[specialityId].tsx` | `/visits/:specialityId?bodyPartId=...` | Visit List |
| `app/visits/[visitId].tsx` | `/visits/:visitId` | Visit Detail |
| `app/visits/new.tsx` | `/visits/new?bodyPartId=...&specialityId=...` | New Visit Entry |
| `app/visits/edit/[visitId].tsx` | `/visits/edit/:visitId` | Edit Visit |
| `app/search.tsx` | `/search` | Global Search |

---

## 9. Mock Seed Data

```typescript
// src/db/seed.ts
// Insert on first launch only. Checked via AsyncStorage key '@CareLog_seeded'.

import AsyncStorage from '@react-native-async-storage/async-storage';
import { visitsRepository } from './visitsRepository';
import { attachmentsRepository } from './attachmentsRepository';
import { remindersRepository } from './remindersRepository';

const SEED_KEY = '@CareLog_seeded_v1';

export async function seedIfNeeded(): Promise<void> {
  const seeded = await AsyncStorage.getItem(SEED_KEY);
  if (seeded) return;

  const MOCK_VISITS = [
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
      follow_up_date: null,
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
      follow_up_date: null,
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

  for (const v of MOCK_VISITS) {
    visitsRepository.create(v as any);
  }

  // Seed a reminder for the ENT visit
  const ent = visitsRepository.findRecent(10).find(v => v.speciality_id === 'ENT');
  if (ent?.follow_up_date) {
    remindersRepository.create(ent.id, ent.follow_up_date);
  }

  const cardio = visitsRepository.findRecent(10).find(v => v.speciality_id === 'CARDIOLOGY');
  if (cardio?.follow_up_date) {
    remindersRepository.create(cardio.id, cardio.follow_up_date);
  }

  await AsyncStorage.setItem(SEED_KEY, 'true');
}
```

---

## 10. Screen Specifications

---

### 10.1 Home Screen — Body Part Selection

**File:** `app/(tabs)/index.tsx`  
**Route:** `/`

#### Layout

```
┌─────────────────────────────────┐
│  🏥 CareLog          🔍  🔔2  │  ← Header with search + notification bell
├─────────────────────────────────┤
│  ┌─────────────────────────┐    │
│  │  BODY MAP (SVG/Grid)    │    │  ← Interactive body map (SVG preferred) OR
│  │  [HEAD]  [CHEST]        │    │     fallback 2-column icon grid
│  │  [ABDOMEN] [BACK]       │    │
│  │  [ARMS] [LEGS]          │    │
│  │  [SKIN] [GENERAL]       │    │
│  └─────────────────────────┘    │
├─────────────────────────────────┤
│  Recent Visits                  │  ← Section header
│  ┌──────┐ ┌──────┐ ┌──────┐    │
│  │ Card │ │ Card │ │ Card │    │  ← Horizontal FlatList
│  └──────┘ └──────┘ └──────┘    │
└─────────────────────────────────┘
```

#### Implementation Notes

- Body map: Render as a **2-column grid of Pressable cards** (each showing icon + label + description). SVG integration is optional for v1 prototype; the grid approach is fully functional.
- On body part press: `router.push('/speciality/' + bodyPart.id)`
- Recent visits strip: calls `visitsStore.loadRecentVisits()` on mount
- Notification badge: count from `remindersStore.upcoming.length`
- Search icon: `router.push('/search')`
- Empty state: shown below recent visits strip when `recentVisits.length === 0`

#### Component Tree

```
HomeScreen
  └── SafeAreaView
        ├── Appbar.Header (title + search icon + bell icon with badge)
        ├── ScrollView
        │     ├── BodyPartGrid (2-column FlatList of BodyPartCard)
        │     │     └── BodyPartCard (Pressable → navigate to speciality)
        │     ├── SectionHeader ("Recent Visits")
        │     └── RecentVisitsList (horizontal FlatList)
        │           └── VisitCard (compact horizontal card)
        └── EmptyState (if zero visits)
```

---

### 10.2 Speciality Selection Screen

**File:** `app/speciality/[bodyPartId].tsx`  
**Route:** `/speciality/:bodyPartId`  
**Params:** `bodyPartId: BodyPartId`

#### Layout

```
┌─────────────────────────────────┐
│  ← Head & Brain                 │  ← Header shows body part label
├─────────────────────────────────┤
│  [Show All]  ← Toggle chip      │
├─────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐    │
│  │🧠 Neurology│  │👂 ENT     │   │  ← 2-column FlatList
│  │  3 visits │  │  1 visit │   │
│  └──────────┘  └──────────┘    │
│  ┌──────────┐  ┌──────────┐    │
│  │👁 Ophthal │  │🦷 Dental  │   │
│  │  0 visits │  │  0 visits│   │
│  └──────────┘  └──────────┘    │
└─────────────────────────────────┘
                              [ + ]  ← FAB
```

#### Implementation Notes

- Filter specialities using `BODY_SPECIALITY_MAP[bodyPartId]`; "Show All" chip removes filter
- Visit count per card: `visitsStore.getSpecialityCount(specialityId)`
- On card tap: `router.push({ pathname: '/visits/' + specialityId, params: { bodyPartId } })`
- FAB: `router.push({ pathname: '/visits/new', params: { bodyPartId, specialityId: null } })`

---

### 10.3 Visit List Screen

**File:** `app/visits/[specialityId].tsx`  
**Route:** `/visits/:specialityId?bodyPartId=...`  
**Params:** `specialityId: SpecialityId`, `bodyPartId: BodyPartId`

#### Layout

```
┌─────────────────────────────────┐
│  ← ENT  •  Head & Brain        │  ← Header: speciality + body part
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │ Dr. Priya Sharma          │  │  ← VisitCard
│  │ 10 Apr 2026               │  │
│  │ Allergic Rhinitis         │  │
│  │ Follow-up: 15 Jun 2026 🟡 │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ Dr. Anita Joshi           │  │
│  │ 22 Jan 2026               │  │
│  └───────────────────────────┘  │
│                                 │
│        (EmptyState if 0)        │
└─────────────────────────────────┘
                              [ + ]  ← FAB → /visits/new
```

#### Implementation Notes

- On mount: `visitsStore.loadVisitsBySpeciality(bodyPartId, specialityId)`
- On visit card tap: `router.push('/visits/' + visit.id)`
- FAB: `router.push({ pathname: '/visits/new', params: { bodyPartId, specialityId } })`
- Pull-to-refresh calls `loadVisitsBySpeciality` again

---

### 10.4 Visit Entry Screen

**File:** `app/visits/new.tsx` and `app/visits/edit/[visitId].tsx`  
**Route:** `/visits/new?bodyPartId=...&specialityId=...` or `/visits/edit/:visitId`  
**Presentation:** Modal

#### Layout (Form Sections — all collapsible)

```
┌─────────────────────────────────┐
│  ✕ Add Visit          [Save]    │  ← Modal header
├─────────────────────────────────┤
│  ▼ Visit Info                   │  ← Collapsible section
│    Visit Date:    [10 May 2026] │
│    Follow-up:     [Select date] │
│    Symptoms:      [____________]│
│                   [____________]│
├─────────────────────────────────┤
│  ▼ Doctor Details               │
│    Doctor Name:   [____________]│
│    Speciality:    [ENT ▼]       │
│    Clinic Name:   [____________]│
│    Clinic Phone:  [____________]│
│    Doctor Fees:   ₹[__________] │
├─────────────────────────────────┤
│  ▼ Diagnosis                    │
│    [________________________________]│
├─────────────────────────────────┤
│  ▼ Attachments                  │
│    Prescription  [📷 Add] [img] │
│    Medicines     [📷 Add]       │
│    Bill          [📷 Add]       │
│    Reports       [📷 Add]       │
├─────────────────────────────────┤
│  ▼ Notes                        │
│    [________________________________]│
└─────────────────────────────────┘
```

#### Form State (local React state — not store)

```typescript
const [form, setForm] = useState<Partial<CreateVisitInput>>({
  body_part_id: params.bodyPartId,
  speciality_id: params.specialityId,
  visit_date: format(new Date(), 'yyyy-MM-dd'),
  currency: 'INR',
});
```

#### Functional Requirements

- FR-FORM-01: `visit_date` required; all other fields optional
- FR-FORM-02: Autocomplete for `doctor_name` and `clinic_name` via store methods
- FR-FORM-03: Date pickers use `@react-native-community/datetimepicker` via Expo
- FR-FORM-04: Each attachment type has its own upload row; tapping opens Action Sheet: "Take Photo" / "Choose from Gallery" / "Choose PDF"
- FR-FORM-05: Thumbnail preview shown inline after upload; × to remove
- FR-FORM-06: Save calls `visitsStore.createVisit(form)` → if `follow_up_date` set, calls `remindersStore.createReminder(visitId, follow_up_date)` → `router.back()`
- FR-FORM-07: Edit mode: pre-fill form from `visitsStore.selectedVisit`; save calls `visitsStore.updateVisit(id, form)`
- FR-FORM-08: Auto-save draft to SQLite `visit_drafts` every 30 seconds using `setInterval`

---

### 10.5 Visit Detail Screen

**File:** `app/visits/[visitId].tsx`  
**Route:** `/visits/:visitId`

#### Layout

```
┌─────────────────────────────────┐
│  ← Visit Detail    [✏️]  [🗑️]   │
├─────────────────────────────────┤
│  🏥 ENT  •  Head & Brain        │  ← Chips
│  📅 10 April 2026               │
│  🔁 Follow-up: 15 June 2026     │  ← Badge: "46 days left" (green) or "Overdue" (red)
├─────────────────────────────────┤
│  Doctor                         │
│  Dr. Priya Sharma               │
│  Sharma ENT Clinic              │
│  📞 9981234567     [Call]       │
│  💰 ₹500                        │
├─────────────────────────────────┤
│  Symptoms                       │
│  Blocked nose, difficulty...    │
├─────────────────────────────────┤
│  Diagnosis                      │
│  Allergic Rhinitis...           │
├─────────────────────────────────┤
│  Prescriptions (2)              │
│  [img][img]                     │
├─────────────────────────────────┤
│  Notes                          │
│  Avoid cold beverages...        │
└─────────────────────────────────┘
```

#### Implementation Notes

- On mount: `visitsStore.loadVisitById(visitId)` + `attachmentsRepository.findByVisitId(visitId)`
- Edit button: `router.push('/visits/edit/' + visitId)`
- Delete button: Alert confirmation → `visitsStore.deleteVisit(visitId)` + delete all attachment files via `fileService` → `router.back()`
- Call button: `Linking.openURL('tel:' + clinic_phone)`
- Attachment tap: full-screen viewer (image or PDF)
- Sections with null data are hidden entirely

---

### 10.6 Reports Hub Screen

**File:** `app/(tabs)/reports.tsx`

#### Layout

```
┌─────────────────────────────────┐
│  Reports Hub          🔍        │
├─────────────────────────────────┤
│  [All][Prescription][Medicine]  │  ← Filter chips (horizontal scroll)
│  [Bill][Report]                 │
├─────────────────────────────────┤
│  Sort: Newest ▼                 │
├─────────────────────────────────┤
│  ┌─────┐ ┌─────┐ ┌─────┐      │
│  │ img │ │ img │ │ PDF │      │  ← Masonry grid
│  │ENT  │ │Ortho│ │Cardio│     │
│  │Apr  │ │Jan  │ │Mar  │      │
│  └─────┘ └─────┘ └─────┘      │
└─────────────────────────────────┘
```

#### Implementation Notes

- On mount: load all attachments from `attachmentsRepository.findAll()`
- Filter chips update displayed list (local state filter, no DB re-query)
- Sort: `newest` / `oldest` / `by_type` — local sort on already-loaded array
- Long-press card: Action Sheet — Share / Save to Device / Delete
- Tap: full-screen viewer

---

### 10.7 Reminders Screen

**File:** `app/(tabs)/reminders.tsx`

#### Layout

```
┌─────────────────────────────────┐
│  Reminders                      │
├─────────────────────────────────┤
│  UPCOMING                       │
│  ┌───────────────────────────┐  │
│  │ Dr. Priya Sharma — ENT    │  │
│  │ Follow-up: 15 Jun 2026    │  │
│  │ 🟢 46 days left            │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ Dr. Ramesh Gupta — Cardio │  │
│  │ Follow-up: 22 Jun 2026    │  │
│  │ 🟢 53 days left            │  │
│  └───────────────────────────┘  │
├─────────────────────────────────┤
│  PAST                           │
│  ┌───────────────────────────┐  │
│  │ Dr. Suresh Mehta — Ortho  │  │
│  │ Follow-up: 10 Jan 2026    │  │
│  │ 🔴 Overdue                 │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

#### Implementation Notes

- On mount: `remindersStore.load()`
- Tap card: navigate to linked visit detail
- Swipe-left on card: Action Sheet — "Reschedule" (date picker) / "Delete Reminder"
- Empty state for each section independently

---

### 10.8 Settings Screen

**File:** `app/(tabs)/settings.tsx`

#### Sections and Controls

| Section | Setting | Control Type |
|---|---|---|
| General | Currency | SegmentedButtons: ₹ INR / $ USD |
| Notifications | Enable reminders | Switch |
| Notifications | Reminder time | Time picker (HH:MM) |
| Data | Export all data | Button → generates ZIP via exportService |
| Data | Storage used | Display only (computed from file sizes) |
| Data | Delete all data | Destructive button → confirmation Alert |
| About | App version | Display: "CareLog v1.0.0" |
| About | Build | Display: Expo build info |

---

### 10.9 Global Search Screen

**File:** `app/search.tsx`

#### Layout

```
┌─────────────────────────────────┐
│  ← 🔍 Search visits...          │  ← Search bar (auto-focused)
├─────────────────────────────────┤
│  Results for "sharma"           │
│  ┌───────────────────────────┐  │
│  │ Dr. Priya Sharma — ENT    │  │
│  │ 10 Apr 2026  •  Head & Brain│
│  │ Allergic Rhinitis          │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ Sharma ENT Clinic         │  │
│  │ 22 Jan 2026  •  ...        │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

#### Implementation Notes

- Debounce search input: 300ms before calling `visitsStore.searchVisits(query)`
- Uses SQLite FTS5 full-text search across `doctor_name`, `clinic_name`, `symptoms`, `diagnosis`, `notes`
- Tap result → `router.push('/visits/' + result.id)`
- Empty query: show recent visits instead
- No results: EmptyState component with hint text

---

## 11. Shared UI Components

### 11.1 VisitCard

```typescript
interface VisitCardProps {
  visit: Visit;
  onPress: () => void;
  compact?: boolean;   // true = horizontal strip; false = full list card
}
```

Renders: doctor name, speciality chip, visit date, diagnosis (truncated), follow-up badge (if set).

### 11.2 SpecialityCard

```typescript
interface SpecialityCardProps {
  speciality: Speciality;
  visitCount: number;
  onPress: () => void;
}
```

Renders: icon (coloured), label, visit count badge, card with left colour border.

### 11.3 AttachmentThumbnail

```typescript
interface AttachmentThumbnailProps {
  attachment: Attachment;
  onPress: () => void;
  onDelete?: () => void;
  size?: number;   // Default: 100
}
```

Renders: image thumbnail OR pdf icon; optional delete (×) overlay.

### 11.4 AttachmentGrid

```typescript
interface AttachmentGridProps {
  attachments: Attachment[];
  type: AttachmentType;
  onAdd: () => void;
  onDelete: (id: string) => void;
  onView: (attachment: Attachment) => void;
  maxFiles: number;
}
```

Renders: grid of AttachmentThumbnail + "Add" card (if under limit).

### 11.5 EmptyState

```typescript
interface EmptyStateProps {
  icon: string;          // MaterialCommunityIcons name
  title: string;
  subtitle?: string;
  actionLabel?: string;
  onAction?: () => void;
}
```

### 11.6 SectionHeader

```typescript
interface SectionHeaderProps {
  title: string;
  actionLabel?: string;
  onAction?: () => void;
}
```

### 11.7 ReminderCard

```typescript
interface ReminderCardProps {
  reminder: Reminder;
  onPress: () => void;
  onReschedule: (newDate: string) => void;
  onDelete: () => void;
}
```

Renders: doctor name, speciality, follow-up date, days-remaining badge (green = future, red = past).

---

## 12. Design System

```typescript
// Design tokens — use with React Native Paper theme or StyleSheet

export const Colors = {
  primary:     '#1A6B8A',   // Teal-blue — primary actions, headers
  secondary:   '#2E9E6B',   // Green — positive states, success
  accent:      '#E67E22',   // Amber — warnings, follow-ups
  error:       '#E53935',   // Red — errors, overdue, destructive
  background:  '#F5F7FA',   // Off-white — screen backgrounds
  surface:     '#FFFFFF',   // Cards, modals
  border:      '#E0E0E0',   // Card borders, dividers
  textPrimary: '#212121',   // Main text
  textSecondary:'#757575',  // Labels, captions
  textDisabled:'#BDBDBD',   // Placeholders
};

export const Spacing = {
  xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48,
};

export const BorderRadius = {
  sm: 6, md: 12, lg: 16, xl: 24, full: 999,
};

export const Typography = {
  h1:      { fontSize: 24, fontWeight: '700' as const, color: Colors.textPrimary },
  h2:      { fontSize: 20, fontWeight: '600' as const, color: Colors.textPrimary },
  h3:      { fontSize: 16, fontWeight: '600' as const, color: Colors.textPrimary },
  body:    { fontSize: 14, fontWeight: '400' as const, color: Colors.textPrimary },
  caption: { fontSize: 12, fontWeight: '400' as const, color: Colors.textSecondary },
  label:   { fontSize: 12, fontWeight: '500' as const, color: Colors.textSecondary },
};

export const Shadow = {
  card: {
    shadowColor: '#000', shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08, shadowRadius: 4, elevation: 2,
  },
};
```

---

## 13. Acceptance Criteria

The prototype is complete when ALL of the following pass:

### Navigation
- [ ] AC-N01: Tapping any body part on Home navigates to Speciality screen showing correct filtered list
- [ ] AC-N02: Tapping a speciality navigates to Visit List for that combination
- [ ] AC-N03: Tapping a visit card navigates to Visit Detail
- [ ] AC-N04: FAB on Visit List opens Add Visit modal
- [ ] AC-N05: All 4 bottom tabs are navigable and render without crashing
- [ ] AC-N06: Back navigation works on all stack screens

### Data — Seed
- [ ] AC-D01: On fresh install, 5 mock visits are visible across the app
- [ ] AC-D02: Seed runs only once; re-launching does not duplicate records
- [ ] AC-D03: Recent Visits strip on Home shows the 3–5 most recent seeded visits

### Data — CRUD
- [ ] AC-D04: Creating a visit with only visit_date saves successfully and appears in Visit List
- [ ] AC-D05: Creating a visit with all fields saves all values correctly
- [ ] AC-D06: Editing a visit pre-fills all fields; saving updates the record
- [ ] AC-D07: Deleting a visit removes it from Visit List and Visit Detail is no longer accessible
- [ ] AC-D08: Visit count badge on Speciality card updates after add/delete

### Search
- [ ] AC-S01: Typing "sharma" returns visits with Dr. Priya Sharma
- [ ] AC-S02: Typing "knee" returns the orthopaedic visit (symptom match)
- [ ] AC-S03: Empty search shows recent visits
- [ ] AC-S04: No results shows EmptyState component

### Attachments
- [ ] AC-A01: Camera and gallery pickers open on both iOS and Android
- [ ] AC-A02: Selected image appears as thumbnail in form
- [ ] AC-A03: Tapping × removes the thumbnail from form state
- [ ] AC-A04: Saved visit displays attachments in detail screen
- [ ] AC-A05: Tapping attachment thumbnail opens full-screen viewer

### Reminders
- [ ] AC-R01: Setting a follow-up date on a visit creates a reminder entry
- [ ] AC-R02: Seeded ENT and Cardiology reminders appear in Reminders tab under "Upcoming"
- [ ] AC-R03: Reminder card shows correct days-remaining count
- [ ] AC-R04: Tapping reminder card navigates to linked visit detail

### Settings
- [ ] AC-SET01: Currency change persists after app restart
- [ ] AC-SET02: "Delete All Data" after confirmation removes all visits from every screen
- [ ] AC-SET03: Storage used figure updates after adding visits with attachments

### Empty States
- [ ] AC-E01: Home screen shows EmptyState when zero visits exist (after Delete All Data)
- [ ] AC-E02: Visit List shows EmptyState for a speciality with no visits
- [ ] AC-E03: Reminders tab shows EmptyState when no reminders exist
- [ ] AC-E04: Reports Hub shows EmptyState when no attachments exist

---

## 14. Family Functionality Extension

> **This section is additive to v1.0.** Everything in Sections 1–13 still applies. Where this section changes an existing artifact (e.g., the `visits` table, the Home screen, the root layout), the change is described explicitly. Build this extension only after the v1.0 prototype runs successfully.

### 14.1 Overview & Navigation Model

CareLog now stores health records for **multiple family members**. Each member owns an independent set of visits (and therefore attachments and reminders, which hang off visits). The two-layer navigation (Body Part → Speciality) is unchanged; a new **member layer** is added in front of it.

**Navigation model — Family Home + drill-in:**

```
Tab 1: FAMILY HOME  (app/(tabs)/index.tsx — REWRITTEN)
   │  Lists all members as cards + family summary (upcoming follow-ups).
   │  "＋ Add" → /members/new
   ▼  tap a member card
MEMBER HOME  (app/member/[memberId].tsx — NEW; body-map grid moved here)
   │  Header = member name. 2-column body-part grid + that member's recent visits.
   ▼  tap a body part
SPECIALITY  (app/speciality/[bodyPartId].tsx — now carries memberId)
   ▼
VISIT LIST  (app/visits/list/[specialityId].tsx — filtered by member + speciality)
   ▼
VISIT DETAIL / NEW / EDIT  (all carry & persist member_id)
```

**Key principles:**
- `memberId` is threaded through the visit flow as a **route param** (not global mutable state) so deep navigation is unambiguous. A `memberStore` holds the member list and family summary for the dashboard.
- Every visit belongs to exactly one member (`visits.member_id`, NOT NULL after migration).
- Reminders and attachments inherit their member through their parent visit (JOIN), so no schema change is needed on those tables.
- The Reminders and Reports tabs remain **family-wide** but now show a **member-name badge** on each row.
- A default member **"Self"** is created automatically by migration; all pre-existing v1.0 visits are backfilled to it.

### 14.2 Constants

```typescript
// src/constants/members.ts
export type RelationshipType = 'SELF' | 'SPOUSE' | 'CHILD' | 'PARENT' | 'SIBLING' | 'OTHER';
export type Gender = 'MALE' | 'FEMALE' | 'OTHER';

export const RELATIONSHIPS: { id: RelationshipType; label: string; icon: string }[] = [
  { id: 'SELF',    label: 'Self',    icon: 'account'        },
  { id: 'SPOUSE',  label: 'Spouse',  icon: 'account-heart'  },
  { id: 'CHILD',   label: 'Child',   icon: 'baby-face-outline' },
  { id: 'PARENT',  label: 'Parent',  icon: 'account-supervisor' },
  { id: 'SIBLING', label: 'Sibling', icon: 'account-multiple' },
  { id: 'OTHER',   label: 'Other',   icon: 'account-question' },
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
```

### 14.3 TypeScript Types

```typescript
// src/types/Member.ts
import { RelationshipType, Gender } from '../constants/members';

export interface Member {
  id: string;                 // UUID v4
  name: string;
  relationship: RelationshipType;
  date_of_birth?: string;     // YYYY-MM-DD (age computed client-side)
  gender?: Gender;
  color: string;              // avatar color (hex)
  created_at: string;         // ISO 8601
  updated_at: string;         // ISO 8601

  // Computed/joined for dashboard (populated by membersRepository.findAllWithStats):
  visit_count?: number;
  next_follow_up?: string | null;   // earliest upcoming follow_up_date among member's visits
  last_visit_date?: string | null;
}

export type CreateMemberInput =
  Omit<Member, 'id' | 'created_at' | 'updated_at' | 'visit_count' | 'next_follow_up' | 'last_visit_date'>;
export type UpdateMemberInput = Partial<CreateMemberInput>;

export interface FamilySummary {
  totalMembers: number;
  totalVisits: number;
  upcomingFollowUps: {
    visit_id: string;
    member_id: string;
    member_name: string;
    member_color: string;
    speciality_id: string;
    doctor_name?: string;
    follow_up_date: string;
  }[];
}
```

**Change to `src/types/Visit.ts`** — add `member_id`:

```typescript
export interface Visit {
  id: string;
  member_id: string;          // NEW — owning family member (UUID)
  body_part_id: BodyPartId;
  // ...all existing fields unchanged...
}
```
`CreateVisitInput` (the `Omit<...>`) automatically gains `member_id` since it is not in the omit list — callers must now supply it.

### 14.4 Database Changes

**New migration `src/db/migrations/003_family.sql`** (wire as version 3 in `database.ts` `MIGRATIONS` array):

```sql
CREATE TABLE IF NOT EXISTS members (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  relationship  TEXT NOT NULL DEFAULT 'OTHER',
  date_of_birth TEXT,
  gender        TEXT,
  color         TEXT NOT NULL DEFAULT '#1A6B8A',
  created_at    TEXT NOT NULL,
  updated_at    TEXT NOT NULL
);

-- Add owning member to visits (nullable at first so existing rows survive ALTER).
ALTER TABLE visits ADD COLUMN member_id TEXT REFERENCES members(id);

CREATE INDEX IF NOT EXISTS idx_visits_member ON visits(member_id);

-- Auto-create the default "Self" member with a fixed id.
INSERT OR IGNORE INTO members (id, name, relationship, color, created_at, updated_at)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'Self', 'SELF', '#1A6B8A',
  '2026-06-01T00:00:00.000Z', '2026-06-01T00:00:00.000Z'
);

-- Backfill all pre-existing visits to the default member.
UPDATE visits
   SET member_id = '11111111-1111-1111-1111-111111111111'
 WHERE member_id IS NULL;
```

> **Notes**
> - SQLite cannot add a `NOT NULL` column without a default to a populated table, so `member_id` is added nullable and immediately backfilled. The application layer (repositories) treats it as required going forward.
> - Member deletion cascades to visits/attachments/reminders **in the repository** (explicit transaction), not via the FK clause — SQLite FK cascade on an `ALTER`-added column is unreliable across connections. See 14.5.

### 14.5 Repositories

**New `src/db/membersRepository.ts`:**

```typescript
import { getDb } from './database';
import { Member, CreateMemberInput, UpdateMemberInput, FamilySummary } from '../types/Member';
import uuid from 'react-native-uuid';

export const membersRepository = {
  create(input: CreateMemberInput): Member {
    const db = getDb();
    const id = uuid.v4() as string;
    const now = new Date().toISOString();
    db.runSync(
      `INSERT INTO members (id, name, relationship, date_of_birth, gender, color, created_at, updated_at)
       VALUES (?,?,?,?,?,?,?,?)`,
      [id, input.name, input.relationship, input.date_of_birth ?? null,
       input.gender ?? null, input.color, now, now]
    );
    return { ...input, id, created_at: now, updated_at: now };
  },

  update(id: string, input: UpdateMemberInput): void {
    const db = getDb();
    const now = new Date().toISOString();
    const fields = Object.keys(input).map(k => `${k} = ?`).join(', ');
    db.runSync(`UPDATE members SET ${fields}, updated_at = ? WHERE id = ?`,
      [...Object.values(input), now, id]);
  },

  // Cascade delete: member → their visits → attachments & reminders of those visits.
  delete(id: string): void {
    const db = getDb();
    db.execSync('BEGIN');
    try {
      db.runSync(
        `DELETE FROM attachments WHERE visit_id IN (SELECT id FROM visits WHERE member_id = ?)`, [id]);
      db.runSync(
        `DELETE FROM reminders   WHERE visit_id IN (SELECT id FROM visits WHERE member_id = ?)`, [id]);
      db.runSync(`DELETE FROM visits  WHERE member_id = ?`, [id]);
      db.runSync(`DELETE FROM members WHERE id = ?`, [id]);
      db.execSync('COMMIT');
    } catch (e) {
      db.execSync('ROLLBACK');
      throw e;
    }
  },

  findById(id: string): Member | null {
    return getDb().getFirstSync<Member>('SELECT * FROM members WHERE id = ?', [id]);
  },

  // Members + per-member stats for the Family Home dashboard.
  findAllWithStats(): Member[] {
    const today = new Date().toISOString().split('T')[0];
    return getDb().getAllSync<Member>(
      `SELECT m.*,
              (SELECT COUNT(*) FROM visits v WHERE v.member_id = m.id) AS visit_count,
              (SELECT MAX(v.visit_date) FROM visits v WHERE v.member_id = m.id) AS last_visit_date,
              (SELECT MIN(v.follow_up_date) FROM visits v
                 WHERE v.member_id = m.id AND v.follow_up_date >= ?) AS next_follow_up
         FROM members m
        ORDER BY (m.relationship = 'SELF') DESC, m.created_at ASC`,
      [today]
    );
  },

  getFamilySummary(): FamilySummary {
    const db = getDb();
    const today = new Date().toISOString().split('T')[0];
    const totals = db.getFirstSync<{ members: number; visits: number }>(
      `SELECT (SELECT COUNT(*) FROM members) AS members,
              (SELECT COUNT(*) FROM visits)  AS visits`
    );
    const upcoming = db.getAllSync<any>(
      `SELECT v.id AS visit_id, v.member_id, m.name AS member_name, m.color AS member_color,
              v.speciality_id, v.doctor_name, v.follow_up_date
         FROM visits v JOIN members m ON v.member_id = m.id
        WHERE v.follow_up_date >= ?
        ORDER BY v.follow_up_date ASC`,
      [today]
    );
    return {
      totalMembers: totals?.members ?? 0,
      totalVisits: totals?.visits ?? 0,
      upcomingFollowUps: upcoming,
    };
  },
};
```

**Changes to `src/db/visitsRepository.ts`:**
- `create(input)` — add `member_id` to the INSERT column list and values (`input.member_id`).
- `findRecent(limit)` → add `findRecentByMember(memberId, limit)` that adds `WHERE member_id = ?`.
- `findBySpeciality(bodyPartId, specialityId)` → add optional `memberId` param: `WHERE member_id = ? AND body_part_id = ? AND speciality_id = ?`.
- `countBySpeciality(specialityId)` → add `countBySpecialityForMember(memberId, specialityId)` for the per-member speciality badges.
- The existing family-wide methods (`findAll`, `search`) stay; search results should JOIN members to show a member badge (add `m.name AS member_name, m.color AS member_color`).

### 14.6 State Management

**New `src/store/memberStore.ts`:**

```typescript
import { create } from 'zustand';
import { Member, CreateMemberInput, UpdateMemberInput, FamilySummary } from '../types/Member';
import { membersRepository } from '../db/membersRepository';
import { MEMBER_COLORS } from '../constants/members';

interface MemberState {
  members: Member[];
  summary: FamilySummary | null;
  loadMembers: () => void;
  loadSummary: () => void;
  createMember: (input: Omit<CreateMemberInput, 'color'>) => Member;  // color auto-assigned
  updateMember: (id: string, input: UpdateMemberInput) => void;
  deleteMember: (id: string) => void;
  getMember: (id: string) => Member | undefined;
}

export const useMemberStore = create<MemberState>((set, get) => ({
  members: [],
  summary: null,

  loadMembers: () => set({ members: membersRepository.findAllWithStats() }),
  loadSummary: () => set({ summary: membersRepository.getFamilySummary() }),

  createMember: (input) => {
    const color = MEMBER_COLORS[get().members.length % MEMBER_COLORS.length];
    const member = membersRepository.create({ ...input, color });
    get().loadMembers();
    return member;
  },

  updateMember: (id, input) => { membersRepository.update(id, input); get().loadMembers(); },
  deleteMember: (id) => { membersRepository.delete(id); get().loadMembers(); get().loadSummary(); },
  getMember: (id) => get().members.find(m => m.id === id),
}));
```

**Changes to `src/store/visitsStore.ts`:**
- `loadRecentVisits()` → `loadRecentVisitsForMember(memberId)` (keep family-wide variant if needed elsewhere).
- `loadVisitsBySpeciality(bodyPartId, specialityId)` → accept `memberId` and pass through.
- `createVisit(input)` — `input` now includes `member_id`; after create, refresh the member-scoped recent list and trigger `memberStore.loadSummary()`.
- `getSpecialityCount` → `getSpecialityCountForMember(memberId, specialityId)`.

**Add to `src/utils/dateUtils.ts`:** `computeAge(dob: string): number` — returns whole years from a `YYYY-MM-DD` DOB to today.

### 14.7 Navigation Changes

**`app/_layout.tsx`** — register the new routes inside the `<Stack>` (in addition to the existing seven):

```tsx
<Stack.Screen name="member/[memberId]"        options={{ headerShown: false }} />
<Stack.Screen name="members/new"              options={{ title: 'Add Member',  presentation: 'modal' }} />
<Stack.Screen name="members/edit/[memberId]"  options={{ title: 'Edit Member', presentation: 'modal' }} />
```

`member/[memberId]` sets `headerShown: false` because the Member Home renders its own `Stack.Screen` header (member name + search/bell), exactly like the v1 Home did.

**`app/(tabs)/_layout.tsx`** — Tab 1 label/icon change only:
- `index` tab: `title: 'Family'`, icon `account-group` (was `'Home'` / `home-heart`). The other three tabs are unchanged.

### 14.8 Screen Specifications

#### 14.8.1 Family Home — `app/(tabs)/index.tsx` (REWRITE)

```
┌─────────────────────────────────┐
│  My Family            ＋ Add    │  ← header: title + add-member action
├─────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐       │
│  │ 👤       │  │ 👤       │      │  ← MemberCard (2-col grid)
│  │ Rahul    │  │ Priya    │      │     avatar circle in member.color
│  │ Self·32y │  │ Spouse   │      │     name · relationship · age
│  │ 4 visits │  │ 2 visits │      │     visit_count
│  │ ⏰ Jun 15 │  │ —        │      │     next_follow_up (or em-dash)
│  └─────────┘  └─────────┘       │
├─────────────────────────────────┤
│  Upcoming Follow-ups            │  ← SectionHeader (family-wide)
│  ┌───────────────────────────┐  │
│  │ 🔵 Rahul · ENT            │  │  ← color dot = member.color
│  │ Dr. Priya Sharma          │  │
│  │ 15 Jun 2026 · 14 days     │  │
│  └───────────────────────────┘  │
│         (EmptyState if none)     │
└─────────────────────────────────┘
```

**Implementation notes**
- On mount (`useEffect`): `memberStore.loadMembers()` + `memberStore.loadSummary()`.
- Use `useFocusEffect` (or re-load on focus) so counts refresh after returning from a member's flow.
- Member grid: 2-column `FlatList` of `MemberCard`. Tap → `router.push('/member/' + member.id)`.
- "＋ Add" (header right): `router.push('/members/new')`.
- Family summary block lists `summary.upcomingFollowUps` (already date-sorted). Each row: member color dot + name + speciality + doctor + date + days-remaining (reuse the days-left helper from `ReminderCard`). Tap → `router.push('/visits/' + item.visit_id)`.
- Empty states: zero members → `EmptyState` ("Add your first family member"); members but zero upcoming → `EmptyState` under the section header.

#### 14.8.2 Member Home — `app/member/[memberId].tsx` (NEW — body map moved here)

This is the **v1.0 Home screen content** (2-column body-part grid + recent visits strip + search/bell header), now scoped to one member.

```
┌─────────────────────────────────┐
│  ← Rahul              🔍  🔔2   │  ← header: member name + search + bell
├─────────────────────────────────┤
│  [HEAD]    [CHEST]               │  ← BodyPartCard grid (unchanged)
│  [ABDOMEN] [BACK]                │
│  [ARMS]    [LEGS]                │
│  [SKIN]    [GENERAL]             │
├─────────────────────────────────┤
│  Recent Visits — Rahul          │
│  ┌──────┐ ┌──────┐ ┌──────┐     │  ← horizontal VisitCards (member-scoped)
└─────────────────────────────────┘
```

**Implementation notes**
- Read `memberId` via `useLocalSearchParams`. Resolve member via `memberStore.getMember(memberId)` (load members if empty) for the header title.
- On mount: `visitsStore.loadRecentVisitsForMember(memberId)`.
- Body part tap → `router.push({ pathname: '/speciality/' + bodyPart.id, params: { memberId } })`.
- Recent visit tap → `router.push('/visits/' + visit.id)`.
- Header renders its own `<Stack.Screen options={{ title: member?.name, headerRight: ... }}>` (search + bell badge), mirroring the original v1 Home implementation. Back arrow returns to Family Home automatically.

#### 14.8.3 Member Form — `app/members/new.tsx` & `app/members/edit/[memberId].tsx` (NEW, modal)

```
┌─────────────────────────────────┐
│  ✕ Add Member          [Save]   │
├─────────────────────────────────┤
│  Name           [_____________] │  ← required
│  Relationship   [Self ▼ chips]  │  ← SegmentedButtons / chip row (RELATIONSHIPS)
│  Date of Birth  [YYYY-MM-DD]    │  ← plain TextInput, validated on blur (optional)
│  Gender         [M / F / Other] │  ← SegmentedButtons (optional)
└─────────────────────────────────┘
```

**Functional requirements**
- FR-MEM-01: `name` required; `relationship` defaults to `OTHER` (or `SELF` if no members exist yet). DOB and gender optional.
- FR-MEM-02: DOB uses a plain `TextInput` (`YYYY-MM-DD`) with the same validator pattern used by visit dates — consistent with the v1 decision to avoid `@react-native-community/datetimepicker`.
- FR-MEM-03: Save (new) → `memberStore.createMember(form)` (color auto-assigned) → `router.back()`.
- FR-MEM-04: Edit mode pre-fills from `memberStore.getMember(id)`; save → `memberStore.updateMember(id, form)`.
- FR-MEM-05: Edit screen shows a **Delete Member** destructive button → confirmation Alert warning that ALL of that member's visits, attachments and reminders will be deleted → `memberStore.deleteMember(id)` → `router.back()`. Guard: if it is the last remaining member, block deletion with an alert.

#### 14.8.4 Threading `memberId` through the visit flow

| Screen | Change |
|---|---|
| `app/speciality/[bodyPartId].tsx` | Read `memberId` from params; pass it to `getSpecialityCountForMember`; forward `memberId` in the push to the visit list and to `/visits/new`. |
| `app/visits/list/[specialityId].tsx` | Read `memberId`; call `loadVisitsBySpeciality(bodyPartId, specialityId, memberId)`; forward `memberId` to `/visits/new`. |
| `app/visits/new.tsx` | Read `memberId` from params; include it in the form's initial state and in `createVisit`. |
| `app/visits/edit/[visitId].tsx` | `member_id` is read from the loaded visit and preserved on update (not user-editable in v1.1). |
| `app/visits/[visitId].tsx` | Show a member chip (name + color dot) alongside the speciality/body-part chips. |
| `app/(tabs)/reminders.tsx` | Add member-name badge to each `ReminderCard` (reminder → visit → member JOIN already available via `remindersRepository`; add `member_name`, `member_color`). |
| `app/(tabs)/reports.tsx` | Add member-name badge to each attachment card (attachments → visit → member JOIN). |

> **`remindersRepository` / `attachmentsRepository` tweak:** extend their JOINed SELECTs to also pull `m.name AS member_name, m.color AS member_color` (JOIN members `m` ON `v.member_id = m.id`). Add `member_name`/`member_color` to the `Reminder` and `Attachment` types as optional joined fields.

#### 14.8.5 New shared component — `MemberCard`

```typescript
interface MemberCardProps {
  member: Member;        // includes visit_count, next_follow_up
  onPress: () => void;
}
```
Renders: circular avatar (initials on `member.color`), name, relationship + age (from `computeAge(date_of_birth)`), visit count, next follow-up date (or em-dash).

#### 14.8.6 New shared component — `MemberBadge`

```typescript
interface MemberBadgeProps {
  name: string;
  color: string;
  size?: 'sm' | 'md';
}
```
A small pill: colored dot + member name. Used on Reminders, Reports, Search, and the Family Summary list.

### 14.9 Seed Data Changes

The v1.0 seed (`seedIfNeeded`, key `@CareLog_seeded_v1`) must set `member_id` on its mock visits. Add a **separate family seed** so existing installs (already past v1 seed) still get demo members.

**`src/db/seed.ts` changes:**
1. In the existing `MOCK_VISITS` loop, set `member_id: DEFAULT_SELF_MEMBER_ID` on each visit (the migration guarantees that member exists).
2. Add `seedFamilyIfNeeded()` (new key `@CareLog_seeded_family_v1`), called from `app/_layout.tsx` right after `seedIfNeeded()`:
   - Create three members: **Priya** (SPOUSE, F), **Aarav** (CHILD, M, DOB making him ~8y), **Sita** (PARENT, F).
   - Create ~1–2 mock visits per new member (e.g., Aarav → ENT/Pediatric-style GENERAL_MEDICINE; Priya → GYNAECOLOGY; Sita → CARDIOLOGY with a future follow-up).
   - Create a reminder for at least one new member's future follow-up so the family summary shows multiple members.
   - Set the new key.

**`app/_layout.tsx` init order becomes:** `initDatabase()` → `seedIfNeeded()` → `seedFamilyIfNeeded()` → `loadSettings()`.

**`app/(tabs)/settings.tsx` — `handleDeleteAll`:** also `DELETE FROM members WHERE id != DEFAULT_SELF_MEMBER_ID;` (keep Self), and remove both seed keys (`@CareLog_seeded_v1`, `@CareLog_seeded_family_v1`) so a relaunch re-seeds a clean family. Keep the default Self member so the app is never memberless.

### 14.10 Acceptance Criteria (Family)

**Members — CRUD**
- [ ] AC-F01: Family Home lists all members; on a fresh/migrated install at least the "Self" member is present.
- [ ] AC-F02: "＋ Add" opens the member modal; saving a member with only a name succeeds and the card appears immediately.
- [ ] AC-F03: Editing a member pre-fills all fields and persists changes.
- [ ] AC-F04: Deleting a member removes the member AND all their visits/attachments/reminders; deletion of the last remaining member is blocked.
- [ ] AC-F05: A unique avatar color is assigned per member and used consistently on cards and badges.

**Member-scoped flow**
- [ ] AC-F06: Tapping a member card opens that member's body-map home with their name in the header.
- [ ] AC-F07: The body-part → speciality → visit-list flow shows ONLY the selected member's visits.
- [ ] AC-F08: Speciality cards show per-member visit counts (not family-wide totals).
- [ ] AC-F09: Creating a visit from inside a member's flow saves with that `member_id` and appears only under that member.
- [ ] AC-F10: A visit created for Member A never appears in Member B's lists.

**Migration & data integrity**
- [ ] AC-F11: After upgrading an existing v1.0 install, all previously-created visits appear under the "Self" member (no orphans, no data loss).
- [ ] AC-F12: Re-launching the app does not duplicate members or visits (both seed guards respected).

**Family summary & badges**
- [ ] AC-F13: Family Home "Upcoming Follow-ups" lists follow-ups across ALL members, date-sorted, each tagged with the correct member name/color; tapping opens the linked visit.
- [ ] AC-F14: Reminders and Reports tabs show a member-name badge on each row.
- [ ] AC-F15: Member card shows correct visit count and next follow-up date; family summary updates after add/delete of a visit or member.

**Empty states**
- [ ] AC-F16: With zero non-Self members, Family Home still renders (Self card + empty/summary states) without crashing.
- [ ] AC-F17: A newly added member with no visits shows an empty Recent Visits strip and zero counts, no crash.

---

*End of Document*  
*CareLog Offline Prototype PRD v1.1-family | 2026-06-01*  
*Scope: Offline-only | Environment: Expo SDK 51 | Consumer: Agentic AI*
