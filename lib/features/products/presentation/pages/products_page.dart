import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/product_card.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/presentation/data/mock_products_data.dart';
import 'package:store/features/products/presentation/pages/product_details_page.dart';

enum ProductSortOption {
  featured('المقترحة'),
  priceLow('الأقل سعراً'),
  priceHigh('الأعلى سعراً'),
  rating('الأعلى تقييماً'),
  sales('الأكثر طلباً');

  const ProductSortOption(this.label);
  final String label;
}

class _ParsedUrlResult {
  const _ParsedUrlResult({
    required this.recognized,
    required this.store,
    required this.message,
  });

  final bool recognized;
  final String? store;
  final String message;
}

/// Products search & Chinese marketplace URL parser screen (matching SearchScreen.tsx).
class ProductsPage extends StatefulWidget {
  const ProductsPage({
    super.key,
    this.initialStore = 'all',
  });

  final String initialStore;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedStore;
  ProductSortOption _currentSort = ProductSortOption.featured;
  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _selectedStore = widget.initialStore;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isUrl {
    final text = _searchController.text.trim().toLowerCase();
    return text.startsWith('http://') || text.startsWith('https://');
  }

  _ParsedUrlResult? get _urlParseResult {
    if (!_isUrl) return null;
    final clean = _searchController.text.trim().toLowerCase();
    if (clean.contains('1688.com')) {
      return const _ParsedUrlResult(
        recognized: true,
        store: '1688',
        message: 'رابط مباشر لمتجر 1688 الصيني للبيع بالجملة من المصانع.',
      );
    }
    if (clean.contains('taobao.com') || clean.contains('tmall.com')) {
      return const _ParsedUrlResult(
        recognized: true,
        store: 'taobao',
        message: 'رابط مباشر لمتجر تاوباو الصيني لأحدث المنتجات والصيحات.',
      );
    }
    if (clean.contains('goofish.com') ||
        clean.contains('2.taobao.com') ||
        clean.contains('xianyu')) {
      return const _ParsedUrlResult(
        recognized: true,
        store: 'goofish',
        message: 'رابط مباشر لمنصة جوفيش للمقتنيات والمستعمل المفحوص.',
      );
    }
    if (clean.contains('aliexpress.com')) {
      return const _ParsedUrlResult(
        recognized: true,
        store: 'aliexpress',
        message: 'رابط مباشر لمتجر علي إكسبريس للتجزئة الدولية.',
      );
    }
    return const _ParsedUrlResult(
      recognized: false,
      store: null,
      message: 'الرجاء إدخال رابط منتج صالح من 1688، Taobao، Goofish، أو AliExpress.',
    );
  }

  List<ProductEntity> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();

