import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/presentation/widgets/auth_picker_sheet.dart';
import 'package:store/features/geography/domain/entities/city_entity.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';
import 'package:store/features/geography/domain/usecases/get_cities_usecase.dart';
import 'package:store/features/platform/domain/entities/content_page_entity.dart';
import 'package:store/features/platform/domain/usecases/get_content_pages_usecase.dart';

/// Registration extras: name, residence country/city, gender, policies.
/// Shows shimmer until countries + cities + policies are fully loaded.
class RegisterExtrasPanel extends StatefulWidget {
  const RegisterExtrasPanel({
    super.key,
    required this.countries,
    required this.enabled,
    required this.nameController,
    required this.selectedCountryId,
    required this.selectedCityId,
    required this.selectedGender,
    required this.acceptedPolicies,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onGenderChanged,
    required this.onPolicyToggled,
  });

  final List<CountryEntity> countries;
  final bool enabled;
  final TextEditingController nameController;
  final int? selectedCountryId;
  final int? selectedCityId;
  final String selectedGender;
  final Set<String> acceptedPolicies;
  final ValueChanged<CountryEntity> onCountryChanged;
  final ValueChanged<int?> onCityChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onPolicyToggled;

  @override
  State<RegisterExtrasPanel> createState() => RegisterExtrasPanelState();
}

class RegisterExtrasPanelState extends State<RegisterExtrasPanel> {
  List<CityEntity> _cities = const [];
  List<ContentPageEntity> _consentPages = const [];
  bool _loading = true;
  bool _loadingCities = false;
  String? _loadError;

  CountryEntity? get _selectedCountry {
    final id = widget.selectedCountryId;
    if (id == null) return null;
    for (final c in widget.countries) {
      if (c.id == id) return c;
    }
    return widget.countries.isNotEmpty ? widget.countries.first : null;
  }

  CityEntity? get _selectedCity {
    final id = widget.selectedCityId;
    if (id == null) return null;
    for (final c in _cities) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant RegisterExtrasPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCountryId != widget.selectedCountryId) {
      _loadCities(widget.selectedCountryId, resetSelection: true);
    }
    if (oldWidget.countries != widget.countries && widget.countries.isNotEmpty) {
      final current = _selectedCountry;
      if (current == null) {
        widget.onCountryChanged(widget.countries.first);
      }
    }
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    final pagesResult = await sl<GetContentPagesUseCase>()(const NoParams());
    if (!mounted) return;

    pagesResult.fold(
      onSuccess: (pages) {
        _consentPages = pages.where((p) => p.requiresConsent).toList();
      },
      onFailure: (f) => _loadError = f.message,
    );

    var country = _selectedCountry;
    if (country == null && widget.countries.isNotEmpty) {
      country = widget.countries.first;
      widget.onCountryChanged(country);
    }

    await _loadCities(country?.id, resetSelection: widget.selectedCityId == null);

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadCities(int? countryId, {required bool resetSelection}) async {
    if (countryId == null) {
      setState(() => _cities = const []);
      return;
    }

    setState(() => _loadingCities = true);
    final citiesResult = await sl<GetCitiesUseCase>()(GetCitiesParams(countryId));
    if (!mounted) return;

    citiesResult.fold(
      onSuccess: (cities) {
        setState(() {
          _cities = cities;
          _loadingCities = false;
        });
        if (cities.isEmpty) {
          widget.onCityChanged(null);
          return;
        }
        final stillValid = cities.any((c) => c.id == widget.selectedCityId);
        if (resetSelection || !stillValid) {
          widget.onCityChanged(cities.first.id);
        }
      },
      onFailure: (f) {
        setState(() {
          _cities = const [];
          _loadingCities = false;
          _loadError = f.message;
        });
        widget.onCityChanged(null);
      },
    );
  }

  Future<void> _pickCountry() async {
    final selected = await showAuthPickerSheet<CountryEntity>(
      context: context,
      title: 'اختر الدولة',
      icon: Icons.public_rounded,
      items: widget.countries,
      selected: _selectedCountry,
      labelOf: (c) => c.nameAr,
      trailingOf: (c) => c.dialCode,
      leadingEmojiOf: (c) => authFlagFromIso2(c.iso2),
      equals: (a, b) => a.id == b.id,
    );
    if (selected != null) {
      widget.onCountryChanged(selected);
    }
  }

  Future<void> _pickCity() async {
    if (_cities.isEmpty) return;
    final selected = await showAuthPickerSheet<CityEntity>(
      context: context,
      title: 'اختر المدينة',
      icon: Icons.location_city_rounded,
      items: _cities,
      selected: _selectedCity,
      labelOf: (c) => c.nameAr,
      trailingOf: (_) => '',
      equals: (a, b) => a.id == b.id,
    );
    if (selected != null) {
      widget.onCityChanged(selected.id);
    }
  }

