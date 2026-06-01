import React, { useCallback } from 'react';
import { FlatList, StyleSheet } from 'react-native';
import { FAB } from 'react-native-paper';
import { Stack, router, useLocalSearchParams, useFocusEffect } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useInsuranceStore } from '@src/store/insuranceStore';
import { useMemberStore } from '@src/store/memberStore';
import { InsuranceCard } from '@src/components/InsuranceCard';
import { EmptyState } from '@src/components/EmptyState';
import { Colors, Spacing } from '@src/utils/theme';
import type { InsurancePolicy } from '@src/types/Insurance';

export default function MemberInsuranceScreen() {
  const { memberId } = useLocalSearchParams<{ memberId: string }>();

  const policies = useInsuranceStore(s => s.policies);
  const loadForMember = useInsuranceStore(s => s.loadForMember);
  const members = useMemberStore(s => s.members);
  const loadMembers = useMemberStore(s => s.loadMembers);
  const getMember = useMemberStore(s => s.getMember);

  // Refresh on focus so newly added/edited/deleted policies appear immediately.
  useFocusEffect(
    useCallback(() => {
      if (members.length === 0) loadMembers();
      loadForMember(memberId);
    }, [memberId])
  );

  const member = getMember(memberId);

  const renderItem = useCallback(
    ({ item }: { item: InsurancePolicy }) => (
      <InsuranceCard
        policy={item}
        onPress={() => router.push(`/insurance/policy/${item.id}`)}
      />
    ),
    []
  );

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right', 'bottom']}>
      <Stack.Screen
        options={{
          title: member ? `${member.name} · Insurance` : 'Insurance',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
        }}
      />

      <FlatList
        data={policies}
        keyExtractor={p => p.id}
        renderItem={renderItem}
        ListEmptyComponent={
          <EmptyState
            icon="shield-plus-outline"
            title="No insurance added"
            subtitle={`Add ${member?.name ?? 'this member'}'s health or life insurance so the details are handy when you need them.`}
            actionLabel="Add Insurance"
            onAction={() =>
              router.push({ pathname: '/insurance/new', params: { memberId } })
            }
          />
        }
        contentContainerStyle={[
          styles.list,
          policies.length === 0 && styles.listEmpty,
        ]}
        showsVerticalScrollIndicator={false}
      />

      <FAB
        icon="plus"
        style={styles.fab}
        color="#FFF"
        onPress={() =>
          router.push({ pathname: '/insurance/new', params: { memberId } })
        }
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  list: {
    paddingTop: Spacing.sm,
    paddingBottom: 88,
  },
  listEmpty: {
    flex: 1,
  },
  fab: {
    position: 'absolute',
    bottom: Spacing.lg,
    right: Spacing.lg,
    backgroundColor: Colors.primary,
  },
});
