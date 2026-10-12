import 'package:store/core/utils/result.dart';
import 'package:store/features/checkout/domain/entities/checkout_entities.dart';

abstract interface class CheckoutRepository {
  Future<Result<List<CheckoutServiceEntity>>> getRequiredServices();

  Future<Result<List<ShippingOptionEntity>>> getShippingOptions({
    required int countryId,
    required double estimatedUnits,
  });

  Future<Result<List<PaymentMethodEntity>>> getPaymentMethods();

  Future<Result<CheckoutPreviewEntity>> preview({
    required List<int> cartItemIds,
    required int shippingLineId,
    int? countryId,
    List<int> extraServiceIds = const [],
  });

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
  });
}
