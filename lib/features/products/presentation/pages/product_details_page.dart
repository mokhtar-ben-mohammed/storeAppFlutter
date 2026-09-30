import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/domain/repositories/catalog_repository.dart';
import 'package:store/features/products/presentation/cubits/product_detail_cubit.dart';

/// Product details matching storeAppUI, bound to catalog APIs.
class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    this.product,
    this.productId,
  }) : assert(product != null || productId != null);

  final ProductEntity? product;
  final String? productId;

  @override
  Widget build(BuildContext context) {
    final id = productId ?? product!.id;
    return BlocProvider(
      create: (_) => ProductDetailCubit(catalogRepository: sl<CatalogRepository>())
        ..load(id, preview: product),
      child: _ProductDetailsView(preview: product),
    );
  }
}

class _ProductDetailsView extends StatefulWidget {
  const _ProductDetailsView({this.preview});
  final ProductEntity? preview;

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  late final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  String _selectedVariantId = '';
  final Map<String, String> _dimensionSelections = {};
  int _quantity = 1;
  bool _isFavorite = false;
  bool _syncedFromProduct = false;

  static const double _cnyToYer = 75.0;
  static const double _cnyToSar = 0.525;
  static const double _cnyToUsd = 0.14;

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _syncFromProduct(ProductEntity product) {
    if (_syncedFromProduct) return;
    _syncedFromProduct = true;
    _isFavorite = product.isFavorite;
    if (product.hasRealSkus) {
      _selectedVariantId = product.variants.first.id;
      _applyVariantAttributes(product.variants.first);
    } else if (product.variants.isNotEmpty) {
      _selectedVariantId = product.variants.first.id;
    }
    final moq = product.moq ?? 1;
    if (_quantity < moq) _quantity = moq;
  }

  void _applyVariantAttributes(ProductVariant variant) {
    _dimensionSelections
      ..clear()
      ..addAll(variant.attributes);
  }

  ProductEntity? _productOf(ProductDetailState state) {
    if (state is ProductDetailLoaded) return state.product;
    if (state is ProductDetailLoading) return state.preview ?? widget.preview;
    if (state is ProductDetailFailure) return state.preview ?? widget.preview;
    return widget.preview;
  }

  ProductVariant? _selectedVariant(ProductEntity product) {
    if (product.variants.isEmpty) return null;
    return product.variants.firstWhere(
      (v) => v.id == _selectedVariantId,
      orElse: () => product.variants.first,
    );
  }

  double _unitPriceCny(ProductEntity product) {
    final selected = _selectedVariant(product);
    if (selected?.priceCny != null) return selected!.priceCny!;
    return product.originalPriceCny + (selected?.priceModifierCny ?? 0);
  }

  double _activeTierPriceCny(ProductEntity product) {
    final unit = _unitPriceCny(product);
    if (product.wholesaleTiers.isEmpty) return unit;
    final matched =
        product.wholesaleTiers.where((t) => _quantity >= t.minQty).toList();
    if (matched.isNotEmpty) return matched.last.priceCny;
    return unit;
  }

  double _totalPriceCny(ProductEntity product) =>
      _activeTierPriceCny(product) * _quantity;

