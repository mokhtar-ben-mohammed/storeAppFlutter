import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/product_card.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/presentation/data/mock_products_data.dart';
import 'package:store/features/products/presentation/pages/product_details_page.dart';

/// Store-specific metadata item matching StoreProductsScreen.tsx.
class _StoreMeta {
  const _StoreMeta({
    required this.title,
    required this.chineseName,
    required this.startColor,
    required this.endColor,
    required this.desc,
    required this.badge,
  });

  final String title;
  final String chineseName;
  final Color startColor;
  final Color endColor;
  final String desc;
  final String badge;
}

/// Screen displaying products filtered by the selected Chinese marketplace.
class StoreProductsPage extends StatefulWidget {
  const StoreProductsPage({
    super.key,
    this.storeId = '1688',
  });

  final String storeId;

  @override
  State<StoreProductsPage> createState() => _StoreProductsPageState();
}

class _StoreProductsPageState extends State<StoreProductsPage> {
  static const Map<String, _StoreMeta> _storeMetadata = {
    '1688': _StoreMeta(
      title: 'متجر 1688 (علي بابا الصين)',
      chineseName: '阿里巴巴 1688',
      startColor: BurhanColors.store1688Start,
      endColor: BurhanColors.store1688End,
      desc: 'بوابة مصانع الصين المباشرة للبيع بالجملة والتجزئة بأقل أسعار التكلفة العالمية.',
      badge: 'أسعار المصانع المباشرة',
    ),
    'taobao': _StoreMeta(
      title: 'متجر تاوباو (Taobao)',
      chineseName: '淘宝网',
      startColor: BurhanColors.storeTaobaoStart,
      endColor: BurhanColors.storeTaobaoEnd,
      desc: 'أضخم منصة تسوق صينية لأحدث صيحات الأزياء، الديكورات، والإلكترونيات الحصرية.',
      badge: 'ملايين المنتجات المتجددة',
    ),
    'goofish': _StoreMeta(
      title: 'متجر جوفيش (Goofish / Xianyu)',
      chineseName: '闲鱼二手',
      startColor: BurhanColors.storeGoofishStart,
      endColor: BurhanColors.storeGoofishEnd,
      desc: 'سوق المقتنيات النادرة والأجهزة المستعملة بحالات ممتازة مع فحص سلامة القطع.',
      badge: 'مفحوص ومضمون من برهان',
    ),
    'aliexpress': _StoreMeta(
      title: 'متجر علي إكسبريس (AliExpress)',
      chineseName: '全球速卖通',
      startColor: BurhanColors.storeAliexpressStart,
      endColor: BurhanColors.storeAliexpressEnd,
      desc: 'تجزئة دولية سريعة مع عروض موسمية وتنوع ضخم في الإكسسوارات والأجهزة الذكية.',
      badge: 'شحن موحد وسريع',
    ),
  };

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteIds = {};
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _StoreMeta get _meta {
    final key = widget.storeId.toLowerCase();
    return _storeMetadata[key] ?? _storeMetadata['1688']!;
  }

  List<ProductEntity> get _filteredProducts {
    var list = MockProductsData.products.where((p) {
      if (widget.storeId.isNotEmpty && widget.storeId.toLowerCase() != 'all') {
        return p.store.toLowerCase() == widget.storeId.toLowerCase();
      }
      return true;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      list = list.where((p) {
        final q = _searchQuery.toLowerCase();
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.supplierName.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    return list;
  }

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

  void _openProductDetails(ProductEntity product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = _meta;
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: BurhanColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: BurhanColors.slate900,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Row(
          children: [
            StoreBadge(store: widget.storeId, size: StoreBadgeSize.sm),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                meta.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BurhanTypography.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Store Hero Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [meta.startColor, meta.endColor],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: meta.startColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          meta.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        meta.chineseName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    meta.desc,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 12.5,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Colors.white, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        'فحص عيني 100% في قوانغتشو وشحن مباشر لليمن',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Search and Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BurhanColors.slate200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        style: BurhanTypography.bodyMedium.copyWith(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'ابحث في منتجات ${meta.title}...',
                          hintStyle: BurhanTypography.bodySmall.copyWith(
                            color: BurhanColors.slate400,
                            fontSize: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: BurhanColors.slate400,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BurhanColors.slate200),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 18, color: BurhanColors.primary),
                      onPressed: () {
                        // Open filter bottom sheet
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Header count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المنتجات المتوفرة',
                    style: BurhanTypography.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${products.length} منتجات',
                    style: BurhanTypography.caption.copyWith(
                      color: BurhanColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Grid
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 48, color: BurhanColors.slate300),
                    const SizedBox(height: 10),
                    Text(
                      'لم يتم العثور على منتجات مطابقة للبحث',
                      style: BurhanTypography.bodyMedium.copyWith(color: BurhanColors.slate500),
                    ),
                  ],
                ),
              ),
            )
          else
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
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      isFavorite: _favoriteIds.contains(product.id),
                      onToggleFavorite: () => _toggleFavorite(product.id),
                      onAddToCart: () => _addToCart(product),
                      onTap: () => _openProductDetails(product),
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
