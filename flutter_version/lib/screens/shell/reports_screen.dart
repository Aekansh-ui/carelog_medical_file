import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/body_parts.dart';
import '../../constants/members.dart';
import '../../constants/specialities.dart';
import '../../models/query_results.dart';
import '../../providers/members_provider.dart';
import '../../providers/visits_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/doc_viewer.dart';
import '../../widgets/empty_state.dart';

const _typeColors = {
  'prescription': Color(0xFF9C27B0),
  'medicine': Color(0xFF4CAF50),
  'bill': Color(0xFFFF9800),
  'report': Color(0xFF2196F3),
};

const _typeBadge = {
  'prescription': 'Rx',
  'medicine': 'Med',
  'bill': 'Bill',
  'report': 'Rpt',
};

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _totalVisits = 0;
  Map<String, int> _bySpeciality = {};
  Map<String, int> _byBodyPart = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final vn = ref.read(visitsProvider.notifier);
    final mn = ref.read(membersProvider.notifier);
    await Future.wait([
      vn.countAll().then((v) => _totalVisits = v),
      vn.countsBySpeciality().then((v) => _bySpeciality = v),
      vn.countsByBodyPart().then((v) => _byBodyPart = v),
      vn.loadRecentAttachments(30),
      mn.loadMembers(),
    ]);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final attachments = ref.watch(visitsProvider).recentAttachments;
    final members = ref.watch(membersProvider).members;

    final totalMembers = members.length;
    final totalAttachments = attachments.length;

    // Sort speciality counts descending
    final specEntries = _bySpeciality.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final bodyPartEntries = _byBodyPart.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _totalVisits == 0
              ? EmptyState(
                  icon: Icons.bar_chart_outlined,
                  title: 'No data yet',
                  subtitle:
                      'Add visits to see your health reports and statistics.',
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: Spacing.xxl),
                  children: [
                    // ── Summary stats ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Spacing.md, Spacing.md, Spacing.md, 0),
                      child: Row(
                        children: [
                          _StatCard(
                              label: 'Visits',
                              value: '$_totalVisits',
                              icon: Icons.medical_services_outlined,
                              color: AppColors.primary),
                          const SizedBox(width: Spacing.sm),
                          _StatCard(
                              label: 'Members',
                              value: '$totalMembers',
                              icon: Icons.people_outlined,
                              color: AppColors.secondary),
                          const SizedBox(width: Spacing.sm),
                          _StatCard(
                              label: 'Files',
                              value: '$totalAttachments',
                              icon: Icons.attach_file,
                              color: AppColors.accent),
                        ],
                      ),
                    ),

                    // ── By Speciality ──────────────────────────────────────
                    if (specEntries.isNotEmpty) ...[
                      _SectionHeader(title: 'By Speciality'),
                      ...specEntries.map((e) {
                        final spec = specialityById(e.key);
                        return _BreakdownRow(
                          icon: spec?.icon ?? Icons.medical_services_outlined,
                          color: spec?.color ?? AppColors.primary,
                          label: spec?.label ?? e.key,
                          count: e.value,
                          onTap: () =>
                              context.push('/visits/list/${e.key}'),
                        );
                      }),
                    ],

                    // ── By Body Part ───────────────────────────────────────
                    if (bodyPartEntries.isNotEmpty) ...[
                      _SectionHeader(title: 'By Body Part'),
                      ...bodyPartEntries.map((e) {
                        final bp = bodyPartById(e.key);
                        return _BreakdownRow(
                          icon: bp?.icon ?? Icons.accessibility_outlined,
                          color: AppColors.primary,
                          label: bp?.label ?? e.key,
                          count: e.value,
                          onTap: () =>
                              context.push('/speciality/${e.key}'),
                        );
                      }),
                    ],

                    // ── By Member ──────────────────────────────────────────
                    if (members.isNotEmpty) ...[
                      _SectionHeader(title: 'By Member'),
                      ...members.map((mws) => _MemberRow(
                            mws: mws,
                            onTap: () => context
                                .push('/member/${mws.member.id}'),
                          )),
                    ],

                    // ── Recent Attachments (AC-F14 member badge) ──────────
                    if (attachments.isNotEmpty) ...[
                      _SectionHeader(title: 'Recent Attachments'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            Spacing.md, 0, Spacing.md, 0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: attachments.length,
                          itemBuilder: (_, i) =>
                              _AttachmentCell(
                            awv: attachments[i],
                            onTap: () {
                              final att = attachments[i].attachment;
                              showDocViewer(context, att);
                            },
                            onVisitTap: () {
                              final vid = attachments[i].visitId;
                              if (vid != null) {
                                context.push('/visits/$vid');
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                    ],
                  ],
                ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: Spacing.md, horizontal: Spacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(value,
                style: AppText.h2.copyWith(color: color, fontSize: 22)),
            Text(label, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.md, Spacing.lg, Spacing.md, Spacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppText.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.textSecondary),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final VoidCallback onTap;
  const _BreakdownRow(
      {required this.icon,
      required this.color,
      required this.label,
      required this.count,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.md, 0, Spacing.md, Spacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: Spacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
                child: Text(label,
                    style: AppText.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final MemberWithStats mws;
  final VoidCallback onTap;
  const _MemberRow({required this.mws, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(mws.member.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.md, 0, Spacing.md, Spacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: Spacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  mws.member.name
                      .trim()
                      .split(' ')
                      .take(2)
                      .map((w) => w.isNotEmpty ? w[0] : '')
                      .join()
                      .toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(mws.member.name,
                  style: AppText.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${mws.visitCount} visit${mws.visitCount == 1 ? '' : 's'}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

// ── Attachment cell (AC-F14 — member color dot) ────────────────────────────────

class _AttachmentCell extends StatelessWidget {
  final AttachmentWithVisit awv;
  final VoidCallback onTap;
  final VoidCallback onVisitTap;
  const _AttachmentCell(
      {required this.awv, required this.onTap, required this.onVisitTap});

  @override
  Widget build(BuildContext context) {
    final att = awv.attachment;
    final isPdf = att.mimeType == 'application/pdf';
    final typeColor = _typeColors[att.type] ?? AppColors.primary;
    final badge = _typeBadge[att.type] ?? att.type;
    final spec = awv.specialityId != null
        ? specialityById(awv.specialityId!)
        : null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onVisitTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: AppShadow.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    isPdf
                        ? Container(
                            color: const Color(0xFFFFF5F5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf,
                                    color: AppColors.error, size: 32),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    att.fileName,
                                    style: const TextStyle(
                                        fontSize: 8,
                                        color: AppColors.textSecondary),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.file(
                            File(att.thumbnailPath ?? att.filePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.border,
                              child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textDisabled),
                            ),
                          ),
                    // Type badge bottom-left
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.87),
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    // Member color dot top-right (AC-F14)
                    if (awv.memberColor != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: colorFromHex(awv.memberColor!),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                                width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Meta below thumb
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(5, 3, 5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (awv.visitDate != null)
                      Text(
                        formatVisitDate(awv.visitDate!),
                        style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (awv.doctorName != null)
                      Text(
                        awv.doctorName!,
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (spec != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: spec.color.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          spec.shortLabel,
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: spec.color),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
