import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/animated_theme_toggle.dart';
import '../../../core/widgets/atoms/landy_maker_logo.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

          // Top Bar for Theme and Language
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _AuthTopBar(),
          ),

          // Main Content
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 768;

              if (isDesktop) {
                return Row(
                  children: [
                    // Left Brand Panel
                    Expanded(
                      flex: 4,
                      child: brandPanel ?? _DefaultBrandPanel(),
                    ),
                    // Right Form Panel
                    Expanded(
                      flex: 6,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: _AuthFormCard(child: form),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LandyMakerLogo(fontSize: 48),
                      const SizedBox(height: 32),
                      _AuthFormCard(child: form),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const AnimatedThemeToggle(size: 36),
            const SizedBox(width: 4),
            const LanguageSwitcherButton(variant: LanguageSwitcherVariant.iconOnly),
          ],
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(40),
      child: child,
    );
  }
}

class _DefaultBrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LandyMakerLogo(fontSize: 64),
          const SizedBox(height: 40),
          Text(
            loc.translate('app_title'),
            style: AppTypography.h1.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.translate('auth_brand_tagline'),
            style: AppTypography.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 18,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
