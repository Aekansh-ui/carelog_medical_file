import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { BorderRadius, Spacing } from '@src/utils/theme';

interface MemberBadgeProps {
  name: string;
  color: string;
  size?: 'sm' | 'md';
}

export function MemberBadge({ name, color, size = 'md' }: MemberBadgeProps) {
  const sm = size === 'sm';
  return (
    <View style={[styles.pill, sm && styles.pillSm]}>
      <View style={[styles.dot, { backgroundColor: color }, sm && styles.dotSm]} />
      <Text style={[styles.label, sm && styles.labelSm]} numberOfLines={1}>
        {name}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  pill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
    backgroundColor: '#EEF1F6',
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 3,
    alignSelf: 'flex-start',
  },
  pillSm: {
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  dotSm: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  label: {
    fontSize: 12,
    fontWeight: '500' as const,
    color: '#424242',
    maxWidth: 120,
  },
  labelSm: {
    fontSize: 11,
  },
});
