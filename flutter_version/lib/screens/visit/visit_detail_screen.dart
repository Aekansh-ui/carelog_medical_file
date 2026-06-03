import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/body_parts.dart';
import '../../constants/specialities.dart';
import '../../data/database.dart';
import '../../providers/members_provider.dart';
import '../../providers/visits_provider.dart';
import '../../services/file_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/attachment_grid.dart';
import '../../widgets/doc_viewer.dart';
import '../../widgets/member_badge.dart';

class VisitDetailScreen extends ConsumerStatefulWidget {
  final String visitId;

  const VisitDetailScreen({super.key, required this.visitId});

  @override
  ConsumerState<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends ConsumerState<VisitDetailScreen> {
  List<Attachment> _attachments = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref.read(visitsProvider.notifier).loadById(widget.visitId);
    final atts =
        await ref.read(visitsProvider.notifier).loadAttachments(widget.visitId);
    if (mounted) setState(() { _attachments = atts; _loaded = true; });
  }

  Future<void> _deleteAttachment(Attachment att) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Attachment'),
        content: Text('Delete "${att.fileName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ref2 = await ref
        .read(visitsProvider.notifier)
        .deleteAttachment(att.id);
    if (ref2 != null) {
      await fileService.deleteFiles([
        ref2.filePath,
        if (ref2.thumbnailPath != null) ref2.thumbnailPath!,
      ]);
    }
    if (mounted) setState(() => _attachments.removeWhere((a) => a.id == att.id));
  }

  Future<void> _deleteVisit(Visit visit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visit'),
        content: const Text(
            'This will permanently delete the visit and all its attachments.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final refs =
        await ref.read(visitsProvider.notifier).deleteVisit(widget.visitId);
    final paths = refs
        .expand((r) => [r.filePath, if (r.thumbnailPath != null) r.thumbnailPath!])
        .toList();
    if (paths.isNotEmpty) await fileService.deleteFiles(paths);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final visit = ref.watch(visitsProvider).currentVisit;
    final membersState = ref.watch(membersProvider);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visit')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (visit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visit')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textDisabled),
              const SizedBox(height: 12),
              const Text('Visit not found',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    final spec = kSpecialities
        .where((s) => s.id == visit.specialityId)
        .firstOrNull;
    final bodyPart = bodyPartById(visit.bodyPartId);
    final mws = membersState.members
        .where((m) => m.member.id == visit.memberId)
        .firstOrNull;
    final member = mws?.member;

    final overdue =
        visit.followUpDate != null && isOverdue(visit.followUpDate!);
    final followColor = overdue ? AppColors.error : AppColors.secondary;

    // Group attachments
    final prescriptions =
        _attachments.where((a) => a.type == 'prescription').toList();
    final medicines =
        _attachments.where((a) => a.type == 'medicine').toList();
    final bills = _attachments.where((a) => a.type == 'bill').toList();
    final reports = _attachments.where((a) => a.type == 'report').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(visit.doctorName ?? 'Visit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/visits/edit/${visit.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteVisit(visit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          // ── Header card ──────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: Spacing.xs,
                  runSpacing: Spacing.xs,
                  children: [
                    if (spec != null)
                      _Chip(
                          label: spec.label,
                          color: spec.color,
                          icon: spec.icon),
                    if (bodyPart != null)
                      _Chip(label: bodyPart.label, color: AppColors.primary),
                    if (member != null)
                      MemberBadge(
                          name: member.name, colorHex: member.color),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Visit Date',
                    value: formatVisitDate(visit.visitDate)),
                if (visit.followUpDate != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Follow-up', style: AppText.caption),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(formatVisitDate(visit.followUpDate!),
                                    style: AppText.body),
                                const SizedBox(width: Spacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Spacing.sm, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        followColor.withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text(
                                    formatDaysRemaining(visit.followUpDate!),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: followColor,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Doctor ──────────────────────────────────────────────────────
          if (visit.doctorName != null ||
              visit.clinicName != null ||
              visit.clinicPhone != null ||
              visit.doctorFees != null) ...[
            const Divider(height: 1),
            _Section(
              title: 'Doctor',
              children: [
                if (visit.doctorName != null)
                  _InfoRow(
                      icon: Icons.person_outlined,
                      label: 'Doctor',
                      value: visit.doctorName!),
                if (visit.clinicName != null)
                  _InfoRow(
                      icon: Icons.local_hospital_outlined,
                      label: 'Clinic',
                      value: visit.clinicName!),
                if (visit.clinicPhone != null)
                  _PhoneRow(phone: visit.clinicPhone!),
                if (visit.doctorFees != null)
                  _InfoRow(
                      icon: Icons.currency_rupee,
                      label: 'Fees',
                      value: formatCurrency(
                          visit.doctorFees, currency: visit.currency)),
              ],
            ),
          ],

          // ── Symptoms ──────────────────────────────────────────────────
          if (visit.symptoms != null) ...[
            const Divider(height: 1),
            _Section(title: 'Symptoms', children: [
              Text(visit.symptoms!, style: AppText.body.copyWith(height: 1.6)),
            ]),
          ],

          // ── Diagnosis ─────────────────────────────────────────────────
          if (visit.diagnosis != null) ...[
            const Divider(height: 1),
            _Section(title: 'Diagnosis', children: [
              Text(visit.diagnosis!,
                  style: AppText.body.copyWith(height: 1.6)),
            ]),
          ],

          // ── Attachments by type ───────────────────────────────────────
          for (final entry in [
            ('Prescriptions', prescriptions),
            ('Medicines', medicines),
            ('Bills', bills),
            ('Reports', reports),
          ])
            if (entry.$2.isNotEmpty) ...[
              const Divider(height: 1),
              _Section(
                title: '${entry.$1} (${entry.$2.length})',
                children: [
                  AttachmentGrid(
                    attachments: entry.$2,
                    type: entry.$1.toLowerCase().replaceAll('s', ''),
                    onDelete: (id) {
                      final att = _attachments
                          .where((a) => a.id == id)
                          .firstOrNull;
                      if (att != null) _deleteAttachment(att);
                    },
                    onView: (att) => showDocViewer(context, att),
                    maxFiles: 0, // view-only: no add button
                  ),
                ],
              ),
            ],

          // ── Notes ──────────────────────────────────────────────────────
          if (visit.notes != null) ...[
            const Divider(height: 1),
            _Section(title: 'Notes', children: [
              Text(visit.notes!, style: AppText.body.copyWith(height: 1.6)),
            ]),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.caption),
                const SizedBox(height: 2),
                Text(value, style: AppText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  final String phone;
  const _PhoneRow({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        children: [
          const Icon(Icons.phone_outlined,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Phone', style: AppText.caption),
                const SizedBox(height: 2),
                Text(phone, style: AppText.body),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () =>
                launchUrl(Uri.parse('tel:$phone')).catchError((_) => false),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md, vertical: 6)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone, size: 14),
                SizedBox(width: 4),
                Text('Call', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppText.caption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: Spacing.sm),
          ...children,
        ],
      ),
    );
  }
}
