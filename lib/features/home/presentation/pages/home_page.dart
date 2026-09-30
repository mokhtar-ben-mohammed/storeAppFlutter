import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/home_carousel_slider.dart';
import 'package:store/core/widgets/marketplace_icons_slider.dart';
import 'package:store/core/widgets/product_card.dart';
import 'package:store/features/home/presentation/data/mock_home_data.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';

/// Main home screen matching HomeScreen.tsx from storeAppUI.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ProductEntity> _products = List.from(MockHomeData.products);
  final Set<String> _favoriteIds = {};
  String? _selectedStore;

  void _toggleFavorite(String productId) {
    setState(() {
      if (_favoriteIds.contains(productId)) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favoriteIds.contains(productId)
              ? 'تمت إضافة المنتج إلى المفضلة'
              : 'تمت إزالة المنتج من المفضلة',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 14, right: 14, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Promotional Carousel Slider
                  const HomeCarouselSlider(),
                  const SizedBox(height: 20),

                  // 2. Chinese Marketplace Circles Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تصفح منتجات المتاجر الصينية',
                        style: BurhanTypography.titleSmall.copyWith(
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        'اسحب أفقياً لاختيار المتجر',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MarketplaceIconsSlider(
                    selectedStoreId: _selectedStore,
                    onStoreSelected: (storeId) {
                      setState(() {
                        _selectedStore = _selectedStore == storeId ? null : storeId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Recommended Products Grid Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 15,
                            color: BurhanColors.amber,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'منتجات مقترحة للشراء المباشر',
                            style: BurhanTypography.titleSmall.copyWith(
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_products.length} منتجات مميزة',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. Products Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        isFavorite: _favoriteIds.contains(product.id),
                        onToggleFavorite: () => _toggleFavorite(product.id),
                        onAddToCart: () => _addToCart(product),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تفاصيل المنتج: ${product.title}'),
                              duration: const Duration(milliseconds: 1200),
                              backgroundColor: BurhanColors.slate900,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
