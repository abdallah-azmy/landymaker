import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import 'layout_option_card.dart';
import 'layout_slot_grid.dart';

List<Map<String, dynamic>> _getLayoutsForType(String type) {
  switch (type) {
    case 'hero':
    case 'hero_saas':
      return [
        {
          'layoutStyle': 'split',
          'name': 'Split',
          'description': 'صورة + نص جنباً إلى جنب',
          'slots': [
            {'slotKey': 'image_main', 'defaultType': 'image', 'label': 'الصورة الرئيسية', 'allowedTypes': ['image', 'video']},
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان الرئيسي'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'النص الوصفي'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'زر الدعوة'},
          ],
        },
        {
          'layoutStyle': 'centered',
          'name': 'مركز',
          'description': 'نص في المنتصف',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان الرئيسي'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'النص الوصفي'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'زر الدعوة'},
          ],
        },
        {
          'layoutStyle': 'gradientOnly',
          'name': 'تدرج لوني',
          'description': 'خلفية متدرجة + نص',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان الرئيسي'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'النص الوصفي'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'زر الدعوة'},
          ],
        },
        {
          'layoutStyle': 'glass',
          'name': 'زجاجي',
          'description': 'بطاقة زجاجية فوق خلفية',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان الرئيسي'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'النص الوصفي'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'زر الدعوة'},
          ],
        },
        {
          'layoutStyle': 'fullWidthBg',
          'name': 'خلفية كاملة',
          'description': 'خلفية بعرض كامل + نص',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان الرئيسي'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'النص الوصفي'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'زر الدعوة'},
          ],
        },
        {
          'layoutStyle': 'fullWidthImage',
          'name': 'خلفية صورة كاملة',
          'description': 'خلفية كاملة مع طبقة تعتيم',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان الرئيسي'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'النص الوصفي'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'زر الدعوة'},
          ],
        },
        {
          'layoutStyle': 'minimal',
          'name': 'بسيط',
          'description': 'عنوان ونص فقط',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان الرئيسي'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'النص الوصفي'},
          ],
        },
      ];

    case 'features':
      return [
        {
          'layoutStyle': 'grid',
          'name': 'شبكة',
          'description': '3 أعمدة متساوية',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'bento',
          'name': 'بينتو',
          'description': 'تصميم مجلة متداخل',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'iconLeft',
          'name': 'أيقونة + نص',
          'description': 'أيقونة يمين النص',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'tabs',
          'name': 'تبويب',
          'description': 'محتوى بنظام التبويب',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'threeCols',
          'name': 'ثلاثة أعمدة',
          'description': '3 أعمدة ممتدة',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
      ];

    case 'cta_banner':
      return [
        {
          'layoutStyle': 'centered',
          'name': 'مركز',
          'description': 'نص + زر في المنتصف',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'الوصف'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'الزر'},
          ],
        },
        {
          'layoutStyle': 'split',
          'name': 'Split',
          'description': 'نص + صورة جنباً',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'الوصف'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'الزر'},
            {'slotKey': 'image_main', 'defaultType': 'image', 'label': 'الصورة', 'allowedTypes': ['image', 'video']},
          ],
        },
        {
          'layoutStyle': 'imageBackground',
          'name': 'خلفية صورة',
          'description': 'نص فوق صورة خلفية',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'الوصف'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'الزر'},
          ],
        },
        {
          'layoutStyle': 'fullWidthImage',
          'name': 'خلفية صورة كاملة',
          'description': 'خلفية كاملة مع طبقة تعتيم',
          'slots': [
            {'slotKey': 'headline', 'defaultType': 'heading', 'label': 'العنوان'},
            {'slotKey': 'description', 'defaultType': 'paragraph', 'label': 'الوصف'},
            {'slotKey': 'cta', 'defaultType': 'button', 'label': 'الزر'},
          ],
        },
      ];

    case 'products':
      return [
        {
          'layoutStyle': 'grid_2',
          'name': 'شبكة 2',
          'description': 'عمودين',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'grid_3',
          'name': 'شبكة 3',
          'description': '3 أعمدة',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'list',
          'name': 'قائمة',
          'description': 'قائمة عمودية',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'carousel',
          'name': 'شريط متحرك',
          'description': 'التمرير أفقي',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
          ],
        },
      ];

    case 'featured_product':
      return [
        {
          'layoutStyle': 'split',
          'name': 'Split',
          'description': 'صورة يمين، نص يسار',
          'slots': [
            {'slotKey': 'product_name', 'defaultType': 'heading', 'label': 'اسم المنتج'},
            {'slotKey': 'product_desc', 'defaultType': 'paragraph', 'label': 'وصف المنتج'},
          ],
        },
        {
          'layoutStyle': 'reversed',
          'name': 'Reversed',
          'description': 'نص يمين، صورة يسار',
          'slots': [
            {'slotKey': 'product_name', 'defaultType': 'heading', 'label': 'اسم المنتج'},
            {'slotKey': 'product_desc', 'defaultType': 'paragraph', 'label': 'وصف المنتج'},
          ],
        },
        {
          'layoutStyle': 'centered',
          'name': 'مركز',
          'description': 'صورة فوق، نص تحت',
          'slots': [
            {'slotKey': 'product_name', 'defaultType': 'heading', 'label': 'اسم المنتج'},
            {'slotKey': 'product_desc', 'defaultType': 'paragraph', 'label': 'وصف المنتج'},
          ],
        },
      ];

    case 'bento_store':
      return [
        {
          'layoutStyle': 'modern',
          'name': 'بينتو عصري',
          'description': 'تخطيط متباعد',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
          ],
        },
        {
          'layoutStyle': 'tight',
          'name': 'بينتو متلاصق',
          'description': 'تصميم مضغوط',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
          ],
        },
        {
          'layoutStyle': 'glass',
          'name': 'بينتو زجاجي',
          'description': 'تأثير زجاجي شفاف',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
          ],
        },
      ];

    case 'testimonials':
      return [
        {
          'layoutStyle': 'masonry',
          'name': 'مايسونري',
          'description': 'شبكة غير منتظمة',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'carousel',
          'name': 'كاروسيل',
          'description': 'متحرك',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
      ];

    case 'statistics_grid':
    case 'animated_counter':
      return [
        {
          'layoutStyle': 'cards',
          'name': 'بطاقات',
          'description': 'بطاقات إحصائية',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'withIcons',
          'name': 'مع أيقونات',
          'description': 'إحصائيات مع أيقونات',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
        {
          'layoutStyle': 'progressBars',
          'name': 'أشرطة تقدم',
          'description': 'أشرطة تقدم百分比',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
            {'slotKey': 'section_desc', 'defaultType': 'paragraph', 'label': 'وصف القسم'},
          ],
        },
      ];

    case 'gallery':
      return [
        {
          'layoutStyle': 'grid',
          'name': 'شبكة',
          'description': 'صور بشبكة',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
          ],
        },
        {
          'layoutStyle': 'carousel',
          'name': 'كاروسيل',
          'description': 'صور متحركة',
          'slots': [
            {'slotKey': 'section_heading', 'defaultType': 'heading', 'label': 'عنوان القسم'},
          ],
        },
      ];

    default:
      return [];
  }
}

