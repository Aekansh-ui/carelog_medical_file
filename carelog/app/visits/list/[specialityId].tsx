import React, { useEffect, useCallback } from 'react';
import { View, FlatList, StyleSheet, RefreshControl } from 'react-native';
import { FAB, Text } from 'react-native-paper';
import { Stack, router, useLocalSearchParams } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useVisitsStore } from '@src/store/visitsStore';
import { SPECIALITIES } from '@src/constants/specialities';
import { BODY_PARTS } from '@src/constants/bodyParts';
import { VisitCard } from '@src/components/VisitCard';
import { EmptyState } from '@src/components/EmptyState';
import { Colors, Spacing, BorderRadius } from '@src/utils/theme';

export default function VisitListScreen() {
  const { specialityId, bodyPartId, memberId } = useLocalSearchParams<{
    specialityId: string;
    bodyPartId: string;
    memberId?: string;
  }>();

  const currentSpecialityVisits = useVisitsStore(s => s.currentSpecialityVisits);
  const isLoading = useVisitsStore(s => s.isLoading);
  const loadVisitsBySpeciality = useVisitsStore(s => s.loadVisitsBySpeciality);

  const speciality = SPECIALITIES.find(s => s.id === specialityId);
  const bodyPart = BODY_PARTS.find(b => b.id === bodyPartId);

  const load = useCallback(() => {
    loadVisitsBySpeciality(bodyPartId ?? '', specialityId ?? '', memberId);
  }, [bodyPartId, specialityId, memberId, loadVisitsBySpeciality]);

  useEffect(() => {
    load();
  }, [load]);

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right', 'bottom']}>
      {/* Override the Stack header title with the speciality label */}
      <Stack.Screen
        options={{
          title: speciality?.label ?? 'Visits',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
        }}
      />

      {/* Breadcrumb strip: Body Part → Speciality */}
      {bodyPart && (
        <View style={styles.breadcrumb}>
          <MaterialCommunityIcons
            name={bodyPart.icon as any}
            size={13}
            color={Colors.primary}
          />
          <Text style={styles.breadcrumbText}>{bodyPart.label}</Text>
          {speciality && (
            <>
              <MaterialCommunityIcons
                name="chevron-right"
                size={13}
                color={Colors.textDisabled}
              />
              <View
                style={[
                  styles.specialityChip,
                  { backgroundColor: speciality.color + '18' },
                ]}
              >
                <Text style={[styles.specialityChipText, { color: speciality.color }]}>
                  {speciality.shortLabel}
                </Text>
              </View>
            </>
          )}
        </View>
      )}

      <FlatList
        data={currentSpecialityVisits}
        keyExtractor={v => v.id}
        renderItem={({ item }) => (
          <VisitCard
            visit={item}
            onPress={() => router.push(`/visits/${item.id}`)}
          />
        )}
        ListEmptyComponent={
          isLoading ? null : (
            <EmptyState
              icon={speciality?.icon ?? 'stethoscope'}
              title="No visits yet"
              subtitle={`No ${speciality?.label ?? ''} visits recorded.\nTap + to add the first one.`}
              actionLabel="Add Visit"
              onAction={() =>
                router.push({
                  pathname: '/visits/new',
                  params: {
                    bodyPartId,
                    specialityId,
                    ...(memberId ? { memberId } : {}),
                  },
                })
              }
            />
          )
        }
        contentContainerStyle={[
          styles.list,
          currentSpecialityVisits.length === 0 && styles.listEmpty,
        ]}
        refreshControl={
          <RefreshControl
            refreshing={isLoading}
            onRefresh={load}
            colors={[Colors.primary]}
            tintColor={Colors.primary}
          />
        }
        showsVerticalScrollIndicator={false}
      />

      <FAB
        icon="plus"
        style={styles.fab}
        color="#FFF"
        onPress={() =>
          router.push({
            pathname: '/visits/new',
            params: {
              bodyPartId,
              specialityId,
              ...(memberId ? { memberId } : {}),
            },
          })
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
  breadcrumb: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.xs,
    backgroundColor: Colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  breadcrumbText: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  specialityChip: {
    borderRadius: BorderRadius.full,
    paddingHorizontal: 8,
    paddingVertical: 1,
  },
  specialityChipText: {
    fontSize: 11,
    fontWeight: '600',
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
