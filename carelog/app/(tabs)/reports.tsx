import React, { useEffect, useMemo, useState, useCallback } from 'react';
import {
  View,
  FlatList,
  ScrollView,
  StyleSheet,
  Modal,
  Pressable,
  Image,
  Alert,
  Linking,
  Share,
  useWindowDimensions,
} from 'react-native';
import { Text, Chip, Menu, Button } from 'react-native-paper';
import { Stack, router } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { attachmentsRepository } from '@src/db/attachmentsRepository';
import { fileService } from '@src/services/fileService';
import { SPECIALITIES } from '@src/constants/specialities';
import { EmptyState } from '@src/components/EmptyState';
import { formatVisitDate } from '@src/utils/dateUtils';
import { Colors, Spacing, BorderRadius, Shadow } from '@src/utils/theme';
import { Attachment, AttachmentType } from '@src/types/Attachment';

// findAll() JOINs visits + members so rows carry these extra columns
interface AttachmentWithVisit extends Attachment {
  doctor_name?: string | null;
  visit_date?: string | null;
  speciality_id?: string | null;
  member_name?: string;
  member_color?: string;
}

type FilterType = 'all' | AttachmentType;
type SortOrder = 'newest' | 'oldest' | 'by_type';

const FILTERS: { key: FilterType; label: string }[] = [
  { key: 'all',          label: 'All'          },
  { key: 'prescription', label: 'Prescription' },
  { key: 'medicine',     label: 'Medicine'     },
  { key: 'bill',         label: 'Bill'         },
  { key: 'report',       label: 'Report'       },
];

const SORT_LABELS: Record<SortOrder, string> = {
  newest:  'Newest First',
  oldest:  'Oldest First',
  by_type: 'By Type',
};

const TYPE_COLORS: Record<string, string> = {
  prescription: '#9C27B0',
  medicine:     '#4CAF50',
  bill:         '#FF9800',
  report:       '#2196F3',
};

const TYPE_BADGE: Record<string, string> = {
  prescription: 'Rx',
  medicine:     'Med',
  bill:         'Bill',
  report:       'Rep',
};

function toFileUri(path: string): string {
  return path.startsWith('file://') ? path : `file://${path}`;
}

// ─── Grid cell ────────────────────────────────────────────────────────────────

interface CellProps {
  item: AttachmentWithVisit;
  cellSize: number;
  onPress: (item: AttachmentWithVisit) => void;
  onLongPress: (item: AttachmentWithVisit) => void;
}

function GridCell({ item, cellSize, onPress, onLongPress }: CellProps) {
  const speciality = item.speciality_id
    ? SPECIALITIES.find(s => s.id === item.speciality_id)
    : null;
  const isPdf = item.mime_type === 'application/pdf';
  const thumbUri = item.thumbnail_path
    ? toFileUri(item.thumbnail_path)
    : toFileUri(item.file_path);
  const typeColor = TYPE_COLORS[item.type] ?? Colors.primary;

  return (
    <Pressable
      style={[styles.cell, { width: cellSize, marginBottom: 6 }]}
      onPress={() => onPress(item)}
      onLongPress={() => onLongPress(item)}
      delayLongPress={350}
      android_ripple={{ color: Colors.border, borderless: false }}
    >
      {/* Thumbnail */}
      <View style={[styles.cellThumb, { height: cellSize }]}>
        {isPdf ? (
          <View style={styles.pdfThumb}>
            <MaterialCommunityIcons
              name="file-pdf-box"
              size={cellSize * 0.42}
              color={Colors.error}
            />
            <Text style={styles.pdfThumbName} numberOfLines={2}>{item.file_name}</Text>
          </View>
        ) : (
          <Image
            source={{ uri: thumbUri }}
            style={styles.cellImage}
            resizeMode="cover"
          />
        )}

        {/* Type badge overlay — bottom left */}
        <View style={[styles.typeBadge, { backgroundColor: typeColor + 'DD' }]}>
          <Text style={styles.typeBadgeText}>{TYPE_BADGE[item.type]}</Text>
        </View>
        {/* Member color dot — top right */}
        {item.member_color ? (
          <View style={[styles.memberDot, { backgroundColor: item.member_color }]} />
        ) : null}
      </View>

      {item.visit_date ? (
        <Text style={styles.cellDate} numberOfLines={1}>
          {formatVisitDate(item.visit_date)}
        </Text>
      ) : null}

      {item.doctor_name ? (
        <Text style={styles.cellDoctor} numberOfLines={1}>{item.doctor_name}</Text>
      ) : null}

      {speciality ? (
        <View style={[styles.cellChip, { backgroundColor: speciality.color + '20' }]}>
          <Text style={[styles.cellChipText, { color: speciality.color }]}>
            {speciality.shortLabel}
          </Text>
        </View>
      ) : null}
    </Pressable>
  );
}

