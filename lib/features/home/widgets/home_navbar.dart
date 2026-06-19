import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/animated_theme_toggle.dart';
import '../../../core/widgets/atoms/landy_maker_logo.dart';
import '../../../core/widgets/atoms/language_switcher_button.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';

/// ======================================================
/// FEATURE: Home Navigation Bar
/// PURPOSE: Responsive header for the landing page with glassmorphism, auth indicators, and animated mobile menu.
/// ARCHITECTURE: Self-contained Auth state integration.
/// Renders [_DesktopNavbar] or [_MobileNavbar] based on width.
/// ======================================================
class HomeNavbar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, dynamic>? config;

  const HomeNavbar({super.key, this.config});

  @override
  // Extra 200px allows the animated mobile menu to expand below the bar
  // without clipping. On desktop only the 70px bar is visible.
  Size get preferredSize => const Size.fromHeight(70 + 200);

  @override
  State<HomeNavbar> createState() => _HomeNavbarState();
}

class _HomeNavbarState extends State<HomeNavbar>
    with SingleTickerProviderStateMixin {
  bool _menuOpen = false;
  late AnimationController _menuController;
  late Animation<double> _menuHeight;
  late Animation<double> _menuOpacity;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _menuHeight = Tween<double>(begin: 0, end: 200).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.easeInOut),
    );
    _menuOpacity = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
    if (_menuOpen) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  void _closeMenu() {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
      _menuController.reverse();
    }
  }

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
            ? (widget.config?['cta_text_ar'] as String?)
            : (widget.config?['cta_text_en'] as String?);

        if (isMobile) {
          return _MobileNavbar(
            isLoggedIn: isLoggedIn,
            userEmail: userEmail,
            userId: userId,
            menuOpen: _menuOpen,
            toggleMenu: _toggleMenu,
            closeMenu: _closeMenu,
            menuController: _menuController,
            menuHeight: _menuHeight,
            menuOpacity: _menuOpacity,
            ctaText: ctaText,
            showLogin: widget.config?['show_login'] as bool? ?? true,
          );
        }

        return _DesktopNavbar(
          isLoggedIn: isLoggedIn,
          userEmail: userEmail,
          userId: userId,
          ctaText: ctaText,
          showLogin: widget.config?['show_login'] as bool? ?? true,
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

  const _DesktopNavbar({
    required this.isLoggedIn,
    required this.userEmail,
    required this.userId,
    this.ctaText,
    this.showLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
      ),
    );
  }
}

/// Mobile version of the Navbar with hamburger menu and animated dropdown.
class _MobileNavbar extends StatelessWidget {
  final bool isLoggedIn;
  final String userEmail;
  final String userId;
  final bool menuOpen;
  final VoidCallback toggleMenu;
  final VoidCallback closeMenu;
  final AnimationController menuController;
  final Animation<double> menuHeight;
  final Animation<double> menuOpacity;
  final String? ctaText;
  final bool showLogin;

  const _MobileNavbar({
    required this.isLoggedIn,
    required this.userEmail,
    required this.userId,
    required this.menuOpen,
    required this.toggleMenu,
    required this.closeMenu,
    required this.menuController,
    required this.menuHeight,
    required this.menuOpacity,
    this.ctaText,
    this.showLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main bar
              SizedBox(
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
                              const AnimatedThemeToggle(size: 32),
                              const SizedBox(width: 4),
                              const LanguageSwitcherButton(
                                variant: LanguageSwitcherVariant.iconOnly,
                              ),
                              const SizedBox(width: 8),
                              RepaintBoundary(
                                child: IconButton(
                                  tooltip: menuOpen
                                      ? context.translate('close_menu')
                                      : context.translate('open_menu'),
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, anim) =>
                                        RotationTransition(
                                          turns: anim,
                                          child: FadeTransition(
                                            opacity: anim,
                                            child: child,
                                          ),
                                        ),
                                    child: Icon(
                                      menuOpen
                                          ? Icons.close_rounded
                                          : Icons.menu_rounded,
                                      key: ValueKey(menuOpen),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      size: 28,
                                    ),
                                  ),
                                  onPressed: toggleMenu,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Mobile drop-down menu
              AnimatedBuilder(
                animation: menuController,
                builder: (context, child) {
                  return ClipRect(
                    child: SizedBox(
                      height: menuHeight.value,
                      child: Opacity(opacity: menuOpacity.value, child: child),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isLoggedIn) ...[
                        if (showLogin) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.15),
                                  child: Text(
                                    userEmail.isNotEmpty
                                        ? userEmail[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    userEmail,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            key: const ValueKey('mobile_go_dashboard'),
                            onPressed: () {
                              closeMenu();
                              context.go('/dashboard');
                            },
                            icon: const Icon(Icons.dashboard_outlined),
                            label: Text(context.translate('dashboard')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            key: const ValueKey('mobile_logout'),
                            onPressed: () {
                              closeMenu();
                              context.read<AuthCubit>().logout();
                            },
                            icon: const Icon(
                              Icons.power_settings_new_rounded,
                              color: AppColors.dangerRed,
                            ),
                            label: Text(
                              context.translate('logout'),
                              style: const TextStyle(
                                color: AppColors.dangerRed,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.dangerRed,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ] else ...[
                        if (showLogin)
                          OutlinedButton(
                            onPressed: () {
                              closeMenu();
                              context.go('/login');
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              context.translate('login'),
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (showLogin) const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            closeMenu();
                            context.go('/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            ctaText ?? context.translate('start_free'),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      onSelected: (value) {
        if (value == 'dashboard') {
          context.go('/dashboard');
        } else if (value == 'logout') {
          context.read<AuthCubit>().logout();
        }
      },
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
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'dashboard',
          child: Row(
            children: [
              const Icon(Icons.dashboard_outlined, size: 18),
              const SizedBox(width: 12),
              Text(loc.translate('dashboard')),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                Icons.power_settings_new_rounded,
                size: 18,
                color: AppColors.dangerRed,
              ),
              const SizedBox(width: 12),
              Text(
                loc.translate('logout'),
                style: const TextStyle(color: AppColors.dangerRed),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
