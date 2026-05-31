import React, { useState, useCallback } from 'react';
import { View, FlatList, StyleSheet, ListRenderItemInfo } from 'react-native';
import { FAB, Chip, Text } from 'react-native-paper';
import { router, useLocalSearchParams } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { BODY_PARTS, BodyPartId } from '@src/constants/bodyParts';
import { SPECIALITIES, Speciality } from '@src/constants/specialities';
import { BODY_SPECIALITY_MAP } from '@src/constants/bodySpecialityMap';
import { SpecialityCard } from '@src/components/SpecialityCard';
import { useVisitsStore } from '@src/store/visitsStore';
import { Colors, Spacing, BorderRadius } from '@src/utils/theme';

export default function SpecialityScreen() {
  const { bodyPartId } = useLocalSearchParams<{ bodyPartId: string }>();
  const [showAll, setShowAll] = useState(false);
  const getSpecialityCount = useVisitsStore(s => s.getSpecialityCount);

  const bodyPart = BODY_PARTS.find(b => b.id === bodyPartId);
  const mappedIds = BODY_SPECIALITY_MAP[bodyPartId as BodyPartId] ?? [];
  const displayed = showAll
    ? SPECIALITIES
    : SPECIALITIES.filter(s => mappedIds.includes(s.id));

  const renderItem = useCallback(
    ({ item }: ListRenderItemInfo<Speciality>) => (
      <SpecialityCard
        speciality={item}
        visitCount={getSpecialityCount(item.id)}
        onPress={() =>
          router.push({
            pathname: '/visits/list/[specialityId]',
            params: { specialityId: item.id, bodyPartId },
          })
        }
      />
    ),
    [bodyPartId, getSpecialityCount],
  );

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right', 'bottom']}>
      <FlatList
        data={displayed}
        keyExtractor={s => s.id}
        numColumns={2}
        renderItem={renderItem}
        contentContainerStyle={styles.grid}
        columnWrapperStyle={styles.row}
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={
          <View style={styles.chipRow}>
            <Chip
              selected={showAll}
              onPress={() => setShowAll(v => !v)}
              mode={showAll ? 'flat' : 'outlined'}
              selectedColor={Colors.primary}
              style={showAll ? styles.chipActive : styles.chipInactive}
              textStyle={showAll ? styles.chipTextActive : styles.chipTextInactive}
            >
              Show All Specialities
            </Chip>
            {!showAll && (
              <Text style={styles.filterNote}>
                {displayed.length} specialit{displayed.length === 1 ? 'y' : 'ies'} for {bodyPart?.label ?? 'this area'}
              </Text>
            )}
          </View>
        }
      />

      <FAB
        icon="plus"
        style={styles.fab}
        color="#FFF"
        onPress={() =>
          router.push({
            pathname: '/visits/new',
            params: { bodyPartId },
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
  chipRow: {
    paddingHorizontal: Spacing.md,
    paddingTop: Spacing.md,
    paddingBottom: Spacing.sm,
    gap: Spacing.xs,
  },
  chipActive: {
    backgroundColor: Colors.primary + '18',
    borderRadius: BorderRadius.full,
    alignSelf: 'flex-start',
  },
  chipInactive: {
    backgroundColor: Colors.surface,
    borderRadius: BorderRadius.full,
    alignSelf: 'flex-start',
  },
  chipTextActive: {
    color: Colors.primary,
    fontWeight: '600',
  },
  chipTextInactive: {
    color: Colors.textSecondary,
  },
  filterNote: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginTop: 2,
  },
  grid: {
    paddingHorizontal: Spacing.sm,
    paddingBottom: 88,
  },
  row: {
    gap: 0,
  },
  fab: {
    position: 'absolute',
    bottom: Spacing.lg,
    right: Spacing.lg,
    backgroundColor: Colors.primary,
  },
});
