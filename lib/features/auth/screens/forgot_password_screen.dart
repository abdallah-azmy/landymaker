import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router_extensions.dart';
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().sendPasswordReset(_emailController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayoutWrapper(
      form: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetEmailSent) {
            ToastService.showSuccess(
              context,
              message: context.read<LocalizationCubit>().isRtl
                  ? "تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني بنجاح!"
                  : "Password reset link sent to your email successfully!",
            );
            context.go('/login');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final errorMessage = state is AuthFailure ? state.message : null;
          final loc = context.watch<LocalizationCubit>();

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.translate('forgot_password'),
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

                // Email input
                FormGroup(
                  label: loc.translate('email'),
                  child: CustomTextField(
                    controller: _emailController,
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSubmit(context),
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
                const SizedBox(height: 32),

                if (errorMessage != null) ...[
                  Text(
                    errorMessage,
                    style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                ],

                PrimaryButton(
                  text: loc.translate('send_reset_link'),
                  onPressed: () => _handleSubmit(context),
                  isLoading: isLoading,
                  width: double.infinity,
                ),
                const SizedBox(height: 32),

                // Back to Login Link
                Center(
                  child: GestureDetector(
                    onTap: () => context.safePop(fallbackPath: '/login'),
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
