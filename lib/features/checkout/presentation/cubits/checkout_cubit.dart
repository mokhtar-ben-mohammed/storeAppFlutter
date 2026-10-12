import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:store/features/checkout/presentation/checkout_args.dart';
import 'package:store/features/checkout/presentation/cubits/checkout_state.dart';
import 'package:store/features/addresses/domain/entities/user_address_entity.dart';
import 'package:store/features/addresses/domain/repositories/address_repository.dart';
import 'package:store/features/checkout/presentation/models/checkout_address_form.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';
import 'package:store/features/geography/domain/repositories/geography_repository.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required this.checkoutRepository,
    required this.geographyRepository,
    required this.addressRepository,
  }) : super(const CheckoutInitial());

  final CheckoutRepository checkoutRepository;
  final GeographyRepository geographyRepository;
  final AddressRepository addressRepository;

  Future<void> initialize(CheckoutArgs args) async {
    emit(const CheckoutLoading());

    final countriesResult = await geographyRepository.getCountries();
    if (countriesResult.isFailure) {
      emit(CheckoutFailure(countriesResult.failureOrNull!));
      return;
    }

    final countries = countriesResult.dataOrNull ?? const <CountryEntity>[];
    CountryEntity? country;
    for (final c in countries) {
      if (c.iso2.toUpperCase() == 'YE') {
        country = c;
        break;
      }
    }
    country ??= countries.isNotEmpty ? countries.first : null;
    if (country == null) {
      emit(const CheckoutFailure(ServerFailure('تعذر تحميل بيانات الدولة')));
      return;
    }

    final citiesResult = await geographyRepository.getCities(country.id);
    final cities = citiesResult.dataOrNull ?? const [];

    final servicesResult = await checkoutRepository.getRequiredServices();
    final shippingResult = await checkoutRepository.getShippingOptions(
      countryId: country.id,
      estimatedUnits: args.estimatedUnits,
    );
    final paymentResult = await checkoutRepository.getPaymentMethods();

    final failure = servicesResult.failureOrNull ??
        shippingResult.failureOrNull ??
        paymentResult.failureOrNull;
    if (failure != null) {
      emit(CheckoutFailure(failure));
      return;
    }

    final services = servicesResult.dataOrNull ?? const [];
    final shippingOptions = shippingResult.dataOrNull ?? const [];
    final paymentMethods = paymentResult.dataOrNull ?? const [];
    final addressesResult = await addressRepository.list();
    final addresses = addressesResult.dataOrNull ?? const <UserAddressEntity>[];
    UserAddressEntity? defaultAddress;
    for (final address in addresses) {
      if (address.isDefault) {
        defaultAddress = address;
        break;
      }
    }
    defaultAddress ??= addresses.isNotEmpty ? addresses.first : null;

    emit(
      CheckoutReady(
        step: 0,
        selectedItemIds: args.selectedItemIds,
        items: args.items,
        services: services,
        shippingOptions: shippingOptions,
        paymentMethods: paymentMethods,
        country: country,
        cities: cities,
        selectedShippingLineId:
            shippingOptions.isNotEmpty ? shippingOptions.first.shippingLineId : null,
        selectedExtraServiceIds: [
          for (final service in services)
            if (service.isRequired) service.id,
        ],
        selectedPaymentCode: paymentMethods.isNotEmpty ? paymentMethods.first.code : null,
        address: defaultAddress == null
            ? const CheckoutAddressForm()
            : CheckoutAddressForm.fromEntity(defaultAddress),
      ),
    );
  }

  void selectSavedAddress(UserAddressEntity address) {
    final current = state;
    if (current is! CheckoutReady) return;
    emit(
      current.copyWith(
        address: CheckoutAddressForm.fromEntity(address),
        fieldErrors: const {},
        clearSubmitError: true,
      ),
    );
  }

  void goToStep(int step) {
    final current = state;
    if (current is! CheckoutReady) return;
    final maxStep = current.preview != null ? 3 : current.step;
    if (step < 0 || step > maxStep) return;
    emit(current.copyWith(step: step, clearSubmitError: true));
  }

  void nextStep() {
    final current = state;
    if (current is! CheckoutReady) return;
    if (current.step == 1 && current.selectedShippingLineId == null) {
      emit(current.copyWith(submitError: 'اختر طريقة الشحن'));
      return;
    }
    if (current.step == 2) {
      final errors = current.address.validate();
      if (errors.isNotEmpty) {
        emit(current.copyWith(fieldErrors: errors));
        return;
      }
      if (current.selectedPaymentCode == null) {
        emit(current.copyWith(submitError: 'اختر طريقة الدفع'));
        return;
      }
      _loadPreview(current);
      return;
    }
    emit(current.copyWith(step: current.step + 1, clearSubmitError: true));
  }

  void previousStep() {
    final current = state;
    if (current is! CheckoutReady || current.step == 0) return;
    emit(current.copyWith(step: current.step - 1, clearSubmitError: true));
  }

  void selectShipping(int shippingLineId) {
    final current = state;
    if (current is! CheckoutReady) return;
    emit(
      current.copyWith(
        selectedShippingLineId: shippingLineId,
        clearSubmitError: true,
        clearPreview: true,
      ),
    );
  }

  void toggleOptionalService(int serviceId) {
    final current = state;
    if (current is! CheckoutReady) return;
    final service = current.services.where((item) => item.id == serviceId);
    if (service.isEmpty || service.first.isRequired) return;

    final selected = [...current.selectedExtraServiceIds];
    if (selected.contains(serviceId)) {
      selected.remove(serviceId);
    } else {
      selected.add(serviceId);
    }
    emit(
      current.copyWith(
        selectedExtraServiceIds: selected,
        clearSubmitError: true,
        clearPreview: true,
      ),
    );
  }

  void selectPayment(String code) {
    final current = state;
    if (current is! CheckoutReady) return;
    emit(current.copyWith(selectedPaymentCode: code, clearSubmitError: true));
  }

  void updateAddress(CheckoutAddressForm address) {
    final current = state;
    if (current is! CheckoutReady) return;
    emit(current.copyWith(address: address, fieldErrors: const {}));
  }

  Future<void> _loadPreview(CheckoutReady current) async {
    emit(current.copyWith(isSubmitting: true, clearSubmitError: true));
    final shippingId = current.selectedShippingLineId;
    if (shippingId == null) return;

    final result = await checkoutRepository.preview(
      cartItemIds: current.selectedItemIds,
      shippingLineId: shippingId,
      countryId: current.country.id,
      extraServiceIds: current.selectedExtraServiceIds,
    );

    result.fold(
      onSuccess: (preview) => emit(
        current.copyWith(
          preview: preview,
          step: 3,
          isSubmitting: false,
        ),
      ),
      onFailure: (failure) => emit(
        current.copyWith(
          isSubmitting: false,
          submitError: failure.message,
        ),
      ),
    );
  }

  Future<void> placeOrder() async {
    final current = state;
    if (current is! CheckoutReady || current.preview == null) return;

    emit(current.copyWith(isSubmitting: true, clearSubmitError: true));
    final shippingId = current.selectedShippingLineId;
    final addressId = current.address.userAddressId;
    final paymentCode = current.selectedPaymentCode;
    if (shippingId == null || addressId == null || paymentCode == null) return;

    final result = await checkoutRepository.placeOrder(
      cartItemIds: current.selectedItemIds,
      shippingLineId: shippingId,
      paymentMethod: paymentCode,
      userAddressId: addressId,
      extraServiceIds: current.selectedExtraServiceIds,
    );

    result.fold(
      onSuccess: (order) => emit(CheckoutOrderPlaced(order)),
      onFailure: (failure) => emit(
        current.copyWith(
          isSubmitting: false,
          submitError: failure.message,
        ),
      ),
    );
  }
}
