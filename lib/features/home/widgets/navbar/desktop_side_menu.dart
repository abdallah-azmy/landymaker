import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/blur_effect.dart';

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

class DesktopSideMenu extends StatefulWidget {
  final bool isLoggedIn;
  final bool showLogin;
  final String? ctaText;
  final VoidCallback onClose;

  const DesktopSideMenu({
    super.key,
    required this.isLoggedIn,
    required this.showLogin,
    this.ctaText,
    required this.onClose,
  });

  @override
  State<DesktopSideMenu> createState() => _DesktopSideMenuState();
}

class _DesktopSideMenuState extends State<DesktopSideMenu>
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
