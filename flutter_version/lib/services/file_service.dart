import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SavedFile {
  final String filePath;
  final String fileName;
  final String? thumbnailPath;
  final int sizeBytes;

  const SavedFile({
    required this.filePath,
    required this.fileName,
    this.thumbnailPath,
    required this.sizeBytes,
  });
}

/// Manages on-disk storage for visit attachments and insurance documents.
/// Files are organised under `<appDocs>/attachments/<ownerId>/` where ownerId
/// is either a visit UUID or a policy UUID — they never collide.
class FileService {
  static const _uuid = Uuid();

  Future<String> _attachmentsRoot() async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, 'attachments');
  }

  String _extForMime(String mimeType) {
    if (mimeType == 'application/pdf') return '.pdf';
    if (mimeType == 'image/png') return '.png';
    return '.jpg';
  }

  /// Copies [sourcePath] into `attachments/<ownerId>/`, compressing images and
  /// generating a thumbnail (max 400 px on the longest edge).
  Future<SavedFile> saveFile(
    String ownerId,
    String label,
    String sourcePath,
    String mimeType,
  ) async {
    final root = await _attachmentsRoot();
    final dir = p.join(root, ownerId);
    await Directory(dir).create(recursive: true);

    final ext = _extForMime(mimeType);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${label}_$stamp$ext';
    final destPath = p.join(dir, fileName);
    final isImage = mimeType.startsWith('image/');

    String? thumbnailPath;

    if (isImage) {
      final bytes = await File(sourcePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        // Compress: limit longest edge to 2048 px
        img.Image processed = decoded;
        final longest = decoded.width > decoded.height ? decoded.width : decoded.height;
        if (longest > 2048) {
          final scale = 2048 / longest;
          processed = img.copyResize(
            decoded,
            width: (decoded.width * scale).round(),
            height: (decoded.height * scale).round(),
          );
        }
        await File(destPath).writeAsBytes(img.encodeJpg(processed, quality: 85));

        // Thumbnail: limit longest edge to 400 px
        final tLongest = processed.width > processed.height ? processed.width : processed.height;
        final tScale = 400 / tLongest;
        final thumb = img.copyResize(
          processed,
          width: (processed.width * tScale).round(),
          height: (processed.height * tScale).round(),
        );
        final thumbName = 'thumb_${_uuid.v4()}.jpg';
        final thumbPath = p.join(dir, thumbName);
        await File(thumbPath).writeAsBytes(img.encodeJpg(thumb, quality: 80));
        thumbnailPath = thumbPath;
      } else {
        // Unrecognised image format — copy as-is
        await File(sourcePath).copy(destPath);
      }
    } else {
      await File(sourcePath).copy(destPath);
    }

    final sizeBytes = await File(destPath).length();
    return SavedFile(
      filePath: destPath,
      fileName: fileName,
      thumbnailPath: thumbnailPath,
      sizeBytes: sizeBytes,
    );
  }

  Future<SavedFile> saveAttachment(
    String visitId,
    String type,
    String sourcePath,
    String mimeType,
  ) =>
      saveFile(visitId, type, sourcePath, mimeType);

  Future<SavedFile> saveInsuranceDocument(
    String policyId,
    String sourcePath,
    String mimeType,
  ) =>
      saveFile(policyId, 'insurance', sourcePath, mimeType);

  Future<void> deleteFiles(List<String> paths) async {
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> deleteOwnerDir(String ownerId) async {
    final root = await _attachmentsRoot();
    final dir = Directory(p.join(root, ownerId));
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  Future<void> deleteAllAttachments() async {
    final root = await _attachmentsRoot();
    final dir = Directory(root);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Sums the size of every file under the attachments root.
  Future<int> getStorageUsedBytes() async {
    final root = await _attachmentsRoot();
    final dir = Directory(root);
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }
}

final fileService = FileService();
