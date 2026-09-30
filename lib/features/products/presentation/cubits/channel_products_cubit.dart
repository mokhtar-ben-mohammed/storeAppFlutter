import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/features/products/domain/entities/product_entity.dart';
import 'package:store/features/products/domain/repositories/catalog_repository.dart';

sealed class ChannelProductsState extends Equatable {
  const ChannelProductsState();
  @override
  List<Object?> get props => [];
}

final class ChannelProductsInitial extends ChannelProductsState {
  const ChannelProductsInitial();
}

final class ChannelProductsLoading extends ChannelProductsState {
  const ChannelProductsLoading();
}

final class ChannelProductsLoaded extends ChannelProductsState {
  const ChannelProductsLoaded({
    required this.products,
    required this.hasMore,
    required this.page,
    this.isLoadingMore = false,
    this.query,
  });

  final List<ProductEntity> products;
  final bool hasMore;
  final int page;
  final bool isLoadingMore;
  final String? query;

  @override
  List<Object?> get props => [products, hasMore, page, isLoadingMore, query];
}

final class ChannelProductsFailure extends ChannelProductsState {
  const ChannelProductsFailure(this.failure);
  final Failure failure;
  String get message => failure.message;
  @override
  List<Object?> get props => [failure];
}

class ChannelProductsCubit extends Cubit<ChannelProductsState> {
  ChannelProductsCubit({
    required this.catalogRepository,
    required this.channelSlug,
  }) : super(const ChannelProductsInitial());

  final CatalogRepository catalogRepository;
  final String channelSlug;

  String? _query;
  static const _pageSize = 20;

  Future<void> load({String? q}) async {
    _query = q?.trim().isEmpty == true ? null : q?.trim();
    emit(const ChannelProductsLoading());
    final result = await catalogRepository.getChannelProducts(
      channelSlug: channelSlug,
      page: 1,
      size: _pageSize,
      q: _query,
    );
    if (result.isSuccess) {
      final page = result.dataOrNull!;
      emit(ChannelProductsLoaded(
        products: page.items,
        hasMore: page.hasMore,
        page: page.currentPage,
        query: _query,
      ));
      return;
    }
    emit(ChannelProductsFailure(result.failureOrNull!));
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ChannelProductsLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    emit(ChannelProductsLoaded(
      products: current.products,
      hasMore: current.hasMore,
      page: current.page,
      isLoadingMore: true,
      query: current.query,
    ));
    final nextPage = current.page + 1;
    final result = await catalogRepository.getChannelProducts(
      channelSlug: channelSlug,
      page: nextPage,
      size: _pageSize,
      q: _query,
    );
    if (result.isSuccess) {
      final page = result.dataOrNull!;
      emit(ChannelProductsLoaded(
        products: [...current.products, ...page.items],
        hasMore: page.hasMore,
        page: page.currentPage,
        query: _query,
      ));
      return;
    }
    emit(ChannelProductsLoaded(
      products: current.products,
      hasMore: current.hasMore,
      page: current.page,
      query: current.query,
    ));
  }

  Future<void> search(String q) => load(q: q);
}
