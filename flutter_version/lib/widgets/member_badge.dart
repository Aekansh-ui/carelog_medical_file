import 'package:flutter/material.dart';

import '../constants/members.dart' show colorFromHex;
import '../theme/app_theme.dart';

class MemberBadge extends StatelessWidget {
  final String name;
  final String colorHex;

  /// Use [small] for compact contexts (search results, reminder cards).
  final bool small;

  const MemberBadge({
    super.key,
    required this.name,
    required this.colorHex,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6.0 : Spacing.sm,
        vertical: small ? 2.0 : 3.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F6),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 6.0 : 8.0,
            height: small ? 6.0 : 8.0,
            decoration: BoxDecoration(
              color: colorFromHex(colorHex),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              name,
              style: TextStyle(
                fontSize: small ? 11.0 : 12.0,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
