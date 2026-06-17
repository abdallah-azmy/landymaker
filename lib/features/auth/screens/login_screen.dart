import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/atoms/social_sign_in_button.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../../core/localization/localization_cubit.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';
import '../widgets/auth_layout_wrapper.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleLoading = false;

  void _handleLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
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
  void dispose() {
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
            if (widget.onLoginSuccess != null) {
              widget.onLoginSuccess!();
            } else {
              context.go('/dashboard');
            }
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
                  loc.translate('login'),
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
                const SizedBox(height: 20),

                // Password Field
                FormGroup(
                  label: loc.translate('password'),
                  child: CustomTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(context),
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
                
                Align(
                  alignment: loc.isRtl ? Alignment.centerLeft : Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: Text(
                      loc.translate('forgot_password'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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
                  text: loc.translate('login'),
                  onPressed: () => _handleLogin(context),
                  isLoading: isLoading,
                  width: double.infinity,
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.translate('dont_have_account'),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        loc.translate('register'),
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
