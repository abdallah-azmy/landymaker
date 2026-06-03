import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/atoms/glass_container.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/utils/toast_service.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            context.go('/login');
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: BlocConsumer<AuthCubit, AuthState>(
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
              context.go('/login');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorMessage = state is AuthFailure ? state.message : null;
            final loc = context.watch<LocalizationCubit>();

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Language Toggle
                      Align(
                        alignment: loc.isRtl
                            ? Alignment.topLeft
                            : Alignment.topRight,
                        child: TextButton.icon(
                          onPressed: () => loc.toggleLanguage(),
                          icon: const Icon(
                            Icons.language,
                            color: AppColors.secondary,
                            size: 18,
                          ),
                          label: Text(
                            loc.translate('switch_language'),
                            style: AppTypography.button.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brand Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.vpn_key_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            loc.translate('app_title'),
                            style: AppTypography.h1.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Form Container Card
                      GlassContainer(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.translate('reset_password') ?? 'تعيين كلمة المرور الجديدة',
                                style: AppTypography.h2.copyWith(fontSize: 20),
                              ),
                              const SizedBox(height: 20),

                              // New Password Input
                              FormGroup(
                                label: loc.translate('new_password') ?? 'كلمة المرور الجديدة',
                                child: CustomTextField(
                                  controller: _passwordController,
                                  hintText: '••••••••',
                                  obscureText: true,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.textSecondary,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Required';
                                    }
                                    if (val.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Confirm New Password Input
                              FormGroup(
                                label: loc.translate('confirm_new_password') ?? 'تأكيد كلمة المرور الجديدة',
                                child: CustomTextField(
                                  controller: _confirmPasswordController,
                                  hintText: '••••••••',
                                  obscureText: true,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.textSecondary,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Required';
                                    }
                                    if (val != _passwordController.text) {
                                      return loc.translate('passwords_do_not_match') ?? 'كلمات المرور غير متطابقة';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (errorMessage != null) ...[
                                Text(
                                  errorMessage,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.dangerRed,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Submit Button
                              PrimaryButton(
                                text: loc.translate('update_password') ?? 'تحديث كلمة المرور',
                                onPressed: () => _handleSubmit(context),
                                isLoading: isLoading,
                                width: double.infinity,
                              ),
                              const SizedBox(height: 20),

                              // Back to Login Link
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    context.go('/login');
                                  },
                                  child: Text(
                                    loc.translate('login'),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
