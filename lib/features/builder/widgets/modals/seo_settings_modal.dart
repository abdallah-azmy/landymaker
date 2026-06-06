import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../controllers/upload_manager_cubit.dart';
import '../../../../injection_container.dart';
import 'image_picker_modal.dart';

class SeoSettingsModal extends StatefulWidget {
  const SeoSettingsModal({super.key});

  @override
  State<SeoSettingsModal> createState() => _SeoSettingsModalState();
}

class _SeoSettingsModalState extends State<SeoSettingsModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _ogImageController;

  @override
  void initState() {
    super.initState();
    final state = context.read<LandingPageBuilderCubit>().state as BuilderLoaded;
    _titleController = TextEditingController(text: state.designMap['meta_title'] ?? '');
    _descController = TextEditingController(text: state.designMap['meta_description'] ?? '');
    _ogImageController = TextEditingController(text: state.designMap['og_image_url'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _ogImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final cubit = context.read<LandingPageBuilderCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.secondary, size: 28),
            const SizedBox(width: 12),
            Text(loc.translate('advanced_settings'), style: AppTypography.h2),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          loc.translate('seo_help'),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        
        // Google Preview
        Text(loc.translate('google_preview'), style: AppTypography.h3),
        const SizedBox(height: 16),
        _buildGoogleSnippet(loc),
        
        const SizedBox(height: 32),
        
        // Form Fields
        FormGroup(
          label: loc.translate('seo_title'),
          helperText: loc.translate('chars_limit')
              .replaceAll('{current}', _titleController.text.length.toString())
              .replaceAll('{max}', '60'),
          helperStyle: TextStyle(
            color: _titleController.text.length > 60 ? AppColors.dangerRed : AppColors.textSecondary,
            fontWeight: _titleController.text.length > 60 ? FontWeight.bold : FontWeight.normal,
          ),
          child: CustomTextField(
            controller: _titleController,
            onChanged: (val) {
              cubit.updateMetadata('meta_title', val);
              setState(() {});
            },
            hintText: "e.g. My Awesome Shop",
          ),
        ),
        const SizedBox(height: 24),
        FormGroup(
          label: loc.translate('seo_description'),
          helperText: loc.translate('chars_limit')
              .replaceAll('{current}', _descController.text.length.toString())
              .replaceAll('{max}', '155'),
          helperStyle: TextStyle(
            color: _descController.text.length > 155 ? AppColors.dangerRed : AppColors.textSecondary,
            fontWeight: _descController.text.length > 155 ? FontWeight.bold : FontWeight.normal,
          ),
          child: CustomTextField(
            controller: _descController,
            maxLines: 3,
            onChanged: (val) {
              cubit.updateMetadata('meta_description', val);
              setState(() {});
            },
            hintText: "Describe what you offer in a few words...",
          ),
        ),
        const SizedBox(height: 24),
        FormGroup(
          label: loc.translate('seo_og_image'),
          helperText: loc.translate('seo_og_image_help'),
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _ogImageController,
                  onChanged: (val) {
                    cubit.updateMetadata('og_image_url', val);
                    setState(() {});
                  },
                  hintText: "https://example.com/image.jpg",
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final selectedData = await ImagePickerModal.show(context);
                  if (selectedData == null) return;

                  final uploadId = 'upload://${DateTime.now().millisecondsSinceEpoch}';
                  final oldUrl = _ogImageController.text;

                  _ogImageController.text = uploadId;
                  cubit.updateMetadata('og_image_url', uploadId);
                  setState(() {});

                  sl<UploadManagerCubit>().upload(
                    uploadId: uploadId,
                    data: selectedData,
                    onSuccess: (finalUrl) {
                      _ogImageController.text = finalUrl;
                      cubit.updateMetadata('og_image_url', finalUrl);
                      setState(() {});
                    },
                    onCancel: () {
                      _ogImageController.text = oldUrl;
                      cubit.updateMetadata('og_image_url', oldUrl);
                      setState(() {});
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.image_search, size: 18),
                label: Text(loc.translate('upload_image')),
              ),
            ],
          ),
        ),
        if (_ogImageController.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomNetworkImage(
                imageUrl: _ogImageController.text,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 40),
        PrimaryButton(
          text: loc.translate('save_and_close'),
          width: double.infinity,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildGoogleSnippet(LocalizationCubit loc) {
    final state = context.read<LandingPageBuilderCubit>().state as BuilderLoaded;
    final title = _titleController.text.isEmpty ? "Page Title will appear here" : _titleController.text;
    final url = "https://landymaker.com/${state.subdomain}";
    final desc = _descController.text.isEmpty 
        ? "Your page description will appear here in Google search results. Make it catchy!" 
        : _descController.text;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: Color(0xFFF1F3F4), child: Icon(Icons.public, size: 14, color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  url,
                  style: const TextStyle(color: Color(0xFF202124), fontSize: 12, fontFamily: 'Arial'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF1A0DAB), fontSize: 18, fontFamily: 'Arial', fontWeight: FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFF4D5156), fontSize: 14, fontFamily: 'Arial', height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
