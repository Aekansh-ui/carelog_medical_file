import React from 'react';
import { Pressable, View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { InsurancePolicy } from '@src/types/Insurance';
import { PLAN_TYPES, INSURANCE_EXPIRY_SOON_DAYS } from '@src/constants/insurance';
import { getExpiryStatus } from '@src/utils/dateUtils';
import { formatCurrency } from '@src/utils/formatters';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';

interface InsuranceCardProps {
  policy: InsurancePolicy;
  onPress: () => void;
}

export function InsuranceCard({ policy, onPress }: InsuranceCardProps) {
  const plan = PLAN_TYPES.find(p => p.id === policy.plan_type);
  const expiry = getExpiryStatus(policy.valid_until, INSURANCE_EXPIRY_SOON_DAYS);

  const badgeColor =
    expiry.status === 'expired'
      ? Colors.error
      : expiry.status === 'expiring'
        ? Colors.accent
        : Colors.secondary;

  return (
    <Pressable onPress={onPress} style={[styles.card, Shadow.card]}>
      <View style={styles.iconCircle}>
        <MaterialCommunityIcons name="shield-check" size={22} color={Colors.primary} />
      </View>

      <View style={styles.body}>
        <Text style={styles.insurer} numberOfLines={1}>{policy.insurer_name}</Text>

        <View style={styles.metaRow}>
          {plan ? (
            <View style={styles.planChip}>
              <MaterialCommunityIcons name={plan.icon as any} size={11} color={Colors.textSecondary} />
              <Text style={styles.planText}>{plan.label}</Text>
            </View>
          ) : null}
          {policy.document_count ? (
            <View style={styles.docChip}>
              <MaterialCommunityIcons name="paperclip" size={11} color={Colors.textSecondary} />
              <Text style={styles.planText}>{policy.document_count}</Text>
            </View>
          ) : null}
        </View>

        {policy.policy_number ? (
          <Text style={styles.policyNo} numberOfLines={1}>No. {policy.policy_number}</Text>
        ) : null}

        {policy.sum_insured != null ? (
          <Text style={styles.sumInsured}>
            Cover {formatCurrency(policy.sum_insured, policy.currency)}
          </Text>
        ) : null}

        {expiry.status !== 'none' ? (
          <View style={[styles.expiryBadge, { backgroundColor: badgeColor + '18' }]}>
            <Text style={[styles.expiryText, { color: badgeColor }]}>{expiry.label}</Text>
          </View>
        ) : null}
      </View>

      <MaterialCommunityIcons name="chevron-right" size={20} color={Colors.textSecondary} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    marginHorizontal: Spacing.md,
    marginBottom: Spacing.sm,
    padding: Spacing.md,
    borderWidth: 1,
    borderColor: Colors.border,
    gap: Spacing.sm,
  },
  iconCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.primary + '14',
    alignItems: 'center',
    justifyContent: 'center',
  },
  body: {
    flex: 1,
    gap: 3,
  },
  insurer: {
    fontSize: 15,
    fontWeight: '600' as const,
    color: Colors.textPrimary,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
    flexWrap: 'wrap',
  },
  planChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 3,
    backgroundColor: '#EEF1F6',
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
  },
  docChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 3,
    backgroundColor: '#EEF1F6',
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
  },
  planText: {
    fontSize: 11,
    color: Colors.textSecondary,
    fontWeight: '500' as const,
  },
  policyNo: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  sumInsured: {
    fontSize: 12,
    color: Colors.textPrimary,
    fontWeight: '500' as const,
  },
  expiryBadge: {
    alignSelf: 'flex-start',
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
    marginTop: 2,
  },
  expiryText: {
    fontSize: 11,
    fontWeight: '700' as const,
  },
});
