import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';

enum MainTab { home, search, cart, orders, profile }

/// Bottom navigation bar matching BottomNav.tsx in storeAppUI.
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.cartCount = 2,
    this.activeOrdersCount = 1,
  });

  final MainTab currentTab;
  final ValueChanged<MainTab> onTabSelected;
  final int cartCount;
  final int activeOrdersCount;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset - 4 : 4, top: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: const Border(
              top: BorderSide(color: BurhanColors.slate200, width: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                tab: MainTab.home,
                label: 'الرئيسية',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
              ),
              _buildNavItem(
                tab: MainTab.search,
                label: 'البحث والرابط',
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
              ),
              _buildNavItem(
                tab: MainTab.cart,
                label: 'السلة',
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                badgeCount: cartCount,
                badgeColor: BurhanColors.amber,
              ),
              _buildNavItem(
                tab: MainTab.orders,
                label: 'طلباتي',
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
                badgeCount: activeOrdersCount,
                badgeColor: BurhanColors.primary,
              ),
              _buildNavItem(
                tab: MainTab.profile,
                label: 'حسابي',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required MainTab tab,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    int? badgeCount,
    Color? badgeColor,
  }) {
    final isActive = currentTab == tab;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(tab),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isActive ? activeIcon : icon,
                        size: 21,
                        color: isActive ? BurhanColors.primary : BurhanColors.slate500,
                      ),
                      if (badgeCount != null && badgeCount > 0)
                        Positioned(
                          top: -4,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                            decoration: BoxDecoration(
                              color: badgeColor ?? BurhanColors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : '$badgeCount',
                              textAlign: TextAlign.center,
                              style: BurhanTypography.badge.copyWith(
                                color: Colors.white,
                                fontSize: 8.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: BurhanTypography.caption.copyWith(
                      fontSize: 10.5,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                      color: isActive ? BurhanColors.primary : BurhanColors.slate500,
                    ),
                  ),
                ],
              ),
              if (isActive)
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: BurhanColors.amber,
                      borderRadius: BorderRadius.circular(2),
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