  void _openPolicySheet(ContentPageEntity page) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: BurhanColors.slate300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    page.titleAr,
                    style: BurhanTypography.titleLarge.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (page.bodyAr?.trim().isNotEmpty ?? false)
                        ? page.bodyAr!
                        : 'سيتم تحديث محتوى هذه الصفحة قريباً من لوحة التحكم.',
                    style: BurhanTypography.bodyMedium.copyWith(
                      fontSize: 13,
                      height: 1.6,
                      color: BurhanColors.slate700,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String? validate() {
    if (widget.nameController.text.trim().isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }
    if (widget.selectedCountryId == null) {
      return 'يرجى اختيار الدولة';
    }
    if (widget.selectedCityId == null) {
      return 'يرجى اختيار المدينة';
    }
    for (final page in _consentPages) {
      if (!widget.acceptedPolicies.contains(page.slug)) {
        return 'يجب الموافقة على ${page.titleAr}';
      }
    }
    return null;
  }

  Widget _shimmerBlock({double height = 50}) {
    return Shimmer.fromColors(
      baseColor: BurhanColors.slate100,
      highlightColor: Colors.white,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: BurhanColors.slate100,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _shimmerBlock(height: 16),
        const SizedBox(height: 8),
        _shimmerBlock(),
        const SizedBox(height: 14),
        _shimmerBlock(height: 16),
        const SizedBox(height: 8),
        _shimmerBlock(),
        const SizedBox(height: 14),
        _shimmerBlock(height: 16),
        const SizedBox(height: 8),
        _shimmerBlock(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _shimmerBlock(height: 44)),
            const SizedBox(width: 8),
            Expanded(child: _shimmerBlock(height: 44)),
          ],
        ),
        const SizedBox(height: 14),
        _shimmerBlock(height: 24),
        const SizedBox(height: 8),
        _shimmerBlock(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || widget.countries.isEmpty) {
      return _buildShimmer();
    }

    final country = _selectedCountry;
    final city = _selectedCity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loadError != null) ...[
          Text(
            _loadError!,
            style: BurhanTypography.bodySmall.copyWith(color: BurhanColors.rose500),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          'الاسم الكامل',
          style: BurhanTypography.titleSmall.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.nameController,
          enabled: widget.enabled,
          textInputAction: TextInputAction.next,
          style: BurhanTypography.bodyMedium.copyWith(
            fontSize: 14,
            color: BurhanColors.slate900,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'مثال: أحمد محمد',
            filled: true,
            fillColor: BurhanColors.slate50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: BurhanColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: BurhanColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: BurhanColors.primary, width: 1.6),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AuthSheetField(
          label: 'الدولة',
          enabled: widget.enabled,
          valueText: country?.nameAr ?? 'اختر الدولة',
          leading: Text(
            authFlagFromIso2(country?.iso2 ?? ''),
            style: const TextStyle(fontSize: 18),
          ),
          onTap: _pickCountry,
        ),
        const SizedBox(height: 14),
        if (_loadingCities)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'المدينة',
                style: BurhanTypography.titleSmall.copyWith(fontSize: 12.5),
              ),
              const SizedBox(height: 8),
              _shimmerBlock(),
            ],
          )
        else
          AuthSheetField(
            label: 'المدينة',
            enabled: widget.enabled && _cities.isNotEmpty,
            valueText: city?.nameAr ??
                (_cities.isEmpty ? 'لا توجد مدن لهذه الدولة' : 'اختر المدينة'),
            leading: const Icon(
              Icons.location_city_rounded,
              size: 18,
              color: BurhanColors.slate500,
            ),
            onTap: _pickCity,
          ),
        const SizedBox(height: 14),
        Text(
          'الجنس',
          style: BurhanTypography.titleSmall.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderChip(
                label: 'ذكر',
                selected: widget.selectedGender == 'male',
                onTap: widget.enabled ? () => widget.onGenderChanged('male') : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GenderChip(
                label: 'أنثى',
                selected: widget.selectedGender == 'female',
                onTap: widget.enabled ? () => widget.onGenderChanged('female') : null,
              ),
            ),
          ],
        ),
        if (_consentPages.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._consentPages.map((page) {
            final accepted = widget.acceptedPolicies.contains(page.slug);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: accepted,
              activeColor: BurhanColors.primary,
              onChanged: widget.enabled
                  ? (_) => widget.onPolicyToggled(page.slug)
                  : null,
              controlAffinity: ListTileControlAffinity.leading,
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'أوافق على ',
                    style: BurhanTypography.bodySmall.copyWith(fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () => _openPolicySheet(page),
                    child: Text(
                      page.titleAr,
                      style: BurhanTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: BurhanColors.primary,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? BurhanColors.primary.withValues(alpha: 0.08)
              : BurhanColors.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? BurhanColors.primary : BurhanColors.slate200,
          ),
        ),
        child: Text(
          label,
          style: BurhanTypography.titleSmall.copyWith(
            color: selected ? BurhanColors.primary : BurhanColors.slate700,
          ),
        ),
      ),
    );
  }
}
