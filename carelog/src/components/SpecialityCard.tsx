import React from 'react';
import { Pressable, View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Speciality } from '@src/constants/specialities';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';

interface SpecialityCardProps {
  speciality: Speciality;
  visitCount: number;
  onPress: () => void;
}

export function SpecialityCard({ speciality, visitCount, onPress }: SpecialityCardProps) {
  return (
    <Pressable onPress={onPress} style={[styles.card, Shadow.card]}>
      {/* Left colour border */}
      <View style={[styles.leftBorder, { backgroundColor: speciality.color }]} />

      <View style={styles.content}>
        <MaterialCommunityIcons
          name={speciality.icon as any}
          size={30}
          color={speciality.color}
        />
        <Text style={styles.label} numberOfLines={2}>{speciality.label}</Text>

        {/* Visit count badge */}
        <View style={[styles.badge, { backgroundColor: speciality.color + '18' }]}>
          <Text style={[styles.badgeText, { color: speciality.color }]}>
            {visitCount} {visitCount === 1 ? 'visit' : 'visits'}
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
    flex: 1,
    margin: Spacing.xs,
    flexDirection: 'row',
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: Colors.border,
  },
  leftBorder: {
    width: 5,
    borderTopLeftRadius: BorderRadius.md,
    borderBottomLeftRadius: BorderRadius.md,
  },
  content: {
    flex: 1,
    padding: Spacing.sm,
    alignItems: 'center',
    justifyContent: 'center',
    gap: Spacing.xs,
  },
  label: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.textPrimary,
    textAlign: 'center',
  },
  badge: {
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
    marginTop: 2,
  },
  badgeText: {
    fontSize: 11,
    fontWeight: '600',
  },
});
