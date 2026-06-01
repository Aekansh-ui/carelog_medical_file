import React from 'react';
import { Pressable, View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Member } from '@src/types/Member';
import { RELATIONSHIPS } from '@src/constants/members';
import { computeAge, formatVisitDate } from '@src/utils/dateUtils';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';

interface MemberCardProps {
  member: Member;
  onPress: () => void;
  onEditPress?: () => void;
}

function initials(name: string): string {
  return name
    .trim()
    .split(/\s+/)
    .map(w => w[0] ?? '')
    .join('')
    .slice(0, 2)
    .toUpperCase();
}

export function MemberCard({ member, onPress, onEditPress }: MemberCardProps) {
  const rel = RELATIONSHIPS.find(r => r.id === member.relationship);
  const age = member.date_of_birth ? computeAge(member.date_of_birth) : null;
  const subtitle = [rel?.label, age != null ? `${age}y` : null].filter(Boolean).join(' · ');

  return (
    <Pressable onPress={onPress} style={[styles.card, Shadow.card]}>
      {onEditPress ? (
        <Pressable onPress={onEditPress} style={styles.editBtn} hitSlop={8}>
          <MaterialCommunityIcons name="pencil-outline" size={14} color={Colors.textSecondary} />
        </Pressable>
      ) : null}
      <View style={[styles.avatar, { backgroundColor: member.color }]}>
        <Text style={styles.avatarText}>{initials(member.name)}</Text>
      </View>

      <Text style={styles.name} numberOfLines={1}>{member.name}</Text>
      {subtitle ? <Text style={styles.subtitle} numberOfLines={1}>{subtitle}</Text> : null}

      <View style={styles.statRow}>
        <MaterialCommunityIcons name="stethoscope" size={12} color={Colors.textSecondary} />
        <Text style={styles.statText}>{member.visit_count ?? 0} visits</Text>
      </View>

      <View style={styles.statRow}>
        <MaterialCommunityIcons name="calendar-clock" size={12} color={Colors.textSecondary} />
        <Text style={styles.statText} numberOfLines={1}>
          {member.next_follow_up ? formatVisitDate(member.next_follow_up) : '—'}
        </Text>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    padding: Spacing.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.border,
    gap: Spacing.xs,
  },
  avatar: {
    width: 52,
    height: 52,
    borderRadius: 26,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 2,
  },
  avatarText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '700' as const,
  },
  name: {
    fontSize: 14,
    fontWeight: '600' as const,
    color: Colors.textPrimary,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 11,
    color: Colors.textSecondary,
    textAlign: 'center',
  },
  statRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 3,
  },
  statText: {
    fontSize: 11,
    color: Colors.textSecondary,
  },
  editBtn: {
    position: 'absolute',
    top: 6,
    right: 6,
    padding: 4,
  },
});
