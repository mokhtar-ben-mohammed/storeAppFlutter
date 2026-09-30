import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/di/injection_container.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';
import 'package:store/features/geography/domain/entities/country_entity.dart';
import 'package:store/features/geography/domain/usecases/get_countries_usecase.dart';

/// Phone login / register screen: dial code + number → send OTP.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.isRegister = false});

  final bool isRegister;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _fallbackCountries = [
    CountryEntity(
      id: 0,
      nameAr: 'اليمن',
      nameEn: 'Yemen',
      iso2: 'YE',
      dialCode: '+967',
    ),
  ];

  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<CountryEntity> _countries = _fallbackCountries;
  CountryEntity _selected = _fallbackCountries.first;
  bool _loadingCountries = true;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final result = await sl<GetCountriesUseCase>()(const NoParams());
    if (!mounted) return;

    result.fold(
      onSuccess: (list) {
        if (list.isEmpty) {
          setState(() => _loadingCountries = false);
          return;
        }
        final yemen = list.where(
          (c) => c.dialCode == '+967' || c.iso2.toUpperCase() == 'YE',
        );
        setState(() {
          _countries = list;
          _selected = yemen.isNotEmpty ? yemen.first : list.first;
          _loadingCountries = false;
        });
      },
      onFailure: (_) {
        setState(() => _loadingCountries = false);
      },
    );
  }

  void _submit() {
    setState(() => _inlineError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthCubit>().sendOtp(
          countryCode: _selected.dialCode,
          phone: _phoneController.text.trim(),
        );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.background,
      appBar: AppBar(
        backgroundColor: BurhanColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: BurhanColors.slate900,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.welcome);
            }
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthOtpSent) {
              context.push(
                '${AppRoutes.otp}?phone=${Uri.encodeComponent(state.phone)}'
                '&country_code=${Uri.encodeComponent(state.countryCode)}',
              );
            } else if (state is AuthFailure) {
              setState(() => _inlineError = state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      widget.isRegister ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                      textAlign: TextAlign.center,
                      style: BurhanTypography.headline.copyWith(
                        fontSize: 28,
                        color: BurhanColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isRegister
                          ? 'أدخل رقم هاتفك لإنشاء حساب برهان'
                          : 'سجّل الدخول برقم هاتفك',
                      textAlign: TextAlign.center,
                      style: BurhanTypography.bodyMedium.copyWith(
                        color: BurhanColors.slate500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'رقم الهاتف',
                      style: BurhanTypography.titleSmall.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minWidth: 108),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: BurhanColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: BurhanColors.slate200),
                          ),
                          child: _loadingCountries
                              ? const SizedBox(
                                  height: 48,
                                  width: 72,
                                  child: Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<CountryEntity>(
                                    value: _selected,
                                    isDense: true,
                                    borderRadius: BorderRadius.circular(12),
                                    items: _countries
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              '${c.dialCode}  ${c.iso2}',
                                              style: BurhanTypography.titleSmall,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              setState(() => _selected = value);
                                            }
                                          },
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            style: BurhanTypography.bodyMedium.copyWith(
                              fontSize: 16,
                              color: BurhanColors.slate900,
                            ),
                            decoration: InputDecoration(
                              hintText: '7XXXXXXXX',
                              hintStyle: BurhanTypography.bodyMedium.copyWith(
                                color: BurhanColors.slate400,
                              ),
                              filled: true,
                              fillColor: BurhanColors.card,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
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
                            validator: (value) {
                              final phone = value?.trim() ?? '';
                              if (phone.length < 8) {
                                return 'أدخل رقم هاتف صالحاً';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_inlineError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _inlineError!,
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
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'إرسال رمز التحقق',
                                style: BurhanTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
