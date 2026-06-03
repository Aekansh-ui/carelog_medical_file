import 'package:flutter/material.dart';

import '../constants/specialities.dart';
import '../models/query_results.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import 'member_badge.dart';

class ReminderCard extends StatelessWidget {
  final ReminderWithVisit rwv;
  final VoidCallback onTap;
  final VoidCallback onMarkDone;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.rwv,
    required this.onTap,
    required this.onMarkDone,
    required this.onReschedule,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final reminder = rwv.reminder;
    final overdue = isOverdue(reminder.followUpDate);
    final accentColor = overdue ? AppColors.error : AppColors.secondary;
    final spec = rwv.specialityId != null
        ? specialityById(rwv.specialityId!)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.md, 0, Spacing.md, Spacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.md, Spacing.md, Spacing.xs, Spacing.sm),
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
                                rwv.doctorName ?? 'Unknown Doctor',
                                style: AppText.h3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (spec != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(spec.icon,
                                        size: 12,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(spec.label,
                                        style: AppText.caption),
                                  ],
                                ),
                              ],
                              if (rwv.memberName != null) ...[
                                const SizedBox(height: 4),
                                MemberBadge(
                                  name: rwv.memberName!,
                                  colorHex:
                                      rwv.memberColor ?? '#1A6B8A',
                                  small: true,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.event_outlined,
                                      size: 13,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Follow-up: ${formatVisitDate(reminder.followUpDate)}',
                                    style: AppText.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Days remaining badge
                        Container(
                          margin: const EdgeInsets.only(left: Spacing.sm),
                          padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            formatDaysRemaining(reminder.followUpDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Action row
                    Row(
                      children: [
                        _ActionBtn(
                          icon: Icons.check_circle_outline,
                          label: 'Done',
                          color: AppColors.secondary,
                          onTap: onMarkDone,
                        ),
                        const SizedBox(width: Spacing.xs),
                        _ActionBtn(
                          icon: Icons.edit_calendar_outlined,
                          label: 'Reschedule',
                          color: AppColors.primary,
                          onTap: onReschedule,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.textDisabled),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32, minHeight: 32),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
