import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/burhan_logo.dart';

/// Top header bar matching TopHeader.tsx in storeAppUI.
class TopHeader extends StatelessWidget implements PreferredSizeWidget {
  const TopHeader({
    super.key,
    this.title,
    this.showBack = false,
    this.onBack,
    this.rightAction,
    this.unreadNotificationsCount = 2,
    this.onNotificationTap,
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? rightAction;
  final int unreadNotificationsCount;
  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: preferredSize.height + MediaQuery.paddingOf(context).top,
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: const Border(
              bottom: BorderSide(color: BurhanColors.slate200, width: 0.8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Start / Left Slot
              if (showBack)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: BurhanColors.slate100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: BurhanColors.slate200, width: 0.8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: BurhanColors.slate800,
                        ),
                      ),
                    ),
                    if (title != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        title!,
                        style: BurhanTypography.titleSmall.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                )
              else
                const BurhanLogo(
                  size: BurhanLogoSize.sm,
                  variant: BurhanLogoVariant.horizontal,
                ),

              // End / Right Slot: Notifications Bell or Action
              if (rightAction != null)
                rightAction!
              else
                InkWell(
                  onTap: onNotificationTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: BurhanColors.slate100.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BurhanColors.slate200, width: 0.8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 18,
                          color: BurhanColors.slate700,
                        ),
                        if (unreadNotificationsCount > 0)
                          Positioned(
                            top: 6,
                            right: 7,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: BurhanColors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
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
