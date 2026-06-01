## CareLog Handoff Note
**Date:** 2026-06-01
**Session Completed:** 5 (full project audit + pre-run fixes)
**Last command completed:** Audit & fix — app ready for first run

---

### Files Created So Far

**App screens**
```
carelog/app/_layout.tsx
carelog/app/(tabs)/_layout.tsx
carelog/app/(tabs)/index.tsx
carelog/app/(tabs)/reports.tsx
carelog/app/(tabs)/reminders.tsx
carelog/app/(tabs)/settings.tsx
carelog/app/search.tsx
carelog/app/speciality/[bodyPartId].tsx
carelog/app/visits/list/[specialityId].tsx
carelog/app/visits/new.tsx
carelog/app/visits/[visitId].tsx
carelog/app/visits/edit/[visitId].tsx
```

**Shared components**
```
carelog/src/components/AttachmentGrid.tsx
carelog/src/components/AttachmentThumbnail.tsx
carelog/src/components/EmptyState.tsx
carelog/src/components/ReminderCard.tsx
carelog/src/components/SectionHeader.tsx
carelog/src/components/SpecialityCard.tsx
carelog/src/components/VisitCard.tsx
carelog/src/components/VisitForm.tsx
```

**Constants / types / utils / DB / store / services**
```
carelog/src/constants/bodyParts.ts
carelog/src/constants/bodySpecialityMap.ts
carelog/src/constants/specialities.ts
carelog/src/constants/theme.ts
carelog/src/db/attachmentsRepository.ts
carelog/src/db/database.ts
carelog/src/db/migrations/001_create_tables.sql
carelog/src/db/migrations/002_create_fts.sql
carelog/src/db/remindersRepository.ts
carelog/src/db/seed.ts
carelog/src/db/visitsRepository.ts
carelog/src/services/exportService.ts
carelog/src/services/fileService.ts
carelog/src/services/notificationService.ts
carelog/src/store/remindersStore.ts
carelog/src/store/settingsStore.ts
carelog/src/store/visitsStore.ts
carelog/src/types/Attachment.ts
carelog/src/types/index.ts
carelog/src/types/Reminder.ts
carelog/src/types/Visit.ts
carelog/src/utils/dateUtils.ts
carelog/src/utils/formatters.ts
carelog/src/utils/theme.ts
carelog/src/utils/validators.ts
```

**Assets**
```
carelog/assets/notification-icon.png   ← placeholder (copied from icon.png)
```

---

### Session 5 Fixes Applied

| File | Fix |
|---|---|
| `app/(tabs)/index.tsx` | Removed `<Appbar.Header>` block; added `<Stack.Screen options={{ headerRight: ... }}>` with search icon + bell badge |
| `app/(tabs)/settings.tsx` | Fixed import `@src/constants/theme` → `@src/utils/theme`; removed `<Appbar.Header>` block; added Storage Used row (calls `fileService.getStorageUsedBytes()`); added Reminder Time TextInput (reads/writes `settingsStore` key `reminderTime`) |
| `assets/notification-icon.png` | Created placeholder (copied from `assets/images/icon.png`) to satisfy `app.json` expo-notifications plugin config |

---

### Audit Results (Session 5)

All items below were audited and confirmed clean:

- ✅ All `@src/*` path aliases resolve to existing files
- ✅ `babel.config.js` — `babel-preset-expo` in SDK 51 reads tsconfig paths automatically, no extra plugin needed
- ✅ `app/_layout.tsx` — `initDatabase()` → `seedIfNeeded()` → `loadSettings()` all called sequentially, guarded by `isReady` splash
- ✅ Every screen calls the correct store load action in `useEffect` on mount
- ✅ All `router.push()` strings match actual file paths in `app/`
- ✅ `(tabs)/_layout.tsx` registers exactly 4 tabs: index, reports, reminders, settings
- ✅ Stack in `app/_layout.tsx` registers all 7 routes: `(tabs)`, `speciality/[bodyPartId]`, `visits/list/[specialityId]`, `visits/[visitId]`, `visits/new`, `visits/edit/[visitId]`, `search`

---

### Known Issues (unchanged from Session 4)

| # | File | Issue |
|---|------|-------|
| 1 | `src/services/exportService.ts` | Imports `react-native-html-to-pdf` which requires native linking — works in a bare/dev-client build but will throw at runtime in Expo Go. The package is in `package.json` so a bare build should be fine. |
| 2 | `react-native-pdf` | Listed in `package.json` but never imported or used by any screen. The attachment viewer uses `Linking.openURL` for PDFs instead. Either remove the dep or implement a proper in-app PDF viewer in a later session. |
| 3 | No `@react-native-community/datetimepicker` | Not installed. All date fields use plain `TextInput` with YYYY-MM-DD format and client-side validation. This is intentional for offline MVP but noticeable UX gap. |
| 4 | `assets/notification-icon.png` | Placeholder only (copy of app icon). Replace with a proper 96×96 white-on-transparent PNG before production build. |
| 5 | `components/` root directory | Contains unused Expo default scaffold files (`EditScreenInfo.tsx`, `ExternalLink.tsx`, `Themed.tsx`, etc.). Safe to delete. |

---

### Next Session Should Start With

The app is ready to run. Start with:

```bash
cd /home/aekansh/Desktop/carelog_medical_record/carelog
npm install
npx expo start
```

After first run, test these acceptance criteria in order:
1. Splash screen shows, then Home loads with 8 body part cards
2. Recent Visits strip shows 5 seeded visits
3. Tap a body part → Speciality screen shows filtered specialities
4. Tap a speciality → Visit list for that combination
5. Tap a visit card → Visit Detail
6. Reminders tab → 2 upcoming reminders (ENT + Cardiology)
7. Settings tab → Currency, Reminder Time, Storage Used all visible

---

### Key Decisions Made

| Decision | PRD Spec | What Was Built | Reason |
|---|---|---|---|
| `VisitForm` extracted as shared component | PRD shows `new.tsx` and `edit/[visitId].tsx` as separate full forms | Single `VisitForm` (`forwardRef` + `useImperativeHandle`) shared by both screens | Avoids ~350-line duplication |
| Visit list route is `visits/list/[specialityId]` | PRD shows `visits/[specialityId]` | `app/visits/list/[specialityId].tsx` | Avoids route collision with `visits/[visitId]` (same dynamic segment pattern) |
| All screen headers use `Stack.Screen options={}` inline | PRD doesn't specify implementation | `Appbar.Header` removed from all screens; tab screens use tab navigator header overridden via `Stack.Screen` | Fixes double-header bug |
| Swipe-to-reveal in Reminders uses `PanResponder` | PRD says "swipe left" | Custom `Animated.View` + `PanResponder` row | `react-native-gesture-handler` not in `package.json` |
| Reschedule picker is a TextInput modal | PRD says "date picker" | `Modal` with `TextInput` YYYY-MM-DD | `@react-native-community/datetimepicker` not installed |
| Share/Save-to-Device uses `Share.share` | PRD says "Save to Device" | Both call `Share.share({ url: fileUri })` | `expo-media-library` not in `package.json` |
| `babel-preset-expo` handles `@src/*` aliases | — | No `babel-plugin-module-resolver` needed | SDK 51's `babel-preset-expo` v11 reads tsconfig paths automatically |
