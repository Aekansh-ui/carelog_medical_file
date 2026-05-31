import React from 'react';
import { View, StyleSheet, Pressable, Alert } from 'react-native';
import { Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Reminder } from '@src/types/Reminder';
import { SPECIALITIES } from '@src/constants/specialities';
import { formatVisitDate, formatDaysRemaining, isOverdue } from '@src/utils/dateUtils';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';

interface ReminderCardProps {
  reminder: Reminder;
  onPress: () => void;
  onReschedule: (newDate: string) => void;
  onDelete: () => void;
}

export function ReminderCard({
  reminder,
  onPress,
  onReschedule,
  onDelete,
}: ReminderCardProps) {
  const overdue = isOverdue(reminder.follow_up_date);
  const badgeColor = overdue ? Colors.error : Colors.secondary;
  const speciality = SPECIALITIES.find(s => s.id === reminder.speciality_id);

  function handleLongPress() {
    Alert.alert('Reminder Options', undefined, [
      {
        text: 'Reschedule',
        onPress: () => {
          // Pass the current follow-up date back; the parent screen
          // is responsible for showing a date picker and calling onReschedule
          // with the new date the user picks.
          onReschedule(reminder.follow_up_date);
        },
      },
      {
        text: 'Delete Reminder',
        style: 'destructive',
        onPress: onDelete,
      },
      { text: 'Cancel', style: 'cancel' },
    ]);
  }

  return (
    <Pressable
      onPress={onPress}
      onLongPress={handleLongPress}
      style={[styles.card, Shadow.card]}
    >
      <View style={[styles.leftAccent, { backgroundColor: badgeColor }]} />

      <View style={styles.body}>
        {/* Left: info */}
        <View style={styles.info}>
          <Text style={styles.doctor} numberOfLines={1}>
            {reminder.doctor_name ?? 'Unknown Doctor'}
          </Text>
          {speciality ? (
            <View style={styles.specialityRow}>
              <MaterialCommunityIcons
                name={speciality.icon as any}
                size={12}
                color={Colors.textSecondary}
              />
              <Text style={styles.specialityLabel}> {speciality.label}</Text>
            </View>
          ) : null}
          <View style={styles.dateRow}>
            <MaterialCommunityIcons
              name="calendar-clock"
              size={13}
              color={Colors.textSecondary}
            />
            <Text style={styles.dateText}>
              {'  '}Follow-up: {formatVisitDate(reminder.follow_up_date)}
            </Text>
          </View>
        </View>

        {/* Right: days badge */}
        <View style={[styles.badge, { backgroundColor: badgeColor + '18' }]}>
          <Text style={[styles.badgeText, { color: badgeColor }]}>
            {formatDaysRemaining(reminder.follow_up_date)}
          </Text>
        </View>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.sm,
    borderWidth: 1,
    borderColor: Colors.border,
    flexDirection: 'row',
    overflow: 'hidden',
  },
  leftAccent: {
    width: 4,
    borderTopLeftRadius: BorderRadius.md,
    borderBottomLeftRadius: BorderRadius.md,
  },
  body: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: Spacing.md,
  },
  info: {
    flex: 1,
    gap: 3,
    marginRight: Spacing.sm,
  },
  doctor: {
    fontSize: 15,
    fontWeight: '600',
    color: Colors.textPrimary,
  },
  specialityRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  specialityLabel: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  dateRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 2,
  },
  dateText: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  badge: {
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 4,
    alignSelf: 'center',
    minWidth: 80,
    alignItems: 'center',
  },
  badgeText: {
    fontSize: 12,
    fontWeight: '700',
    textAlign: 'center',
  },
});
