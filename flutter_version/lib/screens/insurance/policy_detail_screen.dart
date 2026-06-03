import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/insurance.dart';
import '../../data/database.dart';
import '../../providers/insurance_provider.dart';
import '../../providers/members_provider.dart';
import '../../services/file_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/doc_viewer.dart';
import '../../widgets/member_badge.dart';

class PolicyDetailScreen extends ConsumerStatefulWidget {
  final String policyId;

  const PolicyDetailScreen({super.key, required this.policyId});

  @override
  ConsumerState<PolicyDetailScreen> createState() =>
      _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends ConsumerState<PolicyDetailScreen> {
  List<InsuranceDocument> _docs = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref.read(insuranceProvider.notifier).loadById(widget.policyId);
    final docs = await ref
        .read(insuranceProvider.notifier)
        .loadDocuments(widget.policyId);
    if (mounted) setState(() { _docs = docs; _loaded = true; });
  }

  Future<void> _deleteDoc(InsuranceDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${doc.fileName}"?'),
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
        .read(insuranceProvider.notifier)
        .deleteDocument(doc.id);
    if (ref2 != null) {
      await fileService.deleteFiles([
        ref2.filePath,
        if (ref2.thumbnailPath != null) ref2.thumbnailPath!,
      ]);
    }
    if (mounted) {
      setState(() => _docs.removeWhere((d) => d.id == doc.id));
    }
  }

  Future<void> _deletePolicy(InsurancePolicy policy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Policy'),
        content: const Text(
            'This will permanently delete the policy and all its documents.'),
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
        await ref.read(insuranceProvider.notifier).deletePolicy(policy.id);
    final paths = refs
        .expand((r) =>
            [r.filePath, if (r.thumbnailPath != null) r.thumbnailPath!])
        .toList();
    if (paths.isNotEmpty) await fileService.deleteFiles(paths);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(insuranceProvider).currentPolicy;
    final membersState = ref.watch(membersProvider);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Policy')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (policy == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Policy')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textDisabled),
              const SizedBox(height: 12),
              const Text('Policy not found',
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

    final plan = planTypeById(policy.planType);
    final expiry =
        getExpiryStatus(policy.validUntil, soonDays: kInsuranceExpirySoonDays);
    final mws = membersState.members
        .where((m) => m.member.id == policy.memberId)
        .firstOrNull;
    final member = mws?.member;

    final badgeColor = switch (expiry.status) {
      ExpiryStatus.expired => AppColors.error,
      ExpiryStatus.expiring => AppColors.accent,
      _ => AppColors.secondary,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(policy.insurerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/insurance/edit/${policy.id}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined,
                          size: 22, color: AppColors.primary),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(policy.insurerName, style: AppText.h2),
                          if (plan != null)
                            Row(
                              children: [
                                Icon(plan.icon,
                                    size: 13,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(plan.label,
                                    style: AppText.caption),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (member != null) ...[
                  const SizedBox(height: Spacing.sm),
                  MemberBadge(
                      name: member.name, colorHex: member.color),
                ],
                if (expiry.status != ExpiryStatus.none) ...[
                  const SizedBox(height: Spacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      expiry.label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: badgeColor),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Policy Details ────────────────────────────────────────────────
          if (policy.policyNumber != null || policy.policyHolder != null) ...[
            const Divider(height: 1),
            _Section(
              title: 'Policy Details',
              children: [
                if (policy.policyNumber != null)
                  _InfoRow(
                      icon: Icons.numbers,
                      label: 'Policy Number',
                      value: policy.policyNumber!),
                if (policy.policyHolder != null)
                  _InfoRow(
                      icon: Icons.person_outlined,
                      label: 'Policy Holder',
                      value: policy.policyHolder!),
              ],
            ),
          ],

          // ── Coverage & Validity ───────────────────────────────────────────
          if (policy.sumInsured != null ||
              policy.premium != null ||
              policy.validFrom != null ||
              policy.validUntil != null) ...[
            const Divider(height: 1),
            _Section(
              title: 'Coverage & Validity',
              children: [
                if (policy.sumInsured != null)
                  _InfoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Sum Insured',
                      value: formatCurrency(policy.sumInsured,
                          currency: policy.currency)),
                if (policy.premium != null)
                  _InfoRow(
                      icon: Icons.receipt_outlined,
                      label: 'Premium',
                      value: formatCurrency(policy.premium,
                          currency: policy.currency)),
                if (policy.validFrom != null)
                  _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Valid From',
                      value: formatVisitDate(policy.validFrom!)),
                if (policy.validUntil != null)
                  _InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Valid Until',
                      value: formatVisitDate(policy.validUntil!)),
              ],
            ),
          ],

          // ── Contact & Notes ───────────────────────────────────────────────
          if (policy.helplinePhone != null ||
              policy.agentName != null ||
              policy.notes != null) ...[
            const Divider(height: 1),
            _Section(
              title: 'Contact & Notes',
              children: [
                if (policy.helplinePhone != null)
                  _PhoneRow(phone: policy.helplinePhone!),
                if (policy.agentName != null)
                  _InfoRow(
                      icon: Icons.support_agent_outlined,
                      label: 'Agent',
                      value: policy.agentName!),
                if (policy.notes != null)
                  _InfoRow(
                      icon: Icons.notes_outlined,
                      label: 'Notes',
                      value: policy.notes!),
              ],
            ),
          ],

          // ── Documents ─────────────────────────────────────────────────────
          if (_docs.isNotEmpty) ...[
            const Divider(height: 1),
            _Section(
              title: 'Documents (${_docs.length})',
              children: [
                Wrap(
                  children: _docs
                      .map((doc) => _DocThumb(
                            doc: doc,
                            onTap: () =>
                                showInsuranceDocViewer(context, doc),
                            onDelete: () => _deleteDoc(doc),
                          ))
                      .toList(),
                ),
              ],
            ),
          ],

          // ── Delete footer ─────────────────────────────────────────────────
          const SizedBox(height: Spacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: OutlinedButton.icon(
              onPressed: () => _deletePolicy(policy),
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text('Delete Policy',
                  style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

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
                const Text('Helpline', style: AppText.caption),
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

class _DocThumb extends StatelessWidget {
  final InsuranceDocument doc;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _DocThumb(
      {required this.doc, required this.onTap, required this.onDelete});

  bool get _isPdf => doc.mimeType == 'application/pdf';
  String get _displayPath => doc.thumbnailPath ?? doc.filePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 88 + 8,
        height: 88 + 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 88,
              height: 88,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: _isPdf
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              color: AppColors.error, size: 28),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              doc.fileName,
                              style: const TextStyle(
                                  fontSize: 8,
                                  color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    : Image.file(
                        File(_displayPath),
                        fit: BoxFit.cover,
                        width: 88,
                        height: 88,
                        errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textDisabled),
                      ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
