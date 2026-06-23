import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/router_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/animated_theme_toggle.dart';
import '../../../core/widgets/atoms/language_switcher_button.dart';

class AuthLayoutWrapper extends StatelessWidget {
  final Widget form;
  final Widget? brandPanel;

  const AuthLayoutWrapper({
    super.key,
    required this.form,
    this.brandPanel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background subtle gradient
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          // Main Centered Content
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
                child: _AuthFormCard(child: form),
              ),
            ),
          ),

          // Top Bar for Theme and Language (rendered last so it's on top and clickable)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _AuthTopBar(),
          ),
        ],
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationCubit>();

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.75),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: () => context.safePop(fallbackPath: '/'),
                    tooltip: loc.isRtl ? 'العودة للرئيسية' : 'Back to Home',
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimatedThemeToggle(size: 36),
                      const SizedBox(width: 8),
                      const LanguageSwitcherButton(variant: LanguageSwitcherVariant.iconOnly),
                    ],
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

class _AuthFormCard extends StatelessWidget {
  final Widget child;
  const _AuthFormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.25 : 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: child,
    );
  }
}
