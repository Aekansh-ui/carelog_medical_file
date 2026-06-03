import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/app_theme.dart';
import 'attachment_thumbnail.dart';

const _typeLabels = {
  'prescription': 'Prescription',
  'medicine': 'Medicine',
  'bill': 'Bill',
  'report': 'Report',
};

class AttachmentGrid extends StatelessWidget {
  final List<Attachment> attachments;
  final String type;
  final VoidCallback? onAdd;
  final void Function(String id) onDelete;
  final void Function(Attachment att) onView;
  final int maxFiles;

  const AttachmentGrid({
    super.key,
    required this.attachments,
    required this.type,
    this.onAdd,
    required this.onDelete,
    required this.onView,
    this.maxFiles = 10,
  });

  @override
  Widget build(BuildContext context) {
    final canAdd = onAdd != null && attachments.length < maxFiles;
    return Wrap(
      children: [
        ...attachments.map((att) => AttachmentThumbnail(
              attachment: att,
              onTap: () => onView(att),
              onDelete: () => onDelete(att.id),
            )),
        if (canAdd) _AddCard(label: _typeLabels[type] ?? type, onTap: onAdd!),
      ],
    );
  }
}

class _AddCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddCard({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 26, color: AppColors.primary),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
