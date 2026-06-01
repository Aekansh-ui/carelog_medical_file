# CareLog — Flutter Port PRD (v1.0-flutter)

> **Source of truth.** This is a 1:1 functional port of the existing React Native / Expo
> CareLog app (see `../carelog/` and `../CareLog_Offline_Prototype_PRD.md`). The product
> behaviour, data model, screens, seed data, and acceptance criteria are **unchanged**.
> Only the implementation technology changes. Where this document and the RN PRD disagree
> on *behaviour*, the RN app's actual code wins.

---

## AGENT BOOTSTRAP INSTRUCTIONS

1. This app is **100% offline**. No network, no auth, no backend, no cloud sync. All data
   lives in a local SQLite database and the app's document directory.
2. Build in the **phase order** defined in `BUILD_STEPS.md`. Each phase is sized to fit a
   single context window. Do not skip ahead — later phases import earlier ones.
3. Target **Flutter stable (3.24+) / Dart 3.5+**. Material 3 enabled.
4. Mirror the existing data model **exactly** — same tables, columns, ids, enum string
   values, and the fixed `Self` member UUID `11111111-1111-1111-1111-111111111111`. This
   keeps seed data and acceptance tests identical to the RN app.
5. Use the package set in §2. Do **not** add a backend SDK, Firebase, or any network client.
6. After each phase, run `flutter analyze` (zero errors) and `flutter test` where tests exist.

---

## TABLE OF CONTENTS

1. Project Overview
2. Tech Stack & Dependencies
3. Project Structure
4. Design System
5. Domain Model — Enums & Constants
6. Data Layer (Drift)
7. State Management (Riverpod)
8. Navigation (go_router)
9. Services
10. Seed Data
11. Screen Specifications
12. Shared Widgets
13. Acceptance Criteria
14. Build Phasing (see BUILD_STEPS.md)

---

## 1. Project Overview

CareLog is an offline family medical-record keeper. A user records doctor **visits** —
organised by **body part → speciality** — attaches photos/PDFs of prescriptions, bills,
medicines and reports, sets follow-up **reminders**, tracks **insurance** policies per
family **member**, and browses everything through a **Reports** hub and full-text **search**.

Core navigation model:

```
Family Home (member grid)
  └─ Member Home (body-part grid + insurance entry + recent visits)
       ├─ Speciality select  → Visit list → Visit detail (attachments, reminder)
       │                                    └─ Add / Edit visit
       └─ Insurance list → Policy detail → Add / Edit policy (+ documents)
Bottom tabs: Family · Reports · Reminders · Settings
Global search (from header)
```

There is always exactly one undeletable member, **Self**.

---

## 2. Tech Stack & Dependencies

| Concern | RN/Expo (source) | Flutter (target) |
|---|---|---|
| Language | TypeScript | Dart 3.5+ |
| UI kit | react-native-paper (MD3) | Flutter Material 3 |
| Navigation | expo-router (file-based) | `go_router` |
| State | Zustand | `flutter_riverpod` |
| DB | expo-sqlite (raw SQL) | `drift` + `sqlite3_flutter_libs` |
| Key-value | AsyncStorage | `shared_preferences` |
| Files | expo-file-system | `path_provider` + `dart:io` |
| Image pick | expo-image-picker | `image_picker` |
| Camera | expo-camera | `image_picker` (`ImageSource.camera`) |
| Doc pick | expo-document-picker | `file_picker` |
| Image resize | expo-image-manipulator | `image` (Dart package) |
| Notifications | expo-notifications | `flutter_local_notifications` + `timezone` |
| PDF view | react-native-pdf | `printing` / `pdfx` (or open externally via `open_filex`) |
| Export/share | (HTML→PDF, broken in Expo Go) | `printing` (PDF) + `share_plus` |
| Phone dial | Linking | `url_launcher` (`tel:`) |
| UUID | react-native-uuid | `uuid` |
| Icons | MaterialCommunityIcons | Flutter built-in `Icons` (Material) — see icon note |
| Date utils | date-fns | `intl` |

