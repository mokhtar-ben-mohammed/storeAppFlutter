import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/product_card.dart';
import 'package:store/features/home/domain/entities/catalog_channel_entity.dart';
import 'package:store/features/home/domain/repositories/home_repository.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/domain/repositories/catalog_repository.dart';
import 'package:store/features/products/presentation/cubits/channel_products_cubit.dart';
import 'package:store/features/products/presentation/pages/product_details_page.dart';

/// Search tab: active Elim channels only + paginated channel products.
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
  final ScrollController _scrollController = ScrollController();
  List<CatalogChannelEntity> _channels = const [];
  String? _selectedSlug;
  bool _loadingChannels = true;
  ChannelProductsCubit? _productsCubit;
  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _productsCubit?.close();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    final result = await sl<HomeRepository>().getHomeFeed();
    if (!mounted) return;
    final channels = result.dataOrNull?.channels ?? const <CatalogChannelEntity>[];
    setState(() {
      _channels = channels;
      _loadingChannels = false;
      if (channels.isNotEmpty) {
        final initial = widget.initialStore;
        final match = channels.where((c) => c.slug == initial).toList();
        _selectedSlug = match.isNotEmpty ? match.first.slug : channels.first.slug;
      }
    });
    if (_selectedSlug != null) {
      _bindCubit(_selectedSlug!);
    }
  }

  void _bindCubit(String slug) {
    _productsCubit?.close();
    _productsCubit = ChannelProductsCubit(
      catalogRepository: sl<CatalogRepository>(),
      channelSlug: slug,
    )..load(q: _searchController.text);
    setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _productsCubit == null) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      _productsCubit!.loadMore();
    }
  }

  void _selectChannel(String slug) {
    if (_selectedSlug == slug) return;
    setState(() => _selectedSlug = slug);
    _bindCubit(slug);
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

  Future<void> _tryOpenFromUrl() async {
    final text = _searchController.text.trim();
    final idMatch = RegExp(r'(\d{6,})').firstMatch(text);
    if (idMatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر استخراج رقم المنتج من الرابط')),
      );
      return;
    }
    final numericId = idMatch.group(1)!;
    final slug = _selectedSlug ??
        (text.contains('1688') ? '1688' : 'taobao');
    final platform = slug == '1688' ? 'alibaba' : slug;
    final composite = 'elim:$platform:$numericId';
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(productId: composite),
      ),
    );
  }

  bool get _looksLikeUrl {
    final t = _searchController.text.trim().toLowerCase();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'البحث والمنتجات',
          style: BurhanTypography.titleMedium.copyWith(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              children: [
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BurhanColors.slate200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      if (_looksLikeUrl) {
                        _tryOpenFromUrl();
                      } else {
                        _productsCubit?.search(value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث أو الصق رابط منتج صيني',
                      hintStyle: BurhanTypography.bodySmall.copyWith(
                        color: BurhanColors.slate400,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_looksLikeUrl)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: _tryOpenFromUrl,
                      icon: const Icon(Icons.link_rounded, size: 16),
                      label: const Text('استيراد المنتج من الرابط'),
                    ),
                  ),
              ],
            ),
          ),
          if (_loadingChannels)
            const LinearProgressIndicator(minHeight: 2)
          else
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _channels.map((channel) {
                  final selected = channel.slug == _selectedSlug;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(channel.nameAr),
                      selected: selected,
                      onSelected: (_) => _selectChannel(channel.slug),
                      selectedColor: BurhanColors.primary.withValues(alpha: 0.15),
                      labelStyle: BurhanTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? BurhanColors.primary : BurhanColors.slate700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _productsCubit == null
                ? Center(
                    child: Text(
                      _channels.isEmpty
                          ? 'لا توجد قنوات نشطة حالياً'
                          : 'اختر متجراً لعرض المنتجات',
                      style: BurhanTypography.bodyMedium.copyWith(
                        color: BurhanColors.slate500,
                      ),
                    ),
                  )
                : BlocProvider<ChannelProductsCubit>.value(
                    value: _productsCubit!,
                    child: BlocBuilder<ChannelProductsCubit, ChannelProductsState>(
                      builder: (context, state) {
                        if (state is ChannelProductsLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is ChannelProductsFailure) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(state.message),
                                TextButton(
                                  onPressed: () => _productsCubit?.load(),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          );
                        }
                        final products = state is ChannelProductsLoaded
                            ? state.products
                            : const <ProductEntity>[];
                        final loadingMore =
                            state is ChannelProductsLoaded && state.isLoadingMore;
                        if (products.isEmpty) {
                          return Center(
                            child: Text(
                              'لا توجد منتجات',
                              style: BurhanTypography.bodyMedium.copyWith(
                                color: BurhanColors.slate500,
                              ),
                            ),
                          );
                        }
                        return GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.58,
                          ),
                          itemCount: products.length + (loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= products.length) {
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              isFavorite: _favoriteIds.contains(product.id),
                              onTap: () => _openDetails(product),
                              onAddToCart: () => _openDetails(product),
                              onToggleFavorite: () async {
                                final repo = sl<CatalogRepository>();
                                final isFav = _favoriteIds.contains(product.id);
                                final result = isFav
                                    ? await repo.removeFavorite(product.id)
                                    : await repo.addFavorite(
                                        productId: product.id,
                                        title: product.title,
                                        channelSlug: product.store,
                                        imageUrl: product.images.isNotEmpty
                                            ? product.images.first
                                            : null,
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
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
