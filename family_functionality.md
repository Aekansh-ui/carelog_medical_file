# CareLog — Family Functionality: Session Execution Guide

**Goal:** Add multi-member (family) support to CareLog per **Section 14** of `CareLog_Offline_Prototype_PRD.md`.
**Design locked:** Family Home landing tab + drill-into-member flow · basic identity fields only (name, relationship, DOB/age, gender, color) · family summary = upcoming follow-ups.
**No new npm packages are required.** DOB uses a plain `YYYY-MM-DD` TextInput (same as visit dates).

---

## How to use this file

Each **Family Session (F1–F8)** is sized to fit comfortably in one Claude context window. For each session:
1. Start a fresh Claude session in `/home/aekansh/Desktop/carelog_medical_record/carelog`.
2. Paste the **Prompt** block verbatim.
3. After Claude finishes, run the **Shell commands** (if any) and do the **Verify** checks.
4. When green, commit (suggested command given) and move to the next session.

> **Standing rules** (already in each prompt): do NOT recreate files that exist — Read before Edit. Target **Expo SDK 51 / RN 0.74**. Never run `npm audit fix --force` or upgrade `expo`/`react-native`/`react`/`metro` major versions. All DB access goes through repositories; screens use stores only. Every screen must render with zero records.

---

## Dependency order (why this sequence)

```
F1 Data layer  →  F2 Repositories  →  F3 Stores  →  F4 Family Home + Member Home
       (migration 003, types)        (member/visit scoping)   (navigation backbone)
                                                        │
F5 Member CRUD screens  →  F6 Thread memberId through visit flow  →  F7 Seed + summary  →  F8 Test
```
Do not reorder: screens (F4+) import stores (F3) which import repositories (F2) which need the schema/types (F1).

---

## Family Session F1 — Data layer (migration + types)

**Goal:** Schema and types for members. After this the DB has a `members` table, `visits.member_id`, and a backfilled "Self" member. No UI yet.

### Prompt
```
We are adding family (multi-member) support to CareLog per Section 14 of
../CareLog_Offline_Prototype_PRD.md. Read Section 14 first (14.2–14.4), then this
session F1 only — do not build screens or stores yet.

Rules: Expo SDK 51 / RN 0.74. Read every file before editing; do NOT recreate
existing files. Never upgrade expo/react-native/react/metro or run npm audit fix --force.

Tasks for F1:
1. Create src/constants/members.ts exactly per PRD 14.2 (RelationshipType, Gender,
   RELATIONSHIPS, GENDERS, MEMBER_COLORS, DEFAULT_SELF_MEMBER_ID).
2. Create src/types/Member.ts per PRD 14.3 (Member, CreateMemberInput,
   UpdateMemberInput, FamilySummary).
3. Edit src/types/Visit.ts: add `member_id: string;` to the Visit interface (so it
   flows into CreateVisitInput). Update src/types/index.ts if it re-exports types.
4. Create src/db/migrations/003_family.sql exactly per PRD 14.4 (members table,
   ALTER TABLE visits ADD COLUMN member_id, idx_visits_member, INSERT OR IGNORE the
   default Self member, backfill UPDATE).
5. Edit src/db/database.ts: add `{ version: 3, file: require('./migrations/003_family.sql') }`
   to the MIGRATIONS array. Confirm the require() pattern matches 001/002.
6. Add computeAge(dob: string): number to src/utils/dateUtils.ts.

Do not touch repositories, stores, or screens in this session. End by listing the
files you created/edited.
```

### Shell commands
```bash
npx tsc --noEmit            # type-check only; expect no new errors from F1
```

