## CareLog Handoff Note
**Date:** 2026-06-01
**Session Completed:** 4
**Last command completed:** Command 3 — `app/search.tsx` (Global Search screen)

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

---

### Files Partially Complete

**`carelog/app/(tabs)/settings.tsx`** — functional but has three issues:
1. Wrong import: `@src/constants/theme` → must be `@src/utils/theme`
2. Still uses `Appbar.Header` — causes double header because `(tabs)/_layout.tsx` already provides a header via `screenOptions`. Remove `Appbar.Header` and let the tab navigator render it.
3. Missing two PRD features: **Storage used** display (call `fileService.getStorageUsedBytes()` and format as MB) and **Reminder time** picker (HH:MM TextInput to set the daily notification hour, persisted via `settingsStore.setSetting('reminderTime', ...)`)

**`carelog/app/(tabs)/index.tsx`** — still has an `Appbar.Header` + `Appbar.Content` block (confirmed by grep). The tab navigator's `screenOptions` already applies the header, so this produces a double header. Remove the `Appbar.Header` / `Appbar.Content` block and let the tab navigator handle it.

---

### Next Session Should Start With

Fix the two double-header issues and the two missing settings features, then do the first run:

> **Paste this prompt:**
>
> Fix the following issues before we run the app for the first time:
>
> 1. `app/(tabs)/index.tsx` — remove the `<Appbar.Header>` / `<Appbar.Content>` block entirely. The tab navigator in `(tabs)/_layout.tsx` already provides the header via `screenOptions`. The search icon and bell badge that were inside `Appbar.Header` should be moved to `<Stack.Screen options={{ headerRight: ... }}>` rendered inside the component, following the same pattern used in `app/(tabs)/reports.tsx`.
>
> 2. `app/(tabs)/settings.tsx` — (a) fix the import `@src/constants/theme` → `@src/utils/theme`; (b) remove the `<Appbar.Header>` block for the same reason; (c) add a **Storage Used** row in the Data section that calls `fileService.getStorageUsedBytes()` on mount and displays the result formatted as `X.X MB`; (d) add a **Reminder Time** row in the Notifications section with a TextInput (HH:MM format, numeric keyboard) that reads from and writes to `settingsStore` key `reminderTime` — default `"09:00"`.
>
> After both fixes, run `cd /home/aekansh/Desktop/carelog_medical_record/carelog && npx expo start` and report what you see.

---

### Known Issues

| # | File | Issue |
|---|------|-------|
| 1 | `app/(tabs)/index.tsx` | `Appbar.Header` double-header (tab navigator already provides one) |
| 2 | `app/(tabs)/settings.tsx` | Same double-header + wrong import path + missing Storage Used + missing Reminder Time controls |
| 3 | `src/services/exportService.ts` | Imports `react-native-html-to-pdf` which requires native linking — works in a bare/dev-client build but will throw at runtime in Expo Go. The package is in `package.json` so a bare build should be fine. |
| 4 | `react-native-pdf` | Listed in `package.json` but never imported or used by any screen. The attachment viewer uses `Linking.openURL` for PDFs instead. Either remove the dep or implement a proper in-app PDF viewer in a later session. |
| 5 | No `@react-native-community/datetimepicker` | Not installed. All date fields (visit date, follow-up date, reschedule picker) use plain `TextInput` with YYYY-MM-DD format and client-side validation. This is intentional for offline MVP but noticeable UX gap. |
| 6 | Missing `assets/notification-icon.png` | `notificationService.ts` may need a 96×96 PNG at this path for Android notification icons. Add a placeholder before first run on Android. |
| 7 | `components/` root directory | Contains unused Expo default scaffold files (`EditScreenInfo.tsx`, `ExternalLink.tsx`, `Themed.tsx`, etc.). Safe to delete — nothing in `app/` or `src/` imports them. |
| 8 | `settingsStore` has no `reminderTime` key | PRD Section 10.8 specifies a reminder time picker. The store's `setSetting` is generic, so adding `reminderTime` requires only a default value in the store initialiser and a UI row in settings — no DB migration needed (AsyncStorage-backed). |

---

### Key Decisions Made

| Decision | PRD Spec | What Was Built | Reason |
|---|---|---|---|
| `VisitForm` extracted as shared component | PRD shows `new.tsx` and `edit/[visitId].tsx` as separate full forms | Single `VisitForm` (`forwardRef` + `useImperativeHandle`) shared by both screens | Avoids ~350-line duplication; parent screens call `formRef.current.getForm()` at save time |
| All screen headers use `Stack.Screen options={}` inline | PRD doesn't specify implementation | `Appbar.Header` removed from all stack screens; tab screens use tab navigator header | Fixes double-header bug caused by both Stack and Appbar rendering simultaneously |
| Swipe-to-reveal in Reminders uses `PanResponder` | PRD says "swipe left" (implies react-native-gesture-handler `Swipeable`) | Custom `Animated.View` + `PanResponder` row | `react-native-gesture-handler` not in `package.json`; core RN `PanResponder` achieves the same without a new dep |
| Reschedule picker is a TextInput modal | PRD says "date picker" (implies `@react-native-community/datetimepicker`) | `Modal` with `TextInput` YYYY-MM-DD + regex + `parseISO` validation | Package not installed; consistent with all other date inputs in the app |
| Share/Save-to-Device uses `Share.share` | PRD says "Save to Device" as a distinct action | Both Share and Save-to-Device call `Share.share({ url: fileUri })` | `expo-media-library` and `expo-sharing` not in `package.json`; native share sheet lets user pick "Save Image" / "Save to Files" |
| FTS5 match hint is client-side `includes()` | PRD says "show matched field hint" | `getMatchHint()` probes `doctor_name`, `clinic_name`, `symptoms`, `diagnosis`, `notes` with `toLowerCase().includes()` | FTS5 doesn't return which column matched; `includes()` is accurate for non-stemmed queries; falls back to "Matched in: visit content" for stemmed hits |
| SectionList per-section empty states use sentinel items | SectionList has no per-section `ListEmptyComponent` | `{ __empty: true, section: 'upcoming' \| 'past' }` sentinel injected into empty sections; `renderItem` detects and renders section-specific empty UI | Standard React Native pattern for independent section-level empty states |
