import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';

abstract interface class CheckoutRemoteDataSource {
  Future<List<Map<String, dynamic>>> getRequiredServices();

  Future<List<Map<String, dynamic>>> getShippingOptions({
    required int countryId,
    required double estimatedUnits,
  });

  Future<List<Map<String, dynamic>>> getPaymentMethods();

  Future<Map<String, dynamic>> preview({
    required List<int> cartItemIds,
    required int shippingLineId,
    int? countryId,
    List<int> extraServiceIds = const [],
  });

  Future<Map<String, dynamic>> placeOrder({
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

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  const CheckoutRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Map<String, dynamic>>> getRequiredServices() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.checkoutServices,
    );
    final data = ApiResponseParser.requireDataMap(response);
    final list = data['services'] as List<dynamic>? ?? const [];
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getShippingOptions({
    required int countryId,
    required double estimatedUnits,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.checkoutShippingOptions,
      queryParameters: {
        'country_id': countryId,
        'estimated_units': estimatedUnits,
      },
    );
    final data = ApiResponseParser.requireDataMap(response);
    final list = data['options'] as List<dynamic>? ?? const [];
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.checkoutPaymentMethods,
    );
    final data = ApiResponseParser.requireDataMap(response);
    final list = data['methods'] as List<dynamic>? ?? const [];
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> preview({
    required List<int> cartItemIds,
    required int shippingLineId,
    int? countryId,
    List<int> extraServiceIds = const [],
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.checkoutPreview,
      data: {
        'cart_item_ids': cartItemIds,
        'shipping_line_id': shippingLineId,
        'country_id': ?countryId,
        'extra_service_ids': extraServiceIds,
      },
    );
    return ApiResponseParser.requireDataMap(response);
  }

  @override
  Future<Map<String, dynamic>> placeOrder({
    required List<int> cartItemIds,
    required int shippingLineId,
    required String paymentMethod,
    int? userAddressId,
    String? recipientName,
    String? recipientPhone,
    int? cityId,
    String? addressLine,
    List<int> extraServiceIds = const [],
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.orders,
      data: {
        'cart_item_ids': cartItemIds,
        'shipping_line_id': shippingLineId,
        'payment_method': paymentMethod,
        'user_address_id': ?userAddressId,
        'recipient_name': ?recipientName,
        'recipient_phone': ?recipientPhone,
        'city_id': ?cityId,
        'address_line': ?addressLine,
        'extra_service_ids': extraServiceIds,
      },
    );
    return ApiResponseParser.requireDataMap(response);
  }
}