### Verify
- `src/constants/members.ts`, `src/types/Member.ts`, `src/db/migrations/003_family.sql` exist.
- `database.ts` MIGRATIONS array has version 3 wired.
- `npx tsc --noEmit` shows no errors introduced by these files (visit-related call sites may now flag a missing `member_id` — that's expected and fixed in F2/F6).

### Commit
```bash
git add -A && git commit -m "F1: family data layer — members table, types, migration 003"
```

---

## Family Session F2 — Repositories

**Goal:** `membersRepository` + member scoping on `visitsRepository`.

### Prompt
```
Continue CareLog family support (Section 14 of ../CareLog_Offline_Prototype_PRD.md).
Session F2 = repositories only. Read PRD 14.5 and the existing repos before editing.

Rules: Expo SDK 51 / RN 0.74. Read before edit; never recreate files; no major
version upgrades.

Tasks for F2:
1. Create src/db/membersRepository.ts exactly per PRD 14.5 (create, update,
   delete [transactional cascade], findById, findAllWithStats, getFamilySummary).
2. Edit src/db/visitsRepository.ts per PRD 14.5:
   - create(): add member_id to the INSERT columns and values.
   - add findRecentByMember(memberId, limit=5).
   - add a memberId-scoped variant of findBySpeciality (member_id + body_part_id +
     speciality_id), keeping the old signature working.
   - add countBySpecialityForMember(memberId, specialityId).
   - extend search() SELECT to JOIN members and return member_name, member_color.
3. Edit src/db/remindersRepository.ts and src/db/attachmentsRepository.ts: extend
   their JOINed SELECTs to also pull m.name AS member_name, m.color AS member_color
   (JOIN members m ON v.member_id = m.id). Add member_name/member_color as optional
   fields on the Reminder and Attachment types.

Do not edit stores or screens. List files changed at the end.
```

### Shell commands
```bash
npx tsc --noEmit
```

### Verify
- `membersRepository.ts` exists with all six methods.
- `visitsRepository.create` includes `member_id`.
- No type errors except possibly store/screen call sites awaiting F3/F6.

### Commit
```bash
git add -A && git commit -m "F2: membersRepository + member-scoped visit/reminder/attachment queries"
```

---

## Family Session F3 — Stores

**Goal:** `memberStore` + member scoping in `visitsStore`.

### Prompt
```
Continue CareLog family support (Section 14). Session F3 = Zustand stores only.
Read PRD 14.6 and the existing stores before editing.

Rules: Expo SDK 51 / RN 0.74. Read before edit; never recreate files; no major upgrades.

Tasks for F3:
1. Create src/store/memberStore.ts exactly per PRD 14.6 (members, summary,
   loadMembers, loadSummary, createMember [auto color], updateMember, deleteMember,
   getMember).
2. Edit src/store/visitsStore.ts per PRD 14.6:
   - add loadRecentVisitsForMember(memberId) (keep the family-wide one if used).
   - loadVisitsBySpeciality(bodyPartId, specialityId, memberId) — add memberId param,
     pass to the repo's member-scoped query.
   - createVisit(input): input now carries member_id; after create refresh the
     member-scoped recent list. (Do NOT import memberStore here to avoid a cycle —
     instead expose a way for screens to call memberStore.loadSummary() after create,
     or have the Family Home reload summary on focus. Document whichever you choose.)
   - add getSpecialityCountForMember(memberId, specialityId).

Do not edit screens. List files changed and note the createVisit→summary refresh
approach you chose.
```

### Shell commands
```bash
npx tsc --noEmit
```

### Verify
- `memberStore.ts` exists; `visitsStore` exposes member-scoped methods.
- No circular import between `memberStore` and `visitsStore`.

### Commit
```bash
git add -A && git commit -m "F3: memberStore + member-scoped visitsStore actions"
```

---

## Family Session F4 — Family Home + Member Home (navigation backbone)

**Goal:** Tab 1 becomes Family Home; the body-map Home moves to `member/[memberId]`. App is navigable end-to-end (even before member CRUD / seed).

### Prompt
```
Continue CareLog family support (Section 14). Session F4 = navigation backbone +
two screens. Read PRD 14.7, 14.8.1, 14.8.2, 14.8.5, 14.8.6 and the CURRENT
app/(tabs)/index.tsx before editing (the body-map Home content moves to the member
screen — reuse it, don't rewrite from scratch).

Rules: Expo SDK 51 / RN 0.74. Read before edit; never recreate files; no major upgrades.

Tasks for F4:
1. Create app/member/[memberId].tsx = the EXISTING body-map Home content (2-col
   body-part grid + recent visits + search/bell header), scoped to memberId:
   - read memberId via useLocalSearchParams; resolve member via memberStore.getMember
     (call loadMembers if empty) for the header title.
   - on mount call visitsStore.loadRecentVisitsForMember(memberId).
   - body-part tap → router.push({ pathname: '/speciality/'+id, params: { memberId } }).
   - keep the Stack.Screen header (title = member name + search + bell badge).
2. Rewrite app/(tabs)/index.tsx as the Family Home per PRD 14.8.1:
   - loadMembers + loadSummary on mount AND on focus (useFocusEffect).
   - 2-col FlatList of MemberCard → router.push('/member/'+id).
   - header-right "＋ Add" → router.push('/members/new').
   - "Upcoming Follow-ups" section from summary.upcomingFollowUps; row tap →
     router.push('/visits/'+visit_id). EmptyState when none / no members.
3. Create src/components/MemberCard.tsx (PRD 14.8.5) and
   src/components/MemberBadge.tsx (PRD 14.8.6).
4. Edit app/_layout.tsx: register member/[memberId] (headerShown:false),
   members/new (modal), members/edit/[memberId] (modal) per PRD 14.7.
5. Edit app/(tabs)/_layout.tsx: Tab 1 → title 'Family', icon 'account-group'.

The members/new and members/edit screens come in F5 — if needed, create minimal
placeholder screens so the routes resolve, and note that F5 fills them in.
List files changed.
```

### Shell commands
```bash
npx expo start --clear
# press s if needed to use Expo Go, then scan the QR
```

### Verify
- Family tab shows a **Self** card (from the F1 migration backfill).
- Tapping Self opens the body-map with "Self" in the header; the 5 original seeded visits appear in recent/visit-list.
- Body part → speciality → visit list → visit detail still works.
- No crash on the other three tabs.

### Commit
```bash
git add -A && git commit -m "F4: Family Home dashboard + member-scoped Member Home + nav routes"
```

---

## Family Session F5 — Member CRUD screens

**Goal:** Add / edit / delete members.

### Prompt
```
Continue CareLog family support (Section 14). Session F5 = member create/edit/delete
screens. Read PRD 14.8.3 and look at an existing modal form (app/visits/new.tsx /
src/components/VisitForm.tsx) to match style/validation.

Rules: Expo SDK 51 / RN 0.74. Read before edit; never recreate files; no major upgrades.

Tasks for F5:
1. app/members/new.tsx (modal): fields per PRD 14.8.3 — name (required),
   relationship (chips/SegmentedButtons from RELATIONSHIPS; default SELF if no members
   exist else OTHER), date_of_birth (plain YYYY-MM-DD TextInput, validate on blur,
   optional), gender (SegmentedButtons, optional). Save → memberStore.createMember →
   router.back(). FR-MEM-01..03.
2. app/members/edit/[memberId].tsx (modal): pre-fill from memberStore.getMember;
   save → memberStore.updateMember. Add a destructive "Delete Member" button →
   confirmation Alert (warns all visits/attachments/reminders are deleted) →
   memberStore.deleteMember → router.back(). Block deleting the LAST remaining member
   with an alert. FR-MEM-04, FR-MEM-05.
3. If F4 created placeholders for these routes, replace them fully.
4. Make MemberCard / the Member Home header offer an edit affordance
   (e.g., long-press card or an edit icon) → router.push('/members/edit/'+id).

List files changed.
```

### Shell commands
```bash
npx expo start --clear
```

### Verify
- "＋ Add" creates a member; the card appears with a distinct color.
- Edit pre-fills and persists.
- Delete removes the member and their data; deleting the last member is blocked.

### Commit
```bash
git add -A && git commit -m "F5: member add/edit/delete screens"
```

---

## Family Session F6 — Thread memberId through the visit flow

**Goal:** Make the whole visit flow member-aware and add member badges to family-wide tabs.

### Prompt
```
Continue CareLog family support (Section 14). Session F6 = thread memberId through
the visit flow + member badges. Read PRD 14.8.4 and each target screen before editing.

Rules: Expo SDK 51 / RN 0.74. Read before edit; never recreate files; no major upgrades.

Tasks for F6 (per PRD 14.8.4 table):
1. app/speciality/[bodyPartId].tsx: read memberId param; use
   getSpecialityCountForMember(memberId, specialityId) for badges; forward memberId
   when pushing to the visit list AND to /visits/new.
2. app/visits/list/[specialityId].tsx: read memberId; call
   loadVisitsBySpeciality(bodyPartId, specialityId, memberId); forward memberId to
   /visits/new.
3. app/visits/new.tsx (and VisitForm if it owns the form state): read memberId from
   params, seed it into form state, include member_id in createVisit. After save, if
   you chose the "screen triggers summary refresh" approach in F3, call
   memberStore.loadSummary().
4. app/visits/edit/[visitId].tsx: preserve member_id from the loaded visit on update
   (not user-editable).
5. app/visits/[visitId].tsx: render a member chip (MemberBadge) next to the
   speciality/body-part chips.
6. app/(tabs)/reminders.tsx: show MemberBadge on each ReminderCard
   (member_name/member_color now come from remindersRepository).
7. app/(tabs)/reports.tsx: show MemberBadge on each attachment card.

Verify a visit created under one member never appears under another. List files changed.
```

### Shell commands
```bash
npx expo start --clear
```

### Verify
- Speciality counts are per-member.
- Adding a visit inside Member A's flow saves under A only (AC-F09/AC-F10).
- Visit detail shows the member badge; Reminders & Reports rows show member badges.

### Commit
```bash
git add -A && git commit -m "F6: member-scoped visit flow + member badges on reminders/reports"
```

---

## Family Session F7 — Seed + family summary polish

**Goal:** Demo family data + correct delete-all behavior.

### Prompt
```
Continue CareLog family support (Section 14). Session F7 = seed data + delete-all.
Read PRD 14.9 and the current src/db/seed.ts, app/_layout.tsx,
app/(tabs)/settings.tsx before editing.

Rules: Expo SDK 51 / RN 0.74. Read before edit; never recreate files; no major upgrades.

Tasks for F7 (per PRD 14.9):
1. src/db/seed.ts: in the existing MOCK_VISITS loop set member_id =
   DEFAULT_SELF_MEMBER_ID. Add seedFamilyIfNeeded() guarded by key
   '@CareLog_seeded_family_v1': create Priya (SPOUSE,F), Aarav (CHILD,M, DOB ~8y ago),
   Sita (PARENT,F); add 1–2 mock visits each with their member_id; create at least one
   future-dated follow-up + reminder for a new member.
2. app/_layout.tsx: call seedFamilyIfNeeded() right after seedIfNeeded(), before
   loadSettings(). Keep everything behind the existing isReady splash.
3. app/(tabs)/settings.tsx handleDeleteAll: also delete non-Self members
   (DELETE FROM members WHERE id != DEFAULT_SELF_MEMBER_ID) and remove BOTH seed keys
   ('@CareLog_seeded_v1' and '@CareLog_seeded_family_v1'). Keep the Self member.

List files changed.
```

### Shell commands
```bash
# To re-trigger seeds on your already-seeded device, either use Settings →
# "Delete All Data" then restart, OR clear Expo Go's app data for CareLog.
npx expo start --clear
```

### Verify
- Family Home shows Self + Priya + Aarav + Sita.
- "Upcoming Follow-ups" lists follow-ups across multiple members with correct badges.
- Settings → Delete All Data → restart → clean family re-seeds (Self preserved).

### Commit
```bash
git add -A && git commit -m "F7: family seed data + delete-all keeps Self and resets seeds"
```

---

## Family Session F8 — Test & acceptance

**Goal:** Walk the Section 14.10 acceptance criteria; fix any gaps.

### Prompt
```
Final CareLog family session F8 = verification. Read PRD Section 14.10. Do NOT add new
features. Walk every AC-F01..AC-F17, and for each tell me PASS/FAIL with the file:line
that satisfies it (or the fix needed). Then fix only the FAILs you find, smallest change
possible. Read before edit; never recreate files; no major version upgrades.
```

### Shell commands
```bash
npx tsc --noEmit
npx expo start --clear
```

### Verify — run through the AC-F list on device
- [ ] AC-F01–F05 Member CRUD + colors
- [ ] AC-F06–F10 Member-scoped flow isolation
- [ ] AC-F11–F12 Migration backfill (old "Self" visits intact) + no duplication
- [ ] AC-F13–F15 Family summary + badges + live counts
- [ ] AC-F16–F17 Empty states

### Commit
```bash
git add -A && git commit -m "F8: family acceptance pass + fixes"
```

---

## Rollback / safety notes

- The migration only **adds** a table/column and backfills; it never drops v1 data. If anything goes wrong mid-session, `git stash` or checkout the file — the DB already on the device is unaffected by code edits until the new migration version runs.
- If the device DB gets into a bad state during testing, the clean reset is **Settings → Delete All Data → restart** (after F7), or clear Expo Go app storage for CareLog.
- Migration 003 runs exactly once per device (tracked in `schema_migrations`). To re-run it during development you must clear app storage (which resets `schema_migrations`).

---

*Companion to CareLog_Offline_Prototype_PRD.md v1.1-family · Section 14.*
