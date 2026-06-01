import React, { useEffect, useCallback } from 'react';
import { View, FlatList, StyleSheet, Pressable, ListRenderItemInfo } from 'react-native';
import { Badge, Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Stack, router, useLocalSearchParams, useFocusEffect } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useVisitsStore } from '@src/store/visitsStore';
import { useRemindersStore } from '@src/store/remindersStore';
import { useMemberStore } from '@src/store/memberStore';
import { BODY_PARTS, BodyPart } from '@src/constants/bodyParts';
import { VisitCard } from '@src/components/VisitCard';
import { SectionHeader } from '@src/components/SectionHeader';
import { EmptyState } from '@src/components/EmptyState';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';

function BodyPartCard({ bodyPart, onPress }: { bodyPart: BodyPart; onPress: () => void }) {
  return (
    <Pressable onPress={onPress} style={[styles.bodyCard, Shadow.card]}>
      <MaterialCommunityIcons name={bodyPart.icon as any} size={32} color={Colors.primary} />
      <Text style={styles.bodyLabel}>{bodyPart.label}</Text>
      <Text style={styles.bodyDesc} numberOfLines={1}>{bodyPart.description}</Text>
    </Pressable>
  );
}

// Stable reference outside screen — reads recentVisits from the store directly.
function MemberRecentVisits() {
  const recentVisits = useVisitsStore(s => s.recentVisits);
  return (
    <View>
      <SectionHeader title="Recent Visits" />
      {recentVisits.length === 0 ? (
        <EmptyState
          icon="stethoscope"
          title="No visits yet"
          subtitle="Tap a body part above to add your first visit"
        />
      ) : (
        <FlatList
          horizontal
          data={recentVisits}
          keyExtractor={v => v.id}
          renderItem={({ item }) => (
            <VisitCard
              visit={item}
              onPress={() => router.push(`/visits/${item.id}`)}
              compact
            />
          )}
          contentContainerStyle={styles.recentList}
          showsHorizontalScrollIndicator={false}
        />
      )}
    </View>
  );
}

export default function MemberHomeScreen() {
  const { memberId } = useLocalSearchParams<{ memberId: string }>();
  const loadRecentVisitsForMember = useVisitsStore(s => s.loadRecentVisitsForMember);
  const upcoming = useRemindersStore(s => s.upcoming);
  const loadReminders = useRemindersStore(s => s.load);
  const members = useMemberStore(s => s.members);
  const loadMembers = useMemberStore(s => s.loadMembers);
  const getMember = useMemberStore(s => s.getMember);

  // Load member for header title once (or when memberId changes)
  useEffect(() => {
    if (members.length === 0) loadMembers();
  }, [memberId]);

  // Refresh visit/reminder data every time this screen gains focus so that
  // returning from the add-visit flow shows the newly created record immediately.
  useFocusEffect(
    useCallback(() => {
      loadRecentVisitsForMember(memberId);
      loadReminders();
    }, [memberId])
  );

  const member = getMember(memberId);

  const InsuranceEntry = useCallback(
    () => (
      <Pressable
        onPress={() => router.push(`/insurance/member/${memberId}`)}
        style={[styles.insuranceRow, Shadow.card]}
      >
        <View style={styles.insuranceIcon}>
          <MaterialCommunityIcons name="shield-check" size={22} color={Colors.primary} />
        </View>
        <View style={styles.insuranceText}>
          <Text style={styles.insuranceTitle}>Insurance</Text>
          <Text style={styles.insuranceSub} numberOfLines={1}>
            Health & life policies, cards and helplines
          </Text>
        </View>
        <MaterialCommunityIcons name="chevron-right" size={22} color={Colors.textSecondary} />
      </Pressable>
    ),
    [memberId],
  );

  const renderBodyPart = useCallback(
    ({ item }: ListRenderItemInfo<BodyPart>) => (
      <BodyPartCard
        bodyPart={item}
        onPress={() =>
          router.push({ pathname: `/speciality/${item.id}`, params: { memberId } })
        }
      />
    ),
    [memberId],
  );

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right']}>
      <Stack.Screen
        options={{
          title: member?.name ?? 'Member',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
          headerRight: () => (
            <View style={styles.headerRight}>
              <Pressable
                onPress={() => router.push('/search')}
                style={styles.headerBtn}
                hitSlop={8}
              >
                <MaterialCommunityIcons name="magnify" size={24} color="#FFF" />
              </Pressable>
              <View>
                <Pressable
                  onPress={() => router.push('/(tabs)/reminders')}
                  style={styles.headerBtn}
                  hitSlop={8}
                >
                  <MaterialCommunityIcons name="bell-outline" size={24} color="#FFF" />
                </Pressable>
                {upcoming.length > 0 && (
                  <Badge size={16} style={styles.badge}>{upcoming.length}</Badge>
                )}
              </View>
            </View>
          ),
        }}
      />

      <FlatList
        data={BODY_PARTS}
        keyExtractor={item => item.id}
        numColumns={2}
        renderItem={renderBodyPart}
        contentContainerStyle={styles.gridContent}
        columnWrapperStyle={styles.row}
        ListHeaderComponent={InsuranceEntry}
        ListFooterComponent={MemberRecentVisits}
        showsVerticalScrollIndicator={false}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  headerRight: {
    flexDirection: 'row' as const,
    alignItems: 'center' as const,
    marginRight: 4,
  },
  headerBtn: {
    paddingHorizontal: 8,
  },
  badge: {
    position: 'absolute',
    top: 4,
    right: 4,
    backgroundColor: Colors.accent,
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
  bodyCard: {
    flex: 1,
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    padding: Spacing.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.border,
    gap: Spacing.xs,
  },
  bodyLabel: {
    fontSize: 13,
    fontWeight: '600' as const,
    color: Colors.textPrimary,
    textAlign: 'center',
  },
  bodyDesc: {
    fontSize: 11,
    color: Colors.textSecondary,
    textAlign: 'center',
  },
  recentList: {
    paddingHorizontal: Spacing.md,
    paddingBottom: Spacing.md,
  },
  insuranceRow: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.md,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: Spacing.md,
    marginHorizontal: Spacing.sm,
    marginBottom: Spacing.sm,
    gap: Spacing.sm,
  },
  insuranceIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.primary + '14',
    alignItems: 'center',
    justifyContent: 'center',
  },
  insuranceText: {
    flex: 1,
  },
  insuranceTitle: {
    fontSize: 15,
    fontWeight: '600' as const,
    color: Colors.textPrimary,
  },
  insuranceSub: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginTop: 1,
  },
});
