import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/models/landing_page_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/block_animation_wrapper.dart';
import '../molecules/custom_image_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';
import '../../controllers/builder_cubit.dart';
import 'blocks/editor_utils.dart';

class BlockDesignSettings extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final String type;
  final int index;
  final void Function(LandingPageBuilderCubit, int, {bool isBackground}) onPickMedia;
  final void Function(LandingPageBuilderCubit, int, {bool isBackground}) onPersistAsset;
  final VoidCallback onShowLayoutPicker;

  const BlockDesignSettings({
    required this.cubit,
    required this.block,
    required this.type,
    required this.index,
    required this.onPickMedia,
    required this.onPersistAsset,
    required this.onShowLayoutPicker,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.read<LocalizationCubit>();
    final Map<String, dynamic> anim = block['animation'] ?? {'type': 'none'};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تخطيط القسم',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: onShowLayoutPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.dashboard_customize_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مُنتقي التخطيط',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Text(
                          'اختر تخطيطاً وخصّص العناصر',
                          style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        SizedBox(height: 16),

        if (type == 'gallery') ...[
          Text(
            loc.translate('display_mode'),
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              buildAdvancedOption(
                context: context,
                isSelected: (block['display_mode'] ?? 'grid') == 'grid',
                icon: Icons.grid_view_rounded,
                label: loc.translate('grid'),
                onTap: () => cubit.updateBlockProperty(index, 'display_mode', 'grid'),
              ),
              SizedBox(width: 8),
              buildAdvancedOption(
                context: context,
                isSelected: (block['display_mode'] ?? 'grid') == 'carousel',
                icon: Icons.view_carousel_rounded,
                label: loc.translate('carousel'),
                onTap: () => cubit.updateBlockProperty(index, 'display_mode', 'carousel'),
              ),
            ],
          ),
          SizedBox(height: 24),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          SizedBox(height: 16),
        ],

        if (type == 'basic_section') ...[
          buildDropdown(
            context, block,
            loc.translate('layout_direction'),
            'layout_direction',
            ['column', 'row'],
            (val) => cubit.updateBlockProperty(index, 'layout_direction', val),
          ),
          buildSlider(context, loc.translate('spacing'), 'spacing', 0, 100,
            (val) => cubit.updateBlockProperty(index, 'spacing', val),
            block: block,
          ),
          SizedBox(height: 24),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          SizedBox(height: 16),
        ],

        Text(
          loc.translate('animation'),
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        buildDropdown(
          context, block,
          loc.translate('anim_type'),
          'animation.type',
          BlockAnimationType.values.map((e) => e.name).toList(),
          (val) {
            final newAnim = Map<String, dynamic>.from(anim);
            newAnim['type'] = val;
            cubit.updateBlockProperty(index, 'animation', newAnim);
          },
          translateItem: (item) => loc.translate('anim_$item'),
        ),
        if ((anim['type'] ?? 'none') != 'none') ...[
          buildSlider(context, loc.translate('anim_duration'), 'animation.duration', 100, 3000,
            (val) {
              final newAnim = Map<String, dynamic>.from(anim);
              newAnim['duration'] = val.toInt();
              cubit.updateBlockProperty(index, 'animation', newAnim);
            },
            currentValue: (anim['duration'] ?? 800).toDouble(),
          ),
          buildSlider(context, loc.translate('anim_delay'), 'animation.delay', 0, 2000,
            (val) {
              final newAnim = Map<String, dynamic>.from(anim);
              newAnim['delay'] = val.toInt();
              cubit.updateBlockProperty(index, 'animation', newAnim);
            },
            currentValue: (anim['delay'] ?? 0).toDouble(),
          ),
          buildSlider(context, loc.translate('anim_intensity'), 'animation.intensity', 0.1, 2.0,
            (val) {
              final newAnim = Map<String, dynamic>.from(anim);
              newAnim['intensity'] = val;
              cubit.updateBlockProperty(index, 'animation', newAnim);
            },
            currentValue: (anim['intensity'] ?? 1.0).toDouble(),
          ),
        ],
        SizedBox(height: 24),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        SizedBox(height: 16),

        buildDropdown(
          context, block,
          loc.translate('font_family'),
          'fontFamily',
          ['Default', ...LandingPageTheme.availableFonts.map((f) => f['family']!)],
          (val) => cubit.updateBlockProperty(index, 'fontFamily', val == 'Default' ? null : val),
          translateItem: (item) => item,
        ),
        buildDropdown(
          context, block,
          'قالب القسم (Theme Override)',
          'theme_override',
          ['Default', ...LandingPageTheme.palettes.map((p) => p.name)],
          (val) => cubit.updateBlockProperty(index, 'theme_override', val == 'Default' ? null : val),
        ),
        SizedBox(height: 16),
        buildColorPickerItem(
          context,
          "لون خلفية القسم",
          LandingPageTheme.parseColor(block['bg_color'] ?? block['background_color'], null) ?? Colors.transparent,
          () => showBlockColorPicker(
            context,
            cubit,
            index,
            'bg_color',
            LandingPageTheme.parseColor(block['bg_color'] ?? block['background_color'], null) ?? Colors.transparent,
          ),
        ),
        SizedBox(height: 16),
        buildSlider(context, loc.translate('vertical_padding'), 'vertical_padding', 0, 300,
          (val) => cubit.updateBlockProperty(index, 'vertical_padding', val),
          block: block,
        ),
        SizedBox(height: 16),
        CustomImageField(
          label: loc.translate('bg_image_url'),
          imageUrl: block['bg_image_url'],
          isUploading: (block['bg_image_url'] ?? '').toString().startsWith('upload://'),
          onAction: () => onPickMedia(cubit, index, isBackground: true),
          onSaveTemplateAsset: () => onPersistAsset(cubit, index, isBackground: true),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: loc.translate('overlay_opacity'),
          child: Column(
            children: [
              Slider(
                value: ((block['overlay_opacity'] ?? block['bg_overlay_opacity'] ?? 0.4) as num).toDouble(),
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) {
                  cubit.updateBlockProperty(index, 'overlay_opacity', val);
                  cubit.updateBlockProperty(index, 'bg_overlay_opacity', val);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text(loc.translate('visible')),
          value: block['is_visible'] ?? true,
          activeThumbColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) => cubit.updateBlockProperty(index, 'is_visible', val),
        ),
      ],
    );
  }
}
