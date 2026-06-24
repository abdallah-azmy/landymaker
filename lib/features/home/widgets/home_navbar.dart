import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:landymaker/core/widgets/particles/cube_mode_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/animated_cube_mode_toggle.dart';
import '../../../core/widgets/atoms/animated_theme_toggle.dart';
import '../../../core/widgets/atoms/landy_maker_logo.dart';
import '../../../core/widgets/atoms/language_switcher_button.dart';
import '../../../core/widgets/atoms/blur_effect.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';

/// ======================================================
/// FEATURE: Home Navigation Bar
/// PURPOSE: Responsive header for the landing page with glassmorphism, auth indicators, and animated mobile menu.
/// ARCHITECTURE: Self-contained Auth state integration.
/// Renders [_DesktopNavbar] or [_MobileNavbar] based on width.
/// ======================================================
class HomeNavbar extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic>? config;
  final ValueNotifier<int>? cubeCount;
  final VoidCallback? onPreviewTapped;

  const HomeNavbar({super.key, this.config, this.cubeCount, this.onPreviewTapped});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final bool isLoggedIn = authState is Authenticated;
    final String userEmail = isLoggedIn ? authState.email : '';
    final String userId = isLoggedIn ? authState.userId : '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        final ctaText = context.isRtl
            ? (config?['cta_text_ar'] as String?)
            : (config?['cta_text_en'] as String?);

        if (isMobile) {
          return _MobileNavbar(
            isLoggedIn: isLoggedIn,
            userEmail: userEmail,
            userId: userId,
            ctaText: ctaText,
            showLogin: config?['show_login'] as bool? ?? true,
            cubeCount: cubeCount,
            onPreviewTapped: onPreviewTapped,
          );
        }

        return _DesktopNavbar(
          isLoggedIn: isLoggedIn,
          userEmail: userEmail,
          userId: userId,
          ctaText: ctaText,
          showLogin: config?['show_login'] as bool? ?? true,
          cubeCount: cubeCount,
          onPreviewTapped: onPreviewTapped,
        );
      },
    );
  }
}

/// Desktop version of the Navbar with horizontal actions.
class _DesktopNavbar extends StatelessWidget {
  final bool isLoggedIn;
  final String userEmail;
  final String userId;
  final String? ctaText;
  final bool showLogin;
  final ValueNotifier<int>? cubeCount;
  final VoidCallback? onPreviewTapped;

