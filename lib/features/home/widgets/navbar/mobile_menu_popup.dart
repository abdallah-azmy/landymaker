import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/blur_effect.dart';
import '../../../auth/controllers/auth_cubit.dart';

class MobileMenuPopup extends StatelessWidget {
  final bool isLoggedIn;
  final String userEmail;
  final String? userPhotoUrl;
  final bool showLogin;
  final String? ctaText;
  final List<Map<String, String>> parsedLinks;

  const MobileMenuPopup({
    super.key,
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
