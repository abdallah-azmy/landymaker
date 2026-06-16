import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/landy_maker_logo.dart';

/// ======================================================
/// FEATURE: Home Navigation Bar
/// PURPOSE: Responsive header for the landing page with glassmorphism and animated mobile menu.
/// ARCHITECTURE: State is hoisted to [HomeNavbar] wrapper. 
/// Renders [_DesktopNavbar] or [_MobileNavbar] based on width.
/// ======================================================
class HomeNavbar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onGetStartedPressed;

  const HomeNavbar({
    super.key,
    required this.onLoginPressed,
    required this.onGetStartedPressed,
  });

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return _MobileNavbar(
            onLoginPressed: widget.onLoginPressed,
            onGetStartedPressed: widget.onGetStartedPressed,
            menuOpen: _menuOpen,
            toggleMenu: _toggleMenu,
            closeMenu: _closeMenu,
            menuController: _menuController,
            menuHeight: _menuHeight,
            menuOpacity: _menuOpacity,
          );
        }

        return _DesktopNavbar(
          onLoginPressed: widget.onLoginPressed,
          onGetStartedPressed: widget.onGetStartedPressed,
        );
      },
    );
  }
}

/// Desktop version of the Navbar with horizontal actions.
class _DesktopNavbar extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onGetStartedPressed;

  const _DesktopNavbar({
    required this.onLoginPressed,
    required this.onGetStartedPressed,
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
              bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
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
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                context.read<LocalizationCubit>().toggleLanguage(),
                            icon: Icon(
                              Icons.language_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            label: Text(
                              context.translate('switch_language'),
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          TextButton(
                            onPressed: onLoginPressed,
                            child: Text(
                              context.translate('login'),
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: onGetStartedPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
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
                                AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              context.translate('start_free'),
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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
        ),
      ),
    );
  }
}

/// Mobile version of the Navbar with hamburger menu and animated dropdown.
class _MobileNavbar extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onGetStartedPressed;
  final bool menuOpen;
  final VoidCallback toggleMenu;
  final VoidCallback closeMenu;
  final AnimationController menuController;
  final Animation<double> menuHeight;
  final Animation<double> menuOpacity;

  const _MobileNavbar({
    required this.onLoginPressed,
    required this.onGetStartedPressed,
    required this.menuOpen,
    required this.toggleMenu,
    required this.closeMenu,
    required this.menuController,
    required this.menuHeight,
    required this.menuOpacity,
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
              bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
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
                              IconButton(
                                tooltip: context.translate('switch_language'),
                                icon: Icon(
                                  Icons.language_rounded,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 22,
                                ),
                                onPressed: () =>
                                    context.read<LocalizationCubit>().toggleLanguage(),
                              ),
                              SizedBox(width: 8),
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
                                      color: Theme.of(context).colorScheme.onSurface,
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
                      child: Opacity(
                        opacity: menuOpacity.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
                    ),
                  ),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          closeMenu();
                          onLoginPressed();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          context.translate('login'),
                          style: AppTypography.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          closeMenu();
                          onGetStartedPressed();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          context.translate('start_free'),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
        const LandyMakerLogo(fontSize: 22),
        SizedBox(width: 10),
        Image.asset(
          'assets/images/logo_small.webp',
          height: 38,
          width: 38,
        ),
      ],
    );
  }
}
