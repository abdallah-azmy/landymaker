import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:landymaker/core/widgets/particles/cube_mode_cubit.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/atoms/animated_cube_mode_toggle.dart';
import '../../../core/widgets/atoms/landy_maker_logo.dart';
import '../../../core/widgets/atoms/language_switcher_button.dart';
import '../../../core/widgets/atoms/blur_effect.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';
import 'navbar/desktop_side_menu.dart';
import 'navbar/mobile_menu_popup.dart';
import 'navbar/user_avatar_menu.dart';

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

  const HomeNavbar({
    super.key,
    this.config,
    this.cubeCount,
    this.onPreviewTapped,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final bool isLoggedIn = authState is Authenticated;
    final String userEmail = isLoggedIn ? authState.email : '';
    final String userId = isLoggedIn ? authState.userId : '';
    final String? userPhotoUrl = isLoggedIn ? authState.photoURL : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        final ctaText = context.isRtl
            ? (config?['cta_text_ar'] as String?)
            : (config?['cta_text_en'] as String?);

        final logoText = context.isRtl
            ? (config?['logo_text_ar'] as String?)
            : (config?['logo_text_en'] as String?);

        final primaryLinks = context.isRtl
            ? (config?['primary_links_ar'])
            : (config?['primary_links_en']);

        final linksList = (primaryLinks as List<dynamic>?) ?? [];
        final List<Map<String, String>> parsedLinks = linksList.map((e) {
          final m = e as Map<String, dynamic>;
          return {
            'label': (m['label'] as String? ?? ''),
            'path': (m['path'] as String? ?? ''),
          };
        }).toList();

        if (isMobile) {
          return _MobileNavbar(
            isLoggedIn: isLoggedIn,
            userEmail: userEmail,
            userId: userId,
            userPhotoUrl: userPhotoUrl,
            ctaText: ctaText,
            showLogin: config?['show_login'] as bool? ?? true,
            cubeCount: cubeCount,
            onPreviewTapped: onPreviewTapped,
            logoText: logoText,
            parsedLinks: parsedLinks,
          );
        }

        return _DesktopNavbar(
          isLoggedIn: isLoggedIn,
          userEmail: userEmail,
          userId: userId,
          userPhotoUrl: userPhotoUrl,
          ctaText: ctaText,
          showLogin: config?['show_login'] as bool? ?? true,
          cubeCount: cubeCount,
          onPreviewTapped: onPreviewTapped,
          logoText: logoText,
          parsedLinks: parsedLinks,
        );
      },
    );
  }
}

/// Desktop version of the Navbar with horizontal actions.
class _DesktopNavbar extends StatefulWidget {
  final bool isLoggedIn;
  final String userEmail;
  final String userId;
  final String? userPhotoUrl;
  final String? ctaText;
  final bool showLogin;
  final ValueNotifier<int>? cubeCount;
  final VoidCallback? onPreviewTapped;
  final String? logoText;
  final List<Map<String, String>> parsedLinks;

  const _DesktopNavbar({
    required this.isLoggedIn,
    required this.userEmail,
    required this.userId,
    this.userPhotoUrl,
    this.ctaText,
    this.showLogin = true,
    this.cubeCount,
    this.onPreviewTapped,
    this.logoText,
    required this.parsedLinks,
  });

  @override
  State<_DesktopNavbar> createState() => _DesktopNavbarState();
}

class _DesktopNavbarState extends State<_DesktopNavbar> {
  OverlayEntry? _sideMenuOverlay;

  void _toggleSideMenu() {
    if (_sideMenuOverlay != null) {
      _sideMenuOverlay!.remove();
      _sideMenuOverlay = null;
    } else {
      _sideMenuOverlay = OverlayEntry(
        builder: (context) => DesktopSideMenu(
          isLoggedIn: widget.isLoggedIn,
          showLogin: widget.showLogin,
          ctaText: widget.ctaText,
          onClose: () {
            _sideMenuOverlay?.remove();
            _sideMenuOverlay = null;
          },
        ),
      );
      Overlay.of(context).insert(_sideMenuOverlay!);
    }
  }

  @override
  void dispose() {
    _sideMenuOverlay?.remove();
    super.dispose();
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _toggleSideMenu,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _LogoSection(logoText: widget.logoText),
                  ],
                ),

                Row(
                  children: [
                    if (widget.onPreviewTapped != null)
                      IconButton(
                        tooltip: 'وضع استعراض المكعبات',
                        icon: const Icon(Icons.view_in_ar_outlined),
                        onPressed: widget.onPreviewTapped,
                      ),
                    const AnimatedCubeModeToggle(size: 32),

                    // Theme toggle is hidden for now
                    // const SizedBox(width: 6),
                    // const AnimatedThemeToggle(size: 32),
                    const SizedBox(width: 8),
                    const LanguageSwitcherButton(
                      variant: LanguageSwitcherVariant.iconAndText,
                    ),
                    const SizedBox(width: 20),
                    if (widget.isLoggedIn) ...[
                      if (widget.showLogin)
                        UserAvatarMenu(
                          email: widget.userEmail,
                          userId: widget.userId,
                          photoUrl: widget.userPhotoUrl,
                        ),
                    ] else ...[
                      if (widget.showLogin)
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
                      if (widget.showLogin) const SizedBox(width: 16),
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
                          widget.ctaText ?? context.translate('start_free'),
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
  final String? userPhotoUrl;
  final String? ctaText;
  final bool showLogin;
  final ValueNotifier<int>? cubeCount;
  final VoidCallback? onPreviewTapped;
  final String? logoText;
  final List<Map<String, String>> parsedLinks;

  const _MobileNavbar({
    required this.isLoggedIn,
    required this.userEmail,
    required this.userId,
    this.userPhotoUrl,
    this.ctaText,
    this.showLogin = true,
    this.cubeCount,
    this.onPreviewTapped,
    this.logoText,
    required this.parsedLinks,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _LogoSection(logoText: logoText),
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
                                        style: AppTypography.bodyMedium
                                            .copyWith(
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
                        // Theme toggle is hidden for now
                        // const SizedBox(width: 6),
                        // const AnimatedThemeToggle(size: 32),
                        const SizedBox(width: 4),
                        const LanguageSwitcherButton(
                          variant: LanguageSwitcherVariant.iconOnly,
                        ),
                        const SizedBox(width: 8),
                        MobileMenuPopup(
                          isLoggedIn: isLoggedIn,
                          userEmail: userEmail,
                          userPhotoUrl: userPhotoUrl,
                          showLogin: showLogin,
                          ctaText: ctaText,
                          parsedLinks: parsedLinks,
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


/// Shared Logo section for both layouts.
class _LogoSection extends StatelessWidget {
  final String? logoText;

  const _LogoSection({this.logoText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo_small.webp', height: 38, width: 38),
        const SizedBox(width: 10),
        if (logoText != null && logoText!.isNotEmpty)
          InkWell(
            onTap: () {
              try {
                final authState = context.read<AuthCubit>().state;
                if (authState is Authenticated) {
                  context.go('/dashboard');
                  return;
                }
              } catch (_) {}
              context.go('/');
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                logoText!,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          )
        else
          const LandyMakerLogo(fontSize: 22),
      ],
    );
  }
}


