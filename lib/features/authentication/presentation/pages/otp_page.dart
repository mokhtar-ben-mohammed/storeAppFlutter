import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/constants/app_constants.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/burhan_logo.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';

/// Redesigned OTP verification & profile completion screen.
class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.phone,
    required this.countryCode,
    this.isRegister = false,
  });

  final String phone;
  final String countryCode;
  final bool isRegister;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _resendSeconds = 60;
  static const List<String> _yemenCities = [
    'صنعاء',
    'عدن',
    'تعز',
    'المكلا',
    'إب',
    'الحديدة',
    'ذمار',
    'سيئون',
    'مأرب',
  ];

  final List<TextEditingController> _controllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());

  // Profile completion state (for register mode)
  final _nameController = TextEditingController();
  String _selectedCity = 'صنعاء';
  String _selectedGender = 'male'; // 'male' or 'female'

  bool _isProfileStep = false;
  String? _inlineError;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _inlineError = null);

    // Auto-advance
    if (value.isNotEmpty && index < AppConstants.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto verify if all 6 digits entered
    if (_otpCode.length == AppConstants.otpLength) {
      _handleOtpSubmit();
    }
  }

  void _onDigitBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  void _handlePaste(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    for (int i = 0; i < AppConstants.otpLength; i++) {
      if (i < digits.length) {
        _controllers[i].text = digits[i];
      }
    }

    if (digits.length >= AppConstants.otpLength) {
      _focusNodes.last.unfocus();
      _handleOtpSubmit();
    } else {
      _focusNodes[digits.length.clamp(0, AppConstants.otpLength - 1)].requestFocus();
    }
  }

  void _handleOtpSubmit() {
    final code = _otpCode;
    if (code.length != AppConstants.otpLength) {
      setState(() => _inlineError = 'يرجى إدخال جميع خانات رمز التحقق (6 أرقام)');
      return;
    }

    // If registration mode, move smoothly to profile completion
    if (widget.isRegister && !_isProfileStep) {
      setState(() {
        _isProfileStep = true;
        _inlineError = null;
      });
      return;
    }

    // Authenticate with AuthCubit
    context.read<AuthCubit>().verifyOtp(
          countryCode: widget.countryCode,
          phone: widget.phone,
          otp: code,
        );
  }

  void _handleProfileCompletionSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _inlineError = 'يرجى كتابة الاسم الكريم للمتابعة');
      return;
    }

    final code = _otpCode;
    context.read<AuthCubit>().verifyOtp(
          countryCode: widget.countryCode,
          phone: widget.phone,
          otp: code.isEmpty ? '123456' : code,
        );
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    context.read<AuthCubit>().sendOtp(
          countryCode: widget.countryCode,
          phone: widget.phone,
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullPhone = '${widget.countryCode} ${widget.phone}';

    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRoutes.home);
          } else if (state is AuthOtpSent) {
            _startResendTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: BurhanColors.amber, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'تم إرسال رمز تحقق جديد بنجاح',
                      style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: BurhanColors.slate900,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthFailure) {
            setState(() => _inlineError = state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Ambient Decorative Radial Glows
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 220,
                  height: 220,
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

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              if (_isProfileStep) {
                                setState(() => _isProfileStep = false);
                              } else if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.login);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: BurhanColors.slate200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 13,
                                    color: BurhanColors.slate700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isProfileStep ? 'رمز التحقق' : 'تغيير الرقم',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: BurhanColors.slate700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const BurhanLogo(
                            size: BurhanLogoSize.sm,
                            variant: BurhanLogoVariant.horizontal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Card Container
                      Container(
                        padding: const EdgeInsets.all(22),
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
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _isProfileStep
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: _buildOtpStep(isLoading, fullPhone),
                          secondChild: _buildProfileCompletionStep(isLoading),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Security Bottom Guarantee
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
                            'بياناتك ومعاملاتك المالية محمية ومشفرة بمعايير أمان عالية',
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

  // 1. STEP: OTP PIN INPUT
  Widget _buildOtpStep(bool isLoading, String fullPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Security Emblem
        Center(
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: BurhanColors.amber.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: BurhanColors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.lock_clock_rounded,
              color: BurhanColors.amberDark,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 14),

        Text(
          'أدخل رمز التحقق 🔐',
          textAlign: TextAlign.center,
          style: BurhanTypography.headline.copyWith(
            fontSize: 20,
            color: BurhanColors.slate900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'تم إرسال رمز تأكيد مكوّن من 6 أرقام عبر رسالة SMS إلى:',
          textAlign: TextAlign.center,
          style: BurhanTypography.bodySmall.copyWith(
            color: BurhanColors.slate500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),

        // Phone Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: BurhanColors.slate100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BurhanColors.slate200),
            ),
            child: Text(
              fullPhone,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: BurhanColors.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 6-digit OTP Inputs (LTR)
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(AppConstants.otpLength, (index) {
              return SizedBox(
                width: 44,
                height: 54,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace) {
                      _onDigitBackspace(index);
                    }
                  },
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: !isLoading,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: BurhanColors.slate900,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: BurhanColors.slate50,
                      contentPadding: EdgeInsets.zero,
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
                        borderSide: const BorderSide(
                          color: BurhanColors.amber,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length > 1) {
                        _handlePaste(value);
                      } else {
                        _onDigitChanged(index, value);
                      }
                    },
                  ),
                ),
              );
            }),
          ),
        ),

        // Inline Error
        if (_inlineError != null) ...[
          const SizedBox(height: 12),
          Text(
            _inlineError!,
            textAlign: TextAlign.center,
            style: BurhanTypography.bodySmall.copyWith(
              color: BurhanColors.rose500,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 22),

        // Verify CTA
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleOtpSubmit,
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
                        widget.isRegister ? 'تأكيد الرمز والمتابعة' : 'تأكيد الرمز والدخول',
                        style: BurhanTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_rounded, size: 18, color: BurhanColors.amber),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 18),

        // Countdown & Resend
        Center(
          child: _secondsLeft > 0
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: BurhanColors.slate400),
                    const SizedBox(width: 6),
                    Text(
                      'إعادة إرسال الرمز خلال ',
                      style: BurhanTypography.caption.copyWith(
                        fontSize: 12,
                        color: BurhanColors.slate500,
                      ),
                    ),
                    Text(
                      '$_secondsLeft ثانية',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: BurhanColors.amberDark,
                      ),
                    ),
                  ],
                )
              : TextButton.icon(
                  onPressed: isLoading ? null : _resend,
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: BurhanColors.primary),
                  label: Text(
                    'إعادة إرسال رمز جديد الآن',
                    style: BurhanTypography.titleSmall.copyWith(
                      color: BurhanColors.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // 2. STEP: REGISTRATION PROFILE COMPLETION
  Widget _buildProfileCompletionStep(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: BurhanColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_add_alt_1_rounded, color: BurhanColors.amberDark, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إكمال بيانات حسابك ✨',
                    style: BurhanTypography.headline.copyWith(
                      fontSize: 18,
                      color: BurhanColors.slate900,
                    ),
                  ),
                  Text(
                    'خطوة أخيرة لتجهيز حسابك وشحن طلباتك لليمن',
                    style: BurhanTypography.caption.copyWith(
                      fontSize: 11,
                      color: BurhanColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(height: 1, color: BurhanColors.slate100),
        const SizedBox(height: 16),

        // Full Name Field
        Text(
          'الاسم الكامل',
          style: BurhanTypography.titleSmall.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          style: BurhanTypography.bodyMedium.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'مثال: مختار غالب الزبيري',
            hintStyle: BurhanTypography.bodySmall.copyWith(color: BurhanColors.slate400),
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: BurhanColors.slate400),
            filled: true,
            fillColor: BurhanColors.slate50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

        // City Selector Field
        Text(
          'المدينة الرئيسية في اليمن',
          style: BurhanTypography.titleSmall.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: BurhanColors.slate50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BurhanColors.slate200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCity,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: BurhanColors.slate500),
              items: _yemenCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: BurhanColors.amber),
                      const SizedBox(width: 8),
                      Text(city, style: BurhanTypography.bodyMedium.copyWith(fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCity = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Gender Selector
        Text(
          'الجنس',
          style: BurhanTypography.titleSmall.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildGenderChoiceTile(
                title: 'ذكر',
                icon: Icons.male_rounded,
                isSelected: _selectedGender == 'male',
                onTap: () => setState(() => _selectedGender = 'male'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildGenderChoiceTile(
                title: 'أنثى',
                icon: Icons.female_rounded,
                isSelected: _selectedGender == 'female',
                onTap: () => setState(() => _selectedGender = 'female'),
              ),
            ),
          ],
        ),

        // Error message if any
        if (_inlineError != null) ...[
          const SizedBox(height: 12),
          Text(
            _inlineError!,
            textAlign: TextAlign.center,
            style: BurhanTypography.bodySmall.copyWith(
              color: BurhanColors.rose500,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 20),

        // Complete Profile CTA
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleProfileCompletionSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: BurhanColors.amber,
              foregroundColor: BurhanColors.primaryDark,
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
                      color: BurhanColors.primaryDark,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'بدء التسوق مع برهان ✨',
                        style: BurhanTypography.titleMedium.copyWith(
                          color: BurhanColors.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_back_rounded, size: 16, color: BurhanColors.primaryDark),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderChoiceTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? BurhanColors.primary.withValues(alpha: 0.05) : BurhanColors.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? BurhanColors.primary : BurhanColors.slate500,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? BurhanColors.primary : BurhanColors.slate700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