  const _DesktopNavbar({
    required this.isLoggedIn,
    required this.userEmail,
    required this.userId,
    this.ctaText,
    this.showLogin = true,
    this.cubeCount,
    this.onPreviewTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AppBlurEffect(
      blur: 12.0,
      borderRadius: BorderRadius.zero,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 64,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LogoSection(),
                Row(
                  children: [
                    // if (cubeCount != null)
                    //   BlocBuilder<CubeModeCubit, CubeMode>(
                    //     builder: (context, mode) {
                    //       if (mode == CubeMode.merge) {
                    //         return Padding(
                    //           padding: const EdgeInsetsDirectional.only(
                    //             end: 6,
                    //           ),
                    //           child: ValueListenableBuilder<int>(
                    //             valueListenable: cubeCount!,
                    //             builder: (context, count, _) {
                    //               return Text(
                    //                 '$count',
                    //                 style: AppTypography.bodyMedium.copyWith(
                    //                   color: Theme.of(
                    //                     context,
                    //                   ).colorScheme.primary,
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //         );
                    //       }
                    //       return const SizedBox.shrink();
                    //     },
                    //   ),
                    if (onPreviewTapped != null)
                      IconButton(
                        tooltip: 'وضع استعراض المكعبات',
                        icon: const Icon(Icons.view_in_ar_outlined),
                        onPressed: onPreviewTapped,
                      ),
                    const AnimatedCubeModeToggle(size: 32),

                    const SizedBox(width: 6),
                    const AnimatedThemeToggle(size: 32),
                    const SizedBox(width: 8),
                    const LanguageSwitcherButton(
                      variant: LanguageSwitcherVariant.iconAndText,
                    ),
                    const SizedBox(width: 20),
                    if (isLoggedIn) ...[
                      if (showLogin)
                        _UserAvatarMenu(email: userEmail, userId: userId),
                    ] else ...[
                      if (showLogin)
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            context.translate('login'),
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (showLogin) const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/register'),
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ).copyWith(
                              shadowColor: WidgetStateProperty.all(
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                        child: Text(
                          ctaText ?? context.translate('start_free'),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile version of the Navbar with PopupMenu for both logged in and out states.
class _MobileNavbar extends StatelessWidget {
  final bool isLoggedIn;
  final String userEmail;
  final String userId;
  final String? ctaText;
  final bool showLogin;
  final ValueNotifier<int>? cubeCount;
  final VoidCallback? onPreviewTapped;

  const _MobileNavbar({
    required this.isLoggedIn,
    required this.userEmail,
    required this.userId,
    this.ctaText,
    this.showLogin = true,
    this.cubeCount,
    this.onPreviewTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AppBlurEffect(
      blur: 12.0,
      borderRadius: BorderRadius.zero,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _LogoSection(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onPreviewTapped != null)
                          IconButton(
                            tooltip: 'وضع استعراض المكعبات',
                            icon: const Icon(Icons.view_in_ar_outlined),
                            onPressed: onPreviewTapped,
                          ),
                        const AnimatedCubeModeToggle(size: 32),
                        if (cubeCount != null)
                          BlocBuilder<CubeModeCubit, CubeMode>(
                            builder: (context, mode) {
                              if (mode == CubeMode.merge) {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 6,
                                  ),
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: cubeCount!,
                                    builder: (context, count, _) {
                                      return Text(
                                        '$count',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        const SizedBox(width: 6),
                        const AnimatedThemeToggle(size: 32),
                        const SizedBox(width: 4),
                        const LanguageSwitcherButton(
                          variant: LanguageSwitcherVariant.iconOnly,
                        ),
                        const SizedBox(width: 8),
                        _MobileMenuPopup(
                          isLoggedIn: isLoggedIn,
                          userEmail: userEmail,
                          showLogin: showLogin,
                          ctaText: ctaText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileMenuPopup extends StatelessWidget {
  final bool isLoggedIn;
  final String userEmail;
  final bool showLogin;
  final String? ctaText;

  const _MobileMenuPopup({
    required this.isLoggedIn,
    required this.userEmail,
    required this.showLogin,
    this.ctaText,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      onSelected: (value) {},
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Icon(
            Icons.menu_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            padding: EdgeInsets.zero,
            height: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.15),
                    blurRadius: 32,
                    spreadRadius: 4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: AppBlurEffect(
                blur: 20.0,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isLoggedIn) ...[
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                  child: Text(
                                    userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    userEmail,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/dashboard');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(Icons.dashboard_outlined, size: 22, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 16),
                                  Text(
                                    loc.translate('dashboard'),
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              context.read<AuthCubit>().logout();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              child: Row(
                                children: [
                                  const Icon(Icons.power_settings_new_rounded, size: 20, color: AppColors.dangerRed),
                                  const SizedBox(width: 14),
                                  Text(
                                    loc.translate('logout'),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.dangerRed,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          if (showLogin)
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/login');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.login_rounded, size: 22, color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 16),
                                    Text(
                                      loc.translate('login'),
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (showLogin)
                            Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/register');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(Icons.person_add_outlined, size: 22, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 16),
                                  Text(
                                    ctaText ?? loc.translate('start_free'),
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ),
          ),
        ];
      },
    );
  }
}

/// Shared Logo section for both layouts.
class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo_small.webp', height: 38, width: 38),
        const SizedBox(width: 10),
        const LandyMakerLogo(fontSize: 22),
      ],
    );
  }
}

/// Reusable User Avatar Dropdown Menu for Desktop layout.
class _UserAvatarMenu extends StatelessWidget {
  final String email;
  final String userId;

  _UserAvatarMenu({required this.email, required this.userId})
    : super(key: ValueKey(userId));

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      onSelected: (value) {},
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  email.isNotEmpty ? email[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                email.split('@').first,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            padding: EdgeInsets.zero,
            height: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.15),
                    blurRadius: 32,
                    spreadRadius: 4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: AppBlurEffect(
                blur: 20.0,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/dashboard');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Icon(Icons.dashboard_outlined, size: 22, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 16),
                                Text(
                                  loc.translate('dashboard'),
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            context.read<AuthCubit>().logout();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.power_settings_new_rounded, size: 20, color: AppColors.dangerRed),
                                const SizedBox(width: 14),
                                Text(
                                  loc.translate('logout'),
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.dangerRed,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
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
              ),
            ),
            ),
          ),
        ];
      },
    );
  }
}
