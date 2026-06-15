import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../localization/localization_cubit.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;
    _isOffline = !(html.window.navigator.onLine ?? true);
    html.window.addEventListener('online', _onOnline);
    html.window.addEventListener('offline', _onOffline);
  }

  @override
  void dispose() {
    if (kIsWeb) {
      html.window.removeEventListener('online', _onOnline);
      html.window.removeEventListener('offline', _onOffline);
    }
    super.dispose();
  }

  void _onOnline(html.Event _) => setState(() => _isOffline = false);
  void _onOffline(html.Event _) => setState(() => _isOffline = true);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;
    final loc = context.watch<LocalizationCubit>();

    return Column(
      children: [
        if (_isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppColors.dangerRed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.translate('offline_banner'),
                  style: AppTypography.caption.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
