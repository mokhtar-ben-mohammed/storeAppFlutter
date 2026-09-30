import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/home_carousel_slider.dart';
import 'package:store/core/widgets/marketplace_icons_slider.dart';
import 'package:store/core/widgets/product_card.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';
import 'package:store/features/home/domain/entities/catalog_channel_entity.dart';
import 'package:store/features/home/presentation/cubits/home_cubit.dart';
import 'package:store/features/home/presentation/cubits/home_state.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/domain/repositories/catalog_repository.dart';
import 'package:store/features/products/presentation/pages/product_details_page.dart';
import 'package:store/features/products/presentation/pages/store_products_page.dart';

/// Main home screen: carousel (local) + channels + featured products from API.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _favoriteIds = {};
  String? _selectedStore;

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed != null ? Color(parsed) : fallback;
  }

  (Color, Color) _channelColors(CatalogChannelEntity channel) {
    switch (channel.slug) {
      case '1688':
        return (
          _parseColor(channel.primaryColor, BurhanColors.store1688Start),
          _parseColor(channel.secondaryColor, BurhanColors.store1688End),
        );
      case 'taobao':
        return (
          _parseColor(channel.primaryColor, BurhanColors.storeTaobaoStart),
          _parseColor(channel.secondaryColor, BurhanColors.storeTaobaoEnd),
        );
      case 'goofish':
        return (
          _parseColor(channel.primaryColor, BurhanColors.storeGoofishStart),
          _parseColor(channel.secondaryColor, BurhanColors.storeGoofishEnd),
        );
      case 'aliexpress':
        return (
          _parseColor(channel.primaryColor, BurhanColors.storeAliexpressStart),
          _parseColor(channel.secondaryColor, BurhanColors.storeAliexpressEnd),
        );
      default:
        return (
          _parseColor(channel.primaryColor, BurhanColors.primary),
          _parseColor(channel.secondaryColor, BurhanColors.primaryLight),
        );
    }
  }

  List<MarketplaceStoreItem> _mapChannels(List<CatalogChannelEntity> channels) {
    return channels.map((channel) {
      final colors = _channelColors(channel);
      final textColor = _parseColor(channel.primaryTextColor, Colors.white);
      return MarketplaceStoreItem(
        id: channel.slug,
        nameAr: channel.nameAr,
        startColor: colors.$1,
        endColor: colors.$2,
        icon: marketplaceStoreIcon(
          slug: channel.slug,
          nameAr: channel.nameAr,
          logoUrl: channel.logoUrl,
          textColor: textColor,
        ),
      );
    }).toList();
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

  Future<void> _toggleFavorite(ProductEntity product) async {
    if (!_requireAuth()) return;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFav ? 'تمت إزالة المنتج من المفضلة' : 'تمت إضافة المنتج إلى المفضلة',
            style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: BurhanColors.slate900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failureOrNull?.message ?? 'تعذّر تحديث المفضلة',
            style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: BurhanColors.slate900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openProductDetails(ProductEntity product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(
          product: product,
          productId: product.id,
        ),
      ),
    );
  }

  Widget _shimmerBlock({required double height}) {
    return Shimmer.fromColors(
      baseColor: BurhanColors.slate100,
      highlightColor: Colors.white,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: BurhanColors.slate100,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final channels = state is HomeLoaded ? state.feed.channels : const <CatalogChannelEntity>[];
          final allProducts =
              state is HomeLoaded ? state.feed.featuredProducts : const <ProductEntity>[];
          final products = _selectedStore == null
              ? allProducts
              : allProducts.where((p) => p.store == _selectedStore).toList();

          return RefreshIndicator(
            color: BurhanColors.primary,
            onRefresh: () => context.read<HomeCubit>().load(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 14, right: 14, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeCarouselSlider(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تصفح منتجات المتاجر الصينية',
                              style: BurhanTypography.titleSmall.copyWith(fontSize: 12.5),
                            ),
                            Text(
                              'اسحب أفقياً لاختيار المتجر',
                              style: BurhanTypography.caption.copyWith(fontSize: 10.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (state is HomeLoading)
                          _shimmerBlock(height: 90)
                        else if (state is HomeFailure)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              state.message,
                              style: BurhanTypography.bodySmall.copyWith(
                                color: BurhanColors.rose500,
                              ),
                            ),
                          )
                        else
                          MarketplaceIconsSlider(
                            stores: _mapChannels(channels),
                            selectedStoreId: _selectedStore,
                            onStoreSelected: (storeId) {
                              setState(() {
                                _selectedStore =
                                    _selectedStore == storeId ? null : storeId;
                              });
                            },
                          ),
                          if (_selectedStore != null) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => StoreProductsPage(
                                        storeId: _selectedStore!,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.storefront_rounded, size: 16),
                                label: const Text('عرض كل منتجات المتجر'),
                              ),
                            ),
                          ],
                        const SizedBox(height: 16),
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
                                  style: BurhanTypography.titleSmall.copyWith(fontSize: 12.5),
                                ),
                              ],
                            ),
                            Text(
                              '${products.length} منتجات مميزة',
                              style: BurhanTypography.caption.copyWith(fontSize: 10.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (state is HomeLoading)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.58,
                            ),
                            itemBuilder: (_, _) => _shimmerBlock(height: 220),
                          )
                        else if (products.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Center(
                              child: Text(
                                state is HomeFailure
                                    ? 'تعذّر تحميل المنتجات'
                                    : 'لا توجد منتجات للعرض حالياً',
                                style: BurhanTypography.bodyMedium.copyWith(
                                  color: BurhanColors.slate500,
                                ),
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.58,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,
                                isFavorite: _favoriteIds.contains(product.id),
                                onToggleFavorite: () => _toggleFavorite(product),
                                onAddToCart: () => _openProductDetails(product),
                                onTap: () => _openProductDetails(product),
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
        },
      ),
    );
  }
}
