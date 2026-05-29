import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

class CustomLocationMapWidget extends StatelessWidget {
  final String title;
  final String address;
  final String mapIframeUrl;

  const CustomLocationMapWidget({
    super.key,
    required this.title,
    required this.address,
    required this.mapIframeUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Register the iframe view for Flutter Web
    final String viewId = 'map-iframe-${mapIframeUrl.hashCode}';
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => web.HTMLIFrameElement()
        ..src = mapIframeUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(address, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary))),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: HtmlElementView(viewType: viewId),
            ),
          ),
        ],
      ),
    );
  }
}
