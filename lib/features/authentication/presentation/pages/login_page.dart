import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/burhan_logo.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';

/// Country model for dial code selection with flags.
class _AuthCountry {
  const _AuthCountry({
    required this.nameAr,
    required this.dialCode,
    required this.flag,
    required this.example,
  });

  final String nameAr;
  final String dialCode;
  final String flag;
  final String example;
}

/// Redesigned login / registration screen reflecting Burhan's brand identity.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.isRegister = false});

  final bool isRegister;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const List<_AuthCountry> _countries = [
    _AuthCountry(nameAr: 'اليمن', dialCode: '+967', flag: '🇾🇪', example: '77XXXXXXX'),
    _AuthCountry(nameAr: 'السعودية', dialCode: '+966', flag: '🇸🇦', example: '50XXXXXXX'),
    _AuthCountry(nameAr: 'الإمارات', dialCode: '+971', flag: '🇦🇪', example: '50XXXXXXX'),
    _AuthCountry(nameAr: 'عُمان', dialCode: '+968', flag: '🇴🇲', example: '9XXXXXXX'),
    _AuthCountry(nameAr: 'مصر', dialCode: '+20', flag: '🇪🇬', example: '10XXXXXXXX'),
    _AuthCountry(nameAr: 'الكويت', dialCode: '+965', flag: '🇰🇼', example: '9XXXXXXX'),
    _AuthCountry(nameAr: 'قطر', dialCode: '+974', flag: '🇶🇦', example: '5XXXXXXX'),
    _AuthCountry(nameAr: 'الصين', dialCode: '+86', flag: '🇨🇳', example: '13XXXXXXXXX'),
  ];

  late bool _isRegisterMode;
  late _AuthCountry _selectedCountry;

  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.isRegister;
    _selectedCountry = _countries.first; // Yemen (+967) default
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _openCountryPickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.58,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: BurhanColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.public_rounded, size: 20, color: BurhanColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'اختر رمز الدولة ورقم الاتصال',
                      style: BurhanTypography.titleSmall.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: BurhanColors.slate200),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _countries.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: BurhanColors.slate100,
                  ),
                  itemBuilder: (context, index) {
                    final item = _countries[index];
                    final isSelected = item.dialCode == _selectedCountry.dialCode;

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCountry = item);
                        Navigator.pop(sheetContext);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? BurhanColors.slate100 : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(item.flag, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.nameAr,
                                style: BurhanTypography.bodyMedium.copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? BurhanColors.primary : BurhanColors.slate800,
                                ),
                              ),
                            ),
                            Text(
                              item.dialCode,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: BurhanColors.slate600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: BurhanColors.primary,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    setState(() => _inlineError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _phoneController.text.trim();
    context.read<AuthCubit>().sendOtp(
          countryCode: _selectedCountry.dialCode,
          phone: phone,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            context.push(
              '${AppRoutes.otp}?phone=${Uri.encodeComponent(state.phone)}'
              '&country_code=${Uri.encodeComponent(state.countryCode)}'
              '&is_register=$_isRegisterMode',
            );
          } else if (state is AuthFailure) {
            setState(() => _inlineError = state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Ambient Decorative Glows
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        BurhanColors.primary.withValues(alpha: 0.08),
                        BurhanColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        BurhanColors.amber.withValues(alpha: 0.08),
                        BurhanColors.amber.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Scrollable Body
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Top Navigation Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (context.canPop())
                            InkWell(
                              onTap: () => context.pop(),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: BurhanColors.slate200),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 13,
                                      color: BurhanColors.slate700,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'رجوع',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: BurhanColors.slate700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 40),

                          // Guest Browsing Pass
                          TextButton.icon(
                            onPressed: () => context.read<AuthCubit>().continueAsGuest(),
                            icon: const Icon(
                              Icons.storefront_outlined,
                              size: 16,
                              color: BurhanColors.primary,
                            ),
                            label: Text(
                              'تصفح كزائر',
                              style: BurhanTypography.titleSmall.copyWith(
                                color: BurhanColors.primary,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Brand Hero Section
                      const BurhanLogo(
                        size: BurhanLogoSize.lg,
                        variant: BurhanLogoVariant.full,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: BurhanColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: BurhanColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          'بوابتك المباشرة للشراء من الصين إلى اليمن 🇾🇪',
                          style: BurhanTypography.caption.copyWith(
                            color: BurhanColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Form Card Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: BurhanColors.slate200.withValues(alpha: 0.8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BurhanColors.primary.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Segmented Tab Switcher (تسجيل الدخول / إنشاء حساب جديد)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: BurhanColors.slate100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _SegmentedTabItem(
                                        title: 'تسجيل الدخول',
                                        isActive: !_isRegisterMode,
                                        onTap: () {
                                          setState(() {
                                            _isRegisterMode = false;
                                            _inlineError = null;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: _SegmentedTabItem(
                                        title: 'إنشاء حساب جديد',
                                        isActive: _isRegisterMode,
                                        onTap: () {
                                          setState(() {
                                            _isRegisterMode = true;
                                            _inlineError = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Contextual Dynamic Headline
                              Text(
                                _isRegisterMode ? 'انضم إلى منصة برهان ✨' : 'مرحباً بعودتك! 👋',
                                style: BurhanTypography.headline.copyWith(
                                  fontSize: 20,
                                  color: BurhanColors.slate900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isRegisterMode
                                    ? 'أنشئ حسابك وتسوّق مباشرة من 1688، تاوباو، وجود فيش مع فحص وضمان برهان حتى باب بيتك.'
                                    : 'أدخل رقم هاتفك لتسجيل الدخول ومتابعة طلباتك ومسار شحناتك الحالية.',
                                style: BurhanTypography.bodySmall.copyWith(
                                  color: BurhanColors.slate500,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Phone Input Label
                              Text(
                                'رقم الهاتف المحمول',
                                style: BurhanTypography.titleSmall.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Phone & Country Picker Input Row (LTR)
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Country Code Selector Pill
                                    InkWell(
                                      onTap: isLoading ? null : _openCountryPickerSheet,
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: BurhanColors.slate100,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: BurhanColors.slate200),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _selectedCountry.flag,
                                              style: const TextStyle(fontSize: 18),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _selectedCountry.dialCode,
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: BurhanColors.slate800,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 16,
                                              color: BurhanColors.slate500,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Phone Number TextField
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        enabled: !isLoading,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(12),
                                        ],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'monospace',
                                          color: BurhanColors.slate900,
                                          letterSpacing: 1.2,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: _selectedCountry.example,
                                          hintStyle: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'monospace',
                                            color: BurhanColors.slate400,
                                            letterSpacing: 1.0,
                                          ),
                                          filled: true,
                                          fillColor: BurhanColors.slate50,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                              color: BurhanColors.slate200,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                              color: BurhanColors.slate200,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                              color: BurhanColors.primary,
                                              width: 1.6,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          final phone = value?.trim() ?? '';
                                          if (phone.length < 7) {
                                            return 'يرجى إدخال رقم هاتف صحيح';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Carriers Helper Hint
                              Text(
                                'يدعم شبكات اليمن: يمن موبايل (77/78) · يو (73) · سبأفون (71) · واي (70)',
                                style: BurhanTypography.caption.copyWith(
                                  fontSize: 10,
                                  color: BurhanColors.slate400,
                                ),
                              ),

                              // Inline Error Message
                              if (_inlineError != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BurhanColors.rose50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: BurhanColors.rose500.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        size: 16,
                                        color: BurhanColors.rose500,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _inlineError!,
                                          style: BurhanTypography.bodySmall.copyWith(
                                            color: BurhanColors.rose500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),

                              // Primary Action CTA
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: BurhanColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: BurhanColors.slate300,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _isRegisterMode
                                                  ? 'المتابعة للتحقق وإنشاء الحساب'
                                                  : 'إرسال رمز الدخول',
                                              style: BurhanTypography.titleMedium.copyWith(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_back_rounded,
                                              size: 16,
                                              color: BurhanColors.amber,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Platform Pillars Micro Badges
                      Row(
                        children: [
                          _buildPillarTile(
                            icon: Icons.verified_outlined,
                            iconColor: BurhanColors.amber,
                            title: 'فحص عيني 100%',
                            subtitle: 'معاينة بقوانغتشو',
                          ),
                          const SizedBox(width: 8),
                          _buildPillarTile(
                            icon: Icons.flight_takeoff_rounded,
                            iconColor: BurhanColors.blue500,
                            title: 'شحن مباشر',
                            subtitle: 'جوي وبحري لبابك',
                          ),
                          const SizedBox(width: 8),
                          _buildPillarTile(
                            icon: Icons.security_rounded,
                            iconColor: BurhanColors.emerald600,
                            title: 'حماية وضمان',
                            subtitle: 'مطابقة تامة للمواصفات',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Security Bottom Guarantee Note
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: BurhanColors.emerald600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'بياناتك ومعاملاتك المالية محمية ومشفرة بأعلى معايير الأمان',
                            style: BurhanTypography.caption.copyWith(
                              fontSize: 10.5,
                              color: BurhanColors.slate500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPillarTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BurhanColors.slate200.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: BurhanTypography.titleSmall.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: BurhanTypography.caption.copyWith(
                fontSize: 9,
                color: BurhanColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented tab pill item for smooth mode switching.
class _SegmentedTabItem extends StatelessWidget {
  const _SegmentedTabItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: BurhanTypography.titleSmall.copyWith(
            fontSize: 12.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? BurhanColors.primary : BurhanColors.slate500,
          ),
        ),
      ),
    );
  }
}