  String _formatPrice(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  List<SkuDimension> _orderedDimensions(ProductEntity product) {
    final dims = List<SkuDimension>.from(product.skuDimensions);
    int rank(String name) {
      final n = name.toLowerCase();
      if (n.contains('color') || n.contains('colour') || n.contains('لون')) {
        return 0;
      }
      return 1;
    }

    dims.sort((a, b) => rank(a.name).compareTo(rank(b.name)));
    return dims;
  }

  int? _galleryIndexForUrl(ProductEntity product, String url) {
    if (url.isEmpty) return null;
    final exact = product.images.indexWhere((img) => img == url);
    if (exact >= 0) return exact;
    final fuzzy = product.images.indexWhere(
      (img) => img.endsWith(url) || url.endsWith(img),
    );
    return fuzzy >= 0 ? fuzzy : null;
  }

  void _jumpGalleryToImageUrl(ProductEntity product, String url) {
    final idx = _galleryIndexForUrl(product, url);
    if (idx == null) return;
    if (!_imagePageController.hasClients) return;
    _imagePageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    setState(() => _currentImageIndex = idx);
  }

  void _jumpGalleryToVariantImage(ProductEntity product, ProductVariant variant) {
    final url = variant.imageUrl;
    if (url == null || url.isEmpty) return;
    _jumpGalleryToImageUrl(product, url);
  }

  void _selectGalleryThumbnail(int idx) {
    if (!_imagePageController.hasClients) return;
    _imagePageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    setState(() => _currentImageIndex = idx);
  }

  String _formatSkuCny(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  String _humanizeBadge(String raw) {
    if (!raw.contains('_')) return raw;
    return raw
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  void _openProductVideo(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          url,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  bool _requireAuth() {
    final auth = context.read<AuthCubit>().state;
    if (auth is Authenticated) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'يلزم تسجيل الدخول للمتابعة',
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'دخول',
          textColor: BurhanColors.amber,
          onPressed: () => context.go('${AppRoutes.login}?mode=login'),
        ),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  }

  Future<void> _toggleFavorite() async {
    if (!_requireAuth()) return;
    final error = await context.read<ProductDetailCubit>().toggleFavorite(
          currentlyFavorite: _isFavorite,
        );
    if (!mounted) return;
    if (error == null) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: BurhanColors.slate900),
      );
    }
  }