### `pubspec.yaml` dependencies (target)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0
  shared_preferences: ^2.3.0
  image_picker: ^1.1.2
  file_picker: ^8.0.6
  image: ^4.2.0
  flutter_local_notifications: ^17.2.1
  timezone: ^0.9.4
  url_launcher: ^6.3.0
  share_plus: ^9.0.0
  printing: ^5.13.0
  open_filex: ^4.5.0
  uuid: ^4.4.2
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  drift_dev: ^2.18.0
  build_runner: ^2.4.11
```

> **Icon note (decided in P0).** RN uses MaterialCommunityIcons names (e.g. `heart-pulse`).
> The obvious Flutter equivalent, `material_design_icons_flutter`, is **incompatible with
> Flutter 3.44 / Dart 3.12** — its latest release (7.0.7296) subclasses `IconData`
> (`class _MdiIconData extends IconData`), which now fails because Flutter made `IconData` a
> `final class`. `flutter_vector_icons` is also unusable (capped at Dart `<3.0.0`). Both are
> effectively unmaintained. **Decision:** use Flutter's built-in Material `Icons` (ships with
> the SDK, always compatible) and map each RN MDI name to the closest built-in. The MDI names
> in §5 are kept as the *reference* (what to approximate); the Dart field on each constant is
> a built-in `IconData`. If exact MDI parity is later required, bundle the MDI TTF as a font
> asset and define `IconData(codepoint, fontFamily: …)` constants for just the ~25 icons used
> — do **not** re-add `material_design_icons_flutter`.

---

## 3. Project Structure

> The Flutter project is created **in-place** in `flutter_version/` (this directory), so the
> two `.md` files sit alongside `pubspec.yaml`. `flutter create` preserves existing files.

```
flutter_version/                       # Flutter project root (this directory)
├─ CareLog_flutter_prd.md              # this spec
├─ BUILD_STEPS.md                      # the build playbook
├─ pubspec.yaml
├─ lib/
│  ├─ main.dart                        # ProviderScope + bootstrap (init db, seed, settings)
│  ├─ app.dart                         # MaterialApp.router + theme + go_router
│  ├─ theme/
│  │  └─ app_theme.dart                # Colors, spacing, radius, typography, shadows
│  ├─ constants/
│  │  ├─ body_parts.dart
│  │  ├─ specialities.dart
│  │  ├─ body_speciality_map.dart
│  │  ├─ members.dart                  # relationships, genders, colors, SELF id
│  │  └─ insurance.dart                # plan types, expiry-soon days
│  ├─ utils/
│  │  └─ date_utils.dart               # date/currency helpers + ExpiryStatus/getExpiryStatus
│  ├─ data/
│  │  ├─ database.dart                 # Drift @DriftDatabase, tables, migrations
│  │  ├─ database.g.dart               # generated
│  │  ├─ tables/                       # Drift table classes (optional split)
│  │  └─ daos/
│  │     ├─ visits_dao.dart
│  │     ├─ attachments_dao.dart
│  │     ├─ reminders_dao.dart
│  │     ├─ members_dao.dart
│  │     └─ insurance_dao.dart
│  ├─ models/                          # plain Dart value classes / freezed-free DTOs
│  │  ├─ visit.dart
│  │  ├─ attachment.dart
│  │  ├─ reminder.dart
│  │  ├─ member.dart
│  │  └─ insurance.dart
│  ├─ providers/                       # Riverpod (mirror Zustand stores)
│  │  ├─ database_provider.dart
│  │  ├─ visits_provider.dart
│  │  ├─ reminders_provider.dart
│  │  ├─ members_provider.dart
│  │  ├─ insurance_provider.dart
│  │  └─ settings_provider.dart
│  ├─ services/
│  │  ├─ file_service.dart
│  │  ├─ notification_service.dart
│  │  ├─ export_service.dart
│  │  └─ seed.dart
│  ├─ router.dart                      # go_router config (route → page map)
│  ├─ screens/
│  │  ├─ shell/                        # bottom-tab StatefulShellRoute
│  │  │  ├─ family_home_screen.dart    # tab 0
│  │  │  ├─ reports_screen.dart        # tab 1
│  │  │  ├─ reminders_screen.dart      # tab 2
│  │  │  └─ settings_screen.dart       # tab 3
│  │  ├─ member/
│  │  │  ├─ member_home_screen.dart
│  │  │  ├─ member_form_screen.dart    # add + edit
│  │  ├─ visit/
│  │  │  ├─ speciality_select_screen.dart
│  │  │  ├─ visit_list_screen.dart
│  │  │  ├─ visit_detail_screen.dart
│  │  │  └─ visit_form_screen.dart     # add + edit
│  │  ├─ insurance/
│  │  │  ├─ insurance_list_screen.dart
│  │  │  ├─ policy_detail_screen.dart
│  │  │  └─ insurance_form_screen.dart # add + edit
│  │  └─ search_screen.dart
│  └─ widgets/
│     ├─ visit_card.dart
│     ├─ speciality_card.dart
│     ├─ member_card.dart
│     ├─ member_badge.dart
│     ├─ insurance_card.dart
│     ├─ attachment_thumbnail.dart
│     ├─ attachment_grid.dart
│     ├─ reminder_card.dart
│     ├─ doc_viewer.dart               # fullscreen image / PDF modal
│     ├─ empty_state.dart
│     └─ section_header.dart
└─ test/
```

---

## 4. Design System

Port the exact tokens from `../carelog/src/constants/theme.ts` into `app_theme.dart`.

### Colors

| Token | Hex |
|---|---|
| primary | `#1A6B8A` |
| secondary | `#2E9E6B` |
| accent | `#E67E22` |
| error | `#E53935` |
| background | `#F4F6FA` |
| surface | `#FFFFFF` |
| border (hairline) | `#ECEFF3` |
| borderStrong | `#DFE3E9` |
| textPrimary | `#1B2330` |
| textSecondary | `#6B7280` |
| textDisabled | `#B4BBC6` |

