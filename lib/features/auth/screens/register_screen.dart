import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/atoms/social_sign_in_button.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/utils/toast_service.dart';
import '../../../features/builder/controllers/builder_cubit.dart';
import '../../../features/builder/controllers/builder_state.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';
import '../widgets/auth_layout_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegisterSuccess;

  const RegisterScreen({super.key, this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

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

  void _showGoogleConsentDialog(BuildContext context, String email) {
    final loc = context.read<LocalizationCubit>();

    final text = loc.translate('google_new_user_consent_body');
    final privacyText = loc.translate('privacy_policy');
    final termsText = loc.translate('terms_of_service');

    final parts = text.split('{privacy}');
    final part1 = parts[0];
    final remaining = parts[1].split('{terms}');
    final part2 = remaining[0];
    final part3 = remaining[1];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('google_welcome_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(text: part1),
                  TextSpan(
                    text: privacyText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => ctx.push('/privacy-policy'),
                  ),
                  TextSpan(text: part2),
                  TextSpan(
                    text: termsText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => ctx.push('/terms'),
                  ),
                  TextSpan(text: part3),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              email,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().cancelGoogleSignIn();
            },
            child: Text(loc.translate('cancel')),
          ),
          FilledButton(
            onPressed: () {
              context.read<AuthCubit>().confirmGoogleNewUser();
            },
            child: Text(loc.translate('agree_and_continue')),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isGoogleLoading) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && _isGoogleLoading) {
            final authState = context.read<AuthCubit>().state;
            if (authState is! Authenticated) {
              setState(() => _isGoogleLoading = false);
              final authCubit = context.read<AuthCubit>();
              if (authCubit.state is AuthLoading) {
                authCubit.checkAuth();
              }
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayoutWrapper(
      form: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            setState(() => _isGoogleLoading = false);
            _claimGuestPage(context, state.userId);
          } else if (state is RegistrationSuccess) {
            ToastService.showSuccess(
              context,
              message: context.read<LocalizationCubit>().isRtl
                  ? "تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول باستخدام بياناتك."
                  : "Account created successfully! Please log in with your credentials.",
            );
            context.go('/login');
          } else if (state is GoogleNewUserRequiresConsent) {
            setState(() => _isGoogleLoading = false);
            _showGoogleConsentDialog(context, state.pendingEmail);
          } else if (state is AuthFailure) {
            setState(() => _isGoogleLoading = false);
          } else if (state is AuthInitial) {
            setState(() => _isGoogleLoading = false);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading && !_isGoogleLoading;
          final errorMessage = state is AuthFailure ? state.message : null;
          final loc = context.watch<LocalizationCubit>();

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.translate('register'),
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

                // Google Sign-In Button (appears FIRST)
                SocialSignInButton(
                  label: loc.translate('sign_in_google'),
                  isLoading: _isGoogleLoading,
                  onPressed: () {
                    setState(() => _isGoogleLoading = true);
                    context.read<AuthCubit>().signInWithGoogle();
                  },
                ),
                const SizedBox(height: 24),

                _buildDivider(context, loc),
                const SizedBox(height: 24),

                // Name Field
                FormGroup(
                  label: loc.translate('full_name'),
                  child: CustomTextField(
                    controller: _nameController,
                    hintText: 'John Doe',
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return loc.translate('required_field');
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Email Field
                FormGroup(
                  label: loc.translate('email'),
                  child: CustomTextField(
                    controller: _emailController,
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return loc.translate('required_field');
                      if (!val.contains('@')) return loc.translate('invalid_email');
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                FormGroup(
                  label: loc.translate('password'),
                  child: CustomTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleRegister(context),
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
                const SizedBox(height: 24),

                if (errorMessage != null) ...[
                  Text(
                    errorMessage,
                    style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                ],

                PrimaryButton(
                  text: loc.translate('register'),
                  onPressed: () => _handleRegister(context),
                  isLoading: isLoading,
                  width: double.infinity,
                ),
                const SizedBox(height: 16),

                _buildLegalNotice(context, loc),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.translate('already_have_account'),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        loc.translate('login'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
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

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        children: [
          TextSpan(text: part1),
          TextSpan(
            text: privacyText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
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
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push('/terms'),
          ),
          TextSpan(text: part3),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context, LocalizationCubit loc) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            loc.translate('or_continue_with'),
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
      ],
    );
  }
}
