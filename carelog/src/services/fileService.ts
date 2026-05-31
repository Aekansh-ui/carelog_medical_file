import * as FileSystem from 'expo-file-system';
import * as ImageManipulator from 'expo-image-manipulator';
import { AttachmentType } from '@src/types/Attachment';

const BASE_DIR = `${FileSystem.documentDirectory}carelog/`;
const ATTACHMENTS_DIR = `${BASE_DIR}attachments/`;

function visitDir(visitId: string): string {
  return `${ATTACHMENTS_DIR}${visitId}/`;
}

async function ensureDir(path: string): Promise<void> {
  await FileSystem.makeDirectoryAsync(path, { intermediates: true });
}

function extForMime(mimeType: string): string {
  if (mimeType === 'application/pdf') return '.pdf';
  if (mimeType === 'image/png') return '.png';
  return '.jpg';
}

export const fileService = {
  /**
   * Copies sourceUri into carelog/attachments/{visitId}/, optionally compressing
   * and generating a thumbnail for images.
   */
  async saveAttachment(
    visitId: string,
    type: AttachmentType,
    sourceUri: string,
    mimeType: string,
  ): Promise<{ filePath: string; fileName: string; thumbnailPath?: string; sizeBytes: number }> {
    const dir = visitDir(visitId);
    await ensureDir(dir);

    const ext = extForMime(mimeType);
    const fileName = `${type}_${Date.now()}${ext}`;
    const isImage = mimeType.startsWith('image/');

    // Compress before saving if it's an image
    const processedUri = isImage
      ? await fileService.compressImage(sourceUri)
      : sourceUri;

    const filePath = `${dir}${fileName}`;
    await FileSystem.copyAsync({ from: processedUri, to: filePath });

    const info = await FileSystem.getInfoAsync(filePath);
    const sizeBytes = info.exists && !info.isDirectory ? (info as any).size ?? 0 : 0;

    let thumbnailPath: string | undefined;
    if (isImage) {
      thumbnailPath = await fileService.generateThumbnail(filePath);
    }

    return { filePath, fileName, thumbnailPath, sizeBytes };
  },

  /** Deletes a file (and optionally its thumbnail) from the filesystem. */
  async deleteAttachment(filePath: string): Promise<void> {
    const info = await FileSystem.getInfoAsync(filePath);
    if (info.exists) await FileSystem.deleteAsync(filePath, { idempotent: true });
  },

  /**
   * Resizes an image to fit within 200×200 and saves it to the thumbnails
   * subdirectory. Returns the path of the saved thumbnail.
   */
  async generateThumbnail(filePath: string): Promise<string> {
    const thumbDir = `${BASE_DIR}thumbnails/`;
    await ensureDir(thumbDir);

    const result = await ImageManipulator.manipulateAsync(
      filePath,
      [{ resize: { width: 200, height: 200 } }],
      { compress: 0.8, format: ImageManipulator.SaveFormat.JPEG },
    );

    const thumbPath = `${thumbDir}thumb_${Date.now()}.jpg`;
    await FileSystem.copyAsync({ from: result.uri, to: thumbPath });
    return thumbPath;
  },

  /**
   * Compresses an image to max 2048px on the longest edge at quality 85.
   * Returns the URI of the compressed image (in the system tmp cache).
   */
  async compressImage(uri: string): Promise<string> {
    // First pass with no actions to read dimensions
    const probe = await ImageManipulator.manipulateAsync(uri, [], {});
    const { width, height } = probe;
    const longestEdge = Math.max(width, height);

    const actions: ImageManipulator.Action[] = [];
    if (longestEdge > 2048) {
      const scale = 2048 / longestEdge;
      actions.push({
        resize: {
          width: Math.round(width * scale),
          height: Math.round(height * scale),
        },
      });
    }

    const result = await ImageManipulator.manipulateAsync(
      uri,
      actions,
      { compress: 0.85, format: ImageManipulator.SaveFormat.JPEG },
    );
    return result.uri;
  },

  /** Sums the size of every file under carelog/attachments/. */
  async getStorageUsedBytes(): Promise<number> {
    const info = await FileSystem.getInfoAsync(ATTACHMENTS_DIR);
    if (!info.exists) return 0;

    let total = 0;
    const visitFolders = await FileSystem.readDirectoryAsync(ATTACHMENTS_DIR);
    for (const folder of visitFolders) {
      const folderPath = `${ATTACHMENTS_DIR}${folder}/`;
      const folderInfo = await FileSystem.getInfoAsync(folderPath);
      if (!folderInfo.exists || !folderInfo.isDirectory) continue;
      const files = await FileSystem.readDirectoryAsync(folderPath);
      for (const file of files) {
        const fInfo = await FileSystem.getInfoAsync(`${folderPath}${file}`);
        if (fInfo.exists && !fInfo.isDirectory) total += (fInfo as any).size ?? 0;
      }
    }
    return total;
  },

  /** Deletes the entire carelog/ directory (all attachments and thumbnails). */
  async deleteAllAttachments(): Promise<void> {
    const info = await FileSystem.getInfoAsync(BASE_DIR);
    if (info.exists) await FileSystem.deleteAsync(BASE_DIR, { idempotent: true });
  },
};
