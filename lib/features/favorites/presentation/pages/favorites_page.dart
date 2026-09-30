import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/product_card.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/presentation/data/mock_products_data.dart';
import 'package:store/features/products/presentation/pages/product_details_page.dart';

/// Favorites screen matching FavoritesScreen.tsx in storeAppUI.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<ProductEntity> _favorites;

  @override
  void initState() {
    super.initState();
    // Default mock favorites to showcase the UI
    _favorites = MockProductsData.products.take(3).toList();
  }

  void _removeFavorite(String productId) {
    setState(() {
      _favorites.removeWhere((p) => p.id == productId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت إزالة المنتج من المفضلة',
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToCart(ProductEntity product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: BurhanColors.amber, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تمت إضافة "${product.title}" إلى السلة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openProductDetails(ProductEntity product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'قائمة المنتجات المفضلة',
          style: BurhanTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: BurhanColors.rose500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 36,
                        color: BurhanColors.rose500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'قائمة المفضلة فارغة حالياً',
                      style: BurhanTypography.titleSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط على رمز القلب عند تصفح أي منتج من 1688 أو Taobao لحفظه هنا ومقارنة الأسعار.',
                      textAlign: TextAlign.center,
                      style: BurhanTypography.caption.copyWith(
                        color: BurhanColors.slate500,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _favorites = MockProductsData.products.take(3).toList();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BurhanColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'استكشف المنتجات الآن',
                        style: BurhanTypography.buttonSmall.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Text(
                      'المنتجات التي قمت بحفظها للرجوع إليها لاحقاً (${_favorites.length})',
                      style: BurhanTypography.caption.copyWith(
                        color: BurhanColors.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _favorites[index];
                        return ProductCard(
                          product: product,
                          isFavorite: true,
                          onToggleFavorite: () => _removeFavorite(product.id),
                          onAddToCart: () => _addToCart(product),
                          onTap: () => _openProductDetails(product),
                        );
                      },
                      childCount: _favorites.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
