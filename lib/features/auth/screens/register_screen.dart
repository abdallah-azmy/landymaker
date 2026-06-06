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

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegisterSuccess;

  const RegisterScreen({super.key, this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleRegister(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildGoogleSignInButton(
    BuildContext context,
    LocalizationCubit loc,
    bool isLoading,
  ) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                loc.translate('or_continue_with'),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () => context.read<AuthCubit>().signInWithGoogle(),
            icon: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
              height: 20,
              width: 20,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.g_mobiledata, color: Colors.white),
            ),
            label: Text(
              loc.translate('sign_in_google'),
              style: AppTypography.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
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
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              if (widget.onRegisterSuccess != null) {
                widget.onRegisterSuccess!();
              } else {
                context.go('/');
              }
            } else if (state is RegistrationSuccess) {
              ToastService.showSuccess(
                context,
                message: context.read<LocalizationCubit>().isRtl
                    ? "تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول باستخدام بياناتك."
                    : "Account created successfully! Please log in with your credentials.",
              );
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
                              Icons.auto_awesome,
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
                                loc.translate('register'),
                                style: AppTypography.h2.copyWith(fontSize: 20),
                              ),
                              const SizedBox(height: 20),

                              // Name input
                              FormGroup(
                                label: loc.translate('full_name'),
                                child: CustomTextField(
                                  controller: _nameController,
                                  hintText: 'John Doe',
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.textSecondary,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Email input
                              FormGroup(
                                label: loc.translate('email'),
                                child: CustomTextField(
                                  controller: _emailController,
                                  hintText: 'name@domain.com',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty)
                                      return 'Required';
                                    if (!val.contains('@'))
                                      return 'Invalid Email';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password input
                              FormGroup(
                                label: loc.translate('password'),
                                child: CustomTextField(
                                  controller: _passwordController,
                                  hintText: '••••••••',
                                  obscureText: true,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.textSecondary,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty)
                                      return 'Required';
                                    if (val.length < 6)
                                      return 'Password must be at least 6 characters';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              const SizedBox(height: 20),

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
                                text: loc.translate('register'),
                                onPressed: () => _handleRegister(context),
                                isLoading: isLoading,
                                width: double.infinity,
                              ),
                              const SizedBox(height: 20),

                              // Google Sign In
                              _buildGoogleSignInButton(context, loc, isLoading),

                              const SizedBox(height: 20),

                              // Link back to Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
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
                                ],
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
