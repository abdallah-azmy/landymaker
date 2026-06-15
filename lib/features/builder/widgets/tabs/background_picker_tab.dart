import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../controllers/builder_theme_cubit.dart';
import '../../controllers/upload_manager_cubit.dart';
import '../modals/image_picker_modal.dart';
import '../../../../injection_container.dart';

class BackgroundPickerTab extends StatefulWidget {
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;

  const BackgroundPickerTab({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  State<BackgroundPickerTab> createState() => _BackgroundPickerTabState();
}

class _BackgroundPickerTabState extends State<BackgroundPickerTab> {

  Future<void> _pickGlobalBackground() async {
    final selectedData = await ImagePickerModal.show(context);
    if (selectedData == null) return;

    final uploadId = 'upload://${DateTime.now().millisecondsSinceEpoch}';

    // 1. Optimistic update
    final oldUrl = widget.cubit.state is BuilderLoaded 
        ? (widget.cubit.state as BuilderLoaded).theme.globalBgImageUrl 
        : null;

    context.read<BuilderThemeCubit>().updateThemeProperty('globalBgImageUrl', uploadId);

    // 2. Start upload
    sl<UploadManagerCubit>().upload(
      uploadId: uploadId,
      data: selectedData,
      onSuccess: (finalUrl) {
        context.read<BuilderThemeCubit>().updateThemeProperty('globalBgImageUrl', finalUrl);
      },
      onCancel: () {
        context.read<BuilderThemeCubit>().updateThemeProperty('globalBgImageUrl', oldUrl);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingPageBuilderCubit, BuilderState>(
      builder: (context, dynamicState) {
        if (dynamicState is! BuilderLoaded) return const SizedBox.shrink();
        
        final currentBgUrl = dynamicState.theme.globalBgImageUrl;
        final hasBackground = currentBgUrl != null && currentBgUrl.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("خلفية الصفحة", style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              "اختر صورة لجعلها خلفية لكامل صفحة الهبوط. سيؤدي هذا إلى إخفاء ألوان خلفية الأقسام.",
              style: AppTypography.caption,
            ),
            const SizedBox(height: 24),
            
            if (hasBackground)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomNetworkImage(
                    imageUrl: currentBgUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 48),
                      SizedBox(height: 16),
                      Text("لا توجد صورة خلفية محددة", style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickGlobalBackground,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.image_search),
                label: const Text('اختيار أو رفع صورة جديدة'),
              ),
            ),

            if (hasBackground) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<BuilderThemeCubit>().updateThemeProperty('globalBgImageUrl', null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerRed.withValues(alpha: 0.1),
                    foregroundColor: AppColors.dangerRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.dangerRed),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('إزالة صورة الخلفية (استعادة الألوان)'),
                ),
              ),
            ],
              
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