```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF1A6B8A),
  primary: const Color(0xFF1A6B8A),
  secondary: const Color(0xFF2E9E6B),
  tertiary: const Color(0xFFE67E22),
  error: const Color(0xFFE53935),
  surface: const Color(0xFFFFFFFF),
  background: const Color(0xFFF4F6FA),
);
```

### Spacing — `xs 4 · sm 8 · md 16 · lg 24 · xl 32 · xxl 48`
### Radius — `sm 10 · md 16 · lg 20 · xl 28 · full 999`
### Typography
| Style | size / weight |
|---|---|
| h1 | 24 / w700 |
| h2 | 20 / w600 |
| h3 | 16 / w600 |
| body | 14 / w400 |
| caption | 12 / w400 (secondary) |
| label | 12 / w500 (secondary) |

### Elevation (port to `BoxShadow`)
- **sm**: offset (0,1), blur 3, color `#101828` @ 5%
- **card**: offset (0,4), blur 12, color `#101828` @ 7%  ← default card look
- **lg**: offset (0,8), blur 20, color `#101828` @ 12%

App-bar style across the app: background `primary`, foreground white, title weight 700.
Bottom nav: white bg, top hairline border, active tint `primary`, inactive `#9AA3AF`.

---

## 5. Domain Model — Enums & Constants

Port verbatim from `../carelog/src/constants/`. **Enum string values must match exactly**
(they are persisted in the DB and used by seed data).

### Body parts (`body_parts.dart`)
8 entries, ids: `HEAD_BRAIN, CHEST_HEART, ABDOMEN, BACK_SPINE, ARMS_HANDS, LEGS_FEET, SKIN, GENERAL`.
Each: `{ id, label, icon (built-in IconData), description }`. The **MDI column below is the
reference** (the RN look to approximate); pick the nearest built-in `Icons.*` per the icon note
in §2 — e.g. `heart-pulse → Icons.monitor_heart`, `stomach → Icons.lunch_dining`,
`brain/head-cog → Icons.psychology`, `human → Icons.accessibility_new`,
`shoe-print → Icons.directions_walk`, `arm-flex → Icons.fitness_center`.

| id | label | icon (MDI ref) | description |
|---|---|---|---|
| HEAD_BRAIN | Head & Brain | head-cog-outline | Eyes, ears, nose, throat, brain |
| CHEST_HEART | Chest & Heart | heart-pulse | Heart, lungs, chest wall |
| ABDOMEN | Abdomen | stomach | Stomach, liver, kidneys |
| BACK_SPINE | Back & Spine | human-handsdown | Cervical, lumbar, sacral |
| ARMS_HANDS | Arms & Hands | arm-flex-outline | Shoulder, elbow, wrist, fingers |
| LEGS_FEET | Legs & Feet | shoe-print | Hip, knee, ankle, foot |
| SKIN | Skin | hand-back-right-outline | Rashes, infections, wounds |
| GENERAL | General / Whole Body | human | Fever, fatigue, allergies |

