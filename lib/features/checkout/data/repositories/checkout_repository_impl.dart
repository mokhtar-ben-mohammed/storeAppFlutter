import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:store/features/checkout/data/models/checkout_models.dart';
import 'package:store/features/checkout/domain/entities/checkout_entities.dart';
import 'package:store/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final CheckoutRemoteDataSource remote;
  final NetworkInfo networkInfo;

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.ok(await run());
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<List<CheckoutServiceEntity>>> getRequiredServices() => _guard(
        () async => (await remote.getRequiredServices()).map(mapCheckoutService).toList(),
      );

  @override
  Future<Result<List<ShippingOptionEntity>>> getShippingOptions({
    required int countryId,
    required double estimatedUnits,
  }) =>
      _guard(
        () async => (await remote.getShippingOptions(
              countryId: countryId,
              estimatedUnits: estimatedUnits,
            ))
            .map(mapShippingOption)
            .toList(),
      );

  @override
  Future<Result<List<PaymentMethodEntity>>> getPaymentMethods() => _guard(
        () async => (await remote.getPaymentMethods()).map(mapPaymentMethod).toList(),
      );

  @override
  Future<Result<CheckoutPreviewEntity>> preview({
    required List<int> cartItemIds,
    required int shippingLineId,
    int? countryId,
    List<int> extraServiceIds = const [],
  }) =>
      _guard(
        () async => mapCheckoutPreview(
          await remote.preview(
            cartItemIds: cartItemIds,
            shippingLineId: shippingLineId,
            countryId: countryId,
            extraServiceIds: extraServiceIds,
          ),
        ),
      );

  @override
  Future<Result<PlacedOrderEntity>> placeOrder({
    required List<int> cartItemIds,
    required int shippingLineId,
    required String paymentMethod,
    int? userAddressId,
    String? recipientName,
    String? recipientPhone,
    int? cityId,
    String? addressLine,
    List<int> extraServiceIds = const [],
  }) =>
      _guard(
        () async => mapPlacedOrder(
          await remote.placeOrder(
            cartItemIds: cartItemIds,
            shippingLineId: shippingLineId,
            paymentMethod: paymentMethod,
            userAddressId: userAddressId,
            recipientName: recipientName,
            recipientPhone: recipientPhone,
            cityId: cityId,
            addressLine: addressLine,
            extraServiceIds: extraServiceIds,
          ),
        ),
      );
}
