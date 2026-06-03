import 'dart:io';

import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/app_theme.dart';

class AttachmentThumbnail extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final double size;

  const AttachmentThumbnail({
    super.key,
    required this.attachment,
    required this.onTap,
    this.onDelete,
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = attachment.mimeType == 'application/pdf';
    final imagePath = attachment.thumbnailPath ?? attachment.filePath;

    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 4,
            top: 4,
            child: GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: isPdf ? _PdfPlaceholder(name: attachment.fileName, size: size) : _ImageTile(path: imagePath),
                ),
              ),
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.surface, width: 1.5),
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String path;
  const _ImageTile({required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.border,
        child: const Icon(Icons.broken_image_outlined,
            color: AppColors.textDisabled),
      ),
    );
  }
}

class _PdfPlaceholder extends StatelessWidget {
  final String name;
  final double size;
  const _PdfPlaceholder({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF5F5),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf,
              size: size * 0.38, color: AppColors.error),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(
                fontSize: 9, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
