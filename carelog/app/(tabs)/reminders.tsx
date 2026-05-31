import React, { useEffect, useRef, useState } from 'react';
import {
  View,
  SectionList,
  StyleSheet,
  Modal,
  Pressable,
  Animated,
  PanResponder,
  Alert,
  useWindowDimensions,
} from 'react-native';
import { Text, Button } from 'react-native-paper';
import { TextInput as PaperInput } from 'react-native-paper';
import { Stack, router } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { parseISO } from 'date-fns';
import { useRemindersStore } from '@src/store/remindersStore';
import { remindersRepository } from '@src/db/remindersRepository';
import { visitsRepository } from '@src/db/visitsRepository';
import { notificationService } from '@src/services/notificationService';
import { getDb } from '@src/db/database';
import { ReminderCard } from '@src/components/ReminderCard';
import { SectionHeader } from '@src/components/SectionHeader';
import { EmptyState } from '@src/components/EmptyState';
import { formatVisitDate } from '@src/utils/dateUtils';
import { Colors, Spacing, BorderRadius } from '@src/utils/theme';
import { Reminder } from '@src/types/Reminder';

// ─── Constants ────────────────────────────────────────────────────────────────

const ACTION_WIDTH = 136; // total width of the two revealed action buttons
const BTN_WIDTH = 68;     // each button is half

// ─── Sentinel for per-section empty states ────────────────────────────────────

type EmptyItem = { __empty: true; section: 'upcoming' | 'past' };
type SectionItem = Reminder | EmptyItem;

function isEmptyItem(item: SectionItem): item is EmptyItem {
  return '__empty' in item && (item as EmptyItem).__empty === true;
}

// ─── Swipeable row ────────────────────────────────────────────────────────────

interface SwipeableProps {
  reminder: Reminder;
  screenWidth: number;
  onPress: () => void;
  onReschedulePress: () => void;
  onDeletePress: () => void;
}

function SwipeableReminderRow({
  reminder,
  screenWidth,
  onPress,
  onReschedulePress,
  onDeletePress,
}: SwipeableProps) {
  const translateX = useRef(new Animated.Value(0)).current;
  const isOpen = useRef(false);

  const panResponder = useRef(
    PanResponder.create({
      // Only claim the gesture when horizontal movement clearly dominates
      onMoveShouldSetPanResponder: (_, g) =>
        Math.abs(g.dx) > 8 && Math.abs(g.dx) > Math.abs(g.dy) * 1.5,

      onPanResponderMove: (_, g) => {
        const base = isOpen.current ? -ACTION_WIDTH : 0;
        const clamped = Math.min(0, Math.max(-ACTION_WIDTH, base + g.dx));
        translateX.setValue(clamped);
      },

      onPanResponderRelease: (_, g) => {
        // Open if we swiped left past the halfway mark; close otherwise
        const open = isOpen.current
          ? g.dx > -ACTION_WIDTH / 2   // already open: close unless swiped most of the way back
            ? false
            : true
          : g.dx < -ACTION_WIDTH / 2;  // closed: open if swiped past half

        snap(open);
      },
    })
  ).current;

  function snap(open: boolean) {
    isOpen.current = open;
    Animated.spring(translateX, {
      toValue: open ? -ACTION_WIDTH : 0,
      useNativeDriver: true,
      tension: 70,
      friction: 12,
    }).start();
  }

  function close() { snap(false); }

  return (
    // Outer view clips the inner row so actions only show when card slides left
    <View style={{ width: screenWidth, overflow: 'hidden' }}>
      <Animated.View
        style={[swipe.row, { width: screenWidth + ACTION_WIDTH, transform: [{ translateX }] }]}
        {...panResponder.panHandlers}
      >
        {/* Card occupies full screen width */}
        <View style={{ width: screenWidth }}>
          <ReminderCard
            reminder={reminder}
            onPress={() => { close(); onPress(); }}
            onReschedule={() => { close(); onReschedulePress(); }}
            onDelete={() => { close(); onDeletePress(); }}
          />
        </View>

        {/* Action buttons revealed on swipe */}
        <View style={swipe.actions}>
          <Pressable
            style={[swipe.btn, swipe.reschedule]}
            onPress={() => { close(); onReschedulePress(); }}
          >
            <MaterialCommunityIcons name="calendar-edit" size={20} color="#FFF" />
            <Text style={swipe.btnText}>Reschedule</Text>
          </Pressable>

          <Pressable
            style={[swipe.btn, swipe.delete]}
            onPress={() => { close(); onDeletePress(); }}
          >
            <MaterialCommunityIcons name="trash-can-outline" size={20} color="#FFF" />
            <Text style={swipe.btnText}>Delete</Text>
          </Pressable>
        </View>
      </Animated.View>
    </View>
  );
}

