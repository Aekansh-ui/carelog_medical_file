import React from 'react';
import { View, StyleSheet, Pressable } from 'react-native';
import { Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Attachment, AttachmentType } from '@src/types/Attachment';
import { AttachmentThumbnail } from './AttachmentThumbnail';
import { Colors, Spacing, BorderRadius } from '@src/utils/theme';

interface AttachmentGridProps {
  attachments: Attachment[];
  type: AttachmentType;
  onAdd: () => void;
  onDelete: (id: string) => void;
  onView: (attachment: Attachment) => void;
  maxFiles: number;
}

const TYPE_LABEL: Record<AttachmentType, string> = {
  prescription: 'Prescription',
  medicine: 'Medicine',
  bill: 'Bill',
  report: 'Report',
};

export function AttachmentGrid({
  attachments,
  type,
  onAdd,
  onDelete,
  onView,
  maxFiles,
}: AttachmentGridProps) {
  const canAdd = attachments.length < maxFiles;

  return (
    <View style={styles.grid}>
      {attachments.map((att) => (
        <AttachmentThumbnail
          key={att.id}
          attachment={att}
          onPress={() => onView(att)}
          onDelete={() => onDelete(att.id)}
          size={88}
        />
      ))}

      {/* Add card — hidden when at maxFiles limit */}
      {canAdd ? (
        <Pressable onPress={onAdd} style={styles.addCard}>
          <MaterialCommunityIcons name="plus" size={26} color={Colors.primary} />
          <Text style={styles.addLabel}>{TYPE_LABEL[type]}</Text>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingTop: Spacing.xs,
  },
  addCard: {
    width: 88,
    height: 88,
    margin: 4,
    borderRadius: BorderRadius.sm,
    borderWidth: 1.5,
    borderColor: Colors.primary,
    borderStyle: 'dashed',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 2,
    backgroundColor: Colors.primary + '08',
  },
  addLabel: {
    fontSize: 10,
    color: Colors.primary,
    fontWeight: '500',
  },
});