### Specialities (`specialities.dart`)
16 entries: `GENERAL_MEDICINE, ENT, NEUROLOGY, DENTISTRY, CARDIOLOGY, PULMONOLOGY, GASTRO,
NEPHROLOGY, ORTHO, DERMATOLOGY, OPHTHALMOLOGY, GYNAECOLOGY, UROLOGY, ENDOCRINOLOGY,
PSYCHIATRY, OTHER`. Each: `{ id, label, shortLabel, icon (built-in IconData), color(hex) }`.
Copy the **colours** exactly from `../carelog/src/constants/specialities.ts`; map the MDI icon
names there to the nearest built-in `Icons.*` (per §2 icon note).

### Body→Speciality map (`body_speciality_map.dart`)
`Map<BodyPartId, List<SpecialityId>>` — copy from `bodySpecialityMap.ts` exactly. Speciality
screen shows mapped specialities first, then "Other / Custom".

### Members (`members.dart`)
- `RelationshipType`: `SELF, SPOUSE, CHILD, PARENT, SIBLING, OTHER` (+ label, icon).
- `Gender`: `MALE, FEMALE, OTHER`.
- `MEMBER_COLORS`: `['#1A6B8A','#2E9E6B','#E67E22','#8E44AD','#C0392B','#16A085','#D35400','#2C3E50']`
  (assigned by creation order, cycled).
- `DEFAULT_SELF_MEMBER_ID = '11111111-1111-1111-1111-111111111111'`.

### Insurance (`insurance.dart`)
- `PlanType`: `PERSONAL, FAMILY_FLOATER, CORPORATE, OTHER` (+ label, icon).
- `INSURANCE_EXPIRY_SOON_DAYS = 30`.
- Expiry status helper → `none | active | expiring (≤30d) | expired`. Badge colours:
  active = secondary, expiring = accent, expired = error.

---

## 6. Data Layer (Drift)

Recreate the exact schema from `../carelog/src/db/database.ts`. Use Drift tables; replicate
the migration history as Drift schema versions (final `schemaVersion = 4`). String columns
store ISO-8601 dates (`YYYY-MM-DD` for dates, full ISO for timestamps) — **keep the string
format**, do not switch to Dart `DateTime` columns, so data matches the RN app.

### Tables

**visits** — `id (PK text), body_part_id, speciality_id, custom_speciality?, visit_date,
follow_up_date?, doctor_name?, clinic_name?, clinic_phone?, doctor_fees? (real),
currency (default 'INR'), symptoms?, diagnosis?, notes?, member_id (FK members), created_at,
updated_at`. Indexes on body_part_id, speciality_id, visit_date DESC, member_id.

**attachments** — `id (PK), visit_id (FK visits ON DELETE CASCADE), type CHECK in
('prescription','medicine','bill','report'), file_path, file_name, mime_type,
size_bytes (int), thumbnail_path?, created_at`. Index on visit_id.

**reminders** — `id (PK), visit_id (FK visits ON DELETE CASCADE), follow_up_date,
notification_id_d1?, notification_id_d0?, is_active (int default 1), rescheduled_at?,
created_at`. Index on follow_up_date.

**visit_drafts** — `id (PK), form_data (json text), created_at, updated_at`.

**members** — `id (PK), name, relationship (default 'OTHER'), date_of_birth?, gender?,
color (default '#1A6B8A'), created_at, updated_at`. Seed the fixed **Self** row on first run
(migration 3 equivalent), and back-fill any null `visits.member_id` to the Self id.

**insurance_policies** — `id (PK), member_id (FK members), insurer_name, plan_type
(default 'PERSONAL'), policy_number?, policy_holder?, sum_insured? (real), premium? (real),
currency (default 'INR'), valid_from?, valid_until?, helpline_phone?, agent_name?, notes?,
created_at, updated_at`. Indexes on member_id, valid_until.

**insurance_documents** — `id (PK), policy_id (FK insurance_policies ON DELETE CASCADE),
file_path, file_name, mime_type, size_bytes (int), thumbnail_path?, created_at`. Index on policy_id.