    var list = MockProductsData.products.where((p) {
      if (_selectedStore != 'all' && p.store.toLowerCase() != _selectedStore.toLowerCase()) {
        return false;
      }
      if (query.isNotEmpty && !_isUrl) {
        final inTitle = p.title.toLowerCase().contains(query);
        final inDesc = p.description.toLowerCase().contains(query);
        final inSupplier = p.supplierName.toLowerCase().contains(query);
        final inStore = p.store.toLowerCase().contains(query);
        if (!inTitle && !inDesc && !inSupplier && !inStore) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sort
    switch (_currentSort) {
      case ProductSortOption.featured:
        break;
      case ProductSortOption.priceLow:
        list.sort((a, b) => a.originalPriceCny.compareTo(b.originalPriceCny));
        break;
      case ProductSortOption.priceHigh:
        list.sort((a, b) => b.originalPriceCny.compareTo(a.originalPriceCny));
        break;
      case ProductSortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSortOption.sales:
        list.sort((a, b) => b.salesCount.compareTo(a.salesCount));
        break;
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
    final products = _filteredProducts;
    final urlResult = _urlParseResult;

    final storeTabs = [
      {'id': 'all', 'label': 'جميع المتاجر'},
      {'id': '1688', 'label': '1688 (مصانع)'},
      {'id': 'taobao', 'label': 'Taobao'},
      {'id': 'goofish', 'label': 'Goofish'},
      {'id': 'aliexpress', 'label': 'AliExpress'},
    ];

    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Search & URL Input Box
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isUrl ? BurhanColors.amber : BurhanColors.slate200,
                      width: _isUrl ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        _isUrl ? Icons.link_rounded : Icons.search_rounded,
                        size: 20,
                        color: _isUrl ? BurhanColors.amber : BurhanColors.slate400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: BurhanTypography.bodyMedium.copyWith(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'ابحث بالاسم أو الصق رابط منتج من الصين...',
                            hintStyle: BurhanTypography.bodySmall.copyWith(
                              color: BurhanColors.slate400,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: BurhanColors.slate400),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Detected External Link Card (If User Pasted a Chinese URL)
            if (_isUrl && urlResult != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: BurhanColors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BurhanColors.amber.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                urlResult.recognized
                                    ? Icons.check_circle_rounded
                                    : Icons.info_outline_rounded,
                                size: 18,
                                color: urlResult.recognized
                                    ? BurhanColors.amber
                                    : BurhanColors.slate500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                urlResult.recognized
                                    ? 'تم التعرف على رابط المتجر الصيني!'
                                    : 'تنبيه حول الرابط المدخل',
                                style: BurhanTypography.titleSmall.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: BurhanColors.slate900,
                                ),
                              ),
                            ],
                          ),
                          if (urlResult.store != null)
                            StoreBadge(store: urlResult.store!, size: StoreBadgeSize.sm),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        urlResult.message,
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 11.5,
                          color: BurhanColors.slate700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: BurhanColors.slate200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link_rounded, size: 16, color: BurhanColors.slate400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _searchController.text.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: BurhanColors.slate600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                final matched = MockProductsData.products.firstWhere(
                                  (p) => p.store.toLowerCase() == (urlResult.store ?? '').toLowerCase(),
                                  orElse: () => MockProductsData.products.first,
                                );
                                _openProductDetails(matched);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: BurhanColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'استيراد وحساب السعر',
                                  style: BurhanTypography.buttonSmall.copyWith(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
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

            // 3. Store Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: storeTabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tab = storeTabs[index];
                    final isSelected = _selectedStore == tab['id'];

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedStore = tab['id']!;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? BurhanColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: BurhanColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          tab['label']!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : BurhanColors.slate700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 4. Header Bar (Results Count & Sort Selector)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'عثرنا على ${products.length} منتج${_selectedStore != 'all' ? ' في متجر $_selectedStore' : ''}',
                      style: BurhanTypography.caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BurhanColors.slate600,
                      ),
                    ),
                    PopupMenuButton<ProductSortOption>(
                      initialValue: _currentSort,
                      onSelected: (val) => setState(() => _currentSort = val),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (context) => ProductSortOption.values.map((option) {
                        final isSelected = _currentSort == option;
                        return PopupMenuItem<ProductSortOption>(
                          value: option,
                          child: Row(
                            children: [
                              if (isSelected)
                                const Icon(Icons.check_rounded, size: 16, color: BurhanColors.primary)
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Text(
                                option.label,
                                style: BurhanTypography.bodySmall.copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? BurhanColors.primary : BurhanColors.slate800,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: BurhanColors.slate200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.swap_vert_rounded, size: 15, color: BurhanColors.slate500),
                            const SizedBox(width: 4),
                            Text(
                              _currentSort.label,
                              style: BurhanTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: BurhanColors.slate800,
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

            // 5. Product Grid or Empty State
            if (products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: BurhanColors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 32,
                            color: BurhanColors.amber,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'لم نجد نتائج مطابقة للبحث',
                          style: BurhanTypography.titleSmall.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'تأكد من كتابة الكلمات بشكل صحيح، أو جرب تغيير المتجر الصيني المحدد، أو الصق رابط المنتج المباشر من 1688 أو Taobao.',
                          textAlign: TextAlign.center,
                          style: BurhanTypography.caption.copyWith(
                            fontSize: 12,
                            color: BurhanColors.slate500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _selectedStore = 'all';
                              _currentSort = ProductSortOption.featured;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BurhanColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'إعادة ضبط الفلاتر والبحث',
                            style: BurhanTypography.buttonSmall.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 80),
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
      ),
    );
  }
}
