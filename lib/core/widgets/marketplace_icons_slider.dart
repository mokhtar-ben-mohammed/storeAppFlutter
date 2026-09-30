import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';

class MarketplaceStoreItem {
  const MarketplaceStoreItem({
    required this.id,
    required this.nameAr,
    required this.startColor,
    required this.endColor,
    required this.icon,
  });

  final String id;
  final String nameAr;
  final Color startColor;
  final Color endColor;
  final Widget icon;
}

/// Horizontal circular marketplace slider matching MarketplaceAppIcons.tsx.
class MarketplaceIconsSlider extends StatelessWidget {
  const MarketplaceIconsSlider({
    super.key,
    required this.stores,
    this.selectedStoreId,
    this.onStoreSelected,
  });

  final List<MarketplaceStoreItem> stores;
  final String? selectedStoreId;
  final ValueChanged<String>? onStoreSelected;

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        itemCount: stores.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final store = stores[index];
          final isSelected = selectedStoreId == store.id;

          return InkWell(
            onTap: () => onStoreSelected?.call(store.id),
            borderRadius: BorderRadius.circular(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [store.startColor, store.endColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: store.startColor.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: isSelected
                        ? Border.all(color: BurhanColors.amber, width: 3)
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(child: store.icon),
                ),
                const SizedBox(height: 6),
                Text(
                  store.nameAr,
                  style: BurhanTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: BurhanColors.slate800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Builds a store circle icon from optional remote logo or text fallback.
Widget marketplaceStoreIcon({
  required String slug,
  required String nameAr,
  String? logoUrl,
  Color textColor = Colors.white,
}) {
  if (logoUrl != null && logoUrl.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: logoUrl,
      fit: BoxFit.cover,
      width: 58,
      height: 58,
      errorWidget: (_, _, _) => _fallbackGlyph(slug, nameAr, textColor),
    );
  }
  return _fallbackGlyph(slug, nameAr, textColor);
}

Widget _fallbackGlyph(String slug, String nameAr, Color textColor) {
  switch (slug) {
    case '1688':
      return Text(
        '1688',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: -0.5,
        ),
      );
    case 'taobao':
      return Text(
        '淘',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      );
    case 'goofish':
      return Icon(Icons.savings_rounded, color: textColor, size: 26);
    case 'aliexpress':
      return Icon(Icons.shopping_bag_rounded, color: textColor, size: 24);
    case 'factories':
      return const Icon(Icons.factory_rounded, color: BurhanColors.amber, size: 24);
    default:
      return Text(
        nameAr.isNotEmpty ? String.fromCharCodes(nameAr.runes.take(1)) : '•',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      );
  }
}