  Future<void> _addToCart(ProductEntity product) async {
    if (!_requireAuth()) return;
    final selected = _selectedVariant(product);
    final skuId = selected?.id ??
        (product.variants.isNotEmpty ? product.variants.first.id : 'default');
    final error = await context.read<ProductDetailCubit>().addToCart(
          skuId: skuId,
          skuLabel: selected?.name,
          quantity: _quantity,
          unitPriceCny: _activeTierPriceCny(product),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (error == null)
              const Icon(Icons.check_circle_rounded,
                  color: BurhanColors.amber, size: 18),
            if (error == null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                error ?? 'تمت إضافة $_quantity من "${product.title}" إلى السلة',
                maxLines: 2,
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

  void _selectDimension(
    ProductEntity product,
    String dimName,
    SkuDimensionValue value,
  ) {
    ProductVariant? matchedVariant;
    setState(() {
      _dimensionSelections[dimName] = value.label;
      final match = product.variants.where((v) {
        if (v.attributes.isEmpty) return false;
        return _dimensionSelections.entries.every(
          (e) => v.attributes[e.key] == e.value,
        );
      });
      if (match.isNotEmpty) {
        _selectedVariantId = match.first.id;
        matchedVariant = match.first;
      }
    });
    final dimImage = value.image;
    if (dimImage != null && dimImage.isNotEmpty) {
      _jumpGalleryToImageUrl(product, dimImage);
    } else if (matchedVariant != null) {
      _jumpGalleryToVariantImage(product, matchedVariant!);
    }
  }

  void _selectFlatVariant(ProductEntity product, ProductVariant v) {
    if (!v.inStock) return;
    setState(() {
      _selectedVariantId = v.id;
      _applyVariantAttributes(v);
    });
    _jumpGalleryToVariantImage(product, v);
  }

  bool _isDimensionValueAvailable(
    ProductEntity product,
    String dimName,
    String value,
  ) {
    final trial = Map<String, String>.from(_dimensionSelections)
      ..[dimName] = value;
    return product.variants.any((v) {
      if (!v.inStock) return false;
      return trial.entries.every((e) => v.attributes[e.key] == e.value);
    });
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return BurhanColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductDetailCubit, ProductDetailState>(
      listener: (context, state) {
        if (state is ProductDetailLoaded) {
          setState(() {
            _syncedFromProduct = false;
            _syncFromProduct(state.product);
            _isFavorite = state.isFavorite || state.product.isFavorite;
          });
        }
      },
      builder: (context, state) {
        final product = _productOf(state);
        if (product != null) _syncFromProduct(product);

        if (product == null && state is ProductDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                state is ProductDetailFailure
                    ? state.message
                    : 'تعذّر تحميل المنتج',
              ),
            ),
          );
        }

        final images = product.images;
        final showVariants = product.hasRealSkus;
        final showDimensions =
            product.skuDimensions.isNotEmpty && showVariants;
        final unitCny = _activeTierPriceCny(product);
        final totalYer = _totalPriceCny(product) * _cnyToYer;
        final totalSar = _totalPriceCny(product) * _cnyToSar;
        final totalUsd = _totalPriceCny(product) * _cnyToUsd;
        final selected = _selectedVariant(product);
        final moq = product.moq ?? 1;

        return Scaffold(
          backgroundColor: BurhanColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    elevation: 0,
                    scrolledUnderElevation: 2,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18),
                      color: BurhanColors.slate900,
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                    ),
                    title:
                        StoreBadge(store: product.store, size: StoreBadgeSize.sm),
                    centerTitle: false,
                    actions: [
                      IconButton(
                        icon: Icon(
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isFavorite
                              ? BurhanColors.rose500
                              : BurhanColors.slate700,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: BurhanColors.slate700),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم نسخ رابط المنتج للمشاركة',
                                style: BurhanTypography.bodySmall
                                    .copyWith(color: Colors.white),
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
                  if (state is ProductDetailLoading)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 310,
                            child: images.isEmpty
                                ? Container(
                                    color: BurhanColors.slate100,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                      color: BurhanColors.slate400,
                                    ),
                                  )
                                : PageView.builder(
                                    controller: _imagePageController,
                                    itemCount: images.length,
                                    onPageChanged: (idx) =>
                                        setState(() => _currentImageIndex = idx),
                                    itemBuilder: (context, index) {
                                      return CachedNetworkImage(
                                        imageUrl: images[index],
                                        fit: BoxFit.cover,
                                        errorWidget: (_, _, _) => Container(
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
                          if (images.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: SizedBox(
                                height: 56,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: images.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, idx) {
                                    final isSelected =
                                        _currentImageIndex == idx;
                                    return GestureDetector(
                                      onTap: () => _selectGalleryThumbnail(idx),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? BurhanColors.primary
                                                : BurhanColors.slate200,
                                            width: isSelected ? 2.5 : 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: CachedNetworkImage(
                                            imageUrl: images[idx],
                                            fit: BoxFit.cover,
                                            errorWidget: (_, _, _) => Container(
                                              color: BurhanColors.slate100,
                                              child: const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                size: 20,
                                                color: BurhanColors.slate400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.supplierName.isNotEmpty ||
                              product.supplierRating > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (product.supplierName.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.store_rounded,
                                          size: 16, color: BurhanColors.primary),
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
                                  )
                                else
                                  const SizedBox.shrink(),
                                if (product.supplierRating > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: BurhanColors.amber
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded,
                                            size: 13,
                                            color: BurhanColors.amberDark),
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
                          if (product.supplierName.isNotEmpty ||
                              product.supplierRating > 0)
                            const SizedBox(height: 8),
                          Text(
                            product.title,
                            style: BurhanTypography.titleLarge.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                              color: BurhanColors.slate900,
                            ),
                          ),
                          if (product.titleOriginal != null &&
                              product.titleOriginal!.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              product.titleOriginal!.trim(),
                              style: BurhanTypography.bodySmall.copyWith(
                                fontSize: 12,
                                color: BurhanColors.slate500,
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (product.rating > 0) ...[
                                const Icon(Icons.star_rounded,
                                    size: 16, color: BurhanColors.amber),
                                const SizedBox(width: 3),
                                Text(
                                  '${product.rating}',
                                  style: BurhanTypography.titleSmall.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (product.salesCount > 0)
                                Text(
                                  '(${product.salesCount}+ مبيعات بالصين)',
                                  style: BurhanTypography.caption.copyWith(
                                    color: BurhanColors.slate500,
                                    fontSize: 11,
                                  ),
                                ),
                              const Spacer(),
                              if (moq > 1)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: BurhanColors.store1688Bg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: BurhanColors.store1688Border),
                                  ),
                                  child: Text(
                                    'الحد الأدنى: $moq',
                                    style: BurhanTypography.caption.copyWith(
                                      color: BurhanColors.store1688Text,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: BurhanColors.emerald50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: BurhanColors.emerald500
                                        .withValues(alpha: 0.2),
                                  ),
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
                          _buildPriceCard(product, unitCny),
                          if (product.wholesaleTiers.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _buildWholesaleTiersSection(product, unitCny),
                          ],
                          if (showDimensions) ...[
                            const SizedBox(height: 14),
                            _buildDimensionPicker(product),
                          ] else if (showVariants) ...[
                            const SizedBox(height: 14),
                            _buildVariantsSection(product, selected),
                          ],
                          const SizedBox(height: 14),
                          _buildQuantitySelector(product, moq),
                          const SizedBox(height: 14),
                          _buildBurhanGuaranteeCard(),
                          if (product.badges.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _buildBadgesSection(product),
                          ],
                          if (_hasProductMeta(product)) ...[
                            const SizedBox(height: 14),
                            _buildProductMetaRow(product),
                          ],
                          if (product.videoUrl != null &&
                              product.videoUrl!.trim().isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _buildVideoSection(context, product),
                          ],
                          if (product.reviewScores != null) ...[
                            const SizedBox(height: 14),
                            _buildReviewScoresCard(product),
                          ],
                          if (product.shipping != null) ...[
                            const SizedBox(height: 14),
                            _buildShippingCard(product),
                          ],
                          if (product.specs.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _buildSpecTable(product),
                          ],
                          if (product.description.trim().isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _buildDescriptionSection(product),
                          ],
                          if (product.descriptionImages.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _buildDescriptionImagesSection(product),
                          ],
                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomActionBar(
                  product,
                  totalYer: totalYer,
                  totalSar: totalSar,
                  totalUsd: totalUsd,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceCard(ProductEntity product, double unitCny) {
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
                        _formatPrice(unitCny * _cnyToYer),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: BurhanColors.store1688Bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BurhanColors.store1688Border),
                ),
                child: Row(
                  children: [
                    const Text(
                      '¥',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: BurhanColors.store1688Text,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      unitCny == unitCny.roundToDouble()
                          ? '${unitCny.toInt()} يوان صيني'
                          : '${unitCny.toStringAsFixed(2)} يوان صيني',
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
          Text(
            'ما يعادل: ${_formatPrice(unitCny * _cnyToSar)} ر.س · ${_formatPrice(unitCny * _cnyToUsd)} \$',
            style: BurhanTypography.caption.copyWith(
              color: BurhanColors.slate500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWholesaleTiersSection(
    ProductEntity product,
    double activeUnitCny,
  ) {
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
              const Icon(Icons.auto_awesome_rounded,
                  size: 14, color: BurhanColors.amber),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: product.wholesaleTiers.map((tier) {
              final isCurrent = activeUnitCny == tier.priceCny;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? BurhanColors.primary.withValues(alpha: 0.06)
                        : BurhanColors.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? BurhanColors.primary
                          : BurhanColors.slate200,
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
                          color: isCurrent
                              ? BurhanColors.primary
                              : BurhanColors.slate900,
                        ),
                      ),
                      Text(
                        '${(tier.priceCny * _cnyToYer).toInt()} ر.ي',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isCurrent
                              ? BurhanColors.amberDark
                              : BurhanColors.slate400,
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

  Widget _buildDimensionPicker(ProductEntity product) {
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
            'الخيارات والمتغيرات المتوفرة',
            style: BurhanTypography.titleSmall.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ..._orderedDimensions(product).map((dim) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dim.name,
                    style: BurhanTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BurhanColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dim.values.map((value) {
                      final selected =
                          _dimensionSelections[dim.name] == value.label;
                      final available = _isDimensionValueAvailable(
                        product,
                        dim.name,
                        value.label,
                      );
                      final hasImage =
                          value.image != null && value.image!.isNotEmpty;
                      if (hasImage) {
                        return _buildDimensionImageChip(
                          product: product,
                          dimName: dim.name,
                          value: value,
                          selected: selected,
                          available: available,
                        );
                      }
                      return ChoiceChip(
                        label: Text(value.label),
                        selected: selected,
                        onSelected: !available
                            ? null
                            : (_) => _selectDimension(
                                  product,
                                  dim.name,
                                  value,
                                ),
                        selectedColor:
                            BurhanColors.primary.withValues(alpha: 0.12),
                        side: BorderSide(
                          color: selected
                              ? BurhanColors.primary
                              : BurhanColors.slate200,
                          width: selected ? 1.5 : 1,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: available
                              ? (selected
                                  ? BurhanColors.primary
                                  : BurhanColors.slate800)
                              : BurhanColors.slate400,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            '¥${_formatSkuCny(_unitPriceCny(product))}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: BurhanColors.store1688Text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionImageChip({
    required ProductEntity product,
    required String dimName,
    required SkuDimensionValue value,
    required bool selected,
    required bool available,
  }) {
    return InkWell(
      onTap: !available
          ? null
          : () => _selectDimension(product, dimName, value),
      borderRadius: BorderRadius.circular(10),
      child: Opacity(
        opacity: available ? 1 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? BurhanColors.primary.withValues(alpha: 0.06)
                : BurhanColors.slate50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? BurhanColors.primary : BurhanColors.slate200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: value.image!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    width: 40,
                    height: 40,
                    color: BurhanColors.slate100,
                    child: const Icon(Icons.image_outlined, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? BurhanColors.primary
                      : BurhanColors.slate800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariantsSection(
    ProductEntity product,
    ProductVariant? selected,
  ) {
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
              if (selected != null)
                Text(
                  selected.name,
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
            children: product.variants.map((v) {
              final isSelected = v.id == _selectedVariantId;
              final color = _parseColor(v.colorHex);
              return InkWell(
                onTap: v.inStock ? () => _selectFlatVariant(product, v) : null,
                borderRadius: BorderRadius.circular(10),
                child: Opacity(
                  opacity: v.inStock ? 1 : 0.45,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? BurhanColors.primary.withValues(alpha: 0.05)
                          : BurhanColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? BurhanColors.primary
                            : BurhanColors.slate200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (v.imageUrl != null && v.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: v.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                width: 40,
                                height: 40,
                                color: BurhanColors.slate100,
                                child: const Icon(Icons.image_outlined,
                                    size: 18),
                              ),
                            ),
                          )
                        else
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
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? BurhanColors.primary
                                : BurhanColors.slate800,
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
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '¥${_formatSkuCny(_unitPriceCny(product))}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: BurhanColors.store1688Text,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasProductMeta(ProductEntity product) {
    return (product.unit != null && product.unit!.trim().isNotEmpty) ||
        product.stockQuantity != null ||
        (product.sellerType != null && product.sellerType!.trim().isNotEmpty) ||
        product.category.trim().isNotEmpty;
  }

  Widget _buildBadgesSection(ProductEntity product) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.badges.map((badge) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: BurhanColors.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: BurhanColors.amber.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            _humanizeBadge(badge.trim()),
            style: BurhanTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: BurhanColors.amberDark,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductMetaRow(ProductEntity product) {
    final items = <String>[];
    if (product.unit != null && product.unit!.trim().isNotEmpty) {
      items.add('الوحدة: ${product.unit!.trim()}');
    }
    if (product.stockQuantity != null) {
      items.add('المخزون: ${product.stockQuantity}');
    }
    if (product.sellerType != null && product.sellerType!.trim().isNotEmpty) {
      items.add('البائع: ${_humanizeBadge(product.sellerType!.trim())}');
    }
    if (product.category.trim().isNotEmpty) {
      items.add('التصنيف: ${product.category.trim()}');
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BurhanColors.slate200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: items
            .map(
              (text) => Text(
                text,
                style: BurhanTypography.caption.copyWith(
                  color: BurhanColors.slate600,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildReviewScoresCard(ProductEntity product) {
    final scores = product.reviewScores!;
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
            'تقييمات المورد والخدمة',
            style: BurhanTypography.titleSmall.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _reviewScoreRow('التقييم الإجمالي', scores.total),
          _reviewScoreRow('خدمة العملاء', scores.service),
          _reviewScoreRow('الشحن واللوجستيات', scores.logistics),
          _reviewScoreRow('ما بعد البيع', scores.aftersale),
        ],
      ),
    );
  }

  Widget _reviewScoreRow(String label, double? score) {
    if (score == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: BurhanTypography.caption.copyWith(
              color: BurhanColors.slate500,
              fontSize: 11,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 14, color: BurhanColors.amber),
              const SizedBox(width: 4),
              Text(
                score.toStringAsFixed(1),
                style: BurhanTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: BurhanColors.slate800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCard(ProductEntity product) {
    final shipping = product.shipping!;
    final dims = <String>[];
    if (shipping.lengthCm != null) dims.add('${shipping.lengthCm}');
    if (shipping.widthCm != null) dims.add('${shipping.widthCm}');
    if (shipping.heightCm != null) dims.add('${shipping.heightCm}');
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
            'معلومات الشحن من المصنع',
            style: BurhanTypography.titleSmall.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (shipping.address != null && shipping.address!.trim().isNotEmpty)
            _shippingInfoLine('العنوان', shipping.address!.trim()),
          if (shipping.weightKg != null)
            _shippingInfoLine(
              'الوزن',
              '${shipping.weightKg} كغ',
            ),
          if (dims.isNotEmpty)
            _shippingInfoLine('الأبعاد (ط×ع×ار)', dims.join(' × ')),
        ],
      ),
    );
  }

  Widget _shippingInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: BurhanTypography.caption.copyWith(
                color: BurhanColors.slate500,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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
  }

  Widget _buildDescriptionImagesSection(ProductEntity product) {
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
            'صور تفاصيل المنتج',
            style: BurhanTypography.titleSmall.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...product.descriptionImages.map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorWidget: (_, _, _) => Container(
                    height: 120,
                    color: BurhanColors.slate100,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: BurhanColors.slate400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context, ProductEntity product) {
    final url = product.videoUrl!.trim();
    return ActionChip(
      avatar: const Icon(Icons.play_circle_outline_rounded,
          size: 20, color: BurhanColors.primary),
      label: Text(
        'فيديو المنتج',
        style: BurhanTypography.titleSmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: BurhanColors.primary,
        ),
      ),
      backgroundColor: BurhanColors.primary.withValues(alpha: 0.08),
      side: BorderSide(color: BurhanColors.primary.withValues(alpha: 0.25)),
      onPressed: () => _openProductVideo(context, url),
    );
  }

  Widget _buildQuantitySelector(ProductEntity product, int moq) {
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
              if (product.wholesaleTiers.isNotEmpty)
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
                onTap: _quantity > moq
                    ? () => setState(() => _quantity--)
                    : null,
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
                child: const Icon(Icons.shield_rounded,
                    color: BurhanColors.amber, size: 18),
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
          _guaranteeItem(
              'فحص عيني شامل لمطابقة المواصفات واللون وسلامة القطع.'),
          _guaranteeItem(
              'تصوير فيديو وصور دقيقة للمنتج وإرسالها لك قبل شحنه لليمن.'),
          _guaranteeItem(
              'تجميع وإعادة تغليف تجاري مضغوط لتوفير كلفة الشحن.'),
          _guaranteeItem(
              'شحن موثوق ومباشر لجميع المحافظات اليمنية حتى باب بيتك.'),
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
          const Icon(Icons.check_circle_rounded,
              size: 14, color: BurhanColors.amber),
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

  Widget _buildSpecTable(ProductEntity product) {
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
          ...product.specs.map((s) {
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
                  Text(
                    s.label,
                    style: BurhanTypography.caption.copyWith(
                      color: BurhanColors.slate500,
                      fontSize: 11,
                    ),
                  ),
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

  Widget _buildDescriptionSection(ProductEntity product) {
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
            product.description,
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

  Widget _buildBottomActionBar(
    ProductEntity product, {
    required double totalYer,
    required double totalSar,
    required double totalUsd,
  }) {
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
                      _formatPrice(totalYer),
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
                  '≈ ${_formatPrice(totalSar)} ر.س · ${_formatPrice(totalUsd)} \$',
                  style: BurhanTypography.caption.copyWith(
                    fontSize: 9.5,
                    color: BurhanColors.slate400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _addToCart(product),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                  label: const Text(
                    'أضف للسلة',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BurhanColors.primary,
                    side: const BorderSide(color: BurhanColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
