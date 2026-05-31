import React, { useEffect, useCallback } from 'react';
import { View, FlatList, StyleSheet, Pressable, ListRenderItemInfo } from 'react-native';
import { Appbar, Badge, Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useVisitsStore } from '@src/store/visitsStore';
import { useRemindersStore } from '@src/store/remindersStore';
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

function RecentVisitsFooter() {
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

export default function HomeScreen() {
  const loadRecentVisits = useVisitsStore(s => s.loadRecentVisits);
  const upcoming = useRemindersStore(s => s.upcoming);
  const loadReminders = useRemindersStore(s => s.load);

  useEffect(() => {
    loadRecentVisits();
    loadReminders();
  }, []);

  const renderBodyPart = useCallback(
    ({ item }: ListRenderItemInfo<BodyPart>) => (
      <BodyPartCard
        bodyPart={item}
        onPress={() => router.push(`/speciality/${item.id}`)}
      />
    ),
    [],
  );

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right']}>
      <Appbar.Header style={styles.header}>
        <Appbar.Content title="CareLog" titleStyle={styles.headerTitle} />
        <Appbar.Action
          icon="magnify"
          iconColor="#FFF"
          onPress={() => router.push('/search')}
        />
        <View>
          <Appbar.Action
            icon="bell-outline"
            iconColor="#FFF"
            onPress={() => router.push('/(tabs)/reminders')}
          />
          {upcoming.length > 0 && (
            <Badge size={16} style={styles.badge}>{upcoming.length}</Badge>
          )}
        </View>
      </Appbar.Header>

      <FlatList
        data={BODY_PARTS}
        keyExtractor={item => item.id}
        numColumns={2}
        renderItem={renderBodyPart}
        contentContainerStyle={styles.gridContent}
        columnWrapperStyle={styles.row}
        ListFooterComponent={RecentVisitsFooter}
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
  header: {
    backgroundColor: Colors.primary,
  },
  headerTitle: {
    color: '#FFF',
    fontWeight: '700',
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
    fontWeight: '600',
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
});