### Full-text search
The RN app uses an FTS5 virtual table (`visits_fts`) with INSERT/DELETE/UPDATE triggers over
`doctor_name, clinic_name, symptoms, diagnosis, notes`. In Drift, create the FTS5 table and
triggers via a `customStatement` block in the migration (Drift supports raw FTS5). **Acceptable
simplification:** if FTS5 proves fiddly, implement search as a `LIKE`-based query across the
same five columns + doctor/clinic — behaviour to the user is identical for the prototype.
Search results JOIN `members` to expose `member_name` and `member_color` (for the badge).

### Enable foreign keys
Drift: open with `PRAGMA foreign_keys = ON;` in `beforeOpen`. WAL is default for sqlite3 libs.

### DAOs (mirror repository methods)

- **VisitsDao**: `create`, `update`, `delete` (cascades attachments+reminders via FK),
  `findById`, `findRecent(limit)`, `findRecentForMember(memberId, limit)`,
  `findBySpeciality(specialityId[, memberId])`, `search(query)` (JOIN members),
  `countAll` / per-member counts, reports aggregations (group by speciality / body part).
- **AttachmentsDao**: `add`, `findByVisit`, `delete`, `deleteByVisit` (returns file paths for disk cleanup).
- **RemindersDao**: `create(visitId, followUpDate)`, `findUpcoming`, `findByVisit`,
  `setActive`, `update`, `delete`.
- **MembersDao**: `create`, `update`, `delete` (**explicit transaction cascade**: delete
  insurance_documents → insurance_policies → attachments → reminders → visits → member, in a
  `transaction{}`), `findById`, `findAllWithStats` (visit_count, last_visit_date,
  next_follow_up; ordered SELF-first then created_at), `getFamilySummary`.
- **InsuranceDao**: `create`, `update`, `delete` (transaction; returns
  `{filePath, thumbnailPath}` list for disk cleanup), `findById`, `findByMember` (with
  `document_count` subquery, ordered `valid_until IS NULL, valid_until ASC`),
  `countByMember`, `addDocument`, `findDocuments(policyId)`, `deleteDocument`.

> **Cascade note (carried from RN).** Do not rely solely on FK CASCADE for columns added by
> later migrations; the RN app uses an explicit BEGIN/COMMIT transaction in member-delete.
> Replicate that with Drift `transaction()`.

---

## 7. State Management (Riverpod)

One provider per Zustand store. Use `Notifier`/`AsyncNotifier` (Riverpod 2). Providers are
the **only** bridge between screens and DAOs — screens never touch the DB directly.

| RN store | Flutter provider | State |
|---|---|---|
| visitsStore | `visitsProvider` | recentVisits, listVisits, currentVisit; load*/create/update/delete |
| remindersStore | `remindersProvider` | upcoming list; load, create, reschedule, cancel |
| memberStore | `membersProvider` | members (+stats), familySummary; loadMembers, getMember, create/update/delete |
| insuranceStore | `insuranceProvider` | policies for current member; loadForMember, create/update/delete (returns file paths) |
| settingsStore | `settingsProvider` | currency, notificationsEnabled, reminderTime; load, setSetting (persist via shared_preferences) |

