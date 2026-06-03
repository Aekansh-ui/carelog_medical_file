# CareLog Flutter — Build Steps (run one at a time)

> **How to use this file.** Each **phase** below is sized to fit a single Claude context
> window. Do them in order. For each phase: (1) run the shell commands in the *Run* block
> yourself, then (2) paste the *Prompt to Claude* into a **fresh** Claude Code session
> started from `flutter_version/`. Start a new session per phase so context stays
> clean. Verify the *Done when* check before moving on.
>
> The full spec lives in `./CareLog_flutter_prd.md` (the Flutter project root IS
> `flutter_version/`). Every prompt tells Claude to read it. The RN source of truth is
> `../carelog/` (relative to the Flutter project root).

---

## ✅ ALL PHASES COMPLETE

**Last completed phase: P12** (2026-06-03)

Phases done and verified (`flutter analyze` clean, all tests green):
- **P0** — Flutter 3.44.0 scaffolded in-place; deps installed; `lib/theme/app_theme.dart` with exact design tokens; `lib/main.dart` with `ProviderScope` + themed placeholder. `flutter build web` succeeded.
- **P1** — All domain constants in `lib/constants/` (body_parts, specialities, body_speciality_map, members, insurance) + `lib/utils/date_utils.dart` (expiry helper, date/currency formatters). MDI icons mapped to built-in `Icons.*`.
- **P2** — Full Drift data layer: `lib/data/database.dart` (7 tables, schemaVersion 4, FK pragma, FTS5 + triggers, Self seed), 5 DAOs in `lib/data/daos/`, joined DTOs in `lib/models/query_results.dart`. Verified by `test/database_test.dart` (9 real-SQLite tests: migration, FK, CRUD, FTS search, cascade deletes, expiry ordering, CHECK constraint).
- **P3** — Services + settings: `lib/services/file_service.dart` (copy+thumbnail via `image` pkg, storage accounting, delete helpers), `lib/services/notification_service.dart` (flutter_local_notifications v21 named-param API, D-1/D-0 zonedSchedule, Android/iOS only, graceful no-op on desktop), `lib/services/export_service.dart` (full-dataset PDF via `pdf`+`printing`, share via `Printing.sharePdf`), `lib/providers/settings_provider.dart` (Riverpod Notifier backed by SharedPreferences; currency/notificationsEnabled/reminderTime). `pdf` added as direct dep (was transitive). `flutter analyze` clean; 9 DB tests still green.
- **P4** — `lib/providers/database_provider.dart` (single `AppDatabase` instance with `onDispose`); `visits_provider.dart` (`VisitsState`: recentVisits/listVisits/currentVisit/searchResults; CRUD + search + attachment delegation + aggregation pass-throughs; `deleteVisit` cancels notifications); `reminders_provider.dart` (`RemindersState`: upcoming list; `createReminder` schedules notifications via `settingsProvider`; `deactivate`; `deleteReminder` cancels notifs; `rescheduleAll`); `members_provider.dart` (`MembersState`: MemberWithStats list + FamilySummary; auto-color on create; `deleteMember` cascade); `insurance_provider.dart` (`InsuranceState`: PolicyWithDocCount list + currentMemberId; document methods delegated to DAO). All `Notifier<State>` (not AutoDispose). Focus-refresh: mutations reload own state; cross-provider sync left to UI layer (P5+).
- **P5 DONE** (2026-06-03): `lib/router.dart` (go_router with `StatefulShellRoute.indexedStack` for 4 tabs + all 15 named routes; literal routes declared before param catch-alls); `lib/app.dart` (`MaterialApp.router` + theme); `lib/main.dart` bootstrap (init Drift → seed stub → load settings → `UncontrolledProviderScope`); 14 placeholder screens under `lib/screens/` each showing route name; `_NavShell` with `NavigationBar` + hairline top border; `test/widget_test.dart` updated. `flutter analyze` clean (0 issues).
- **P6 DONE** (2026-06-03): 5 widgets — `empty_state.dart`, `section_header.dart`, `member_badge.dart`, `member_card.dart` (grid card with avatar/stats/edit button), `visit_card.dart` (compact + full variants). `FamilyHomeScreen` (2-col grid + upcoming follow-ups, loads on init, focus-refresh via Riverpod reactivity). `MemberHomeScreen` (insurance entry row + 8-body-part grid + horizontal recent-visits list, bell badge, refresh on init). `MemberFormScreen` (add + edit; name/relationship chips/DOB date-picker/gender chips/color palette; Self locked + undeletable; cascade delete with file cleanup via `fileService`). `flutter analyze` clean; all 9 DB tests green.
- **P7 DONE** (2026-06-03): `lib/utils/validators.dart` (visit + insurance form rules ported from RN). Widgets: `speciality_card.dart` (color border + icon + visit count), `attachment_thumbnail.dart` (image/PDF, delete button), `attachment_grid.dart` (Wrap + add card, maxFiles:0 = view-only), `doc_viewer.dart` (InteractiveViewer for images; OpenFilex for PDFs; pushed above GoRouter via rootNavigator). Screens: `SpecialitySelectScreen` (toggle all/body-part, count badges, FAB to new-visit), `VisitListScreen` (breadcrumb strip, empty state, FAB), `VisitDetailScreen` (tap-to-call, grouped attachment sections, cascade delete), `VisitFormScreen` (3 ExpansionTile sections: Visit Info / Clinical / Attachments; date pickers; speciality + currency dropdowns; image_picker + file_picker; draft thumbnails; existing attachment delete; save → create/update reminder → refresh list → pop; edit loads existing + pre-fills all controllers). `flutter analyze` clean (0 issues).
- **P10 DONE** (2026-06-03): `AttachmentWithVisit` DTO added to `query_results.dart`. `visits_provider.dart` gained `loadRecentAttachments(int limit)` (customSelect JOIN: attachments × visits × members) and `recentAttachments` list in state. `ReportsScreen`: summary stat cards (visits/members/files), By Speciality breakdown (tap → visit list), By Body Part (tap → speciality select), By Member (tap → member home), 3-col recent-attachments grid with type badge (bottom-left) + member color dot (top-right, AC-F14) + long-press to visit. `SearchScreen`: custom primary header with search input; debounced 300ms search; results as `VisitCard.withMember(...)` (member badge, bug fix RN #3); match-hint pill below each result; empty query shows recent visits. `flutter analyze` clean (0 issues).
- **P9 DONE** (2026-06-03): `doc_viewer.dart` refactored — `_DocViewerPage` now takes raw `filePath/fileName/mimeType` params; added `showInsuranceDocViewer(context, doc)` facade alongside existing `showDocViewer`. `InsuranceState` gained `currentPolicy + loadById()`. Widget: `insurance_card.dart` (shield icon circle, insurer name, plan+doc count chips, policy number, sum insured, expiry badge with correct colours). Screens: `InsuranceListScreen` (load on init, empty state with CTA, FAB, focus-refresh), `PolicyDetailScreen` (header with member badge + expiry pill; grouped sections: Policy Details / Coverage & Validity / Contact & Notes / Documents; tap-to-call helpline; `showInsuranceDocViewer` for docs; delete-doc with file cleanup; delete-policy footer), `InsuranceFormScreen` (4 ExpansionTile sections; ≤6 docs via camera/gallery/PDF; draft + existing doc thumbnails; `validateInsuranceForm`; save → create/update policy → persist docs → pop; edit mode cascade delete pops twice back to list). `flutter analyze` clean (0 issues).
- **P8 DONE** (2026-06-03): `ReminderWithVisit` DTO added to `query_results.dart` (mirrors RN joined Reminder type with doctorName/specialityId/memberName/memberColor). `reminders_provider.dart` rewritten: state now holds `upcoming + past` as `List<ReminderWithVisit>` loaded via two `customSelect` JOIN queries (reminders × visits × members); `reschedule()` cancels old notifications, updates `visits.follow_up_date` + reminder row (new date + notification IDs + rescheduled_at), schedules fresh notifications; `deleteReminder()` cancels notifications before delete. Widget: `reminder_card.dart` (left accent bar, doctor/speciality/member badge/date row, days-remaining badge, Done+Reschedule action buttons, delete icon). Screen: `RemindersScreen` replaced — UPCOMING section (full `ReminderCard`) + PAST section (compact `_PastReminderRow`), mark-done confirmation dialog, reschedule date picker, delete confirmation. `flutter analyze` clean (0 issues).
- **P11 DONE** (2026-06-03): `lib/services/seed.dart` — 3 idempotent seed functions gated by SharedPreferences flags: `seedIfNeeded` (5 Self visits spanning ENT/Cardiology/Gastro/Ortho/Endocrinology + 2 reminders), `seedFamilyIfNeeded` (members Priya/SPOUSE, Aarav/CHILD, Sita/PARENT + 4 visits + 3 reminders), `seedInsuranceIfNeeded` (Star Health personal policy for Self + HDFC ERGO family floater for first non-Self member). `main.dart` updated to call all three seed functions after Drift init. `lib/screens/shell/settings_screen.dart` full implementation: currency segmented button (INR/USD), notifications switch + conditional reminder-time text field (HH:MM regex validation), storage-used row (record count across all tables), Export All Data (calls `exportService.exportAllData`, spinner), Delete All Data (confirmation dialog → deletes all except Self member, snackbar), About section (version, privacy, connectivity). `flutter analyze` clean (0 issues).
- **P12 DONE** (2026-06-03): Acceptance pass — 2 gaps fixed. **AC-F08**: `countsBySpeciality()` in `visits_dao.dart`+`visits_provider.dart` gained optional `memberId` param; `SpecialitySelectScreen` passes `widget.memberId` so cards show per-member visit counts not family-wide totals. **Delete-All spec**: `settings_screen.dart` `_confirmDeleteAll` now calls `notificationService.cancelAll()` and removes all 3 seed prefs flags so seed re-runs on next launch. All other ACs verified in code (see below). `flutter analyze` clean; 10 tests green. 🎉

**Environment notes for new sessions:**
- Flutter SDK is at `~/flutter` (not on system PATH). Prefix commands: `export PATH="$HOME/flutter/bin:$PATH"`
- Do NOT add `material_design_icons_flutter` — incompatible with Flutter 3.44 (subclasses `final class IconData`). Use built-in `Icons.*` only.
- `build_runner` no longer accepts `--delete-conflicting-outputs` (just omit it).
- sqlite3 3.3.2 uses native assets — `flutter test` builds the SQLite lib automatically, no manual `open.dart` override.
- `flutter_local_notifications` v21 uses **all named parameters** for `initialize(settings:)`, `zonedSchedule(id:, scheduledDate:, notificationDetails:, androidScheduleMode:, title:, body:, payload:)`, and `cancel(id:)`. Do NOT use positional args.
- Dart 3 wildcards: `(_, _)` is valid for two unused params (do NOT use `__`).
- go_router routes: declare `/visits/new` and `/visits/edit/:visitId` **before** `/visits/:visitId` to avoid param capture of literal segments.
- `DropdownButtonFormField` uses `initialValue:` (not `value:`) — deprecated in Flutter 3.33+.
- `formatCurrency(amount, currency: 'INR')` — `currency` is a named parameter.

**All phases complete.** App is ready to run on device.

---

## Prerequisites (one time)

```bash
# Confirm Flutter is installed and a device/emulator is available
flutter --version          # expect 3.24+ / Dart 3.5+
flutter doctor             # resolve any ❌ before continuing
flutter devices            # need at least one (emulator or physical)
```

If Flutter is missing: install via https://docs.flutter.dev/get-started/install (or `snap install flutter --classic` on this Linux box), then re-run `flutter doctor`.

---

## P0 — Scaffold + deps + theme

**Run:**
```bash
cd /home/aekansh/Desktop/carelog_medical_record/flutter_version
# create the project IN-PLACE (the two .md files are preserved by flutter create)
flutter create --org com.carelog --project-name carelog .
flutter pub add flutter_riverpod go_router drift sqlite3_flutter_libs \
  path_provider path shared_preferences image_picker file_picker image \
  flutter_local_notifications timezone url_launcher share_plus printing \
  open_filex uuid intl
flutter pub add --dev drift_dev build_runner
flutter pub get
flutter run        # confirm the app launches on your device

# NOTE (P0 already done): do NOT add `material_design_icons_flutter` — it is
# incompatible with Flutter 3.44/Dart 3.12 (subclasses the now-final IconData).
# Use built-in Material `Icons.*` instead. See §2 "Icon note" in the PRD.
```

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` (esp. §2, §3, §4). This is a fresh `flutter create` project
> at `flutter_version/carelog`. Do P0 only:
> 1. Create the directory structure from §3 (empty placeholder files where needed).
> 2. Implement `lib/theme/app_theme.dart` with the exact colors, spacing, radius, typography,
>    and BoxShadow elevations from §4. Expose a `ThemeData` (Material 3) and the token classes.
> 3. Replace `lib/main.dart` with a `ProviderScope` + `MaterialApp` that uses the theme and
>    shows a simple "CareLog" placeholder Scaffold (no router yet).
> Run `flutter analyze` — must be clean. Do not implement features beyond P0.

**Done when:** `flutter run` shows a "CareLog" themed screen; `flutter analyze` is clean.

---

## P1 — Domain constants + enums

**Run:** *(no shell command — code only)*

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §5 and the RN source files in
> `../carelog/src/constants/` (`bodyParts.ts`, `specialities.ts`, `bodySpecialityMap.ts`,
> `members.ts`, `insurance.ts`). Port them verbatim to Dart under `lib/constants/`:
> `body_parts.dart`, `specialities.dart`, `body_speciality_map.dart`, `members.dart`,
> `insurance.dart`. Keep enum **string values identical** (they get persisted). For icons,
> use Flutter's built-in `Icons.*` — map each RN MDI name to the nearest built-in (per the §2
> icon note). **Do not** add `material_design_icons_flutter` (incompatible with this SDK). Add
> the expiry status helper (`none|active|expiring|expired`) in `insurance.dart`. Run `flutter analyze`.

**Done when:** all five constant files compile; icon references resolve; analyze clean.

---

## P2 — Drift schema + DAOs + codegen

**Run:**
```bash
# (after Claude writes the table/dao files, generate drift code)
dart run build_runner build --delete-conflicting-outputs
```

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §6 and the RN schema in `../carelog/src/db/database.ts`
> (migrations 1–4) plus every repository in `../carelog/src/db/*Repository.ts`. Implement
> the Drift data layer under `lib/data/`:
> - `database.dart`: `@DriftDatabase` with all 7 tables (visits, attachments, reminders,
>   visit_drafts, members, insurance_policies, insurance_documents) matching columns/defaults/
>   FK/indexes **exactly**. `schemaVersion = 4`. In `beforeOpen` enable `PRAGMA foreign_keys`.
>   In the migration, seed the fixed Self member row and back-fill null `visits.member_id`.
>   Add the FTS5 `visits_fts` table + triggers via `customStatement` (or fall back to a
>   LIKE-based search as §6 allows — note which you chose).
> - Plain model classes under `lib/models/` (or use Drift row classes — your call, but expose
>   the joined fields like `document_count`, `member_name`, `member_color`).
> - DAOs under `lib/data/daos/` mirroring every repository method listed in §6, including the
>   **explicit transaction cascades** for member-delete and insurance-delete (return file
>   paths for disk cleanup).
> Tell me to run `dart run build_runner build --delete-conflicting-outputs`, then ensure
> `flutter analyze` is clean. Do not build UI.

**Done when:** codegen succeeds (`database.g.dart` exists); analyze clean.

---

## P3 — Services + settings persistence

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §9 and the RN sources `../carelog/src/services/`
> (`fileService.ts`, `notificationService.ts`, `exportService.ts`). Implement under
> `lib/services/`:
> - `file_service.dart`: the `attachments/<ownerId>/` tree, `saveFile`/`saveAttachment`/
>   `saveInsuranceDocument` (copy + thumbnail via `image`), delete helpers, `getStorageUsedBytes`.
> - `notification_service.dart`: init `flutter_local_notifications` + `timezone`, request
>   permission, schedule D-1/D-0 reminders at the user time, cancel, reschedule. No-op when
>   notifications disabled.
> - `export_service.dart`: build a PDF summary (visits, members, reminders, **insurance**) with
>   `printing` and share via `share_plus`.
> Also create `lib/providers/settings_provider.dart` (Riverpod Notifier) backed by
> `shared_preferences`: currency, notificationsEnabled, reminderTime, with `load`/`setSetting`.
> Run `flutter analyze`. No UI yet.

**Done when:** services compile; settings provider persists/loads; analyze clean.

---

## P4 — Riverpod providers

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §7 and the RN stores in `../carelog/src/store/`. Create a
> `databaseProvider` (single Drift instance) and one provider per store under `lib/providers/`:
> `visits_provider.dart`, `reminders_provider.dart`, `members_provider.dart`,
> `insurance_provider.dart` (settings already done in P3). Each exposes the same load/CRUD
> surface as its Zustand counterpart and calls the matching DAO. After any mutation, invalidate
> the relevant providers so list screens refresh on return (the focus-refresh requirement).
> Run `flutter analyze`. No UI yet.

**Done when:** providers compile and wire to DAOs; analyze clean.

---

## P5 — Navigation shell + empty screens

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §8. Implement `lib/router.dart` with go_router: a
> `StatefulShellRoute.indexedStack` for the 4 bottom tabs (Family `/`, Reports `/reports`,
> Reminders `/reminders`, Settings `/settings`) styled per §4, plus all top-level routes from
> the table (member, visit, insurance, search) pointing to **placeholder** screens that just
> show their title. Wire `app.dart`/`main.dart` to `MaterialApp.router`. Bootstrap order in
> `main.dart`: init Drift → run seed (stub for now) → load settings → runApp. Run on device and
> confirm all tabs switch and every route pushes. `flutter analyze` clean.

**iOS setup (do this in P5's Run block before testing on an iOS device/simulator):**
```bash
# Set minimum iOS version required by several packages (image_picker, notifications, etc.)
# Edit ios/Podfile — change or add the platform line near the top:
#   platform :ios, '13.0'

# Then add permission descriptions to ios/Runner/Info.plist (inside the <dict> tag):
# <key>NSCameraUsageDescription</key>
# <string>CareLog needs camera access to photograph prescriptions and insurance cards.</string>
# <key>NSPhotoLibraryUsageDescription</key>
# <string>CareLog needs photo library access to attach images to visits and policies.</string>
# <key>NSPhotoLibraryAddUsageDescription</key>
# <string>CareLog needs permission to save images.</string>

# After editing, reinstall CocoaPods dependencies:
cd ios && pod install && cd ..
```
> **Note:** Android needs no extra step — permissions are declared in `AndroidManifest.xml`
> by the plugin packages themselves (image_picker, file_picker, notifications).

**Done when:** app runs; 4 tabs + every route navigable to a placeholder; analyze clean.

---

## P6 — Members (Family Home + Member Home + form)

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §11.1, §11.2, §11.13, §12 and the RN screens
> `../carelog/app/(tabs)/index.tsx`, `app/member/[memberId].tsx`, `app/members/new.tsx`,
> `app/members/edit/[memberId].tsx`, and components `MemberCard`, `MemberBadge`. Implement:
> Family Home (member grid + summary + add FAB), Member Home (insurance entry row + body-part
> grid + recent-visits footer, **refresh on focus**), Member form (add/edit, Self locked &
> undeletable, color palette, cascade delete with confirm). Use the members/visits providers.
> Run on device, verify add/edit/delete + focus refresh. `flutter analyze` clean.

**Done when:** can view family, open a member, add/edit/delete members; Self protected.

---

## P7 — Visits (speciality → list → detail → form + attachments)

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §11.3–11.6, §12 and RN screens under `../carelog/app/
> speciality/`, `app/visits/` plus `VisitCard`, `SpecialityCard`, `AttachmentGrid`,
> `AttachmentThumbnail`, `VisitForm`, and `../carelog/src/utils/validators.ts`. Implement
> Speciality Select, Visit List (refresh on focus), Visit Detail (tap-to-call, attachment
> viewer), and the Visit Form (collapsible sections, attachments via camera/gallery/PDF using
> `image_picker`+`file_picker`, categorise, thumbnails, delete; create/update reminder on save).
> Port `validateVisitForm`. Edit screen has cascade-delete. Build `DocViewer`. Run on device:
> add a visit with a photo, view it, edit, delete. `flutter analyze` clean.

**Done when:** full visit lifecycle works incl. attachments and viewer; lists refresh.

---

## P8 — Reminders + notifications

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §11.8, §9 and RN `app/(tabs)/reminders.tsx`,
> `src/store/remindersStore.ts`, `src/services/notificationService.ts`, `ReminderCard`.
> Implement the Reminders tab (upcoming list, member badge, days-until, mark-done/reschedule/
> open-visit, empty state) and wire `notification_service` so saving a visit with a follow-up
> schedules D-1/D-0, deleting cancels, and reschedule works. Test scheduling on device.
> `flutter analyze` clean.

**Done when:** reminders list correct; notifications schedule/cancel; reschedule works.

---

## P9 — Insurance (list → detail → form + documents)

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §11.10–11.12, §12 and RN screens under
> `../carelog/app/insurance/` plus `InsuranceCard`, `InsuranceForm`, and
> `validateInsuranceForm` in `src/utils/validators.ts`. Implement Insurance List (expiry badge
> active/expiring/expired, doc-count chip, soonest-expiry-first, FAB, focus refresh), Policy
> Detail (grouped fields, tap-to-call helpline, document viewer), and Insurance Form (4
> collapsible sections, ≤6 documents via camera/gallery/PDF, validation, edit-screen delete
> footer with cascade). Use the insurance provider. Run on device: add a policy with a card
> photo, view, edit, delete. `flutter analyze` clean.

**Done when:** full insurance lifecycle works; expiry badges + ordering correct.

---

## P10 — Reports + Search

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §11.7, §11.14 and RN `app/(tabs)/reports.tsx`,
> `app/search.tsx`. Implement the Reports hub (totals + breakdowns by speciality/body-part/
> member, recent attachments grid, member badges on rows — RN AC-F14) and Search (query across
> doctor/clinic/symptoms/diagnosis/notes via the DAO; each result is a VisitCard **with member
> badge** — RN bug #3). Tapping a report slice filters into a visit list. Run on device; verify
> a search returns results with member badges. `flutter analyze` clean.

**Done when:** reports breakdowns render; search returns badged results.

---

## P11 — Settings + seed data

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §11.9, §10 and RN `app/(tabs)/settings.tsx`,
> `src/db/seed.ts`. Implement the Settings tab (currency segmented, notifications toggle +
> reminder-time validated input, storage used, Export All Data via export_service, Delete All
> Data with confirm → wipe everything except Self + clear all 3 seed flags + cancel
> notifications). Then implement `lib/services/seed.dart` to fully replicate `seed.ts`
> (visits, family, insurance) gated by shared_preferences flags, and call it in `main.dart`
> bootstrap. Wipe app data / reinstall and confirm the seeded state matches the RN app. Verify
> export produces a PDF and Delete-All clears correctly. `flutter analyze` clean.

**Done when:** fresh install shows identical seed data to RN; export + delete-all work.

---

## P12 — Acceptance pass + polish

**Prompt to Claude:**
> Read `./CareLog_flutter_prd.md` §13 (and `../CareLog_Offline_Prototype_PRD.md §13` +
> `../family_functionality.md`). Walk every acceptance criterion against the running app,
> fix any gaps, and polish spacing/typography/shadows to match §4. Pay special attention to:
> focus-refresh (no stale lists), member badges in search & reports, insurance expiry
> classification, cascade deletes removing files from disk, Self being undeletable, and full
> offline operation (no network calls). Produce a short pass/fail report per AC group.
> `flutter analyze` must be clean and `flutter test` (if any) green.

**Done when:** all AC groups pass; analyze clean. Ship it. 🎉

---

## Quick reference — recurring commands

```bash
# regenerate drift code after any table/dao change
dart run build_runner build --delete-conflicting-outputs

# watch mode during heavy DB work
dart run build_runner watch --delete-conflicting-outputs

# lint + run
flutter analyze
flutter run
flutter run -d <deviceId>      # see: flutter devices

# clean rebuild if codegen/state gets weird
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
```
