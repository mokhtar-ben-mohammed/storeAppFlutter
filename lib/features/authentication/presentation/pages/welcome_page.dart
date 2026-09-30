import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:store/app/router/app_routes.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:store/features/authentication/presentation/cubits/auth_state.dart';

/// Entry gate: sign in, create account (OTP), or continue as guest.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is GuestBrowsing) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                BurhanColors.primary,
                BurhanColors.primaryDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'برهان',
                    textAlign: TextAlign.center,
                    style: BurhanTypography.headline.copyWith(
                      fontSize: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ادخل بحسابك أو تصفّح كضيف\nلاستكشاف المتاجر والمنتجات',
                    textAlign: TextAlign.center,
                    style: BurhanTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(flex: 3),
                  _PrimaryButton(
                    label: 'تسجيل الدخول',
                    onPressed: () => context.push('${AppRoutes.login}?mode=login'),
                  ),
                  const SizedBox(height: 12),
                  _PrimaryButton(
                    label: 'إنشاء حساب',
                    filled: false,
                    onPressed: () => context.push('${AppRoutes.login}?mode=register'),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => context.read<AuthCubit>().continueAsGuest(),
                    child: Text(
                      'المتابعة كضيف',
                      style: BurhanTypography.titleMedium.copyWith(
                        color: BurhanColors.amber,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يمكنك إنشاء الحساب لاحقاً برقم الهاتف فقط',
                    textAlign: TextAlign.center,
                    style: BurhanTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: BurhanColors.amber,
                foregroundColor: BurhanColors.primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                label,
                style: BurhanTypography.titleMedium.copyWith(
                  color: BurhanColors.primaryDark,
                  fontSize: 15,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                label,
                style: BurhanTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
    );
  }
}
