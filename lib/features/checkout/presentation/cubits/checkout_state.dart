import 'package:equatable/equatable.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:store/features/checkout/domain/entities/checkout_entities.dart';
import 'package:store/features/checkout/presentation/models/checkout_address_form.dart';
import 'package:store/features/geography/domain/entities/city_entity.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutReady extends CheckoutState {
  const CheckoutReady({
    required this.step,
    required this.selectedItemIds,
    required this.items,
    required this.services,
    required this.shippingOptions,
    required this.paymentMethods,
    required this.country,
    required this.cities,
    this.selectedShippingLineId,
    this.selectedExtraServiceIds = const [],
    this.selectedPaymentCode,
    this.address = const CheckoutAddressForm(),
    this.preview,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.submitError,
  });

  final int step;
  final List<int> selectedItemIds;
  final List<CartItemEntity> items;
  final List<CheckoutServiceEntity> services;
  final List<ShippingOptionEntity> shippingOptions;
  final List<PaymentMethodEntity> paymentMethods;
  final CountryEntity country;
  final List<CityEntity> cities;
  final int? selectedShippingLineId;
  final List<int> selectedExtraServiceIds;
  final String? selectedPaymentCode;
  final CheckoutAddressForm address;
  final CheckoutPreviewEntity? preview;
  final Map<String, String> fieldErrors;
  final bool isSubmitting;
  final String? submitError;

  ShippingOptionEntity? get selectedShipping {
    if (selectedShippingLineId == null) return null;
    for (final option in shippingOptions) {
      if (option.shippingLineId == selectedShippingLineId) return option;
    }
    return null;
  }

  PaymentMethodEntity? get selectedPayment {
    if (selectedPaymentCode == null) return null;
    for (final method in paymentMethods) {
      if (method.code == selectedPaymentCode) return method;
    }
    return null;
  }

  CheckoutReady copyWith({
    int? step,
    List<CheckoutServiceEntity>? services,
    List<ShippingOptionEntity>? shippingOptions,
    List<PaymentMethodEntity>? paymentMethods,
    List<CityEntity>? cities,
    int? selectedShippingLineId,
    List<int>? selectedExtraServiceIds,
    String? selectedPaymentCode,
    CheckoutAddressForm? address,
    CheckoutPreviewEntity? preview,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
    String? submitError,
    bool clearPreview = false,
    bool clearSubmitError = false,
  }) {
    return CheckoutReady(
      step: step ?? this.step,
      selectedItemIds: selectedItemIds,
      items: items,
      services: services ?? this.services,
      shippingOptions: shippingOptions ?? this.shippingOptions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      country: country,
      cities: cities ?? this.cities,
      selectedShippingLineId: selectedShippingLineId ?? this.selectedShippingLineId,
      selectedExtraServiceIds: selectedExtraServiceIds ?? this.selectedExtraServiceIds,
      selectedPaymentCode: selectedPaymentCode ?? this.selectedPaymentCode,
      address: address ?? this.address,
      preview: clearPreview ? null : (preview ?? this.preview),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props => [
        step,
        selectedItemIds,
        items,
        services,
        shippingOptions,
        paymentMethods,
        country,
        cities,
        selectedShippingLineId,
        selectedExtraServiceIds,
        selectedPaymentCode,
        address,
        preview,
        fieldErrors,
        isSubmitting,
        submitError,
      ];
}

class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class CheckoutOrderPlaced extends CheckoutState {
  const CheckoutOrderPlaced(this.order);

  final PlacedOrderEntity order;

  @override
  List<Object?> get props => [order];
}
