import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/app_text_field.dart';
import 'package:store/core/widgets/burhan_bottom_sheet.dart';
import 'package:store/features/addresses/domain/entities/user_address_entity.dart';
import 'package:store/features/addresses/presentation/cubits/addresses_cubit.dart';
import 'package:store/features/addresses/presentation/sheets/address_location_picker_sheet.dart';
import 'package:store/features/geography/domain/entities/city_entity.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';
import 'package:store/features/geography/domain/repositories/geography_repository.dart';

Future<UserAddressEntity?> showAddressFormSheet({
  required BuildContext context,
  required AddressesCubit cubit,
  UserAddressEntity? existing,
}) {
  return BurhanBottomSheet.show<UserAddressEntity>(
    context: context,
    title: existing == null ? 'إضافة عنوان جديد' : 'تعديل العنوان',
    child: BlocProvider.value(
      value: cubit,
      child: _AddressFormBody(existing: existing),
    ),
  );
}

class _AddressFormBody extends StatefulWidget {
  const _AddressFormBody({this.existing});

  final UserAddressEntity? existing;

  @override
  State<_AddressFormBody> createState() => _AddressFormBodyState();
}

class _AddressFormBodyState extends State<_AddressFormBody> {
  late final TextEditingController _label;
  late final TextEditingController _description;
  late final TextEditingController _phone;
  late UserAddressDraft _draft;
  Map<String, String> _errors = {};
  List<CountryEntity> _countries = const [];
  List<CityEntity> _cities = const [];
  bool _loadingGeo = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _draft = UserAddressDraft(
      label: existing?.label ?? '',
      description: existing?.description ?? '',
      phone: existing?.phone ?? '',
      countryId: existing?.countryId,
      cityId: existing?.cityId,
      latitude: existing?.latitude,
      longitude: existing?.longitude,
      isDefault: existing?.isDefault ?? false,
    );
    _label = TextEditingController(text: _draft.label);
    _description = TextEditingController(text: _draft.description);
    _phone = TextEditingController(text: _draft.phone);
    _loadGeography();
  }

  Future<void> _loadGeography() async {
    final repo = sl<GeographyRepository>();
    final countriesResult = await repo.getCountries();
    final countries = countriesResult.dataOrNull ?? const <CountryEntity>[];
    CountryEntity? country;
    for (final item in countries) {
      if (item.id == _draft.countryId || item.iso2.toUpperCase() == 'YE') {
        country = item;
        if (item.id == _draft.countryId) break;
      }
    }
    country ??= countries.isNotEmpty ? countries.first : null;
    var cities = const <CityEntity>[];
    if (country != null) {
      cities = (await repo.getCities(country.id)).dataOrNull ?? const [];
    }
    if (!mounted) return;
    setState(() {
      _countries = countries;
      _cities = cities;
      _draft = _draft.copyWith(countryId: country?.id);
      _loadingGeo = false;
    });
  }

  Future<void> _onCountryChanged(int? countryId) async {
    if (countryId == null) return;
    setState(() {
      _draft = _draft.copyWith(countryId: countryId, clearCity: true);
      _cities = const [];
    });
    final cities =
        (await sl<GeographyRepository>().getCities(countryId)).dataOrNull ??
            const <CityEntity>[];
    if (!mounted) return;
    setState(() => _cities = cities);
  }

  Future<void> _pickLocation() async {
    final result = await showAddressLocationPickerSheet(
      context: context,
      initialLatitude: _draft.latitude,
      initialLongitude: _draft.longitude,
    );
    if (result == null || !mounted) return;
    setState(() {
      _draft = _draft.copyWith(
        latitude: result.latitude,
        longitude: result.longitude,
      );
    });
  }

  Future<void> _save() async {
    final draft = _draft.copyWith(
      label: _label.text,
      description: _description.text,
      phone: _phone.text,
    );
    final errors = draft.validate();
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _errors = {};
    });
    final cubit = context.read<AddressesCubit>();
    final existing = widget.existing;
    final saved = existing == null
        ? await cubit.create(draft)
        : await cubit.update(existing.id, draft);
    if (!mounted) return;
    if (saved == null) {
      setState(() {
        _saving = false;
        _error = 'تعذر حفظ العنوان. حاول مرة أخرى.';
      });
      return;
    }
    Navigator.of(context).pop(saved);
  }

  @override
  void dispose() {
    _label.dispose();
    _description.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingGeo) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _label,
            label: 'اسم العنوان',
            hint: 'مثل: البيت، العمل',
          ),
          if (_errors['label'] != null) _errorText(_errors['label']!),
          const SizedBox(height: 10),
          AppTextField(
            controller: _description,
            label: 'وصف العنوان',
            hint: 'الحي، الشارع، أقرب معلم',
            maxLines: 3,
          ),
          if (_errors['description'] != null) _errorText(_errors['description']!),
          const SizedBox(height: 10),
          AppTextField(
            controller: _phone,
            label: 'رقم الهاتف',
            keyboardType: TextInputType.phone,
          ),
          if (_errors['phone'] != null) _errorText(_errors['phone']!),
          const SizedBox(height: 10),
          Text('الدولة', style: BurhanTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            initialValue: _draft.countryId,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: _errors['countryId'],
            ),
            items: _countries
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nameAr)))
                .toList(),
            onChanged: _onCountryChanged,
          ),
          const SizedBox(height: 10),
          Text('المدينة', style: BurhanTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            initialValue: _draft.cityId,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: _errors['cityId'],
            ),
            hint: const Text('اختر المدينة'),
            items: _cities
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nameAr)))
                .toList(),
            onChanged: (id) => setState(() => _draft = _draft.copyWith(cityId: id)),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickLocation,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BurhanColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BurhanColors.slate200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, color: BurhanColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _draft.latitude == null
                          ? 'تحديد الموقع على خريطة Google'
                          : 'موقع محدد: ${_draft.latitude!.toStringAsFixed(5)}, ${_draft.longitude!.toStringAsFixed(5)}',
                      style: BurhanTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BurhanColors.slate700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: BurhanColors.slate400),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'تعيين كعنوان افتراضي',
              style: BurhanTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
            value: _draft.isDefault,
            activeThumbColor: BurhanColors.primary,
            onChanged: (value) => setState(() => _draft = _draft.copyWith(isDefault: value)),
          ),
          if (_error != null) ...[
            _errorText(_error!),
            const SizedBox(height: 8),
          ],
          SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BurhanColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'حفظ العنوان',
                      style: BurhanTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: BurhanTypography.caption.copyWith(color: BurhanColors.rose500),
      ),
    );
  }
}
