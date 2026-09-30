import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';

/// Product card matching ProductCard.tsx in storeAppUI.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onToggleFavorite,
    this.isFavorite = false,
  });

  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BurhanColors.slate200, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.images.isNotEmpty && product.images.first.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.images.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: BurhanColors.slate100,
                            highlightColor: Colors.white,
                            child: Container(color: BurhanColors.slate100),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: BurhanColors.slate100,
                            child: const Center(
                              child: Icon(Icons.image_outlined, color: BurhanColors.slate400, size: 28),
                            ),
                          ),
                        )
                      : Container(
                          color: BurhanColors.slate100,
                          child: const Center(
                            child: Icon(Icons.image_outlined, color: BurhanColors.slate400, size: 28),
                          ),
                        ),

                  // Top-start: Store Badge & Verified supplier
                  Positioned(
                    top: 8,
                    right: 8, // RTL Start is Right
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StoreBadge(
                          store: StoreBadge.fromString(product.store),
                          isSmall: true,
                        ),
                        if (product.isVerifiedSupplier) ...[
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: BurhanColors.primary.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 9,
                                  color: BurhanColors.amberLight,
                                ),
                                const SizedBox(width: 2.5),
                                Text(
                                  'مورد موثوق',
                                  style: BurhanTypography.badge.copyWith(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Top-end: Favorite Button
                  Positioned(
                    top: 8,
                    left: 8, // RTL End is Left
                    child: InkWell(
                      onTap: onToggleFavorite,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 15,
                          color: isFavorite ? BurhanColors.rose500 : BurhanColors.slate400,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-start: Rating Badge (hide when missing)
                  if (product.rating > 0)
                    Positioned(
                      bottom: 6,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 10, color: BurhanColors.amber),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: BurhanTypography.caption.copyWith(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content details with flexible distribution to prevent RenderBox overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 6, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Title and factory info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BurhanTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            color: BurhanColors.slate900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              'سعر الصين: ¥${product.originalPriceCny.toInt()}',
                              style: BurhanTypography.caption.copyWith(
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              ' · ',
                              style: BurhanTypography.caption.copyWith(fontSize: 9),
                            ),
                            Text(
                              '+${product.salesCount} مبيع',
                              style: BurhanTypography.caption.copyWith(
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom: Price & Plus button row
                    Container(
                      padding: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: BurhanColors.slate100)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'سعر برهان:',
                                  style: BurhanTypography.caption.copyWith(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  product.formattedPriceYer,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: BurhanTypography.priceMain.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: onAddToCart,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: BurhanColors.primary,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: BurhanColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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
