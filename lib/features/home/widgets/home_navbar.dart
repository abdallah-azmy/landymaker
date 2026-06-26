import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
        builder: (context) => _DesktopSideMenu(
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

                    const SizedBox(width: 6),
                    const AnimatedThemeToggle(size: 32),
                    const SizedBox(width: 8),
                    const LanguageSwitcherButton(
                      variant: LanguageSwitcherVariant.iconAndText,
                    ),
                    const SizedBox(width: 20),
                    if (widget.isLoggedIn) ...[
                      if (widget.showLogin)
                        _UserAvatarMenu(
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

/// Desktop side menu with all page links.
class _DesktopSideMenu extends StatefulWidget {
  final bool isLoggedIn;
  final bool showLogin;
  final String? ctaText;
  final VoidCallback onClose;

  const _DesktopSideMenu({
    required this.isLoggedIn,
    required this.showLogin,
    this.ctaText,
    required this.onClose,
  });

  @override
  State<_DesktopSideMenu> createState() => _DesktopSideMenuState();
}

class _DesktopSideMenuState extends State<_DesktopSideMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  Animation<Offset> _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);
  late final FocusNode _menuFocusNode;

  @override
  void initState() {
    super.initState();
    _menuFocusNode = FocusNode();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _menuFocusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSlideAnimation();
  }

  void _updateSlideAnimation() {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    _slideAnimation =
        Tween<Offset>(
          begin: Offset(isRtl ? 1.0 : -1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _menuFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _close() {
    _animController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final menuItems = <_SideMenuItem>[];

    if (widget.isLoggedIn) {
      menuItems.add(
        _SideMenuItem(
          icon: Icons.dashboard_outlined,
          label: loc.translate('dashboard'),
          path: '/dashboard',
        ),
      );
    }

    menuItems.addAll([
      _SideMenuItem(
        icon: Icons.info_outline_rounded,
        label: context.isRtl ? 'من نحن' : 'About',
        path: '/about',
      ),
      _SideMenuItem(
        icon: Icons.description_outlined,
        label: context.isRtl ? 'الشروط والأحكام' : 'Terms',
        path: '/terms',
      ),
      _SideMenuItem(
        icon: Icons.privacy_tip_outlined,
        label: context.isRtl ? 'سياسة الخصوصية' : 'Privacy',
        path: '/privacy-policy',
      ),
      _SideMenuItem(
        icon: Icons.article_outlined,
        label: context.isRtl ? 'المدونة' : 'Blog',
        path: '/blog',
      ),
    ]);

    if (!widget.isLoggedIn) {
      if (widget.showLogin) {
        menuItems.add(
          _SideMenuItem(
            icon: Icons.login_rounded,
            label: loc.translate('login'),
            path: '/login',
          ),
        );
      }
      if (widget.showLogin) {
        menuItems.add(
          _SideMenuItem(
            icon: Icons.person_add_outlined,
            label: widget.ctaText ?? loc.translate('start_free'),
            path: '/register',
            isHighlighted: true,
          ),
        );
      }
    }

    menuItems.add(
      _SideMenuItem(
        icon: Icons.grid_view_rounded,
        label: context.isRtl ? 'القوالب' : 'Templates',
        path: '/templates',
      ),
    );

    menuItems.add(
      _SideMenuItem(
        icon: Icons.crop_square_rounded,
        label: context.isRtl ? 'صفحة المكعبات' : 'Cubes',
        path: '/cubes',
        isBottom: true,
      ),
    );

    return CallbackShortcuts(
      bindings: {SingleActivator(LogicalKeyboardKey.escape): _close},
      child: Focus(
        focusNode: _menuFocusNode,
        autofocus: true,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _close,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: SafeArea(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 300,
                        margin: const EdgeInsets.only(top: 70),
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.95),
                          border: BorderDirectional(
                            end: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 4,
                              offset: const Offset(8, 0),
                            ),
                          ],
                        ),
                        child: AppBlurEffect(
                          blur: 20.0,
                          borderRadius: BorderRadius.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.zero,
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.menu_rounded,
                                          size: 24,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          context.isRtl ? 'القائمة' : 'Menu',
                                          style: AppTypography.h3.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Menu Items
                                  Expanded(
                                    child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      children: [
                                        for (
                                          int i = 0;
                                          i < menuItems.length;
                                          i++
                                        ) ...[
                                          if (menuItems[i].isBottom &&
                                              i > 0) ...[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 8,
                                                  ),
                                              child: Divider(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outlineVariant
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                          ],
                                          _buildMenuItem(context, menuItems[i]),
                                        ],
                                      ],
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _SideMenuItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _close();
            if (item.path.startsWith('http://') ||
                item.path.startsWith('https://')) {
              launchUrl(Uri.parse(item.path));
            } else {
              context.go(item.path);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.isHighlighted
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15)
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: item.isHighlighted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: item.isHighlighted
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: item.isHighlighted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SideMenuItem {
  final IconData icon;
  final String label;
  final String path;
  final bool isHighlighted;
  final bool isBottom;

  const _SideMenuItem({
    required this.icon,
    required this.label,
    required this.path,
    this.isHighlighted = false,
    this.isBottom = false,
  });
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

class _MobileMenuPopup extends StatelessWidget {
  final bool isLoggedIn;
  final String userEmail;
  final String? userPhotoUrl;
  final bool showLogin;
  final String? ctaText;
  final List<Map<String, String>> parsedLinks;

  const _MobileMenuPopup({
    required this.isLoggedIn,
    required this.userEmail,
    this.userPhotoUrl,
    this.showLogin = true,
    this.ctaText,
    required this.parsedLinks,
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
                    color: Colors.black.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.4
                          : 0.15,
                    ),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
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
                          // Primary Links (Mobile Popup)
                          if (parsedLinks.isNotEmpty) ...[
                            ...parsedLinks.map((link) {
                              final label = link['label'] ?? '';
                              final path = link['path'] ?? '';
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (path.startsWith('http://') ||
                                          path.startsWith('https://')) {
                                        launchUrl(Uri.parse(path));
                                      } else {
                                        context.go(path);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.link_rounded,
                                            size: 22,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            label,
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.3),
                                  ),
                                ],
                              );
                            }),
                          ],
                          if (isLoggedIn) ...[
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: userPhotoUrl != null
                                        ? NetworkImage(userPhotoUrl!)
                                        : null,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.15),
                                    child: userPhotoUrl == null
                                        ? Text(
                                            userEmail.isNotEmpty
                                                ? userEmail[0].toUpperCase()
                                                : 'U',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
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
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/dashboard');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.dashboard_outlined,
                                      size: 22,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      loc.translate('dashboard'),
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                context.read<AuthCubit>().logout();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.power_settings_new_rounded,
                                      size: 20,
                                      color: AppColors.dangerRed,
                                    ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.login_rounded,
                                        size: 22,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        loc.translate('login'),
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (showLogin)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.3),
                              ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/register');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_add_outlined,
                                      size: 22,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      ctaText ?? loc.translate('start_free'),
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
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

/// Reusable User Avatar Dropdown Menu for Desktop layout.
class _UserAvatarMenu extends StatelessWidget {
  final String email;
  final String userId;
  final String? photoUrl;

  _UserAvatarMenu({required this.email, required this.userId, this.photoUrl})
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
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl!)
                    : null,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                child: photoUrl == null
                    ? Text(
                        email.isNotEmpty ? email[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    : null,
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
                    color: Colors.black.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.4
                          : 0.15,
                    ),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.dashboard_outlined,
                                    size: 22,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    loc.translate('dashboard'),
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              context.read<AuthCubit>().switchGoogleAccount();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    context.isRtl
                                        ? 'تبديل الحساب'
                                        : 'Switch account',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              context.read<AuthCubit>().logout();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.power_settings_new_rounded,
                                    size: 20,
                                    color: AppColors.dangerRed,
                                  ),
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
