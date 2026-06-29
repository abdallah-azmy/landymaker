import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/blur_effect.dart';
import '../../../auth/controllers/auth_cubit.dart';

class UserAvatarMenu extends StatelessWidget {
  final String email;
  final String userId;
  final String? photoUrl;

  UserAvatarMenu({required this.email, required this.userId, this.photoUrl})
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
