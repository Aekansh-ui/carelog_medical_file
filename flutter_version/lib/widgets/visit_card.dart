import 'package:flutter/material.dart';

import '../constants/specialities.dart';
import '../data/database.dart';
import '../models/query_results.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import 'member_badge.dart';

class VisitCard extends StatelessWidget {
  final Visit visit;
  final VoidCallback onTap;
  final bool compact;
  final String? memberName;
  final String? memberColorHex;

  const VisitCard({
    super.key,
    required this.visit,
    required this.onTap,
    this.compact = false,
    this.memberName,
    this.memberColorHex,
  });

  factory VisitCard.withMember(
    VisitWithMember vwm, {
    required VoidCallback onTap,
    bool compact = false,
  }) =>
      VisitCard(
        visit: vwm.visit,
        onTap: onTap,
        compact: compact,
        memberName: vwm.memberName,
        memberColorHex: vwm.memberColor,
      );

  @override
  Widget build(BuildContext context) {
    final spec =
        kSpecialities.where((s) => s.id == visit.specialityId).firstOrNull;
    return compact ? _buildCompact(spec) : _buildFull(spec);
  }

  Widget _buildCompact(Speciality? spec) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadow.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Speciality accent bar
              Container(
                  height: 4, color: spec?.color ?? AppColors.primary),
              Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.doctorName ?? 'Unknown Doctor',
                      style: AppText.h3.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(formatVisitDate(visit.visitDate),
                        style: AppText.caption),
                    if (visit.diagnosis != null &&
                        visit.diagnosis!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        visit.diagnosis!,
                        style: AppText.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildFull(Speciality? spec) {
    final overdue =
        visit.followUpDate != null && isOverdue(visit.followUpDate!);
    final followUpColor = overdue ? AppColors.error : AppColors.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: Spacing.xs),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.doctorName ?? 'Unknown Doctor',
                        style: AppText.h3.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(formatVisitDate(visit.visitDate),
                          style: AppText.caption),
                    ],
                  ),
                ),
                if (spec != null) ...[
                  const SizedBox(width: Spacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: spec.color.withValues(alpha: 0.13),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      spec.shortLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: spec.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (visit.diagnosis != null && visit.diagnosis!.isNotEmpty) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                visit.diagnosis!.length > 80
                    ? '${visit.diagnosis!.substring(0, 80)}…'
                    : visit.diagnosis!,
                style: AppText.body
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (visit.followUpDate != null) ...[
              const SizedBox(height: Spacing.xs),
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 13, color: followUpColor),
                  const SizedBox(width: Spacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: followUpColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${formatVisitDate(visit.followUpDate!)}  ·  ${formatDaysRemaining(visit.followUpDate!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: followUpColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (memberName != null && memberColorHex != null) ...[
              const SizedBox(height: Spacing.xs),
              MemberBadge(
                  name: memberName!,
                  colorHex: memberColorHex!,
                  small: true),
            ],
          ],
        ),
      ),
    );
  }
}
