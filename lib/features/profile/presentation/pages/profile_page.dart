import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/app/router/main_scaffold.dart';
import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/localization/app_locales.dart';
import 'package:store/core/storage/local_storage_service.dart';
import 'package:store/core/theme/app_theme_mode.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/theme/theme_cubit.dart';
import 'package:store/core/theme/theme_state.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/core/widgets/bottom_nav.dart';
import 'package:store/core/widgets/burhan_bottom_sheet.dart';
import 'package:store/core/widgets/burhan_confirm_sheet.dart';
import 'package:store/core/widgets/profile_menu_tile.dart';
import 'package:store/features/addresses/domain/repositories/address_repository.dart';
import 'package:store/features/addresses/presentation/cubits/addresses_cubit.dart';
import 'package:store/features/addresses/presentation/sheets/address_list_sheet.dart';
import 'package:store/features/authentication/domain/entities/user_entity.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';
import 'package:store/features/chat/presentation/cubits/chat_unread_cubit.dart';
import 'package:store/features/authentication/presentation/widgets/auth_picker_sheet.dart';
import 'package:store/features/finance/domain/entities/currency_entity.dart';
import 'package:store/features/finance/domain/usecases/get_currencies_usecase.dart';
import 'package:store/features/geography/domain/entities/city_entity.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';
import 'package:store/features/geography/domain/usecases/get_cities_usecase.dart';
import 'package:store/features/geography/domain/usecases/get_countries_usecase.dart';
import 'package:store/features/platform/domain/entities/content_page_entity.dart';
import 'package:store/features/platform/domain/repositories/content_page_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// Profile & Account screen matching ProfileScreen.tsx in storeAppUI.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final storage = sl<LocalStorageService>();
    _notificationsEnabled =
        storage.getBool(StorageKeys.notificationsEnabled) ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthCubit>().state;
      if (auth is Authenticated) {
        context.read<AuthCubit>().refreshProfile();
      }
    });
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _requireAuthThen(VoidCallback action) async {
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) {
      action();
      return;
    }
    final goLogin = await BurhanConfirmSheet.show(
      context: context,
      title: 'تسجيل الدخول مطلوب',
      message: 'للوصول إلى إعدادات الحساب يجب تسجيل الدخول أولاً.',
      confirmLabel: 'تسجيل الدخول',
      cancelLabel: 'لاحقاً',
      icon: Icons.lock_outline_rounded,
      accentColor: BurhanColors.primary,
      accentBg: BurhanColors.slate100,
      destructive: false,
    );
    if (goLogin && mounted) {
      context.go('${AppRoutes.login}?mode=login');
    }
  }

  Future<void> _openCurrencySheet(UserEntity? user) async {
    setState(() => _busy = true);
    final result = await sl<GetCurrenciesUseCase>()(const NoParams());
    if (!mounted) return;
    setState(() => _busy = false);

    if (!result.isSuccess) {
      _showToast(result.failureOrNull?.message ?? 'تعذّر تحميل العملات');
      return;
    }

    final currencies = result.dataOrNull ?? const <CurrencyEntity>[];
    final selectedId = user?.currency?.id;

    await BurhanBottomSheet.show<void>(
      context: context,
      title: 'اختر عملة التسوق والعرض',
      child: Column(
        children: currencies.map((currency) {
          final isSelected = selectedId == currency.id;
          return InkWell(
            onTap: () async {
              Navigator.pop(context);
              if (user == null) return;
              if (currency.id == selectedId) return;
              final error = await context.read<AuthCubit>().updateProfile(
                    currencyId: currency.id,
                  );
              if (!mounted) return;
              if (error != null) {
                _showToast(error);
              } else {
                _showToast('تم تغيير العملة إلى ${currency.displayLabel}');
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? BurhanColors.slate100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(currency.flagEmoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.displayLabel,
                          style: BurhanTypography.titleSmall.copyWith(fontSize: 12),
                        ),
                        if (currency.symbol != null && currency.symbol!.isNotEmpty)
                          Text(
                            'الرمز: ${currency.symbol}',
                            style: BurhanTypography.caption.copyWith(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? BurhanColors.primary : BurhanColors.slate300,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _openLanguageSheet() async {
    final current = context.locale.languageCode;
    final options = [
      {'id': 'ar', 'label': 'العربية (Arabic)', 'desc': 'واجهة استخدام عربية كاملة من اليمين لليسار'},
      {'id': 'en', 'label': 'English', 'desc': 'English interface and international layout'},
    ];

    await BurhanBottomSheet.show<void>(
      context: context,
      title: 'لغة واجهة التطبيق',
      child: Column(
        children: options.map((opt) {
          final id = opt['id']!;
          final isSelected = current == id;
          return InkWell(
            onTap: () async {
              Navigator.pop(context);
              final locale = id == 'en' ? AppLocales.english : AppLocales.arabic;
              await context.setLocale(locale);
              await sl<LocalStorageService>().setString(
                StorageKeys.languageCode,
                locale.languageCode,
              );
              if (!mounted) return;
              setState(() {});
              _showToast(id == 'ar' ? 'تم اختيار اللغة العربية' : 'English selected');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? BurhanColors.slate100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt['label']!,
                          style: BurhanTypography.titleSmall.copyWith(fontSize: 12),
                        ),
                        Text(
                          opt['desc']!,
                          style: BurhanTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? BurhanColors.primary : BurhanColors.slate300,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _openThemeSheet() async {
    final themeCubit = context.read<ThemeCubit>();
    final current = themeCubit.state.mode.name;
    final options = [
      {
        'id': 'light',
        'label': 'المظهر الفاتح (Light Mode)',
        'icon': Icons.light_mode_outlined,
        'desc': 'تصميم ناصع وواضح لمختلف ظروف الإضاءة',
      },
      {
        'id': 'dark',
        'label': 'المظهر الداكن (Dark Mode)',
        'icon': Icons.dark_mode_outlined,
        'desc': 'توفير لطاقة البطارية وراحة إضافية للعين',
      },
      {
        'id': 'system',
        'label': 'تلقائي حسب النظام (System Default)',
        'icon': Icons.auto_awesome_rounded,
        'desc': 'يتبع الإعداد المفضل لجهازك الذكي',
      },
    ];

    await BurhanBottomSheet.show<void>(
      context: context,
      title: 'مظهر وثيم التطبيق',
      child: Column(
        children: options.map((opt) {
          final id = opt['id']! as String;
          final isSelected = current == id;
          final icon = opt['icon']! as IconData;
          return InkWell(
            onTap: () async {
              Navigator.pop(context);
              await themeCubit.setThemeMode(AppThemeMode.fromString(id));
              if (!mounted) return;
              _showToast('تم تطبيق ${opt['label']}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? BurhanColors.slate100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: BurhanColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: BurhanColors.slate700),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt['label']! as String,
                          style: BurhanTypography.titleSmall.copyWith(fontSize: 12),
                        ),
                        Text(
                          opt['desc']! as String,
                          style: BurhanTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? BurhanColors.primary : BurhanColors.slate300,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<List<CityEntity>> _loadCitiesForUser(UserEntity user) async {
    final countryId = user.city?.countryId;
    if (countryId != null && countryId > 0) {
      final citiesResult = await sl<GetCitiesUseCase>()(GetCitiesParams(countryId));
      return citiesResult.dataOrNull ?? const [];
    }

    final countriesResult = await sl<GetCountriesUseCase>()(const NoParams());
    final countries = countriesResult.dataOrNull ?? const <CountryEntity>[];
    final yemen = countries.cast<CountryEntity?>().firstWhere(
          (c) => c?.iso2.toUpperCase() == 'YE',
          orElse: () => countries.isNotEmpty ? countries.first : null,
        );
    if (yemen == null) return const [];

    final citiesResult = await sl<GetCitiesUseCase>()(GetCitiesParams(yemen.id));
    return citiesResult.dataOrNull ?? const [];
  }

  Future<void> _openEditProfileSheet(UserEntity user) async {
    setState(() => _busy = true);
    final cities = await _loadCitiesForUser(user);
    if (!mounted) return;
    setState(() => _busy = false);

    final nameController = TextEditingController(text: user.name ?? '');
    CityEntity? selectedCity = cities.cast<CityEntity?>().firstWhere(
          (c) => c?.id == user.city?.id,
          orElse: () => cities.isNotEmpty ? cities.first : null,
        );

    await BurhanBottomSheet.show<void>(
      context: context,
      title: 'تعديل بيانات الملف الشخصي',
      child: StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الاسم الكامل',
                style: BurhanTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                style: BurhanTypography.bodyMedium,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: BurhanColors.slate100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: BurhanColors.slate200),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'المدينة',
                style: BurhanTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: cities.isEmpty
                    ? null
                    : () async {
                        final picked = await showAuthPickerSheet<CityEntity>(
                          context: context,
                          title: 'اختر المدينة',
                          icon: Icons.location_city_rounded,
                          items: cities,
                          selected: selectedCity,
                          labelOf: (c) => c.nameAr,
                          trailingOf: (_) => '',
                          equals: (a, b) => a.id == b.id,
                        );
                        if (picked != null) {
                          setSheetState(() => selectedCity = picked);
                        }
                      },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: BurhanColors.slate100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BurhanColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedCity?.nameAr ?? 'اختر المدينة',
                          style: BurhanTypography.bodyMedium,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BurhanColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      _showToast('الاسم مطلوب');
                      return;
                    }
                    Navigator.pop(sheetContext);
                    final error = await context.read<AuthCubit>().updateProfile(
                          name: name,
                          cityId: selectedCity?.id,
                        );
                    if (!mounted) return;
                    if (error != null) {
                      _showToast(error);
                    } else {
                      _showToast('تم تحديث الملف الشخصي');
                    }
                  },
                  child: Text(
                    'حفظ التعديلات',
                    style: BurhanTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await BurhanConfirmSheet.show(
      context: context,
      title: 'تأكيد تسجيل الخروج',
      message: 'هل تريد الخروج من هذا الجهاز؟ يمكنك تسجيل الدخول لاحقاً بنفس الرقم.',
      confirmLabel: 'تسجيل الخروج',
      icon: Icons.logout_rounded,
      accentColor: BurhanColors.amberDark,
      accentBg: BurhanColors.store1688Bg,
      destructive: false,
    );
    if (!confirmed || !mounted) return;
    await context.read<AuthCubit>().logout();
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await BurhanConfirmSheet.show(
      context: context,
      title: 'تأكيد حذف الحساب نهائياً',
      message:
          'هذا الإجراء لا يمكن التراجع عنه بسهولة. سيتم تعطيل حسابك وإلغاء جلساتك على منصة برهان.',
      confirmLabel: 'تأكيد الحذف النهائي',
      icon: Icons.warning_amber_rounded,
    );
    if (!confirmed || !mounted) return;

    final error = await context.read<AuthCubit>().deleteAccount();
    if (!mounted) return;
    if (error != null) {
      _showToast(error);
    } else {
      _showToast('تم تعطيل الحساب بنجاح');
    }
  }

  Future<void> _openExternal(String url, {String? fallbackLabel}) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showToast('الرابط غير صالح');
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      _showToast(fallbackLabel ?? 'تعذّر الفتح — تم نسخ الرابط');
    }
  }

  Future<void> _openContentPage(String slug, {String fallbackTitle = 'محتوى المنصة'}) async {
    setState(() => _busy = true);
    final result = await sl<ContentPageRepository>().getPage(slug);
    if (!mounted) return;
    setState(() => _busy = false);

    if (!result.isSuccess) {
      _showToast(result.failureOrNull?.message ?? 'تعذّر تحميل الصفحة');
      return;
    }

    final page = result.dataOrNull;
    if (page == null) {
      _showToast('الصفحة غير متاحة حالياً');
      return;
    }
    _showContentPageSheet(page, fallbackTitle: fallbackTitle);
  }

  void _showContentPageSheet(
    ContentPageEntity page, {
    String fallbackTitle = 'محتوى المنصة',
  }) {
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
            final body = (page.bodyAr?.trim().isNotEmpty ?? false)
                ? page.bodyAr!
                : 'سيتم تحديث محتوى هذه الصفحة قريباً من لوحة التحكم.';
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
                    page.titleAr.isNotEmpty ? page.titleAr : fallbackTitle,
                    style: BurhanTypography.titleLarge.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
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

  void _openSupportSheet() {
    BurhanBottomSheet.show<void>(
      context: context,
      title: 'خدمة العملاء والمساعدة',
      child: Column(
        children: [
          ProfileMenuTile(
            title: 'واتساب الدعم',
            subtitle: 'تواصل مباشر مع فريق برهان',
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: BurhanColors.emerald600,
            iconBgColor: BurhanColors.emerald50,
            onTap: () {
              Navigator.pop(context);
              _openExternal(
                'https://wa.me/967770000000',
                fallbackLabel: 'تم نسخ رابط واتساب الدعم',
              );
            },
          ),
          ProfileMenuTile(
            title: 'تيليجرام',
            subtitle: 'قناة التحديثات والإشعارات',
            icon: Icons.send_outlined,
            iconColor: BurhanColors.blue500,
            iconBgColor: BurhanColors.blue50,
            onTap: () {
              Navigator.pop(context);
              _openExternal(
                'https://t.me/burhan_platform',
                fallbackLabel: 'تم نسخ رابط تيليجرام',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openDeliveryAddressSheet(UserEntity user) async {
    final cubit = AddressesCubit(repository: sl<AddressRepository>());
    await cubit.load();
    if (!mounted) return;
    await showAddressListSheet(
      context: context,
      cubit: cubit,
      selectionMode: false,
    );
    await cubit.close();
  }


  String _currencyBadge(UserEntity? user) {
    final code = user?.currency?.code;
    if (code == null || code.isEmpty) return '—';
    final flag = switch (code.toUpperCase()) {
      'YER' => '🇾🇪',
      'SAR' => '🇸🇦',
      'USD' => '🇺🇸',
      'CNY' => '🇨🇳',
      _ => '💱',
    };
    return '$flag $code';
  }

  String _themeBadge(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => 'فاتح',
      AppThemeMode.dark => 'داكن',
      AppThemeMode.system => 'تلقائي',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('حسابي', style: BurhanTypography.titleMedium.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final isGuest = authState is GuestBrowsing;
          final user = authState is Authenticated ? authState.session.user : null;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 10, left: 14, right: 14, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserCard(user: user, isGuest: isGuest),
                    const SizedBox(height: 16),
                    _buildSectionHeader('المشتريات والنشاط'),
                    const SizedBox(height: 6),
                    _buildCardGroup([
                      ProfileMenuTile(
                        title: 'سجل طلباتي',
                        subtitle: 'متابعة مسار الشحنات ومراحل التوصيل',
                        icon: Icons.inventory_2_outlined,
                        iconColor: BurhanColors.blue500,
                        iconBgColor: BurhanColors.blue50,
                        onTap: () => MainScaffold.goToTab(context, MainTab.orders),
                      ),
                      ProfileMenuTile(
                        title: 'سلة التسوق والشراء الجزئي',
                        subtitle: 'إدارة المنتجات وتحديد ما تريد شراءه',
                        icon: Icons.shopping_bag_outlined,
                        iconColor: BurhanColors.amberDark,
                        iconBgColor: BurhanColors.store1688Bg,
                        onTap: () => MainScaffold.goToTab(context, MainTab.cart),
                      ),
                      ProfileMenuTile(
                        title: 'المنتجات المفضلة',
                        subtitle: 'المنتجات المحفوظة للطلب لاحقاً',
                        icon: Icons.favorite_border_rounded,
                        iconColor: BurhanColors.rose500,
                        iconBgColor: BurhanColors.rose50,
                        onTap: () => context.push(AppRoutes.favorites),
                      ),
                      ProfileMenuTile(
                        title: 'عناوين التوصيل المسجلة',
                        subtitle: 'إدارة مواقع الاستلام في محافظات اليمن',
                        icon: Icons.location_on_outlined,
                        iconColor: BurhanColors.emerald600,
                        iconBgColor: BurhanColors.emerald50,
                        onTap: () => _requireAuthThen(() {
                          final auth = context.read<AuthCubit>().state;
                          if (auth is Authenticated) {
                            _openDeliveryAddressSheet(auth.session.user);
                          }
                        }),
                      ),
                      ProfileMenuTile(
                        title: 'مركز الإشعارات',
                        subtitle: 'تنبيهات الطلبات والعروض والتنبيهات العامة',
                        icon: Icons.notifications_active_outlined,
                        iconColor: BurhanColors.amberDark,
                        iconBgColor: BurhanColors.store1688Bg,
                        onTap: () => context.push(AppRoutes.notifications),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionHeader('إعدادات التطبيق والمظهر'),
                    const SizedBox(height: 6),
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, themeState) {
                        final langCode = context.locale.languageCode;
                        return _buildCardGroup([
                          ProfileMenuTile(
                            title: 'العملة المعروضة',
                            subtitle: 'تحويل فوري لأسعار المصانع الصينية',
                            icon: Icons.credit_card_outlined,
                            iconColor: BurhanColors.slate700,
                            iconBgColor: BurhanColors.slate100,
                            badgeText: _currencyBadge(user),
                            onTap: () => _requireAuthThen(() => _openCurrencySheet(user)),
                          ),
                          ProfileMenuTile(
                            title: 'لغة التطبيق',
                            subtitle: 'واجهة المستخدم واتجاه العرض',
                            icon: Icons.language_rounded,
                            iconColor: BurhanColors.slate700,
                            iconBgColor: BurhanColors.slate100,
                            badgeText: langCode == 'ar' ? 'العربية' : 'English',
                            onTap: _openLanguageSheet,
                          ),
                          ProfileMenuTile(
                            title: 'المظهر والثيم',
                            subtitle: 'نمط الألوان وراحة العين',
                            icon: themeState.mode == AppThemeMode.dark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            iconColor: BurhanColors.slate700,
                            iconBgColor: BurhanColors.slate100,
                            badgeText: _themeBadge(themeState.mode),
                            onTap: _openThemeSheet,
                          ),
                          ProfileMenuTile(
                            title: 'إشعارات الشحنات والعروض',
                            subtitle: 'تنبيهات حالة الشحن وتصوير الفحص',
                            icon: Icons.notifications_none_rounded,
                            iconColor: BurhanColors.slate700,
                            iconBgColor: BurhanColors.slate100,
                            trailing: Switch(
                              value: _notificationsEnabled,
                              activeThumbColor: BurhanColors.primary,
                              onChanged: (val) async {
                                setState(() => _notificationsEnabled = val);
                                await sl<LocalStorageService>().setBool(
                                  StorageKeys.notificationsEnabled,
                                  val,
                                );
                                _showToast(
                                  val
                                      ? 'تم تفعيل إشعارات الشحن'
                                      : 'تم كتم إشعارات التطبيق مؤقتاً',
                                );
                              },
                            ),
                          ),
                        ]);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('الدعم والضمانات'),
                    const SizedBox(height: 6),
                    _buildCardGroup([
                      BlocBuilder<ChatUnreadCubit, int>(
                        builder: (context, unread) {
                          return ProfileMenuTile(
                            title: 'المحادثات',
                            subtitle: 'تحدث مع دعم الملكة حول طلباتك وشحناتك',
                            icon: Icons.chat_outlined,
                            iconColor: BurhanColors.primary,
                            iconBgColor: BurhanColors.slate100,
                            badgeText: unread > 0 ? '$unread' : null,
                            badgeColor: BurhanColors.rose500,
                            badgeTextColor: Colors.white,
                            onTap: () => _requireAuthThen(
                              () => context.push(AppRoutes.chats),
                            ),
                          );
                        },
                      ),
                      ProfileMenuTile(
                        title: 'دليل عمل منصة برهان',
                        subtitle: 'خطوات الشراء، الفحص، والشحن لبابك',
                        icon: Icons.help_outline_rounded,
                        iconColor: BurhanColors.amberDark,
                        iconBgColor: BurhanColors.store1688Bg,
                        onTap: () => _openContentPage(
                          'about',
                          fallbackTitle: 'دليل عمل منصة برهان',
                        ),
                      ),
                      ProfileMenuTile(
                        title: 'خدمة العملاء والمساعدة',
                        subtitle: 'فريق الدعم المباشر عبر واتساب وتيليجرام',
                        icon: Icons.support_agent_rounded,
                        iconColor: BurhanColors.blue500,
                        iconBgColor: BurhanColors.blue50,
                        onTap: _openSupportSheet,
                      ),
                      ProfileMenuTile(
                        title: 'الضمانات وسياسة الاسترجاع',
                        subtitle: 'فحص عيني 100% واسترداد عند عدم المطابقة',
                        icon: Icons.verified_user_outlined,
                        iconColor: BurhanColors.emerald600,
                        iconBgColor: BurhanColors.emerald50,
                        onTap: () => _openContentPage(
                          'terms',
                          fallbackTitle: 'الضمانات وسياسة الاسترجاع',
                        ),
                      ),
                    ]),
                    if (!isGuest) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader('إدارة الحساب والأمان'),
                      const SizedBox(height: 6),
                      _buildCardGroup([
                        ProfileMenuTile(
                          title: 'تسجيل الخروج',
                          subtitle: 'الخروج من هذا الجهاز أو التبديل لحساب آخر',
                          icon: Icons.logout_rounded,
                          iconColor: BurhanColors.amberDark,
                          iconBgColor: BurhanColors.store1688Bg,
                          onTap: _confirmLogout,
                        ),
                        ProfileMenuTile(
                          title: 'حذف الحساب نهائياً',
                          subtitle: 'تعطيل الحساب ومسح الجلسات من الخوادم',
                          icon: Icons.delete_outline_rounded,
                          iconColor: BurhanColors.rose500,
                          iconBgColor: BurhanColors.rose50,
                          isDestructive: true,
                          onTap: _confirmDeleteAccount,
                        ),
                      ]),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'منصة برهان (Burhan) · الإصدار 2.4.0',
                            style: BurhanTypography.caption.copyWith(
                              color: BurhanColors.slate400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'بوابتك الموثوقة للشراء المباشر من مصانع الصين',
                            style: BurhanTypography.caption.copyWith(
                              color: BurhanColors.slate400,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33FFFFFF),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserCard({required UserEntity? user, required bool isGuest}) {
    if (isGuest || user == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BurhanColors.slate200, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: BurhanColors.slate100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline_rounded, color: BurhanColors.slate500),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تصفح كزائر', style: BurhanTypography.titleSmall.copyWith(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    'سجّل الدخول لإدارة حسابك وطلباتك',
                    style: BurhanTypography.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.go('${AppRoutes.login}?mode=login'),
              style: TextButton.styleFrom(
                backgroundColor: BurhanColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'دخول',
                style: BurhanTypography.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final initial = user.displayName.isNotEmpty ? user.displayName.characters.first : 'ب';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BurhanColors.slate200, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [BurhanColors.primary, BurhanColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: BurhanColors.amber,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -1,
                      right: -1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: BurhanColors.emerald500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: BurhanTypography.titleSmall.copyWith(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: BurhanColors.amber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: BurhanColors.amber.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'موثق',
                              style: BurhanTypography.badge.copyWith(
                                color: BurhanColors.amberDark,
                                fontSize: 8.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.displayPhone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: BurhanColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: BurhanColors.amber,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              'اليمن - ${user.displayCity}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: BurhanTypography.caption.copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _openEditProfileSheet(user),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: BurhanColors.slate100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BurhanColors.slate200),
              ),
              child: const Icon(Icons.edit_outlined, size: 15, color: BurhanColors.slate700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: BurhanTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: BurhanColors.slate500,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BurhanColors.slate200, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: children.length,
        separatorBuilder: (_, _) => const Divider(
          color: BurhanColors.slate100,
          height: 1,
          thickness: 1,
        ),
        itemBuilder: (_, index) => children[index],
      ),
    );
  }
}
