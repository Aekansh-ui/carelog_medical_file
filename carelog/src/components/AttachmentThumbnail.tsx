import React from 'react';
import { View, Image, Pressable, StyleSheet, TouchableOpacity } from 'react-native';
import { Text } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Attachment } from '@src/types/Attachment';
import { Colors, BorderRadius } from '@src/utils/theme';

interface AttachmentThumbnailProps {
  attachment: Attachment;
  onPress: () => void;
  onDelete?: () => void;
  size?: number;
}

export function AttachmentThumbnail({
  attachment,
  onPress,
  onDelete,
  size = 100,
}: AttachmentThumbnailProps) {
  const isPdf = attachment.mime_type === 'application/pdf';
  const imageUri = attachment.thumbnail_path ?? attachment.file_path;

  return (
    <View style={[styles.wrapper, { width: size, height: size }]}>
      <Pressable onPress={onPress} style={styles.fill}>
        {isPdf ? (
          <View style={[styles.pdfPlaceholder, styles.fill]}>
            <MaterialCommunityIcons name="file-pdf-box" size={size * 0.38} color={Colors.error} />
            <Text style={styles.pdfLabel} numberOfLines={2}>{attachment.file_name}</Text>
          </View>
        ) : (
          <Image
            source={{ uri: imageUri }}
            style={styles.fill}
            resizeMode="cover"
          />
        )}
      </Pressable>

      {/* × delete overlay */}
      {onDelete ? (
        <TouchableOpacity
          onPress={onDelete}
          style={styles.deleteBtn}
          hitSlop={{ top: 6, right: 6, bottom: 6, left: 6 }}
        >
          <View style={styles.deleteDot}>
            <MaterialCommunityIcons name="close" size={10} color="#FFFFFF" />
          </View>
        </TouchableOpacity>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    borderRadius: BorderRadius.sm,
    overflow: 'visible',
    margin: 4,
    position: 'relative',
  },
  fill: {
    width: '100%',
    height: '100%',
    borderRadius: BorderRadius.sm,
    overflow: 'hidden',
  },
  pdfPlaceholder: {
    backgroundColor: '#FFF5F5',
    borderWidth: 1,
    borderColor: '#FFCDD2',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 4,
  },
  pdfLabel: {
    fontSize: 9,
    textAlign: 'center',
    color: Colors.textSecondary,
    marginTop: 2,
    paddingHorizontal: 2,
  },
  deleteBtn: {
    position: 'absolute',
    top: -8,
    right: -8,
    zIndex: 10,
  },
  deleteDot: {
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: Colors.error,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1.5,
    borderColor: Colors.surface,
  },
});