// ─── Full-screen viewer ───────────────────────────────────────────────────────

interface ViewerProps {
  item: AttachmentWithVisit;
  onClose: () => void;
  onShare: () => void;
}

function AttachmentViewer({ item, onClose, onShare }: ViewerProps) {
  const fileUri = toFileUri(item.file_path);
  const isPdf = item.mime_type === 'application/pdf';

  return (
    <Modal visible animationType="fade" statusBarTranslucent onRequestClose={onClose}>
      <View style={viewer.container}>
        <SafeAreaView style={viewer.topBar} edges={['top', 'left', 'right']}>
          <Pressable onPress={onClose} style={viewer.iconBtn} hitSlop={8}>
            <MaterialCommunityIcons name="close" size={26} color="#FFF" />
          </Pressable>
          <Text style={viewer.title} numberOfLines={1}>{item.file_name}</Text>
          <Pressable onPress={onShare} style={viewer.iconBtn} hitSlop={8}>
            <MaterialCommunityIcons name="share-variant" size={22} color="#FFF" />
          </Pressable>
        </SafeAreaView>

        {isPdf ? (
          <View style={viewer.pdfFallback}>
            <MaterialCommunityIcons name="file-pdf-box" size={80} color={Colors.error} />
            <Text style={viewer.pdfName}>{item.file_name}</Text>
            <Button
              mode="contained"
              style={{ marginTop: Spacing.md }}
              onPress={() =>
                Linking.openURL(fileUri).catch(() =>
                  Alert.alert('Cannot Open', 'No PDF viewer found on this device.')
                )
              }
            >
              Open with System Viewer
            </Button>
          </View>
        ) : (
          <ScrollView
            style={viewer.scrollArea}
            contentContainerStyle={viewer.scrollContent}
            maximumZoomScale={4}
            minimumZoomScale={1}
            bouncesZoom
            centerContent
            showsHorizontalScrollIndicator={false}
            showsVerticalScrollIndicator={false}
          >
            <Image
              source={{ uri: fileUri }}
              style={viewer.image}
              resizeMode="contain"
            />
          </ScrollView>
        )}
      </View>
    </Modal>
  );
}

// ─── Action sheet ─────────────────────────────────────────────────────────────

interface ActionSheetProps {
  item: AttachmentWithVisit;
  onClose: () => void;
  onShare: () => void;
  onSave: () => void;
  onDelete: () => void;
}

