import 'package:equatable/equatable.dart';

class CheckoutServiceEntity extends Equatable {
  const CheckoutServiceEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.isRequired,
    required this.pricedLater,
    this.priceCny,
  });

  final int id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final bool isRequired;
  final bool pricedLater;
  final double? priceCny;

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        descriptionAr,
        descriptionEn,
        isRequired,
        pricedLater,
        priceCny,
      ];
}

class ShippingOptionEntity extends Equatable {
  const ShippingOptionEntity({
    required this.shippingLineId,
    required this.methodCode,
    required this.nameAr,
    required this.nameEn,
    required this.minDays,
    required this.maxDays,
    required this.estimatedChargeCny,
  });

  final int shippingLineId;
  final String methodCode;
  final String nameAr;
  final String nameEn;
  final int minDays;
  final int maxDays;
  final double estimatedChargeCny;

  @override
  List<Object?> get props =>
      [shippingLineId, methodCode, nameAr, nameEn, minDays, maxDays, estimatedChargeCny];
}

class PaymentMethodEntity extends Equatable {
  const PaymentMethodEntity({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.flow,
    this.subtitleAr = '',
    this.subtitleEn = '',
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.imageUrl,
  });

  final String code;
  final String nameAr;
  final String nameEn;
  final String flow;
  final String subtitleAr;
  final String subtitleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String? imageUrl;

  bool get isTwoStep => flow == 'two_step';

  @override
  List<Object?> get props => [
        code,
        nameAr,
        nameEn,
        flow,
        subtitleAr,
        subtitleEn,
        descriptionAr,
        descriptionEn,
        imageUrl,
      ];
}

class CheckoutPreviewEntity extends Equatable {
  const CheckoutPreviewEntity({
    required this.itemsSubtotalCny,
    required this.servicesSubtotalCny,
    required this.shippingChargeCny,
    required this.grandTotalCny,
    required this.grandTotalYer,
    required this.services,
    required this.shippingNameAr,
    required this.shippingMinDays,
    required this.shippingMaxDays,
  });

  final double itemsSubtotalCny;
  final double servicesSubtotalCny;
  final double shippingChargeCny;
  final double grandTotalCny;
  final double grandTotalYer;
  final List<CheckoutServiceEntity> services;
  final String shippingNameAr;
  final int shippingMinDays;
  final int shippingMaxDays;

  @override
  List<Object?> get props => [
        itemsSubtotalCny,
        servicesSubtotalCny,
        shippingChargeCny,
        grandTotalCny,
        grandTotalYer,
        services,
        shippingNameAr,
        shippingMinDays,
        shippingMaxDays,
      ];
}

class PlacedOrderEntity extends Equatable {
  const PlacedOrderEntity({
    required this.id,
    required this.number,
    required this.grandTotalYer,
  });

  final int id;
  final String number;
  final double grandTotalYer;

  @override
  List<Object?> get props => [id, number, grandTotalYer];
}
