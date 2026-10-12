import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/burhan_bottom_sheet.dart';
import 'package:store/features/addresses/domain/entities/user_address_entity.dart';
import 'package:store/features/addresses/presentation/cubits/addresses_cubit.dart';
import 'package:store/features/addresses/presentation/cubits/addresses_state.dart';
import 'package:store/features/addresses/presentation/sheets/address_form_sheet.dart';

Future<UserAddressEntity?> showAddressListSheet({
  required BuildContext context,
  required AddressesCubit cubit,
  int? selectedId,
  bool selectionMode = true,
}) {
  return BurhanBottomSheet.show<UserAddressEntity>(
    context: context,
    title: selectionMode ? 'اختيار عنوان التوصيل' : 'عناوين التوصيل',
    child: BlocProvider.value(
      value: cubit,
      child: _AddressListBody(
        selectedId: selectedId,
        selectionMode: selectionMode,
      ),
    ),
  );
}

class _AddressListBody extends StatefulWidget {
  const _AddressListBody({
    this.selectedId,
    required this.selectionMode,
  });

  final int? selectedId;
  final bool selectionMode;

  @override
  State<_AddressListBody> createState() => _AddressListBodyState();
}

class _AddressListBodyState extends State<_AddressListBody> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<AddressesCubit>();
    if (cubit.state is! AddressesReady) {
      cubit.load();
    }
  }

  Future<void> _addOrEdit({UserAddressEntity? existing}) async {
    final cubit = context.read<AddressesCubit>();
    final saved = await showAddressFormSheet(
      context: context,
      cubit: cubit,
      existing: existing,
    );
    if (saved != null && widget.selectionMode && mounted) {
      Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressesCubit, AddressesState>(
      builder: (context, state) {
        if (state is AddressesLoading || state is AddressesInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AddressesFailure) {
          return Column(
            children: [
              Text(
                state.failure.message,
                style: BurhanTypography.caption.copyWith(color: BurhanColors.rose500),
              ),
              TextButton(
                onPressed: () => context.read<AddressesCubit>().load(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          );
        }
        final ready = state as AddressesReady;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.65,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ready.items.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد عناوين محفوظة بعد.',
                          style: BurhanTypography.caption.copyWith(
                            color: BurhanColors.slate600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: ready.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final address = ready.items[index];
                          final selected = address.id == widget.selectedId;
                          return _AddressCard(
                            address: address,
                            selected: selected,
                            selectionMode: widget.selectionMode,
                            onTap: () {
                              if (widget.selectionMode) {
                                Navigator.of(context).pop(address);
                              }
                            },
                            onEdit: () => _addOrEdit(existing: address),
                            onDefault: () =>
                                context.read<AddressesCubit>().makeDefault(address.id),
                            onDelete: () =>
                                context.read<AddressesCubit>().remove(address.id),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => _addOrEdit(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة عنوان جديد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BurhanColors.primary,
                    side: const BorderSide(color: BurhanColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onEdit,
    required this.onDefault,
    required this.onDelete,
  });

  final UserAddressEntity address;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? BurhanColors.emerald50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? BurhanColors.emerald500.withValues(alpha: 0.45)
                : BurhanColors.slate200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.label,
                    style: BurhanTypography.titleSmall.copyWith(fontSize: 13),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BurhanColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'افتراضي',
                      style: BurhanTypography.caption.copyWith(
                        color: BurhanColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                if (selected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle_rounded, color: BurhanColors.emerald500, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              address.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: BurhanTypography.caption.copyWith(color: BurhanColors.slate600),
            ),
            const SizedBox(height: 2),
            Text(
              address.phone,
              style: BurhanTypography.caption.copyWith(
                fontFamily: 'monospace',
                color: BurhanColors.slate500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: onDefault,
                    child: const Text('تعيين افتراضي'),
                  ),
                TextButton(onPressed: onEdit, child: const Text('تعديل')),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(foregroundColor: BurhanColors.rose500),
                  child: const Text('حذف'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