function ActionSheet({ item, onClose, onShare, onSave, onDelete }: ActionSheetProps) {
  const insets = useSafeAreaInsets();
  return (
    <Modal visible animationType="slide" transparent onRequestClose={onClose}>
      <Pressable style={styles.actionOverlay} onPress={onClose} />
      <View style={[styles.actionSheet, { paddingBottom: insets.bottom + Spacing.sm }]}>
        <View style={styles.actionHandle} />
        <Text style={styles.actionFileName} numberOfLines={1}>{item.file_name}</Text>
        <View style={styles.actionDivider} />

        <Pressable style={styles.actionRow} onPress={onShare}>
          <MaterialCommunityIcons name="share-variant" size={22} color={Colors.textPrimary} />
          <Text style={styles.actionRowText}>Share</Text>
        </Pressable>

        <Pressable style={styles.actionRow} onPress={onSave}>
          <MaterialCommunityIcons name="download" size={22} color={Colors.textPrimary} />
          <Text style={styles.actionRowText}>Save to Device</Text>
        </Pressable>

        <View style={styles.actionDivider} />

        <Pressable style={styles.actionRow} onPress={onDelete}>
          <MaterialCommunityIcons name="trash-can-outline" size={22} color={Colors.error} />
          <Text style={[styles.actionRowText, { color: Colors.error }]}>Delete</Text>
        </Pressable>
      </View>
    </Modal>
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────

export default function ReportsScreen() {
  const { width } = useWindowDimensions();

  const [all, setAll] = useState<AttachmentWithVisit[]>([]);
  const [filter, setFilter] = useState<FilterType>('all');
  const [sort, setSort] = useState<SortOrder>('newest');
  const [sortMenuVisible, setSortMenuVisible] = useState(false);
  const [viewerItem, setViewerItem] = useState<AttachmentWithVisit | null>(null);
  const [actionItem, setActionItem] = useState<AttachmentWithVisit | null>(null);

  // 3 columns with 6px column gap and 16px horizontal padding on each side
  const COL_GAP = 6;
  const CELL_SIZE = Math.floor((width - Spacing.md * 2 - COL_GAP * 2) / 3);

  useEffect(() => {
    setAll(attachmentsRepository.findAll() as AttachmentWithVisit[]);
  }, []);

  const displayed = useMemo(() => {
    let list: AttachmentWithVisit[] =
      filter === 'all' ? all : all.filter(a => a.type === filter);

    if (sort === 'newest') {
      list = [...list].sort((a, b) => b.created_at.localeCompare(a.created_at));
    } else if (sort === 'oldest') {
      list = [...list].sort((a, b) => a.created_at.localeCompare(b.created_at));
    } else {
      // by_type: group alphabetically, then newest-first within each type
      list = [...list].sort((a, b) =>
        a.type.localeCompare(b.type) || b.created_at.localeCompare(a.created_at)
      );
    }
    return list;
  }, [all, filter, sort]);

  // ── Action handlers ────────────────────────────────────────────────────────

  const doShare = useCallback(async (att: AttachmentWithVisit) => {
    const fileUri = toFileUri(att.file_path);
    if (att.mime_type === 'application/pdf') {
      Linking.openURL(fileUri).catch(() =>
        Alert.alert('Cannot Open', 'No app found to open this file.')
      );
      return;
    }
    try {
      await Share.share({ url: fileUri, title: att.file_name });
    } catch (e: any) {
      if (e?.message !== 'User cancelled') {
        Alert.alert('Error', 'Could not share this file.');
      }
    }
  }, []);

  const doSave = useCallback(async (att: AttachmentWithVisit) => {
    const fileUri = toFileUri(att.file_path);
    try {
      // Native share sheet lets user pick "Save Image" / "Save to Files"
      await Share.share({ url: fileUri, title: att.file_name, message: att.file_name });
    } catch (e: any) {
      if (e?.message !== 'User cancelled') {
        Alert.alert('Error', 'Could not save this file.');
      }
    }
  }, []);

  const doDelete = useCallback((att: AttachmentWithVisit) => {
    Alert.alert(
      'Delete Attachment',
      `Delete "${att.file_name}"? This cannot be undone.`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try { await fileService.deleteAttachment(att.file_path); } catch {}
            attachmentsRepository.delete(att.id);
            setAll(prev => prev.filter(a => a.id !== att.id));
          },
        },
      ]
    );
  }, []);

  // Bound to current actionItem / viewerItem so sub-components don't need deps
  const handleShare = useCallback(() => {
    const target = actionItem ?? viewerItem;
    if (!target) return;
    setActionItem(null);
    doShare(target);
  }, [actionItem, viewerItem, doShare]);

  const handleSave = useCallback(() => {
    if (!actionItem) return;
    setActionItem(null);
    doSave(actionItem);
  }, [actionItem, doSave]);

  const handleDelete = useCallback(() => {
    if (!actionItem) return;
    setActionItem(null);
    doDelete(actionItem);
  }, [actionItem, doDelete]);

  // ── Render helpers ────────────────────────────────────────────────────────

  const renderCell = useCallback(
    ({ item }: { item: AttachmentWithVisit }) => (
      <GridCell
        item={item}
        cellSize={CELL_SIZE}
        onPress={setViewerItem}
        onLongPress={setActionItem}
      />
    ),
    [CELL_SIZE]
  );

  const listHeader = useMemo(
    () => (
      <View>
        {/* Filter chips — horizontal scroll */}
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.chipRow}
        >
          {FILTERS.map(f => (
            <Chip
              key={f.key}
              selected={filter === f.key}
              onPress={() => setFilter(f.key)}
              mode={filter === f.key ? 'flat' : 'outlined'}
              style={styles.chip}
              compact
            >
              {f.label}
            </Chip>
          ))}
        </ScrollView>

        {/* Sort row */}
        <View style={styles.sortRow}>
          <Menu
            visible={sortMenuVisible}
            onDismiss={() => setSortMenuVisible(false)}
            anchor={
              <Pressable style={styles.sortBtn} onPress={() => setSortMenuVisible(true)}>
                <MaterialCommunityIcons name="sort" size={15} color={Colors.textSecondary} />
                <Text style={styles.sortBtnLabel}>{SORT_LABELS[sort]}</Text>
                <MaterialCommunityIcons name="chevron-down" size={15} color={Colors.textSecondary} />
              </Pressable>
            }
          >
            {(['newest', 'oldest', 'by_type'] as SortOrder[]).map(s => (
              <Menu.Item
                key={s}
                title={SORT_LABELS[s]}
                onPress={() => { setSort(s); setSortMenuVisible(false); }}
                leadingIcon={sort === s ? 'check' : undefined}
              />
            ))}
          </Menu>

          <Text style={styles.countText}>
            {displayed.length} file{displayed.length !== 1 ? 's' : ''}
          </Text>
        </View>
      </View>
    ),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [filter, sort, sortMenuVisible, displayed.length]
  );

  // ── Render ────────────────────────────────────────────────────────────────

  return (
    <SafeAreaView style={styles.safe} edges={['left', 'right', 'bottom']}>
      <Stack.Screen
        options={{
          title: 'Reports Hub',
          headerStyle: { backgroundColor: Colors.primary },
          headerTintColor: '#FFF',
          headerTitleStyle: { fontWeight: '700' as const },
          headerRight: () => (
            <Pressable
              onPress={() => router.push('/search')}
              style={styles.headerBtn}
              hitSlop={8}
            >
              <MaterialCommunityIcons name="magnify" size={24} color="#FFF" />
            </Pressable>
          ),
        }}
      />

      <FlatList<AttachmentWithVisit>
        data={displayed}
        numColumns={3}
        keyExtractor={a => a.id}
        renderItem={renderCell}
        ListHeaderComponent={listHeader}
        ListEmptyComponent={
          <EmptyState
            icon="folder-open-outline"
            title="No files found"
            subtitle={
              filter === 'all'
                ? 'Attachments you add to visits will appear here.'
                : `No ${filter} files yet.`
            }
          />
        }
        contentContainerStyle={[
          styles.grid,
          displayed.length === 0 && styles.gridEmpty,
        ]}
        columnWrapperStyle={{ gap: COL_GAP }}
        showsVerticalScrollIndicator={false}
      />

      {viewerItem && (
        <AttachmentViewer
          item={viewerItem}
          onClose={() => setViewerItem(null)}
          onShare={handleShare}
        />
      )}

      {actionItem && (
        <ActionSheet
          item={actionItem}
          onClose={() => setActionItem(null)}
          onShare={handleShare}
          onSave={handleSave}
          onDelete={handleDelete}
        />
      )}
    </SafeAreaView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  headerBtn: {
    paddingHorizontal: Spacing.sm,
  },

  // Chips
  chipRow: {
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    gap: Spacing.xs,
  },
  chip: {
    borderRadius: BorderRadius.full,
  },

  // Sort row
  sortRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: Spacing.md,
    paddingBottom: Spacing.sm,
  },
  sortBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingVertical: Spacing.xs,
    paddingRight: Spacing.xs,
  },
  sortBtnLabel: {
    fontSize: 13,
    color: Colors.textSecondary,
    fontWeight: '500',
  },
  countText: {
    fontSize: 12,
    color: Colors.textDisabled,
  },

  // Grid
  grid: {
    paddingHorizontal: Spacing.md,
    paddingBottom: 24,
  },
  gridEmpty: {
    flex: 1,
  },

  // Cell
  cell: {
    borderRadius: BorderRadius.sm,
    overflow: 'hidden',
    backgroundColor: Colors.surface,
    ...Shadow.card,
  },
  cellThumb: {
    width: '100%',
    backgroundColor: Colors.border,
    position: 'relative',
    overflow: 'hidden',
  },
  cellImage: {
    width: '100%',
    height: '100%',
  },
  pdfThumb: {
    flex: 1,
    backgroundColor: '#FFF5F5',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 6,
    gap: 2,
  },
  pdfThumbName: {
    fontSize: 9,
    textAlign: 'center',
    color: Colors.textSecondary,
    paddingHorizontal: 2,
  },
  typeBadge: {
    position: 'absolute',
    bottom: 4,
    left: 4,
    borderRadius: BorderRadius.sm,
    paddingHorizontal: 5,
    paddingVertical: 1,
  },
  typeBadgeText: {
    fontSize: 9,
    fontWeight: '700',
    color: '#FFF',
  },
  memberDot: {
    position: 'absolute',
    top: 4,
    right: 4,
    width: 9,
    height: 9,
    borderRadius: 5,
    borderWidth: 1.5,
    borderColor: 'rgba(255,255,255,0.7)',
  },
  cellDate: {
    fontSize: 10,
    color: Colors.textSecondary,
    paddingHorizontal: 5,
    paddingTop: 4,
  },
  cellDoctor: {
    fontSize: 10,
    fontWeight: '600',
    color: Colors.textPrimary,
    paddingHorizontal: 5,
    paddingTop: 1,
  },
  cellChip: {
    alignSelf: 'flex-start',
    borderRadius: BorderRadius.full,
    marginHorizontal: 5,
    marginTop: 3,
    marginBottom: 5,
    paddingHorizontal: 6,
    paddingVertical: 1,
  },
  cellChipText: {
    fontSize: 9,
    fontWeight: '700',
  },

  // Action sheet
  actionOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.35)',
  },
  actionSheet: {
    backgroundColor: Colors.surface,
    borderTopLeftRadius: BorderRadius.lg,
    borderTopRightRadius: BorderRadius.lg,
    paddingTop: Spacing.sm,
    paddingHorizontal: Spacing.md,
    ...Shadow.card,
  },
  actionHandle: {
    alignSelf: 'center',
    width: 36,
    height: 4,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.border,
    marginBottom: Spacing.sm,
  },
  actionFileName: {
    fontSize: 13,
    color: Colors.textSecondary,
    marginBottom: Spacing.sm,
  },
  actionDivider: {
    height: 1,
    backgroundColor: Colors.border,
    marginVertical: Spacing.xs,
  },
  actionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.md,
    paddingVertical: 14,
  },
  actionRowText: {
    fontSize: 15,
    color: Colors.textPrimary,
    fontWeight: '500',
  },
});

// ─── Viewer styles ────────────────────────────────────────────────────────────

const viewer = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: Spacing.xs,
    paddingVertical: Spacing.xs,
    backgroundColor: 'rgba(0,0,0,0.6)',
  },
  iconBtn: {
    padding: Spacing.sm,
  },
  title: {
    flex: 1,
    color: '#FFF',
    fontSize: 14,
    fontWeight: '500',
    marginHorizontal: Spacing.xs,
  },
  scrollArea: {
    flex: 1,
  },
  scrollContent: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  image: {
    width: '100%',
    aspectRatio: 1,
  },
  pdfFallback: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: Spacing.xl,
    gap: Spacing.sm,
  },
  pdfName: {
    color: '#FFF',
    fontSize: 14,
    textAlign: 'center',
  },
});
