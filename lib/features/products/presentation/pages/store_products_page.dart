import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/product_card.dart';
import 'package:store/core/widgets/store_badge.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/domain/repositories/catalog_repository.dart';
import 'package:store/features/products/presentation/cubits/channel_products_cubit.dart';
import 'package:store/features/products/presentation/pages/product_details_page.dart';

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

/// Channel product listing with API pagination.
class StoreProductsPage extends StatelessWidget {
  const StoreProductsPage({
    super.key,
    this.storeId = '1688',
  });

  final String storeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChannelProductsCubit(
        catalogRepository: sl<CatalogRepository>(),
        channelSlug: storeId,
      )..load(),
      child: _StoreProductsView(storeId: storeId),
    );
  }
}

class _StoreProductsView extends StatefulWidget {
  const _StoreProductsView({required this.storeId});

  final String storeId;

  @override
  State<_StoreProductsView> createState() => _StoreProductsViewState();
}

class _StoreProductsViewState extends State<_StoreProductsView> {
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
  };

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _favoriteIds = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _StoreMeta get _meta {
    final key = widget.storeId.toLowerCase();
    return _storeMetadata[key] ??
        _StoreMeta(
          title: 'متجر $key',
          chineseName: key,
          startColor: BurhanColors.primary,
          endColor: BurhanColors.primaryLight,
          desc: 'منتجات مباشرة من القناة المختارة عبر وسيط الكتالوج.',
          badge: 'كتالوج مباشر',
        );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      context.read<ChannelProductsCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      context.read<ChannelProductsCubit>().search(value);
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleFavorite(ProductEntity product) async {
    final isFav = _favoriteIds.contains(product.id);
    final repo = sl<CatalogRepository>();
    final result = isFav
        ? await repo.removeFavorite(product.id)
        : await repo.addFavorite(
            productId: product.id,
            title: product.title,
            channelSlug: product.store,
            imageUrl: product.images.isNotEmpty ? product.images.first : null,
            priceCny: product.originalPriceCny,
          );
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() {
        if (isFav) {
          _favoriteIds.remove(product.id);
        } else {
          _favoriteIds.add(product.id);
        }
      });
      _toast(isFav ? 'تمت إزالة المنتج من المفضلة' : 'تمت إضافة المنتج إلى المفضلة');
    } else {
      _toast(result.failureOrNull?.message ?? 'يلزم تسجيل الدخول للمفضلة');
    }
  }

  void _openDetails(ProductEntity product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(
          product: product,
          productId: product.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = _meta;

    return Scaffold(
      backgroundColor: BurhanColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: BlocBuilder<ChannelProductsCubit, ChannelProductsState>(
        builder: (context, state) {
          final products = state is ChannelProductsLoaded
              ? state.products
              : const <ProductEntity>[];
          final loadingMore =
              state is ChannelProductsLoaded && state.isLoadingMore;

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BurhanColors.slate200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
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
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  child: Text(
                    state is ChannelProductsLoaded
                        ? 'المنتجات المتوفرة · ${products.length}'
                        : 'المنتجات المتوفرة',
                    style: BurhanTypography.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (state is ChannelProductsLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is ChannelProductsFailure)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: BurhanTypography.bodyMedium.copyWith(
                              color: BurhanColors.rose500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                context.read<ChannelProductsCubit>().load(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'لا توجد منتجات للعرض',
                      style: BurhanTypography.bodyMedium.copyWith(
                        color: BurhanColors.slate500,
                      ),
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
                        if (index >= products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          isFavorite: _favoriteIds.contains(product.id),
                          onToggleFavorite: () => _toggleFavorite(product),
                          onAddToCart: () => _openDetails(product),
                          onTap: () => _openDetails(product),
                        );
                      },
                      childCount: products.length + (loadingMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
