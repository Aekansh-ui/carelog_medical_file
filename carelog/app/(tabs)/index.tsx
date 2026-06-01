import React, { useCallback } from 'react';
import { View, FlatList, StyleSheet, Pressable } from 'react-native';
import { Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Stack, router, useFocusEffect } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useMemberStore } from '@src/store/memberStore';
import { MemberCard } from '@src/components/MemberCard';
import { SectionHeader } from '@src/components/SectionHeader';
import { EmptyState } from '@src/components/EmptyState';
import { SPECIALITIES } from '@src/constants/specialities';
import { formatVisitDate, formatDaysRemaining } from '@src/utils/dateUtils';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';
import type { FamilySummary, Member } from '@src/types/Member';

type FollowUpItem = FamilySummary['upcomingFollowUps'][0];

function FollowUpRow({ item }: { item: FollowUpItem }) {
  const spec = SPECIALITIES.find(s => s.id === item.speciality_id);
  return (
    <Pressable
      onPress={() => router.push(`/visits/${item.visit_id}`)}
      style={[styles.followUpCard, Shadow.card]}
    >
      <View style={[styles.memberDot, { backgroundColor: item.member_color }]} />
      <View style={styles.followUpInfo}>
        <Text style={styles.followUpTitle} numberOfLines={1}>
          {item.member_name}
          {spec ? `  ·  ${spec.shortLabel}` : ''}
        </Text>
        {item.doctor_name ? (
          <Text style={styles.followUpDoctor} numberOfLines={1}>{item.doctor_name}</Text>
        ) : null}
        <Text style={styles.followUpDate}>
          {formatVisitDate(item.follow_up_date)}
          {'  ·  '}
          {formatDaysRemaining(item.follow_up_date)}
        </Text>
      </View>
      <MaterialCommunityIcons name="chevron-right" size={20} color={Colors.textSecondary} />
    </Pressable>
  );
}

function FollowUpSection({ items }: { items: FollowUpItem[] }) {
  return (
    <View style={styles.followUpSection}>
      <SectionHeader title="Upcoming Follow-ups" />
      {items.length === 0 ? (
        <EmptyState
          icon="calendar-clock"
          title="No upcoming follow-ups"
          subtitle="Follow-ups from all family members appear here"
        />
      ) : (
        items.map(item => <FollowUpRow key={item.visit_id} item={item} />)
      )}
    </View>
  );
}

export default function FamilyHomeScreen() {
  const members = useMemberStore(s => s.members);
  const summary = useMemberStore(s => s.summary);
  const loadMembers = useMemberStore(s => s.loadMembers);
  const loadSummary = useMemberStore(s => s.loadSummary);

  useFocusEffect(
    useCallback(() => {
      loadMembers();
      loadSummary();
    }, [])
  );

  const renderMember = useCallback(
    ({ item }: { item: Member }) => (
      <MemberCard
        member={item}
        onPress={() => router.push(`/member/${item.id}`)}
        onEditPress={() => router.push(`/members/edit/${item.id}`)}
      />
    ),
    []
  );

  const upcomingFollowUps = summary?.upcomingFollowUps ?? [];

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right']}>
      <Stack.Screen
        options={{
          title: 'My Family',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
          headerRight: () => (
            <Pressable
              onPress={() => router.push('/members/new')}
              style={styles.headerBtn}
              hitSlop={8}
            >
              <Text style={styles.addText}>＋ Add</Text>
            </Pressable>
          ),
        }}
      />

      {members.length === 0 ? (
        <EmptyState
          icon="account-group"
          title="No family members yet"
          subtitle={'Tap "＋ Add" to add your first family member'}
        />
      ) : (
        <FlatList
          data={members}
          keyExtractor={item => item.id}
          numColumns={2}
          renderItem={renderMember}
          contentContainerStyle={styles.gridContent}
          columnWrapperStyle={styles.row}
          ListFooterComponent={<FollowUpSection items={upcomingFollowUps} />}
          showsVerticalScrollIndicator={false}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  headerBtn: {
    paddingHorizontal: 8,
  },
  addText: {
    color: '#FFF',
    fontSize: 15,
    fontWeight: '600' as const,
  },
  gridContent: {
    paddingHorizontal: Spacing.sm,
    paddingTop: Spacing.sm,
    paddingBottom: Spacing.xl,
  },
  row: {
    gap: Spacing.sm,
    marginBottom: Spacing.sm,
  },
  followUpSection: {
    marginTop: Spacing.sm,
  },
  followUpCard: {
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
  memberDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    flexShrink: 0,
  },
  followUpInfo: {
    flex: 1,
    gap: 2,
  },
  followUpTitle: {
    fontSize: 14,
    fontWeight: '600' as const,
    color: Colors.textPrimary,
  },
  followUpDoctor: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  followUpDate: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
});
