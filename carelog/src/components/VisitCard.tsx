import React from 'react';
import { Pressable, View, StyleSheet } from 'react-native';
import { Text, Chip } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Visit } from '@src/types/Visit';
import { SPECIALITIES } from '@src/constants/specialities';
import { formatVisitDate, formatDaysRemaining, isOverdue } from '@src/utils/dateUtils';
import { truncateText } from '@src/utils/formatters';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';

interface VisitCardProps {
  visit: Visit;
  onPress: () => void;
  compact?: boolean;
}

export function VisitCard({ visit, onPress, compact = false }: VisitCardProps) {
  const speciality = SPECIALITIES.find(s => s.id === visit.speciality_id);

  if (compact) {
    return (
      <Pressable onPress={onPress} style={[styles.compactCard, Shadow.card]}>
        <View style={[styles.compactAccent, { backgroundColor: speciality?.color ?? Colors.primary }]} />
        <View style={styles.compactContent}>
          <Text style={styles.doctorName} numberOfLines={1}>
            {visit.doctor_name ?? 'Unknown Doctor'}
          </Text>
          <Text style={styles.date}>{formatVisitDate(visit.visit_date)}</Text>
          {visit.diagnosis ? (
            <Text style={styles.diagnosisText} numberOfLines={2}>
              {truncateText(visit.diagnosis, 60)}
            </Text>
          ) : null}
        </View>
      </Pressable>
    );
  }

  const overdue = visit.follow_up_date ? isOverdue(visit.follow_up_date) : false;
  const badgeColor = overdue ? Colors.error : Colors.secondary;

  return (
    <Pressable onPress={onPress} style={[styles.card, Shadow.card]}>
      {/* Header: doctor name + speciality chip */}
      <View style={styles.cardHeader}>
        <View style={styles.headerLeft}>
          <Text style={styles.doctorName} numberOfLines={1}>
            {visit.doctor_name ?? 'Unknown Doctor'}
          </Text>
          <Text style={styles.date}>{formatVisitDate(visit.visit_date)}</Text>
        </View>
        {speciality ? (
          <Chip
            compact
            style={[styles.specialityChip, { backgroundColor: speciality.color + '22' }]}
            textStyle={{ color: speciality.color, fontSize: 11 }}
          >
            {speciality.shortLabel}
          </Chip>
        ) : null}
      </View>

      {/* Diagnosis — truncated to 60 chars */}
      {visit.diagnosis ? (
        <Text style={styles.diagnosisText} numberOfLines={2}>
          {truncateText(visit.diagnosis, 60)}
        </Text>
      ) : null}

      {/* Follow-up badge */}
      {visit.follow_up_date ? (
        <View style={styles.followUpRow}>
          <MaterialCommunityIcons
            name="calendar-clock"
            size={13}
            color={badgeColor}
          />
          <View style={[styles.followUpBadge, { backgroundColor: badgeColor + '18' }]}>
            <Text style={[styles.followUpText, { color: badgeColor }]}>
              {formatVisitDate(visit.follow_up_date)}
              {'  ·  '}
              {formatDaysRemaining(visit.follow_up_date)}
            </Text>
          </View>
        </View>
      ) : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  // ── Full card ────────────────────────────────────────────────
  card: {
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    padding: Spacing.md,
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.sm,
    borderWidth: 1,
    borderColor: Colors.border,
    gap: Spacing.xs,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  headerLeft: {
    flex: 1,
    gap: 2,
    marginRight: Spacing.sm,
  },
  doctorName: {
    fontSize: 15,
    fontWeight: '600',
    color: Colors.textPrimary,
  },
  date: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  specialityChip: {
    height: 24,
    alignSelf: 'flex-start',
  },
  diagnosisText: {
    fontSize: 13,
    color: Colors.textSecondary,
    lineHeight: 18,
  },
  followUpRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
    marginTop: 2,
  },
  followUpBadge: {
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
  },
  followUpText: {
    fontSize: 11,
    fontWeight: '600',
  },

  // ── Compact card (horizontal strip) ─────────────────────────
  compactCard: {
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    width: 160,
    overflow: 'hidden',
    marginRight: Spacing.sm,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  compactAccent: {
    height: 4,
    width: '100%',
  },
  compactContent: {
    padding: Spacing.sm,
    gap: 2,
  },
});
