import 'package:flutter/material.dart';

import '../constants/insurance.dart';
import '../models/query_results.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';

class InsuranceCard extends StatelessWidget {
  final PolicyWithDocCount pwdc;
  final VoidCallback onTap;

  const InsuranceCard({super.key, required this.pwdc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final policy = pwdc.policy;
    final plan = planTypeById(policy.planType);
    final expiry =
        getExpiryStatus(policy.validUntil, soonDays: kInsuranceExpirySoonDays);

    final badgeColor = switch (expiry.status) {
      ExpiryStatus.expired => AppColors.error,
      ExpiryStatus.expiring => AppColors.accent,
      _ => AppColors.secondary,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.md, 0, Spacing.md, Spacing.sm),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          children: [
            // Shield icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined,
                  size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: Spacing.sm),
            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policy.insurerName,
                    style: AppText.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Plan chip + doc count chip
                  Wrap(
                    spacing: Spacing.xs,
                    children: [
                      if (plan != null)
                        _Chip(
                            icon: plan.icon, label: plan.label),
                      if (pwdc.documentCount > 0)
                        _Chip(
                            icon: Icons.attach_file,
                            label: '${pwdc.documentCount}'),
                    ],
                  ),
                  if (policy.policyNumber != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'No. ${policy.policyNumber}',
                      style: AppText.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (policy.sumInsured != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Cover ${formatCurrency(policy.sumInsured, currency: policy.currency)}',
                      style: AppText.caption
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                  if (expiry.status != ExpiryStatus.none) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        expiry.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F6),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
