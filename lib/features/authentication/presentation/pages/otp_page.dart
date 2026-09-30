import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/constants/app_constants.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';

/// OTP verification screen (6 digits) with resend support.
class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.phone,
    required this.countryCode,
  });

  final String phone;
  final String countryCode;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const _resendSeconds = 60;

  final List<TextEditingController> _controllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());

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
    if (value.length == 1 && index < AppConstants.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_otpCode.length == AppConstants.otpLength) {
      _verify();
    }
  }

  void _verify() {
    final otp = _otpCode;
    if (otp.length != AppConstants.otpLength) {
      setState(() => _inlineError = 'أدخل رمز التحقق المكوّن من 6 أرقام');
      return;
    }
    context.read<AuthCubit>().verifyOtp(
          countryCode: widget.countryCode,
          phone: widget.phone,
          otp: otp,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = '${widget.countryCode} ${widget.phone}';

    return Scaffold(
      backgroundColor: BurhanColors.background,
      appBar: AppBar(
        backgroundColor: BurhanColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: BurhanColors.slate900,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go(AppRoutes.home);
            } else if (state is AuthOtpSent) {
              _startResendTimer();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إعادة إرسال الرمز',
                    style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
                  ),
                  backgroundColor: BurhanColors.slate900,
                ),
              );
            } else if (state is AuthFailure) {
              setState(() => _inlineError = state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'رمز التحقق',
                    textAlign: TextAlign.center,
                    style: BurhanTypography.headline.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل الرمز المرسل إلى\n$maskedPhone',
                    textAlign: TextAlign.center,
                    style: BurhanTypography.bodyMedium.copyWith(
                      color: BurhanColors.slate500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(AppConstants.otpLength, (index) {
                        return SizedBox(
                          width: 46,
                          height: 56,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            enabled: !isLoading,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: BurhanTypography.titleLarge.copyWith(fontSize: 20),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: BurhanColors.card,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: BurhanColors.slate200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: BurhanColors.slate200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: BurhanColors.primary),
                              ),
                            ),
                            onChanged: (value) => _onDigitChanged(index, value),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (_inlineError != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _inlineError!,
                      textAlign: TextAlign.center,
                      style: BurhanTypography.bodySmall.copyWith(
                        color: BurhanColors.rose500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _verify,
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
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'تأكيد',
                              style: BurhanTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: (!isLoading && _secondsLeft == 0) ? _resend : null,
                    child: Text(
                      _secondsLeft > 0
                          ? 'إعادة الإرسال خلال $_secondsLeft ث'
                          : 'إعادة إرسال الرمز',
                      style: BurhanTypography.bodyMedium.copyWith(
                        color: _secondsLeft > 0
                            ? BurhanColors.slate400
                            : BurhanColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
