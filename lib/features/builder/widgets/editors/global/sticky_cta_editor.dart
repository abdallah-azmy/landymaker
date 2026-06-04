import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/localization/localization_cubit.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../controllers/builder_state.dart';

class StickyCtaEditor extends StatefulWidget {
  final LocalizationCubit loc;
  
  const StickyCtaEditor({super.key, required this.loc});

  @override
  State<StickyCtaEditor> createState() => _StickyCtaEditorState();
}

class _StickyCtaEditorState extends State<StickyCtaEditor> {
  late TextEditingController _textController;
  late TextEditingController _priceController;
  late TextEditingController _btnTextController;
  late TextEditingController _actionValueController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LandingPageBuilderCubit>();
    final state = cubit.state;
    final config = state is BuilderLoaded 
        ? (state.designMap['sticky_cta'] as Map<String, dynamic>? ?? {})
        : <String, dynamic>{};

    _textController = TextEditingController(text: _getLocalized(config['text'], widget.loc.isRtl));
    _priceController = TextEditingController(text: _getLocalized(config['price_text'], widget.loc.isRtl));
    _btnTextController = TextEditingController(text: _getLocalized(config['button_text'], widget.loc.isRtl));
    _actionValueController = TextEditingController(text: config['button_action_value']?.toString() ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    _priceController.dispose();
    _btnTextController.dispose();
    _actionValueController.dispose();
    super.dispose();
  }

  String _getLocalized(dynamic data, bool isRtl) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is Map) {
      return data[isRtl ? 'ar' : 'en'] ?? '';
    }
    return data.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingPageBuilderCubit, BuilderState>(
      builder: (context, state) {
        if (state is! BuilderLoaded) return const SizedBox.shrink();

        final cubit = context.read<LandingPageBuilderCubit>();
        final config = state.designMap['sticky_cta'] as Map<String, dynamic>? ?? {
          'is_enabled': false,
          'text': {'ar': '', 'en': ''},
          'price_text': {'ar': '', 'en': ''},
          'button_text': {'ar': 'شراء', 'en': 'Buy'},
          'button_action_type': 'link',
          'button_action_value': '',
        };

        void updateConfig(String key, dynamic value) {
          cubit.updateStickyCta(key, value);
        }

        void updateLocalizedText(String field, String value) {
          final currentMap = Map<String, dynamic>.from(config[field] is Map ? config[field] : {'ar': config[field], 'en': config[field]});
          currentMap[widget.loc.isRtl ? 'ar' : 'en'] = value;
          updateConfig(field, currentMap);
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("شريط الإجراء الثابت (Sticky CTA)", style: AppTypography.h3),
                  Switch(
                    value: config['is_enabled'] == true,
                    activeThumbColor: AppColors.secondary,
                    onChanged: (val) => updateConfig('is_enabled', val),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "يظهر شريط التثبيت أسفل الشاشة لزيادة التحويلات",
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              
              if (config['is_enabled'] == true) ...[
                Text("النص الأساسي", style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _textController,
                  onChanged: (val) => updateLocalizedText('text', val),
                  hintText: "مثال: اشترك الآن واحصل على خصم",
                ),
                const SizedBox(height: 16),
                
                Text("السعر (اختياري)", style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _priceController,
                  onChanged: (val) => updateLocalizedText('price_text', val),
                  hintText: "مثال: 99 ج.م بدلاً من 150 ج.م",
                ),
                const SizedBox(height: 16),
                
                Text("نص الزر", style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _btnTextController,
                  onChanged: (val) => updateLocalizedText('button_text', val),
                ),
                const SizedBox(height: 16),
                
                Text("إجراء الزر", style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: AppColors.cardBg,
                      value: config['button_action_type'] ?? 'link',
                      items: const [
                        DropdownMenuItem(value: 'link', child: Text("رابط خارجي")),
                        DropdownMenuItem(value: 'checkout', child: Text("صفحة الدفع (Checkout)")),
                      ],
                      onChanged: (val) => updateConfig('button_action_type', val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text("قيمة الإجراء (رابط الدفع أو الرابط الخارجي)", style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _actionValueController,
                  onChanged: (val) => updateConfig('button_action_value', val),
                  hintText: "مثال: https://...",
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
