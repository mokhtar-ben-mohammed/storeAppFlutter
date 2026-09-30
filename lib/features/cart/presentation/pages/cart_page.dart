import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:store/features/cart/presentation/data/mock_cart_data.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/presentation/pages/product_details_page.dart';

/// Shopping Cart Screen matching CartScreen.tsx in storeAppUI.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItemEntity> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = MockCartData.initialItems;
  }

  bool get _allSelected =>
      _cartItems.isNotEmpty && _cartItems.every((item) => item.isSelected);

  List<CartItemEntity> get _selectedItems =>
      _cartItems.where((item) => item.isSelected).toList();

  double get _selectedTotalCny =>
      _selectedItems.fold(0.0, (sum, item) => sum + item.totalPriceCny);

  double get _selectedTotalYer => _selectedTotalCny * 75.0;
  double get _selectedTotalSar => _selectedTotalCny * 0.525;
  double get _selectedTotalUsd => _selectedTotalCny * 0.14;

  String _formatPrice(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _toggleSelectAll() {
    final nextState = !_allSelected;
    setState(() {
      _cartItems = _cartItems
          .map((item) => item.copyWith(isSelected: nextState))
          .toList();
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      _cartItems = _cartItems.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isSelected: !item.isSelected);
        }
        return item;
      }).toList();
    });
  }

  void _updateQuantity(String itemId, int delta) {
    setState(() {
      _cartItems = _cartItems.map((item) {
        if (item.id == itemId) {
          final newQty = item.quantity + delta;
          if (newQty < 1) return item;
          return item.copyWith(quantity: newQty);
        }
        return item;
      }).toList();
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == itemId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حذف المنتج من السلة',
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _removeSelectedItems() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف المنتجات المحددة',
          style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'هل أنت متأكد من حذف ${_selectedItems.length} منتجات محددة من سلة التسوق؟',
          style: BurhanTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'إلغاء',
              style: BurhanTypography.buttonSmall.copyWith(color: BurhanColors.slate600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BurhanColors.rose500,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'حذف',
              style: BurhanTypography.buttonSmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _cartItems.removeWhere((item) => item.isSelected);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حذف المنتجات المحددة من السلة',
            style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: BurhanColors.slate900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _moveToFavorites(CartItemEntity item) {
    _removeItem(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: BurhanColors.rose500, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تم نقل "${item.product.title}" إلى المفضلة',
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

  void _openDetails(ProductEntity product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(product: product),
      ),
    );
  }

  void _proceedToCheckout() {
    if (_selectedItems.isEmpty) return;
    context.push(AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    if (_cartItems.isEmpty) {
      return Scaffold(
        backgroundColor: BurhanColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: BurhanColors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 44,
                      color: BurhanColors.amber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'سلة التسوق فارغة حالياً',
                    style: BurhanTypography.titleLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تصفح آلاف المنتجات من 1688، تاوباو، جوفيش وعلي إكسبريس وأضف ما يعجبك لنشتريه ونفحصه لك!',
                    textAlign: TextAlign.center,
                    style: BurhanTypography.bodySmall.copyWith(
                      color: BurhanColors.slate500,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.go(AppRoutes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BurhanColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      'ابدأ التسوق واستكشاف المنتجات',
                      style: BurhanTypography.buttonMedium.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final selectedCount = _selectedItems.length;
    final totalCount = _cartItems.length;

    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header Toolbar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BurhanColors.slate200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Select All Checkbox
                          InkWell(
                            onTap: _toggleSelectAll,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _allSelected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    size: 21,
                                    color: _allSelected
                                        ? BurhanColors.amber
                                        : BurhanColors.slate400,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'تحديد الكل ($totalCount)',
                                    style: BurhanTypography.titleSmall.copyWith(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: BurhanColors.slate800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Delete Selected Button
                          if (selectedCount > 0)
                            InkWell(
                              onTap: _removeSelectedItems,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: BurhanColors.rose500.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 14,
                                      color: BurhanColors.rose500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'حذف المحدد ($selectedCount)',
                                      style: BurhanTypography.caption.copyWith(
                                        color: BurhanColors.rose500,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
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
                ),

                // 2. Partial Selection Smart Banner
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BurhanColors.amber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: BurhanColors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: BurhanColors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'خاصية الشراء الجزئي الذكي (Partial Checkout)',
                                style: BurhanTypography.titleSmall.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: BurhanColors.slate900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'حدد المنتجات التي ترغب بشرائها الآن، وستبقى بقية المنتجات غير المحددة محفوظة في سلتك بأمان للطلبات القادمة.',
                                style: BurhanTypography.caption.copyWith(
                                  fontSize: 11,
                                  color: BurhanColors.slate700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Cart Items List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _cartItems[index];
                        return _buildCartItemCard(item);
                      },
                      childCount: _cartItems.length,
                    ),
                  ),
                ),
              ],
            ),

            // 4. Sticky Bottom Checkout Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomCheckoutBar(selectedCount, totalCount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItemEntity item) {
    final isSelected = item.isSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? BurhanColors.amber.withValues(alpha: 0.6)
              : BurhanColors.slate200,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: InkWell(
              onTap: () => _toggleItemSelection(item.id),
              borderRadius: BorderRadius.circular(6),
              child: Icon(
                isSelected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 22,
                color: isSelected ? BurhanColors.amber : BurhanColors.slate400,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Thumbnail with Store Badge
          InkWell(
            onTap: () => _openDetails(item.product),
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: BurhanColors.slate100,
                    child: item.product.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.product.images.first,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Shimmer.fromColors(
                              baseColor: BurhanColors.slate100,
                              highlightColor: Colors.white,
                              child: Container(color: BurhanColors.slate100),
                            ),
                            errorWidget: (_, _, _) => const Center(
                              child: Icon(Icons.image_outlined, size: 24, color: BurhanColors.slate400),
                            ),
                          )
                        : const Icon(Icons.image_outlined, size: 24, color: BurhanColors.slate400),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: StoreBadge(
                    store: item.product.store,
                    size: StoreBadgeSize.sm,
                    showChineseLabel: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Details & Actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _openDetails(item.product),
                        child: Text(
                          item.product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BurhanTypography.titleSmall.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      color: BurhanColors.slate400,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _removeItem(item.id),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Variant chip & favorite button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: BurhanColors.slate100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.selectedVariant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BurhanTypography.caption.copyWith(
                          fontSize: 10,
                          color: BurhanColors.slate700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _moveToFavorites(item),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_border_rounded, size: 12, color: BurhanColors.slate400),
                          const SizedBox(width: 2),
                          Text(
                            'للمفضلة',
                            style: BurhanTypography.caption.copyWith(
                              fontSize: 10,
                              color: BurhanColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Price and Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¥${item.totalPriceCny.toInt()} (سعر الصين)',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: BurhanColors.slate400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatPrice(item.totalPriceYer),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: BurhanColors.primary,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'ر.ي',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: BurhanColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Quantity Stepper
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: BurhanColors.slate100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: BurhanColors.slate200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 14),
                            color: BurhanColors.slate700,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28),
                            onPressed: () => _updateQuantity(item.id, -1),
                          ),
                          Text(
                            '${item.quantity}',
                            style: BurhanTypography.titleSmall.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 14),
                            color: BurhanColors.slate700,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28),
                            onPressed: () => _updateQuantity(item.id, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(int selectedCount, int totalCount) {
    final hasSelection = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: BurhanColors.slate200, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price summary
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'المحدد للشراء: ',
                      style: BurhanTypography.caption.copyWith(
                        color: BurhanColors.slate500,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$selectedCount من أصل $totalCount',
                      style: BurhanTypography.caption.copyWith(
                        color: BurhanColors.amber,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      hasSelection ? _formatPrice(_selectedTotalYer) : '0',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: BurhanColors.primary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      'ر.ي',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: BurhanColors.primary,
                      ),
                    ),
                  ],
                ),
                if (hasSelection)
                  Text(
                    '≈ ${_formatPrice(_selectedTotalSar)} ر.س · ${_formatPrice(_selectedTotalUsd)} \$',
                    style: BurhanTypography.caption.copyWith(
                      fontSize: 9.5,
                      color: BurhanColors.slate400,
                    ),
                  ),
              ],
            ),
          ),

          // Checkout CTA button
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: hasSelection ? _proceedToCheckout : null,
              icon: Text(
                'إكمال الشراء ($selectedCount)',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              label: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: BurhanColors.primary,
                disabledBackgroundColor: BurhanColors.slate300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
