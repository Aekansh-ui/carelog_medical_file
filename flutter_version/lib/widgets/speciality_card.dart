import 'package:flutter/material.dart';

import '../constants/specialities.dart';
import '../theme/app_theme.dart';

class SpecialityCard extends StatelessWidget {
  final Speciality speciality;
  final int visitCount;
  final VoidCallback onTap;

  const SpecialityCard({
    super.key,
    required this.speciality,
    required this.visitCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadow.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Row(
            children: [
              // Left colour accent bar
              Container(width: 5, color: speciality.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(speciality.icon, size: 30, color: speciality.color),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        speciality.label,
                        style: AppText.label.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: speciality.color.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '$visitCount ${visitCount == 1 ? 'visit' : 'visits'}',
                          style: TextStyle(
                              fontSize: 11,
                              color: speciality.color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
