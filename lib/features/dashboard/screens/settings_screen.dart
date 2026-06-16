import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/pwa_install_service.dart';

/// ======================================================
/// FEATURE: Settings Screen
/// PURPOSE: Handles user preferences like notifications and PWA installation.
/// ARCHITECTURE: State is hoisted to [SettingsScreen]. 
/// Renders [_SettingsDesktop] or [_SettingsMobile] based on width.
/// ======================================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;
  Timer? _pwaPollTimer;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = FcmService.notificationsEnabled;
    _pwaPollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _pwaPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    FcmService.setNotificationsEnabled(value);

    if (value) {
      final granted = await FcmService.requestPermission();
      if (!granted && mounted) {
        setState(() => _notificationsEnabled = false);
        FcmService.setNotificationsEnabled(false);
        final loc = context.read<LocalizationCubit>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('notifications_permission_denied')),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        title: Text(
          loc.translate('settings'),
          style: AppTypography.h3,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: AppColors.border, height: 1.5),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return _SettingsMobile(
              notificationsEnabled: _notificationsEnabled,
              toggleNotifications: _toggleNotifications,
              loc: loc,
            );
          }

          return _SettingsDesktop(
            notificationsEnabled: _notificationsEnabled,
            toggleNotifications: _toggleNotifications,
            loc: loc,
          );
        },
      ),
    );
  }
}

/// Desktop version of the Settings Screen.
class _SettingsDesktop extends StatelessWidget {
  final bool notificationsEnabled;
  final Function(bool) toggleNotifications;
  final LocalizationCubit loc;

  const _SettingsDesktop({
    required this.notificationsEnabled,
    required this.toggleNotifications,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: loc.translate('notifications_settings')),
              const SizedBox(height: 16),
              _NotificationToggleTile(
                notificationsEnabled: notificationsEnabled,
                toggleNotifications: toggleNotifications,
                loc: loc,
              ),
              const SizedBox(height: 40),
              _SectionHeader(title: loc.translate('install_app')),
              const SizedBox(height: 16),
              _InstallAppTile(loc: loc),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile version of the Settings Screen.
class _SettingsMobile extends StatelessWidget {
  final bool notificationsEnabled;
  final Function(bool) toggleNotifications;
  final LocalizationCubit loc;

  const _SettingsMobile({
    required this.notificationsEnabled,
    required this.toggleNotifications,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: loc.translate('notifications_settings')),
          const SizedBox(height: 16),
          _NotificationToggleTile(
            notificationsEnabled: notificationsEnabled,
            toggleNotifications: toggleNotifications,
            loc: loc,
          ),
          const SizedBox(height: 40),
          _SectionHeader(title: loc.translate('install_app')),
          const SizedBox(height: 16),
          _InstallAppTile(loc: loc),
        ],
      ),
    );
  }
}

/// Shared Section Header.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.h3.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Shared Notification Toggle Tile.
class _NotificationToggleTile extends StatelessWidget {
  final bool notificationsEnabled;
  final Function(bool) toggleNotifications;
  final LocalizationCubit loc;

  const _NotificationToggleTile({
    required this.notificationsEnabled,
    required this.toggleNotifications,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          _IconWrapper(icon: Icons.notifications_active_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('enable_notifications'),
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.translate('enable_notifications_desc'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: notificationsEnabled,
            onChanged: toggleNotifications,
            activeColor: AppColors.secondary,
            activeTrackColor: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

/// Shared Install App Tile.
class _InstallAppTile extends StatelessWidget {
  final LocalizationCubit loc;

  const _InstallAppTile({required this.loc});

  @override
  Widget build(BuildContext context) {
    final canInstall = PwaInstallService.canInstall;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          _IconWrapper(icon: Icons.download_for_offline_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('install_app'),
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  canInstall
                      ? loc.translate('install_app_desc')
                      : loc.translate('app_already_installed'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (canInstall)
            ElevatedButton.icon(
              onPressed: PwaInstallService.promptInstall,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(loc.translate('install_now')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared Icon Wrapper.
class _IconWrapper extends StatelessWidget {
  final IconData icon;

  const _IconWrapper({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.secondary, size: 22),
    );
  }
}
