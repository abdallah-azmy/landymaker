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
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'azmy@gmail.com');
  final _passwordController = TextEditingController(text: '123456');

  void _handleLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              if (widget.onLoginSuccess != null) {
                widget.onLoginSuccess!();
              } else {
                context.go('/');
              }
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
                      // Language Toggle at Top Right/Left
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
                          Image.asset(
                            'assets/images/logo.webp',
                            height: 64,
                            width: 64,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            loc.translate('app_title'),
                            style: AppTypography.h1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // Glass Container Form Card
                      GlassContainer(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.translate('login'),
                                style: AppTypography.h2.copyWith(fontSize: 22),
                              ),
                              const SizedBox(height: 24),

                              // Email FormGroup
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
                                    if (val == null || val.isEmpty) {
                                      return 'Required';
                                    }
                                    if (!val.contains('@')) {
                                      return 'Invalid Email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Password FormGroup
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
                                text: loc.translate('login'),
                                onPressed: () => _handleLogin(context),
                                isLoading: isLoading,
                                width: double.infinity,
                              ),
                              const SizedBox(height: 24),

                              // Toggle switch to Register screen
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.go('/register');
                                    },
                                    child: Text(
                                      loc.translate('register'),
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
