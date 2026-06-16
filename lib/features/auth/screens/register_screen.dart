import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/atoms/glass_container.dart';
import '../../../core/widgets/atoms/social_sign_in_button.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/utils/toast_service.dart';
import '../../../features/builder/controllers/builder_cubit.dart';
import '../../../features/builder/controllers/builder_state.dart';
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

  Future<void> _claimGuestPage(BuildContext context, String userId) async {
    final builderCubit = context.read<LandingPageBuilderCubit>();
    if (builderCubit.state is BuilderLoaded) {
      final pageId = await builderCubit.claimGuestDesign(userId);
      if (pageId != null) {
        if (!context.mounted) return;
        ToastService.showSuccess(
          context,
          message: "تم حفظ صفحتك! يمكنك متابعة التعديل الآن.",
        );
        context.go('/builder/$pageId');
        return;
      }
    }
    if (!context.mounted) return;
    if (widget.onRegisterSuccess != null) {
      widget.onRegisterSuccess!();
    } else {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildLegalNotice(BuildContext context, LocalizationCubit loc) {
    final text = loc.translate('agree_to_terms');
    final privacyText = loc.translate('privacy_policy');
    final termsText = loc.translate('terms_of_service');

    final parts = text.split('{privacy}');
    final part1 = parts[0];
    final remaining = parts[1].split('{terms}');
    final part2 = remaining[0];
    final part3 = remaining[1];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          children: [
            TextSpan(text: part1),
            TextSpan(
              text: privacyText,
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push('/privacy-policy'),
            ),
            TextSpan(text: part2),
            TextSpan(
              text: termsText,
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push('/terms'),
            ),
            TextSpan(text: part3),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.safePop(fallbackPath: '/'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.darkGradient),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              _claimGuestPage(context, state.userId);
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
                          icon: Icon(
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
                      SizedBox(height: 16),

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
                            child: Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            loc.translate('app_title'),
                            style: AppTypography.h1.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28),

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
                              SizedBox(height: 20),

                              // Name input
                              FormGroup(
                                label: loc.translate('full_name'),
                                child: CustomTextField(
                                  controller: _nameController,
                                  hintText: 'John Doe',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 16),

                              // Email input
                              FormGroup(
                                label: loc.translate('email'),
                                child: CustomTextField(
                                  controller: _emailController,
                                  hintText: 'name@domain.com',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              SizedBox(height: 16),

                              // Password input
                              FormGroup(
                                label: loc.translate('password'),
                                child: CustomTextField(
                                  controller: _passwordController,
                                  hintText: '••••••••',
                                  obscureText: true,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              SizedBox(height: 16),

                              if (errorMessage != null) ...[
                                Text(
                                  errorMessage,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.dangerRed,
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],

                              // Submit Button
                              PrimaryButton(
                                text: loc.translate('register'),
                                onPressed: () => _handleRegister(context),
                                isLoading: isLoading,
                                width: double.infinity,
                              ),
                              SizedBox(height: 16),

                              _buildLegalNotice(context, loc),

                              SizedBox(height: 8),

                              // Google Sign In
                              SocialSignInButton(
                                label: loc.translate('sign_in_google'),
                                isLoading: isLoading,
                                onPressed: () => context
                                    .read<AuthCubit>()
                                    .signInWithGoogle(),
                              ),

                              SizedBox(height: 20),

                              // Link back to Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
