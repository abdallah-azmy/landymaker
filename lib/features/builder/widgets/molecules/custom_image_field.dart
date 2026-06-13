import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_network_image.dart';

import '../../../../core/localization/app_localizations.dart';

class CustomImageField extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final VoidCallback onAction;
  final VoidCallback? onSaveTemplateAsset;
  final bool isUploading;

  const CustomImageField({
    super.key,
    this.imageUrl,
    required this.label,
    required this.onAction,
    this.onSaveTemplateAsset,
    this.isUploading = false,
  });

  bool _isTemplateAsset(String? url) {
    if (url == null || url.isEmpty) return false;
    // Template assets are usually external (pixabay, etc.)
    // LandyMaker hosted assets usually have 'supabase' in the URL or the specific project ID
    return !url.contains('supabase.co');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final bool canPersist = hasImage && onSaveTemplateAsset != null && _isTemplateAsset(imageUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CustomNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_rounded, size: 32, color: Colors.white24),
                        const SizedBox(height: 8),
                        Text(context.translate('choose_image') ?? "اختر صورة", style: const TextStyle(color: Colors.white24, fontSize: 12)),
                      ],
                    ),
                  ),
                
                // Overlay for Action
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: hasImage ? 0.3 : 0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasImage ? Icons.edit_rounded : Icons.add_rounded, 
                            size: 16, 
                            color: const Color(0xFF00E5FF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasImage ? (context.translate('edit') ?? "تغيير") : (context.translate('upload_image') ?? "رفع صورة"),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (isUploading)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                    ),
                  ),

                if (canPersist && !isUploading)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Tooltip(
                      message: context.translate('save_to_gallery') ?? "حفظ في المعرض",
                      child: InkWell(
                        onTap: onSaveTemplateAsset,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: const Icon(Icons.download_for_offline_rounded, size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
