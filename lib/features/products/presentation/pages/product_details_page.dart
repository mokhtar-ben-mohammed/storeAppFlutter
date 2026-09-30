import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';

/// Product details screen matching storeAppUI ProductDetailsScreen.tsx.
class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final PageController _imagePageController;
  int _currentImageIndex = 0;
  late String _selectedVariantId;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _showPriceBreakdown = true;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _isFavorite = widget.product.isFavorite;
    _selectedVariantId = widget.product.variants.isNotEmpty
        ? widget.product.variants.first.id
        : '';
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  ProductVariant? get _selectedVariant {
    if (widget.product.variants.isEmpty) return null;
    return widget.product.variants.firstWhere(
      (v) => v.id == _selectedVariantId,
      orElse: () => widget.product.variants.first,
    );
  }

  double get _unitPriceCny {
    final basePrice = widget.product.originalPriceCny;
    final modifier = _selectedVariant?.priceModifierCny ?? 0;
    return basePrice + modifier;
  }

  double get _activeTierPriceCny {
    final unitPrice = _unitPriceCny;
    if (widget.product.wholesaleTiers.isEmpty) return unitPrice;

    final matchedTiers = widget.product.wholesaleTiers
        .where((t) => _quantity >= t.minQty)
        .toList();

    if (matchedTiers.isNotEmpty) {
      return matchedTiers.last.priceCny;
    }
    return unitPrice;
  }

  double get _totalPriceCny => _activeTierPriceCny * _quantity;
  double get _totalPriceYer => _totalPriceCny * 75.0;
  double get _totalPriceSar => _totalPriceCny * 0.525;
  double get _totalPriceUsd => _totalPriceCny * 0.14;

  String _formatPrice(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: BurhanColors.amber, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تمت إضافة $_quantity من "${widget.product.title}" إلى السلة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _proceedToCheckout() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'الانتقال إلى إتمام الطلب والشحن المباشر لليمن...',
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: BurhanColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images.isNotEmpty
        ? product.images
        : [
            'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&w=800&q=80',
          ];

    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Header App Bar
              SliverAppBar(
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 2,
                backgroundColor: Colors.white,
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
                title: StoreBadge(store: product.store, size: StoreBadgeSize.sm),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? BurhanColors.rose500 : BurhanColors.slate700,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isFavorite
                                ? 'تمت إضافة المنتج إلى المفضلة'
                                : 'تمت إزالة المنتج من المفضلة',
                            style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: BurhanColors.slate900,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: BurhanColors.slate700),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم نسخ رابط المنتج للمشاركة',
                            style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
                          ),
                          backgroundColor: BurhanColors.slate900,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              // Image Gallery Carousel
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 310,
                        child: PageView.builder(
                          controller: _imagePageController,
                          itemCount: images.length,
                          onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: BurhanColors.slate100,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: BurhanColors.slate400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Indicators & Thumbnails
                      if (images.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (idx) {
                              final isSelected = _currentImageIndex == idx;
                              return GestureDetector(
                                onTap: () {
                                  _imagePageController.animateToPage(
                                    idx,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: isSelected ? 22 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isSelected ? BurhanColors.primary : BurhanColors.slate300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Product Info Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Supplier Header Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.store_rounded, size: 16, color: BurhanColors.primary),
                              const SizedBox(width: 5),
                              Text(
                                product.supplierName,
                                style: BurhanTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: BurhanColors.slate700,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BurhanColors.amber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 13, color: BurhanColors.amberDark),
                                const SizedBox(width: 3),
                                Text(
                                  '${product.supplierRating}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: BurhanColors.amberDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Product Title
                      Text(
                        product.title,
                        style: BurhanTypography.titleLarge.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          color: BurhanColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating & Sales Count
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: BurhanColors.amber),
                          const SizedBox(width: 3),
                          Text(
                            '${product.rating}',
                            style: BurhanTypography.titleSmall.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${product.salesCount}+ مبيعات بالصين)',
                            style: BurhanTypography.caption.copyWith(
                              color: BurhanColors.slate500,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BurhanColors.emerald50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: BurhanColors.emerald500.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              'متوفر للشحن لليمن',
                              style: BurhanTypography.caption.copyWith(
                                color: BurhanColors.emerald600,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Price & Currency Card
                      _buildPriceCard(),
                      const SizedBox(height: 14),

                      // Wholesale Tiers (1688 Factory bulk discounts)
                      if (product.wholesaleTiers.isNotEmpty) ...[
                        _buildWholesaleTiersSection(),
                        const SizedBox(height: 14),
                      ],

                      // Variants Selector
                      if (product.variants.isNotEmpty) ...[
                        _buildVariantsSection(),
                        const SizedBox(height: 14),
                      ],

                      // Quantity Selector
                      _buildQuantitySelector(),
                      const SizedBox(height: 14),

                      // Burhan 100% Inspection Guarantee Banner
                      _buildBurhanGuaranteeCard(),
                      const SizedBox(height: 14),

                      // Specifications Table
                      if (product.specs.isNotEmpty) ...[
                        _buildSpecTable(),
                        const SizedBox(height: 14),
                      ],

                      // Detailed Description
                      _buildDescriptionSection(),
                      const SizedBox(height: 90), // Bottom padding for action bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Sticky Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  // 1. PRICE BREAKDOWN CARD
  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BurhanColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السعر المباشر بالريال اليمني',
                    style: BurhanTypography.caption.copyWith(
                      color: BurhanColors.slate500,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatPrice(_activeTierPriceCny * 75.0),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: BurhanColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ر.ي',
                        style: BurhanTypography.titleSmall.copyWith(
                          fontSize: 12,
                          color: BurhanColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Original CNY Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: BurhanColors.store1688Bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BurhanColors.store1688Border),
                ),
                child: Row(
                  children: [
                    const Text('¥', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: BurhanColors.store1688Text)),
                    const SizedBox(width: 3),
                    Text(
                      '${_activeTierPriceCny.toInt()} يوان صيني',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: BurhanColors.store1688Text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: BurhanColors.slate100),
          const SizedBox(height: 8),

          // Secondary Currency Equivalents (SAR and USD)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ما يعادل: ${_formatPrice(_activeTierPriceCny * 0.525)} ر.س · ${_formatPrice(_activeTierPriceCny * 0.14)} \$',
                style: BurhanTypography.caption.copyWith(
                  color: BurhanColors.slate500,
                  fontSize: 11,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _showPriceBreakdown = !_showPriceBreakdown),
                child: Row(
                  children: [
                    Text(
                      'تفاصيل التكلفة',
                      style: BurhanTypography.caption.copyWith(
                        color: BurhanColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      _showPriceBreakdown
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: BurhanColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_showPriceBreakdown) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BurhanColors.slate50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _priceBreakdownRow('سعر المصنع في الصين', '${_activeTierPriceCny.toInt()} ¥'),
                  const SizedBox(height: 4),
                  _priceBreakdownRow('سعر الصرف المعتمد', '1 ¥ = 75.0 ر.ي'),
                  const SizedBox(height: 4),
                  _priceBreakdownRow('رسوم فحص الجودة وتصوير الفيديو', 'مجاناً 100%'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: BurhanTypography.caption.copyWith(color: BurhanColors.slate500, fontSize: 10.5)),
        Text(value, style: BurhanTypography.caption.copyWith(fontWeight: FontWeight.w700, color: BurhanColors.slate800, fontSize: 10.5)),
      ],
    );
  }

  // 2. WHOLESALE BULK PRICING TIERS
  Widget _buildWholesaleTiersSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BurhanColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أسعار الجملة للمصنع (تدرج الكميات)',
                style: BurhanTypography.titleSmall.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.auto_awesome_rounded, size: 14, color: BurhanColors.amber),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: widget.product.wholesaleTiers.map((tier) {
              final isCurrent = _activeTierPriceCny == tier.priceCny;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? BurhanColors.primary.withValues(alpha: 0.06) : BurhanColors.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent ? BurhanColors.primary : BurhanColors.slate200,
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${tier.minQty}+ قطع',
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: BurhanColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tier.priceCny.toInt()} ¥',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isCurrent ? BurhanColors.primary : BurhanColors.slate900,
                        ),
                      ),
                      Text(
                        '${(tier.priceCny * 75).toInt()} ر.ي',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? BurhanColors.amberDark : BurhanColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 3. VARIANTS SELECTOR
  Widget _buildVariantsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BurhanColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخيارات والمتغيرات المتوفرة',
                style: BurhanTypography.titleSmall.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_selectedVariant != null)
                Text(
                  _selectedVariant!.name,
                  style: BurhanTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BurhanColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.variants.map((v) {
              final isSelected = v.id == _selectedVariantId;
              final color = _parseColor(v.colorHex);

              return InkWell(
                onTap: () => setState(() => _selectedVariantId = v.id),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? BurhanColors.primary.withValues(alpha: 0.05) : BurhanColors.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        v.name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? BurhanColors.primary : BurhanColors.slate800,
                        ),
                      ),
                      if (v.priceModifierCny > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '+${v.priceModifierCny.toInt()}¥',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: BurhanColors.amberDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return BurhanColors.primary;
    }
  }

  // 4. QUANTITY SELECTOR
  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BurhanColors.slate200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الكمية المطلوبة',
                style: BurhanTypography.titleSmall.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'كلما زادت الكمية، انخفض سعر القطعة من المصنع',
                style: BurhanTypography.caption.copyWith(
                  color: BurhanColors.slate400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _quantityBtn(
                icon: Icons.remove,
                onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 40),
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: BurhanColors.slate900,
                  ),
                ),
              ),
              _quantityBtn(
                icon: Icons.add,
                onTap: () => setState(() => _quantity++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityBtn({required IconData icon, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? BurhanColors.slate100 : BurhanColors.slate50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: BurhanColors.slate200),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? BurhanColors.slate800 : BurhanColors.slate300,
        ),
      ),
    );
  }

  // 5. BURHAN 100% INSPECTION GUARANTEE
  Widget _buildBurhanGuaranteeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BurhanColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BurhanColors.primaryDark.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: BurhanColors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, color: BurhanColors.amber, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ضمان وفحص بُرهان 100% في قوانغتشو',
                      style: BurhanTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'وسيطك الآمن للشراء المباشر من مصانع الصين',
                      style: BurhanTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _guaranteeItem('فحص عيني شامل لمطابقة المواصفات واللون وسلامة القطع.'),
          _guaranteeItem('تصوير فيديو وصور دقيقة للمنتج وإرسالها لك قبل شحنه لليمن.'),
          _guaranteeItem('تجميع وإعادة تغليف تجاري مضغوط لتوفير كلفة الشحن.'),
          _guaranteeItem('شحن موثوق ومباشر لجميع المحافظات اليمنية حتى باب بيتك.'),
        ],
      ),
    );
  }

  Widget _guaranteeItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: BurhanColors.amber),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. SPECIFICATIONS TABLE
  Widget _buildSpecTable() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BurhanColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المواصفات الفنية للقطعة',
            style: BurhanTypography.titleSmall.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...widget.product.specs.map((s) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: BurhanColors.slate50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.label, style: BurhanTypography.caption.copyWith(color: BurhanColors.slate500, fontSize: 11)),
                  Expanded(
                    child: Text(
                      s.value,
                      textAlign: TextAlign.end,
                      style: BurhanTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BurhanColors.slate800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 7. DESCRIPTION
  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BurhanColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل المنتج ووصف المصنع',
            style: BurhanTypography.titleSmall.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: BurhanTypography.bodySmall.copyWith(
              color: BurhanColors.slate700,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // 8. BOTTOM STICKY ACTION BAR
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: BurhanColors.slate200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Total Price Summary
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الإجمالي ($_quantity قطع)',
                  style: BurhanTypography.caption.copyWith(
                    color: BurhanColors.slate500,
                    fontSize: 10.5,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatPrice(_totalPriceYer),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: BurhanColors.primary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      'ر.ي',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: BurhanColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '≈ ${_formatPrice(_totalPriceSar)} ر.س · ${_formatPrice(_totalPriceUsd)} \$',
                  style: BurhanTypography.caption.copyWith(
                    fontSize: 9.5,
                    color: BurhanColors.slate400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Add To Cart Button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                  label: const Text(
                    'أضف للسلة',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BurhanColors.primary,
                    side: const BorderSide(color: BurhanColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Buy Now Direct Checkout Button
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _proceedToCheckout,
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text(
                    'شراء مباشر',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BurhanColors.amber,
                    foregroundColor: BurhanColors.primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
