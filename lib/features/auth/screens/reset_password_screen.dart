import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/utils/toast_service.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';
import '../widgets/auth_layout_wrapper.dart';
import '../../../core/widgets/particles/loading_logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().resetPassword(
      _passwordController.text,
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayoutWrapper(
      form: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            ToastService.showSuccess(
              context,
              message: context.read<LocalizationCubit>().isRtl
                  ? "تم تحديث كلمة المرور بنجاح! يرجى تسجيل الدخول بكلمة المرور الجديدة."
                  : "Password updated successfully! Please login with your new password.",
            );
            // Log out the active recovery session to force manual login with new password
            context.read<AuthCubit>().logout();
          } else if (state is Unauthenticated) {
            final uri = Uri.base;
            final hasRecovery = uri.fragment.contains('access_token=') || 
                                uri.queryParameters.containsKey('access_token') ||
                                uri.fragment.contains('type=recovery');
            if (!hasRecovery) {
              context.go('/login');
            }
          }
        },
        builder: (context, state) {
          final loc = context.watch<LocalizationCubit>();
          final uri = Uri.base;
          final hasRecovery = uri.fragment.contains('access_token=') || 
                              uri.queryParameters.containsKey('access_token') ||
                              uri.fragment.contains('type=recovery');

          if ((state is Unauthenticated || state is AuthInitial) && hasRecovery) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingLogo(),
                  const SizedBox(height: 24),
                  Text(
                    loc.isRtl
                        ? "جاري التحقق من الرابط وتأكيد الجلسة..."
                        : "Verifying recovery link and establishing session...",
                    style: AppTypography.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final isLoading = state is AuthLoading;
          final errorMessage = state is AuthFailure ? state.message : null;

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.translate('reset_password'),
                  style: AppTypography.h2.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('auth_brand_tagline'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // New Password Input
                FormGroup(
                  label: loc.translate('new_password'),
                  child: CustomTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return loc.translate('required_field');
                      if (val.length < 6) return 'Too short';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm New Password Input
                FormGroup(
                  label: loc.translate('confirm_new_password'),
                  child: CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: '••••••••',
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSubmit(context),
                    prefixIcon: Icon(
                      Icons.lock_reset_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return loc.translate('required_field');
                      if (val != _passwordController.text) {
                        return loc.translate('passwords_do_not_match');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                if (errorMessage != null) ...[
                  Text(
                    errorMessage,
                    style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                ],

                PrimaryButton(
                  text: loc.translate('update_password'),
                  onPressed: () => _handleSubmit(context),
                  isLoading: isLoading,
                  width: double.infinity,
                ),
                const SizedBox(height: 32),

                // Back to Login Link
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      loc.translate('login'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