**Focus refresh:** the RN app uses `useFocusEffect` to reload lists when a screen regains
focus (so a freshly-added visit shows on back-navigation). In go_router, achieve the same by
invalidating/refreshing the relevant provider in the screen's `didChangeDependencies` or via a
`GoRouterState`-driven `ref.refresh` on the route's `onExit`/return. Simplest reliable pattern:
make list screens watch a provider that is `ref.invalidate`d after any create/update/delete
mutation. Acceptance: returning to Member Home / Visit List after adding a record shows it
immediately (RN bug #1/#2 — must not regress).

---

## 8. Navigation (go_router)

Mirror the expo-router tree. Use a `StatefulShellRoute.indexedStack` for the 4 bottom tabs,
and top-level routes for the stack screens. Modal-style screens (add/edit) push as full pages
(Flutter has no "modal presentation" flag; use a normal push — optionally
`MaterialPage(fullscreenDialog: true)` to get the iOS-style down-arrow).

| Path | Screen | Notes |
|---|---|---|
| `/` (shell tab 0) | FamilyHome | member grid |
| `/reports` (tab 1) | Reports | hub |
| `/reminders` (tab 2) | Reminders | list |
| `/settings` (tab 3) | Settings | |
| `/member/:memberId` | MemberHome | body-part grid + insurance entry + recent visits |
| `/members/new` | MemberForm | add (fullscreenDialog) |
| `/members/edit/:memberId` | MemberForm | edit |
| `/speciality/:bodyPartId?memberId=` | SpecialitySelect | |
| `/visits/list/:specialityId?memberId=` | VisitList | |
| `/visits/:visitId` | VisitDetail | |
| `/visits/new?memberId=&bodyPartId=&specialityId=` | VisitForm | add |
| `/visits/edit/:visitId` | VisitForm | edit |
| `/insurance/member/:memberId` | InsuranceList | |
| `/insurance/policy/:policyId` | PolicyDetail | |
| `/insurance/new?memberId=` | InsuranceForm | add |
| `/insurance/edit/:policyId` | InsuranceForm | edit |
| `/search` | Search | from header magnify icon |

---

## 9. Services

### file_service.dart (port of `fileService.ts`)
- App docs root: `<path_provider getApplicationDocumentsDirectory()>/attachments/<ownerId>/`.
  `ownerId` is **either** a visitId or a policyId — both share the same tree (RN `ownerDir`).
- `saveFile(ownerId, label, sourceUri, mimeType)`: copy source into owner dir with a uuid+label
  filename; for images, also write a resized thumbnail (max ~400px) using the `image` package.
- `saveAttachment(visitId, type, uri, mime)` and `saveInsuranceDocument(policyId, uri, mime)`
  both delegate to `saveFile`.
- `deleteFiles(paths)`, `deleteOwnerDir(ownerId)`, `deleteAllAttachments()`, `getStorageUsedBytes()`.

### notification_service.dart (port of `notificationService.ts`)
- `flutter_local_notifications` + `timezone`. Request permission on first enable.
- For each reminder: schedule a **D-1** and **D-0** local notification at the user's
  `reminderTime` (HH:MM). Store the platform notification ids back on the reminder row
  (`notification_id_d1`, `notification_id_d0`).
- Cancel on reminder delete / visit delete / Delete-All.
- Reschedule when `reminderTime` changes or follow-up date is edited.
- Gracefully no-op if `notificationsEnabled == false`.

### export_service.dart (port of `exportService.ts`)
- Build an HTML/text summary of all data and render to PDF with `printing`, then `share_plus`.
  **Note:** the RN export was non-functional in Expo Go; in Flutter this is straightforward —
  implement it properly and **include insurance** in the export (visits, members, reminders,
  insurance policies + document filenames).

### seed.dart (port of `seed.ts`) — see §10.

---

## 10. Seed Data

Replicate `../carelog/src/db/seed.ts` exactly, gated by `shared_preferences` flags so it runs
once. Run order on bootstrap (in `main.dart` after DB init):
`seedVisits → seedFamily → seedInsurance → loadSettings`.

- **Seed flags:** `@CareLog_seeded_v1`, `@CareLog_seeded_family_v1`, `@CareLog_seeded_insurance_v1`.
- **seedVisits:** 5 visits for the Self member (ENT, Cardiology, Gastro, Ortho, Endocrinology)
  with the exact doctor names, dates, fees, symptoms, diagnoses, notes from the source file.
  Create reminders for the ENT and Cardiology follow-ups.
- **seedFamily:** members **Priya** (Spouse, 1988-07-20, F, `#2E9E6B`), **Aarav** (Child,
  2018-04-12, M, `#E67E22`), **Sita** (Parent, 1955-09-10, F, `#8E44AD`); one visit each
  (Priya Gynae +reminder, Aarav General Medicine, Sita Cardiology +reminder).
- **seedInsurance:** Star Health **PERSONAL** policy on Self (`SH-2024-887341`, ₹5,00,000 sum,
  ₹12,500 premium, 2026-01-01→2026-12-31, helpline 18004252255, agent Rohit Verma) + HDFC ERGO
  **FAMILY_FLOATER** on the first non-Self member (`HE-FLT-556210`, ₹10,00,000, ₹28,000,
  2026-04-01→2027-03-31, helpline 18002700700).

(Exact field values: copy from `seed.ts` lines verbatim.)

---

## 11. Screen Specifications

> Behaviour mirrors the RN app. Pull pixel/label details from
> `../CareLog_Offline_Prototype_PRD.md §10` and the actual screen `.tsx` files.

### 11.1 Family Home (tab 0)
Grid of `MemberCard`s from `findAllWithStats` (Self pinned first). Each card: colored avatar
(initial), name, relationship, visit count, next follow-up chip. FAB / "+ Add member" →
`/members/new`. Tapping a card → `/member/:id`. App-bar shows family summary + search + bell
(with upcoming-reminder count badge).

### 11.2 Member Home (`/member/:memberId`)
Scrollable: header title = member name. **Insurance entry row** (shield icon, "Insurance",
subtitle, chevron) → `/insurance/member/:id`. Then a **2-column body-part grid** (8 cards).
Footer = horizontal **Recent Visits** list (or empty state). Body-part tap →
`/speciality/:bodyPartId?memberId=`. Header has search + bell-with-badge. **Refresh recent
visits + reminders on focus.**

### 11.3 Speciality Select (`/speciality/:bodyPartId`)
Lists specialities mapped to the body part (from the map), then "Other / Custom" at the end.
Each `SpecialityCard` (icon, label, color accent). Tap → `/visits/list/:specialityId?memberId=`.
For "Other", allow entering a `custom_speciality` string (carried into the visit form).

### 11.4 Visit List (`/visits/list/:specialityId`)
List of visits for that member+speciality, newest first. Each `VisitCard`: date, doctor,
clinic, diagnosis snippet, fees, follow-up chip, attachment count. FAB → `/visits/new` with
member/bodyPart/speciality prefilled. Empty state if none. **Refresh on focus.**

### 11.5 Visit Form (`/visits/new`, `/visits/edit/:visitId`)
Collapsible sections (all in one scroll): **Visit Info** (date picker, follow-up date,
doctor, clinic, phone, fees+currency) · **Clinical** (symptoms, diagnosis, notes) ·
**Attachments** (add via camera / gallery / PDF; categorise as prescription/medicine/bill/
report; thumbnail grid; tap to view; delete). On save: write visit; if follow-up date set and
notifications on, create/update reminder + schedule notifications. Edit screen has a Delete
button (confirm dialog → cascade delete + remove files + cancel notifications → pop). Validate
via the port of `validators.ts` (`validateVisitForm`).

### 11.6 Visit Detail (`/visits/:visitId`)
Read view of all fields, speciality/body-part chips, member badge, attachment grid (tap →
`DocViewer`), tap-to-call clinic phone (`url_launcher tel:`), follow-up + reminder status.
Header pencil → edit. **Refresh on focus.**

### 11.7 Reports (tab 1)
Hub: totals + breakdowns (visits by speciality, by body part, by member), recent attachments
grid, quick links. Tapping a slice filters into a visit list. Member badge shown on rows
(RN AC-F14 — must show member badge in the Reports grid).

### 11.8 Reminders (tab 2)
Upcoming follow-ups (from `findUpcoming`), each `ReminderCard` (member badge, doctor,
speciality, date, days-until). Actions: mark done / reschedule / open visit. Empty state.

### 11.9 Settings (tab 3)
- **Currency** segmented (₹ INR / $ USD) → persisted.
- **Notifications** toggle + **Reminder Time** (HH:MM, 24h, validated) → persisted; toggling
  reschedules all active reminders.
- **Data**: Storage Used (MB), **Export All Data** (PDF + share), **Delete All Data**
  (confirm → clears reminders, attachments, insurance_documents, insurance_policies, visits,
  visit_drafts, all members **except Self**, deletes attachment files, clears all 3 seed flags,
  cancels notifications).
- **About**: app version, environment.

### 11.10 Insurance List (`/insurance/member/:memberId`)
Policies for the member (`findByMember`, soonest-expiry first, NULLs last). Each
`InsuranceCard`: insurer icon circle, insurer name, plan chip, document-count chip, policy
number, sum insured, **expiry badge** (active/expiring/expired colours). FAB → `/insurance/new`.
Empty state. **Refresh on focus.**

### 11.11 Policy Detail (`/insurance/policy/:policyId`)
All fields grouped (Policy details · Coverage & validity · Contact & notes · Documents grid).
Tap-to-call helpline. Documents tap → `DocViewer`. Header pencil → edit. **Refresh on focus.**

### 11.12 Insurance Form (`/insurance/new`, `/insurance/edit/:policyId`)
Four collapsible sections: **Policy Details** (insurer*, plan type, policy number, holder) ·
**Coverage & Validity** (sum insured, premium, currency, valid from, valid until) · **Contact
& Notes** (helpline, agent, notes) · **Documents** (≤6 files; camera/gallery/PDF; thumbnails;
delete). Validate via port of `validateInsuranceForm` (insurer required, date formats,
from<until, phone format, non-negative amounts). Edit screen footer has Delete (confirm →
cascade delete + remove files → pop back to list).

### 11.13 Member Form (`/members/new`, `/members/edit/:memberId`)
Name*, relationship (chips), DOB (date picker), gender, color (palette picker). Self cannot be
deleted; its relationship is locked to SELF. Edit footer Delete (confirm → cascade member
delete → pop).

### 11.14 Search (`/search`)
Query box → results across visits (FTS or LIKE on doctor/clinic/symptoms/diagnosis/notes).
Each result is a `VisitCard` **with member badge** (JOIN members → member_name/color). Tap →
visit detail. Empty + no-results states. (RN bug #3 — badge must render in results.)

---

## 12. Shared Widgets

Port each RN component to a Flutter widget with the same visual contract:
`VisitCard` (full + `compact` variants), `SpecialityCard`, `MemberCard`, `MemberBadge`
(name + color dot/pill, `sm` size), `InsuranceCard`, `AttachmentThumbnail`, `AttachmentGrid`,
`ReminderCard`, `DocViewer` (fullscreen image via `InteractiveViewer`; PDF via `pdfx`/`printing`
or `open_filex`), `EmptyState` (icon + title + subtitle), `SectionHeader`.

---

## 13. Acceptance Criteria

All criteria from `../CareLog_Offline_Prototype_PRD.md §13` and the family-extension AC
(`../family_functionality.md`) carry over unchanged. Key ones:

**Navigation** — all routes reachable; back-nav returns to correct screen; bottom tabs persist
state (indexedStack).
**Seed** — fresh install shows 5 Self visits + 3 family members with their visits + 2 seed
insurance policies + the seeded reminders; seed runs exactly once.
**CRUD** — create/edit/delete works for visits, members, insurance; deletes cascade
(attachments, reminders, insurance docs) and remove files from disk.
**Focus refresh** — adding a visit then going back shows it immediately on Member Home and
Visit List (no stale list).
**Search** — matches across doctor/clinic/symptoms/diagnosis/notes; each result shows the
member badge.
**Attachments** — camera/gallery/PDF add; thumbnails render; viewer opens; counts correct.
**Insurance** — multiple policies per member; expiry badge classification correct
(active/expiring≤30d/expired); soonest-expiry-first ordering; ≤6 docs per policy; doc count chip
correct; helpline tap-to-call.
**Reminders** — D-1 and D-0 scheduled when notifications enabled; cancel on delete; reschedule
on time change.
**Members** — Self always present, undeletable; member delete cascades all their data.
**Settings** — currency + reminder time persist across restarts; Delete-All wipes everything
except Self and clears seed flags.
**Empty states** — shown for no visits / no reminders / no insurance / no search results.
**Offline** — app fully functional with no network; no network calls anywhere.

---

## 14. Build Phasing

The build is broken into context-window-sized phases. Execute them **in order** using the
commands and prompts in **`BUILD_STEPS.md`** (sibling of this file). Each phase ends green
(`flutter analyze` clean) before the next begins.

```
P0  Scaffold + deps + theme + run on device
P1  Domain constants + enums
P2  Drift schema + DAOs + codegen
P3  Services (file, notifications stub, settings + shared_preferences)
P4  Riverpod providers
P5  Navigation shell (go_router + 4 tabs + empty screens)
P6  Members: Family Home + Member Home + Member form
P7  Visits: speciality → list → detail → form (+ attachments)
P8  Reminders + notifications wiring
P9  Insurance: list → detail → form (+ documents)
P10 Reports + Search
P11 Settings (export, delete-all) + seed data
P12 Acceptance pass + polish
```
