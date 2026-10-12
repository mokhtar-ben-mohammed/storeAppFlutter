import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:store/features/checkout/domain/entities/checkout_entities.dart';
import 'package:store/features/checkout/presentation/checkout_args.dart';
import 'package:store/features/addresses/domain/repositories/address_repository.dart';
import 'package:store/features/addresses/presentation/cubits/addresses_cubit.dart';
import 'package:store/features/addresses/presentation/sheets/address_list_sheet.dart';
import 'package:store/features/checkout/presentation/cubits/checkout_cubit.dart';
import 'package:store/features/checkout/presentation/cubits/checkout_state.dart';
import 'package:store/features/orders/presentation/cubits/orders_cubit.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key, required this.args});

  final CheckoutArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CheckoutCubit>()..initialize(args),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  static const _stepTitles = [
    'المنتجات المحددة',
    'الخدمات والشحن',
    'عنوان التسليم',
    'مراجعة وتأكيد',
  ];

  String _formatPrice(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutOrderPlaced) {
          sl<CartCubit>().load();
          sl<OrdersCubit>().load();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إنشاء الطلب ${state.order.number} بنجاح',
                style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
              ),
              backgroundColor: BurhanColors.emerald500,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'طلباتي',
                textColor: Colors.white,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: BurhanColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onPressed: () {
                  if (state is CheckoutReady && state.step > 0) {
                    context.read<CheckoutCubit>().previousStep();
                  } else {
                    context.pop();
                  }
                },
              ),
              title: Text(
                'إكمال الشراء',
                style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w900),
              ),
              centerTitle: true,
            ),
            body: switch (state) {
              CheckoutInitial() || CheckoutLoading() => const Center(
                  child: CircularProgressIndicator(color: BurhanColors.primary),
                ),
              CheckoutFailure(:final failure) => Center(
                  child: Text(failure.message, style: BurhanTypography.bodyMedium),
                ),
              CheckoutReady() => _buildReady(context, state),
              CheckoutOrderPlaced() => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }

  Widget _buildReady(BuildContext context, CheckoutReady state) {
    return Column(
      children: [
        _buildStepHeader(context, state),
        if (state.submitError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(
              state.submitError!,
              style: BurhanTypography.caption.copyWith(color: BurhanColors.rose500),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
            child: switch (state.step) {
              0 => _buildProductsStep(state),
              1 => _buildServicesShippingStep(context, state),
              2 => _buildAddressStep(context, state),
              _ => _buildReviewStep(state),
            },
          ),
        ),
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildStepHeader(BuildContext context, CheckoutReady state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BurhanColors.slate200),
      ),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final active = index == state.step;
          final done = index < state.step;
          final maxStep = state.preview != null ? 3 : state.step;
          final tappable = index <= maxStep && index != state.step;
          return Expanded(
            child: InkWell(
              onTap: tappable ? () => context.read<CheckoutCubit>().goToStep(index) : null,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: done || active ? BurhanColors.primary : BurhanColors.slate200,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: done || active ? Colors.white : BurhanColors.slate600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stepTitles[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BurhanTypography.caption.copyWith(
                      fontSize: 8.5,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active ? BurhanColors.primary : BurhanColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductsStep(CheckoutReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملخص المنتجات (${state.items.length})',
          style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...state.items.map((item) {
          final image = item.product.images.isNotEmpty ? item.product.images.first : null;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BurhanColors.slate200),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: image != null
                        ? CachedNetworkImage(imageUrl: image, fit: BoxFit.cover)
                        : const ColoredBox(color: BurhanColors.slate100),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: BurhanTypography.titleSmall.copyWith(fontSize: 12),
                      ),
                      Text(
                        '${item.selectedVariant.name} · الكمية ${item.quantity}',
                        style: BurhanTypography.caption.copyWith(color: BurhanColors.slate500),
                      ),
                    ],
                  ),
                ),
                Text(
                  '¥${item.totalPriceCny.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: BurhanColors.primary),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _servicePriceLabel(CheckoutServiceEntity service) {
    if (service.pricedLater || service.priceCny == null) {
      return 'يُسعَّر لاحقاً';
    }
    return '¥${service.priceCny!.toStringAsFixed(0)}';
  }

  Widget _buildServicesShippingStep(BuildContext context, CheckoutReady state) {
    final requiredServices = state.services.where((s) => s.isRequired).toList();
    final optionalServices = state.services.where((s) => !s.isRequired).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requiredServices.isNotEmpty) ...[
          Text('الخدمات الإلزامية', style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...requiredServices.map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BurhanColors.amber.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BurhanColors.amber.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.nameAr, style: BurhanTypography.titleSmall.copyWith(fontSize: 12)),
                        if (s.descriptionAr.isNotEmpty)
                          Text(
                            s.descriptionAr,
                            style: BurhanTypography.caption.copyWith(fontSize: 10.5, color: BurhanColors.slate600),
                          ),
                      ],
                    ),
                  ),
                  Text(_servicePriceLabel(s), style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
        if (optionalServices.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('خدمات اختيارية', style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...optionalServices.map((s) {
            final selected = state.selectedExtraServiceIds.contains(s.id);
            return InkWell(
              onTap: () => context.read<CheckoutCubit>().toggleOptionalService(s.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? BurhanColors.primary : BurhanColors.slate200,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: selected ? BurhanColors.primary : BurhanColors.slate400,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.nameAr, style: BurhanTypography.titleSmall.copyWith(fontSize: 12)),
                          if (s.descriptionAr.isNotEmpty)
                            Text(
                              s.descriptionAr,
                              style: BurhanTypography.caption.copyWith(fontSize: 10.5, color: BurhanColors.slate600),
                            ),
                        ],
                      ),
                    ),
                    Text(_servicePriceLabel(s), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            );
          }),
        ],
        const SizedBox(height: 16),
        Text('طريقة الشحن', style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...state.shippingOptions.map((option) {
          final selected = state.selectedShippingLineId == option.shippingLineId;
          final isAir = option.methodCode.contains('air') || option.nameAr.contains('جو');
          return InkWell(
            onTap: () => context.read<CheckoutCubit>().selectShipping(option.shippingLineId),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? BurhanColors.primary : BurhanColors.slate200,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isAir ? Icons.flight_takeoff_rounded : Icons.directions_boat_rounded,
                    color: selected ? BurhanColors.primary : BurhanColors.slate500,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.nameAr, style: BurhanTypography.titleSmall.copyWith(fontSize: 12.5)),
                        Text(
                          '${option.minDays}-${option.maxDays} يوم · ¥${option.estimatedChargeCny.toStringAsFixed(0)}',
                          style: BurhanTypography.caption.copyWith(color: BurhanColors.slate500),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: BurhanColors.primary, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _openAddressPicker(BuildContext context, CheckoutReady state) async {
    final cubit = AddressesCubit(repository: sl<AddressRepository>());
    await cubit.load();
    if (!context.mounted) return;
    final selected = await showAddressListSheet(
      context: context,
      cubit: cubit,
      selectedId: state.address.userAddressId,
      selectionMode: true,
    );
    await cubit.close();
    if (selected != null && context.mounted) {
      context.read<CheckoutCubit>().selectSavedAddress(selected);
    }
  }

  Widget _buildAddressStep(BuildContext context, CheckoutReady state) {
    final form = state.address;
    final hasAddress = form.userAddressId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('عنوان التسليم', style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _openAddressPicker(context, state),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: state.fieldErrors['userAddressId'] != null
                    ? BurhanColors.rose500
                    : BurhanColors.slate200,
              ),
            ),
            child: hasAddress
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              form.label.isEmpty ? 'عنوان محفوظ' : form.label,
                              style: BurhanTypography.titleSmall.copyWith(fontSize: 13),
                            ),
                          ),
                          Text(
                            'تغيير',
                            style: BurhanTypography.caption.copyWith(
                              color: BurhanColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        form.addressLine,
                        style: BurhanTypography.caption.copyWith(color: BurhanColors.slate600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if ((form.cityNameAr ?? '').isNotEmpty) form.cityNameAr!,
                          form.recipientPhone,
                        ].where((e) => e.trim().isNotEmpty).join(' · '),
                        style: BurhanTypography.caption.copyWith(color: BurhanColors.slate500),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.add_location_alt_outlined, color: BurhanColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'اختر عنواناً محفوظاً أو أضف عنواناً جديداً',
                          style: BurhanTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: BurhanColors.slate700,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (state.fieldErrors['userAddressId'] != null) ...[
          const SizedBox(height: 6),
          Text(
            state.fieldErrors['userAddressId']!,
            style: BurhanTypography.caption.copyWith(color: BurhanColors.rose500),
          ),
        ],
        const SizedBox(height: 16),
        Text('طريقة الدفع', style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...state.paymentMethods.map((method) {
          final selected = state.selectedPaymentCode == method.code;
          return InkWell(
            onTap: () => context.read<CheckoutCubit>().selectPayment(method.code),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? BurhanColors.emerald50 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? BurhanColors.emerald500.withValues(alpha: 0.4) : BurhanColors.slate200,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: method.imageUrl != null && method.imageUrl!.isNotEmpty
                          ? ColoredBox(
                              color: Colors.white,
                              child: CachedNetworkImage(
                                imageUrl: method.imageUrl!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : ColoredBox(
                              color: selected ? BurhanColors.emerald50 : BurhanColors.slate100,
                              child: Icon(
                                Icons.payments_outlined,
                                color: selected ? BurhanColors.emerald500 : BurhanColors.slate500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(method.nameAr, style: BurhanTypography.titleSmall.copyWith(fontSize: 12.5)),
                        if (method.subtitleAr.isNotEmpty)
                          Text(
                            method.subtitleAr,
                            style: BurhanTypography.caption.copyWith(color: BurhanColors.slate600),
                          )
                        else
                          Text(
                            method.isTwoStep ? 'خطوتان — جاهز للربط لاحقاً' : 'خطوة واحدة',
                            style: BurhanTypography.caption.copyWith(color: BurhanColors.slate600),
                          ),
                        if (method.descriptionAr.isNotEmpty)
                          Text(
                            method.descriptionAr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: BurhanTypography.caption.copyWith(fontSize: 10.5, color: BurhanColors.slate500),
                          ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: BurhanColors.emerald500),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReviewStep(CheckoutReady state) {
    final preview = state.preview;
    if (preview == null) {
      return const Center(child: CircularProgressIndicator(color: BurhanColors.primary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ملخص الفاتورة', style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _reviewRow('المنتجات', '¥${preview.itemsSubtotalCny.toStringAsFixed(2)}'),
        _reviewRow('الخدمات', '¥${preview.servicesSubtotalCny.toStringAsFixed(2)}'),
        _reviewRow('الشحن (${preview.shippingNameAr})', '¥${preview.shippingChargeCny.toStringAsFixed(2)}'),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الإجمالي', style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w900)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_formatPrice(preview.grandTotalYer)} ر.ي',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: BurhanColors.primary,
                  ),
                ),
                Text(
                  '¥${preview.grandTotalCny.toStringAsFixed(2)}',
                  style: BurhanTypography.caption.copyWith(color: BurhanColors.slate500),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'التوصيل المتوقع: ${preview.shippingMinDays}-${preview.shippingMaxDays} يوم',
          style: BurhanTypography.caption.copyWith(color: BurhanColors.slate600),
        ),
        const SizedBox(height: 14),
        Text('عنوان التسليم', style: BurhanTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          [
            if (state.address.label.isNotEmpty) state.address.label,
            state.address.addressLine,
            if ((state.address.cityNameAr ?? '').isNotEmpty) state.address.cityNameAr!,
            state.address.recipientPhone,
          ].where((e) => e.trim().isNotEmpty).join(' · '),
          style: BurhanTypography.caption.copyWith(color: BurhanColors.slate600, height: 1.45),
        ),
        if (state.selectedPayment != null) ...[
          const SizedBox(height: 10),
          Text(
            'الدفع: ${state.selectedPayment!.nameAr}',
            style: BurhanTypography.caption.copyWith(color: BurhanColors.slate600),
          ),
        ],
      ],
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: BurhanTypography.bodySmall.copyWith(color: BurhanColors.slate600)),
          Text(value, style: BurhanTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CheckoutReady state) {
    final isLast = state.step == 3;
    final paymentLabel = state.selectedPayment?.nameAr;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.step >= 1) ...[
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => context.read<CheckoutCubit>().previousStep(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'السابق',
                    style: BurhanTypography.buttonMedium.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: state.step >= 1 ? 2 : 1,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        if (isLast) {
                          context.read<CheckoutCubit>().placeOrder();
                        } else {
                          context.read<CheckoutCubit>().nextStep();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BurhanColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isLast
                            ? (paymentLabel == null ? 'تأكيد الطلب' : 'تأكيد الطلب — $paymentLabel')
                            : 'متابعة',
                        style: BurhanTypography.buttonMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
