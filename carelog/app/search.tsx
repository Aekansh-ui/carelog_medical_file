import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  FlatList,
  Pressable,
  StyleSheet,
  TextInput,
  View,
} from 'react-native';
import { Text } from 'react-native-paper';
import { Stack, router } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useVisitsStore } from '@src/store/visitsStore';
import { VisitCard } from '@src/components/VisitCard';
import { SectionHeader } from '@src/components/SectionHeader';
import { EmptyState } from '@src/components/EmptyState';
import { Colors, Spacing, BorderRadius } from '@src/utils/theme';
import { Visit } from '@src/types/Visit';

// ─── Match hint ───────────────────────────────────────────────────────────────
//
// FTS5 indexes these five columns. We probe them in priority order to tell the
// user which part of the visit matched their query. `includes()` is an
// approximation of FTS5 tokenisation — close enough for non-stemmed queries.

const SEARCHABLE_FIELDS: { key: keyof Visit; label: string }[] = [
  { key: 'doctor_name', label: 'Doctor name' },
  { key: 'clinic_name', label: 'Clinic name' },
  { key: 'symptoms',    label: 'Symptoms'    },
  { key: 'diagnosis',   label: 'Diagnosis'   },
  { key: 'notes',       label: 'Notes'       },
];

function getMatchHint(visit: Visit, query: string): string {
  const q = query.toLowerCase().trim();
  for (const { key, label } of SEARCHABLE_FIELDS) {
    const value = visit[key];
    if (typeof value === 'string' && value.toLowerCase().includes(q)) {
      return `Matched in: ${label}`;
    }
  }
  // FTS5 stemming / prefix match caught it but simple includes() didn't
  return 'Matched in: visit content';
}

// ─── Result item ──────────────────────────────────────────────────────────────

interface ResultItemProps {
  visit: Visit;
  query: string;
  showHint: boolean;
}

function ResultItem({ visit, query, showHint }: ResultItemProps) {
  const hint = showHint ? getMatchHint(visit, query) : null;

  return (
    <View>
      <VisitCard
        visit={visit}
        onPress={() => router.push(`/visits/${visit.id}`)}
      />
      {hint ? (
        <View style={styles.matchHint}>
          <MaterialCommunityIcons name="text-search" size={11} color={Colors.primary} />
          <Text style={styles.matchHintText}>{hint}</Text>
        </View>
      ) : null}
    </View>
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────

export default function SearchScreen() {
  const inputRef = useRef<TextInput>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout>>();

  const [query, setQuery] = useState('');

  const recentVisits    = useVisitsStore(s => s.recentVisits);
  const searchResults   = useVisitsStore(s => s.searchResults);
  const loadRecentVisits = useVisitsStore(s => s.loadRecentVisits);
  const searchVisits    = useVisitsStore(s => s.searchVisits);
  const clearSearch     = useVisitsStore(s => s.clearSearch);

  useEffect(() => {
    loadRecentVisits();
    // Belt-and-suspenders auto-focus in case the autoFocus prop fires before
    // the component is fully laid out (common on Android)
    const t = setTimeout(() => inputRef.current?.focus(), 80);
    return () => {
      clearTimeout(t);
      if (debounceRef.current) clearTimeout(debounceRef.current);
      clearSearch();
    };
  // loadRecentVisits and clearSearch are stable Zustand actions
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleChangeText = useCallback(
    (text: string) => {
      setQuery(text);
      if (debounceRef.current) clearTimeout(debounceRef.current);
      debounceRef.current = setTimeout(() => {
        // searchVisits clears results when text is empty, so no branch needed
        searchVisits(text.trim());
      }, 300);
    },
    [searchVisits],
  );

  function handleClear() {
    handleChangeText('');
  }

  function handleBack() {
    clearSearch();
    router.back();
  }

  const isSearching = query.trim().length > 0;
  const data = isSearching ? searchResults : recentVisits;
  const listTitle = isSearching
    ? `Results for "${query.trim()}"`
    : 'Recent Visits';

  const renderItem = useCallback(
    ({ item }: { item: Visit }) => (
      <ResultItem visit={item} query={query.trim()} showHint={isSearching} />
    ),
    [query, isSearching],
  );

  return (
    <>
      {/* Hide the Stack header — we render a fully custom search bar instead */}
      <Stack.Screen options={{ headerShown: false }} />

      <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
        {/* ── Custom search header ── */}
        <View style={styles.header}>
          <Pressable onPress={handleBack} style={styles.backBtn} hitSlop={8}>
            <MaterialCommunityIcons name="arrow-left" size={24} color="#FFF" />
          </Pressable>

          <View style={styles.searchBar}>
            <MaterialCommunityIcons
              name="magnify"
              size={18}
              color="rgba(255,255,255,0.65)"
            />
            <TextInput
              ref={inputRef}
              value={query}
              onChangeText={handleChangeText}
              placeholder="Search visits…"
              placeholderTextColor="rgba(255,255,255,0.5)"
              style={styles.searchInput}
              autoFocus
              returnKeyType="search"
              autoCapitalize="none"
              autoCorrect={false}
              selectTextOnFocus={false}
            />
            {query.length > 0 ? (
              <Pressable onPress={handleClear} hitSlop={10}>
                <MaterialCommunityIcons
                  name="close-circle"
                  size={17}
                  color="rgba(255,255,255,0.65)"
                />
              </Pressable>
            ) : null}
          </View>
        </View>

        {/* ── Results / recent list ── */}
        <FlatList<Visit>
          data={data}
          keyExtractor={v => v.id}
          renderItem={renderItem}
          ListHeaderComponent={<SectionHeader title={listTitle} />}
          ListEmptyComponent={
            isSearching ? (
              <EmptyState
                icon="magnify-close"
                title="No visits found"
                subtitle={`No visits found for "${query.trim()}"`}
              />
            ) : null
          }
          contentContainerStyle={[
            styles.list,
            data.length === 0 && styles.listEmpty,
          ]}
          keyboardShouldPersistTaps="handled"
          keyboardDismissMode="on-drag"
          showsVerticalScrollIndicator={false}
        />
      </SafeAreaView>
    </>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: Colors.background,
  },

  // Custom search header
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.primary,
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.sm,
    gap: Spacing.xs,
  },
  backBtn: {
    padding: Spacing.sm,
  },
  searchBar: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: BorderRadius.full,
    paddingHorizontal: Spacing.sm,
    height: 40,
  },
  searchInput: {
    flex: 1,
    color: '#FFF',
    fontSize: 15,
    paddingVertical: 0, // remove Android default vertical padding
  },

  // Results list
  list: {
    paddingTop: Spacing.xs,
    paddingBottom: Spacing.xl,
  },
  listEmpty: {
    flex: 1,
  },

  // Match hint shown below each result card
  matchHint: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    alignSelf: 'flex-start',
    marginLeft: Spacing.md + Spacing.sm,  // indent to align with card content
    marginTop: -Spacing.xs,               // tuck up under the card's bottom margin
    marginBottom: Spacing.xs,
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
    backgroundColor: Colors.primary + '14',
    borderRadius: BorderRadius.full,
  },
  matchHintText: {
    fontSize: 11,
    color: Colors.primary,
    fontWeight: '500',
  },
});
