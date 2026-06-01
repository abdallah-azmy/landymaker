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

class SeoSettingsModal extends StatefulWidget {
  const SeoSettingsModal({super.key});

  @override
  State<SeoSettingsModal> createState() => _SeoSettingsModalState();
}

class _SeoSettingsModalState extends State<SeoSettingsModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    final state = context.read<LandingPageBuilderCubit>().state as BuilderLoaded;
    _titleController = TextEditingController(text: state.designMap['meta_title'] ?? '');
    _descController = TextEditingController(text: state.designMap['meta_description'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