class LayoutPickerPanel extends StatefulWidget {
  final int blockIndex;

  const LayoutPickerPanel({required this.blockIndex, super.key});

  @override
  State<LayoutPickerPanel> createState() => _LayoutPickerPanelState();
}

class _LayoutPickerPanelState extends State<LayoutPickerPanel> {
  String? _selectedLayoutStyle;
  Map<String, String> _slotSelections = {};
  List<Map<String, dynamic>> _layouts = [];
  List<Map<String, dynamic>> _currentSlots = [];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LandingPageBuilderCubit>();
    final state = cubit.state;
    if (state is BuilderLoaded) {
      final blocks = state.designMap['blocks'] as List? ?? [];
      if (widget.blockIndex < blocks.length) {
        final block = blocks[widget.blockIndex] as Map<String, dynamic>;
        final type = block['type'] as String? ?? '';
        _layouts = _getLayoutsForType(type);

        final currentStyle = block['layout_style'] as String?;
        if (currentStyle != null && _layouts.any((l) => l['layoutStyle'] == currentStyle)) {
          _selectedLayoutStyle = currentStyle;
          _updateSlots(currentStyle);
        } else if (_layouts.isNotEmpty) {
          _selectedLayoutStyle = _layouts.first['layoutStyle'] as String;
          _updateSlots(_layouts.first['layoutStyle'] as String);
        }
      }
    }
  }

  void _updateSlots(String layoutStyle) {
    final layout = _layouts.firstWhere(
      (l) => l['layoutStyle'] == layoutStyle,
      orElse: () => <String, dynamic>{},
    );
    final slots = (layout['slots'] as List?) ?? [];
    _currentSlots = slots.cast<Map<String, dynamic>>();

    _slotSelections = {};
    for (final slot in _currentSlots) {
      final key = slot['slotKey'] as String;
      final defaultType = slot['defaultType'] as String? ?? 'heading';
      _slotSelections[key] = defaultType;
    }
  }

  void _selectLayout(String layoutStyle) {
    setState(() {
      _selectedLayoutStyle = layoutStyle;
      _updateSlots(layoutStyle);
    });

    context.read<LandingPageBuilderCubit>().updateBlockProperty(
      widget.blockIndex,
      'layout_style',
      layoutStyle,
    );
  }

  void _onSlotChanged(String slotKey, String widgetType) {
    setState(() {
      _slotSelections[slotKey] = widgetType;
    });

    final slotWidgets = Map<String, String>.from(_slotSelections);
    context.read<LandingPageBuilderCubit>().updateBlockProperty(
      widget.blockIndex,
      'slot_widgets',
      slotWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.read<LocalizationCubit>();

    if (_layouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.dashboard_customize_rounded, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
              SizedBox(height: 16),
              Text(
                'هذا القسم لا يدعم تغيير التخطيط',
                style: AppTypography.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مُنتقي التخطيط',
                style: AppTypography.h3,
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  loc.translate('close'),
                  style: AppTypography.button.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'اختر تخطيطاً للقسم ثم خصص عناصره',
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: 20),

          Text(
            'أنماط التخطيط',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _layouts.length,
            itemBuilder: (context, index) {
              final layout = _layouts[index];
              return LayoutOptionCard(
                name: layout['name'] as String,
                description: layout['description'] as String,
                layoutStyle: layout['layoutStyle'] as String,
                isSelected: _selectedLayoutStyle == layout['layoutStyle'],
                onTap: () => _selectLayout(layout['layoutStyle'] as String),
              );
            },
          ),

          if (_selectedLayoutStyle != null && _currentSlots.isNotEmpty) ...[
            SizedBox(height: 24),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            LayoutSlotGrid(
              slots: _currentSlots,
              selections: _slotSelections,
              onSlotChanged: _onSlotChanged,
            ),
          ],

          SizedBox(height: 32),
          PrimaryButton(
            text: loc.translate('apply'),
            icon: Icons.check_rounded,
            width: double.infinity,
            onPressed: () => Navigator.pop(context, true),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
