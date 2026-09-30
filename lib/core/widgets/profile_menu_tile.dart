import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';

/// Reusable profile list tile matching ProfileScreen.tsx.
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.trailing,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Widget? trailing;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 10),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: BurhanTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                      color: isDestructive ? BurhanColors.rose500 : BurhanColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subtitle,
                    style: BurhanTypography.caption.copyWith(
                      fontSize: 9.5,
                      color: BurhanColors.slate400,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing / Badge
            if (trailing != null)
              trailing!
            else ...[
              if (badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? BurhanColors.slate100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    badgeText!,
                    style: BurhanTypography.badge.copyWith(
                      color: badgeTextColor ?? BurhanColors.slate700,
                      fontSize: 9.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 13,
                color: isDestructive ? BurhanColors.rose500 : BurhanColors.slate400,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
