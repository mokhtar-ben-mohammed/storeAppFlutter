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

/// OTP verification screen (registration profile is collected before this step).
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

  final List<TextEditingController> _controllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final List<FocusNode> _keyboardNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode(skipTraversal: true));

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

    if (value.isNotEmpty && index < AppConstants.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

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

    for (var i = 0; i < AppConstants.otpLength; i++) {
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

    context.read<AuthCubit>().verifyOtp(
          countryCode: widget.countryCode,
          phone: widget.phone,
          otp: code,
        );
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    context.read<AuthCubit>().sendOtp(
          countryCode: widget.countryCode,
          phone: widget.phone,
          intent: widget.isRegister ? 'register' : 'login',
          registration: context.read<AuthCubit>().pendingRegistration,
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
    for (final f in _keyboardNodes) {
      f.dispose();
    }
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
                    const Icon(
                      Icons.check_circle_rounded,
                      color: BurhanColors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تم إرسال رمز تحقق جديد بنجاح',
                        style: BurhanTypography.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 24,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(AppRoutes.login);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: BurhanColors.slate200,
                                      ),
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
                                          'تغيير الرقم',
                                          style: BurhanTypography.bodySmall.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: BurhanColors.slate700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Flexible(
                                  child: BurhanLogo(
                                    size: BurhanLogoSize.sm,
                                    variant: BurhanLogoVariant.horizontal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: BurhanColors.slate200.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: BurhanColors.primary.withValues(
                                      alpha: 0.04,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: _buildOtpStep(isLoading, fullPhone),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  size: 14,
                                  color: BurhanColors.emerald600,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'بياناتك ومعاملاتك المالية محمية ومشفرة بمعايير أمان عالية',
                                    textAlign: TextAlign.center,
                                    style: BurhanTypography.caption.copyWith(
                                      fontSize: 10.5,
                                      color: BurhanColors.slate500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOtpStep(bool isLoading, String fullPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          'أدخل رمز التحقق',
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
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 8.0;
            const totalGaps = gap * (AppConstants.otpLength - 1);
            final boxWidth = ((constraints.maxWidth - totalGaps) /
                    AppConstants.otpLength)
                .clamp(36.0, 48.0);

            return Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppConstants.otpLength, (index) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == AppConstants.otpLength - 1 ? 0 : gap,
                    ),
                    child: SizedBox(
                      width: boxWidth,
                      height: 54,
                      child: KeyboardListener(
                        focusNode: _keyboardNodes[index],
                        onKeyEvent: (event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey ==
                                  LogicalKeyboardKey.backspace) {
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: BurhanColors.slate50,
                            contentPadding: EdgeInsets.zero,
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
                    ),
                  );
                }),
              ),
            );
          },
        ),
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
                      Flexible(
                        child: Text(
                          widget.isRegister
                              ? 'تأكيد الرمز والمتابعة'
                              : 'تأكيد الرمز والدخول',
                          overflow: TextOverflow.ellipsis,
                          style: BurhanTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: BurhanColors.amber,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: _secondsLeft > 0
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: BurhanColors.slate400,
                    ),
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
                      style: BurhanTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: BurhanColors.amberDark,
                      ),
                    ),
                  ],
                )
              : TextButton.icon(
                  onPressed: isLoading ? null : _resend,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: BurhanColors.primary,
                  ),
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
}
