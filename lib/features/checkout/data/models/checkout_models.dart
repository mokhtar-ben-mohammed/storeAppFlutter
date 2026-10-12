import 'package:store/features/checkout/domain/entities/checkout_entities.dart';

CheckoutServiceEntity mapCheckoutService(Map<String, dynamic> json) {
  final pricedLater = json['priced_later'] as bool? ?? json['price_cny'] == null;
  final rawPrice = json['price_cny'];

  return CheckoutServiceEntity(
    id: (json['id'] as num).toInt(),
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String? ?? '',
    descriptionAr: json['description_ar'] as String? ?? '',
    descriptionEn: json['description_en'] as String? ?? '',
    isRequired: json['is_required'] as bool? ?? false,
    pricedLater: pricedLater,
    priceCny: pricedLater || rawPrice == null ? null : (rawPrice as num).toDouble(),
  );
}

ShippingOptionEntity mapShippingOption(Map<String, dynamic> json) {
  return ShippingOptionEntity(
    shippingLineId: (json['shipping_line_id'] as num).toInt(),
    methodCode: json['method_code'] as String? ?? '',
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String? ?? '',
    minDays: (json['min_days'] as num?)?.toInt() ?? 0,
    maxDays: (json['max_days'] as num?)?.toInt() ?? 0,
    estimatedChargeCny: (json['estimated_charge_cny'] as num).toDouble(),
  );
}

PaymentMethodEntity mapPaymentMethod(Map<String, dynamic> json) {
  return PaymentMethodEntity(
    code: json['code'] as String? ?? 'cod',
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String? ?? '',
    flow: json['flow'] as String? ?? 'one_step',
    subtitleAr: json['subtitle_ar'] as String? ?? '',
    subtitleEn: json['subtitle_en'] as String? ?? '',
    descriptionAr: json['description_ar'] as String? ?? '',
    descriptionEn: json['description_en'] as String? ?? '',
    imageUrl: json['image_url'] as String?,
  );
}

CheckoutPreviewEntity mapCheckoutPreview(Map<String, dynamic> json) {
  final servicesRaw = json['services'] as List<dynamic>? ?? const [];
  final shipping = json['shipping'] as Map<String, dynamic>? ?? const {};

  return CheckoutPreviewEntity(
    itemsSubtotalCny: (json['items_subtotal_cny'] as num?)?.toDouble() ?? 0,
    servicesSubtotalCny: (json['services_subtotal_cny'] as num?)?.toDouble() ?? 0,
    shippingChargeCny: (shipping['estimated_charge_cny'] as num?)?.toDouble() ?? 0,
    grandTotalCny: (json['grand_total_cny'] as num?)?.toDouble() ?? 0,
    grandTotalYer: (json['grand_total_yer'] as num?)?.toDouble() ?? 0,
    services: servicesRaw
        .map((e) => mapCheckoutService(e as Map<String, dynamic>))
        .toList(),
    shippingNameAr: shipping['name_ar'] as String? ?? '',
    shippingMinDays: (shipping['min_days'] as num?)?.toInt() ?? 0,
    shippingMaxDays: (shipping['max_days'] as num?)?.toInt() ?? 0,
  );
}

PlacedOrderEntity mapPlacedOrder(Map<String, dynamic> json) {
  return PlacedOrderEntity(
    id: (json['id'] as num).toInt(),
    number: json['number'] as String? ?? '',
    grandTotalYer: (json['grand_total_yer'] as num?)?.toDouble() ?? 0,
  );
}