const swipe = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'stretch',
  },
  actions: {
    width: ACTION_WIDTH,
    flexDirection: 'row',
    // Right-side padding matches the card's right margin so buttons align
    paddingRight: Spacing.md,
    paddingBottom: Spacing.sm, // matches card's marginBottom
    gap: Spacing.xs,
  },
  btn: {
    width: BTN_WIDTH - Spacing.xs,
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 4,
    borderRadius: BorderRadius.md,
  },
  reschedule: {
    backgroundColor: Colors.primary,
  },
  delete: {
    backgroundColor: Colors.error,
  },
  btnText: {
    color: '#FFF',
    fontSize: 11,
    fontWeight: '600',
    textAlign: 'center',
  },
});

// ─── Reschedule date picker ───────────────────────────────────────────────────

interface ReschedulePickerProps {
  visible: boolean;
  currentDate: string;
  onConfirm: (newDate: string) => void;
  onCancel: () => void;
}

function ReschedulePicker({ visible, currentDate, onConfirm, onCancel }: ReschedulePickerProps) {
  const [input, setInput] = useState(currentDate);
  const [error, setError] = useState('');

  useEffect(() => {
    if (visible) {
      setInput(currentDate);
      setError('');
    }
  }, [visible, currentDate]);

  function handleConfirm() {
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(input.trim())) {
      setError('Use YYYY-MM-DD format, e.g. 2026-06-15');
      return;
    }
    const parsed = parseISO(input.trim());
    if (isNaN(parsed.getTime())) {
      setError('Invalid date — check day and month values');
      return;
    }
    onConfirm(input.trim());
  }

  return (
    <Modal visible={visible} animationType="fade" transparent onRequestClose={onCancel}>
      <Pressable style={picker.overlay} onPress={onCancel} />
      <View style={picker.sheet}>
        <Text style={picker.title}>Reschedule Follow-up</Text>
        <Text style={picker.current}>
          Current: {currentDate ? formatVisitDate(currentDate) : '—'}
        </Text>

        <PaperInput
          label="New date (YYYY-MM-DD)"
          value={input}
          onChangeText={t => { setInput(t); setError(''); }}
          placeholder="2026-06-15"
          error={!!error}
          mode="outlined"
          style={picker.input}
          keyboardType="numbers-and-punctuation"
          autoFocus
          returnKeyType="done"
          onSubmitEditing={handleConfirm}
        />
        {error ? <Text style={picker.errorText}>{error}</Text> : null}

        <View style={picker.btnRow}>
          <Button onPress={onCancel} style={picker.btn}>Cancel</Button>
          <Button mode="contained" onPress={handleConfirm} style={picker.btn}>Confirm</Button>
        </View>
      </View>
    </Modal>
  );
}

const picker = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.4)',
  },
  sheet: {
    position: 'absolute',
    left: Spacing.lg,
    right: Spacing.lg,
    top: '35%',
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.lg,
    padding: Spacing.lg,
    gap: Spacing.sm,
  },
  title: {
    fontSize: 17,
    fontWeight: '700',
    color: Colors.textPrimary,
  },
  current: {
    fontSize: 13,
    color: Colors.textSecondary,
  },
  input: {
    backgroundColor: Colors.surface,
    marginTop: Spacing.xs,
  },
  errorText: {
    fontSize: 12,
    color: Colors.error,
    marginTop: -Spacing.xs,
  },
  btnRow: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: Spacing.sm,
    marginTop: Spacing.xs,
  },
  btn: {
    borderRadius: BorderRadius.full,
  },
});

// ─── Screen ───────────────────────────────────────────────────────────────────

export default function RemindersScreen() {
  const { width } = useWindowDimensions();

  const upcoming = useRemindersStore(s => s.upcoming);
  const past = useRemindersStore(s => s.past);
  const load = useRemindersStore(s => s.load);
  const deleteReminder = useRemindersStore(s => s.deleteReminder);

  const [rescheduleTarget, setRescheduleTarget] = useState<Reminder | null>(null);
  const [rescheduling, setRescheduling] = useState(false);

  useEffect(() => {
    load();
  }, [load]);

  // ── Handlers ──────────────────────────────────────────────────────────────

  async function handleReschedule(reminder: Reminder, newDate: string) {
    setRescheduleTarget(null);
    setRescheduling(true);
    try {
      // Cancel the existing OS notifications for this reminder
      await notificationService.cancelNotifications(
        reminder.notification_id_d1 ?? '',
        reminder.notification_id_d0 ?? '',
      );

      // Update the visit's own follow_up_date field
      visitsRepository.update(reminder.visit_id, { follow_up_date: newDate });

      // Schedule fresh notifications and capture the new IDs
      const { d1Id, d0Id } = await notificationService.scheduleFollowUp(
        reminder.visit_id,
        newDate,
      );

      // Write the new date + notification IDs + rescheduled_at back to the reminder row
      getDb().runSync(
        `UPDATE reminders
            SET follow_up_date      = ?,
                notification_id_d1  = ?,
                notification_id_d0  = ?,
                rescheduled_at      = ?
          WHERE id = ?`,
        [newDate, d1Id, d0Id, new Date().toISOString(), reminder.id],
      );

      // Refresh the store so both sections re-sort correctly
      load();
    } catch {
      Alert.alert('Error', 'Failed to reschedule. Please try again.');
    } finally {
      setRescheduling(false);
    }
  }

  function handleDelete(reminder: Reminder) {
    Alert.alert(
      'Delete Reminder',
      'The visit will not be deleted — only this follow-up reminder.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            await notificationService.cancelNotifications(
              reminder.notification_id_d1 ?? '',
              reminder.notification_id_d0 ?? '',
            );
            deleteReminder(reminder.id);
          },
        },
      ],
    );
  }

  // ── SectionList data ───────────────────────────────────────────────────────
  //
  // Inject a sentinel item into each empty section so renderItem can show
  // a per-section empty state without fighting SectionList's ListEmptyComponent.

  const sections: { title: string; key: string; data: SectionItem[] }[] = [
    {
      title: 'UPCOMING',
      key: 'upcoming',
      data:
        upcoming.length > 0
          ? (upcoming as SectionItem[])
          : [{ __empty: true, section: 'upcoming' } satisfies EmptyItem],
    },
    {
      title: 'PAST',
      key: 'past',
      data:
        past.length > 0
          ? (past as SectionItem[])
          : [{ __empty: true, section: 'past' } satisfies EmptyItem],
    },
  ];

  // ── Render ────────────────────────────────────────────────────────────────

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right', 'bottom']}>
      <Stack.Screen
        options={{
          title: 'Reminders',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
        }}
      />

      <SectionList<SectionItem, (typeof sections)[0]>
        sections={sections}
        keyExtractor={(item, idx) =>
          isEmptyItem(item) ? `empty-${item.section}` : (item as Reminder).id + idx
        }
        renderSectionHeader={({ section }) => (
          <SectionHeader title={section.title} />
        )}
        renderItem={({ item }) => {
          if (isEmptyItem(item)) {
            return (
              <View style={styles.sectionEmpty}>
                {item.section === 'upcoming' ? (
                  <EmptyState
                    icon="calendar-check-outline"
                    title="No upcoming reminders"
                    subtitle="Follow-up dates you add to visits will appear here."
                  />
                ) : (
                  <View style={styles.pastEmpty}>
                    <MaterialCommunityIcons
                      name="calendar-remove-outline"
                      size={32}
                      color={Colors.textDisabled}
                    />
                    <Text style={styles.pastEmptyText}>No past reminders</Text>
                  </View>
                )}
              </View>
            );
          }

          const reminder = item as Reminder;
          return (
            <SwipeableReminderRow
              reminder={reminder}
              screenWidth={width}
              onPress={() => router.push(`/visits/${reminder.visit_id}`)}
              onReschedulePress={() => setRescheduleTarget(reminder)}
              onDeletePress={() => handleDelete(reminder)}
            />
          );
        }}
        stickySectionHeadersEnabled={false}
        contentContainerStyle={styles.list}
        showsVerticalScrollIndicator={false}
      />

      <ReschedulePicker
        visible={rescheduleTarget !== null && !rescheduling}
        currentDate={rescheduleTarget?.follow_up_date ?? ''}
        onConfirm={date => rescheduleTarget && handleReschedule(rescheduleTarget, date)}
        onCancel={() => setRescheduleTarget(null)}
      />
    </SafeAreaView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  list: {
    paddingBottom: Spacing.xl,
  },

  // Upcoming section empty state — centred, taller
  sectionEmpty: {
    minHeight: 160,
    justifyContent: 'center',
  },

  // Past section empty state — compact inline row
  pastEmpty: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.sm,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.md,
  },
  pastEmptyText: {
    fontSize: 14,
    color: Colors.textDisabled,
  },
});
