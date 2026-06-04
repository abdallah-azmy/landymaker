import 'package:flutter/material.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../../../builder/controllers/builder_cubit.dart';
import '../editor_types.dart';

class VideoEmbedEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;

  const VideoEmbedEditor({
    super.key,
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: "رابط الفيديو (Video URL)",
          helperText: "يدعم روابط يوتيوب، فيميو، أو روابط التضمين المباشرة",
          child: CustomTextField(
            controller: getController("${index}_video_url", block['video_url'] ?? ''),
            focusNode: getFocusNode("${index}_video_url"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'video_url', val),
            hintText: "مثال: https://youtube.com/watch?v=...",
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "العنوان (Title)",
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "وصف فرعي (Subtitle)",
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FormGroup(
                label: "أبعاد الفيديو (Aspect Ratio)",
                child: DropdownButtonFormField<String>(
                  initialValue: block['aspect_ratio'] ?? '16:9',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: '16:9', child: Text('16:9 (عريض)')),
                    DropdownMenuItem(value: '4:3', child: Text('4:3 (كلاسيكي)')),
                    DropdownMenuItem(value: '1:1', child: Text('1:1 (مربع)')),
                    DropdownMenuItem(value: '9:16', child: Text('9:16 (طولي / Shorts)')),
                  ],
                  onChanged: (val) {
                    if (val != null) cubit.updateBlockProperty(index, 'aspect_ratio', val);
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FormGroup(
                label: "أقصى عرض (Max Width)",
                child: CustomTextField(
                  controller: getController("${index}_max_width", (block['max_width'] ?? 900).toString()),
                  focusNode: getFocusNode("${index}_max_width"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final numValue = int.tryParse(val);
                    if (numValue != null) {
                      cubit.updateBlockProperty(index, 'max_width', numValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "الإعدادات الإضافية",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('استخدام صورة مصغرة (Lazy Load)'),
          subtitle: const Text('يزيد من سرعة الموقع بتأجيل تحميل الفيديو'),
          value: block['use_thumbnail'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'use_thumbnail', val),
        ),
        if (block['use_thumbnail'] ?? true) ...[
          const SizedBox(height: 8),
          FormGroup(
            label: "رابط صورة مصغرة مخصصة (Custom Thumbnail URL)",
            helperText: "اتركه فارغاً للسحب التلقائي من يوتيوب",
            child: CustomTextField(
              controller: getController("${index}_thumbnail_url", block['thumbnail_url'] ?? ''),
              focusNode: getFocusNode("${index}_thumbnail_url"),
              onChanged: (val) => cubit.updateBlockProperty(index, 'thumbnail_url', val),
            ),
          ),
        ],
        SwitchListTile(
          title: const Text('تشغيل تلقائي (Autoplay)'),
          subtitle: const Text('يعمل صامتاً في معظم المتصفحات'),
          value: block['autoplay'] ?? false,
          onChanged: (val) => cubit.updateBlockProperty(index, 'autoplay', val),
        ),
        SwitchListTile(
          title: const Text('إظهار أزرار التحكم (Controls)'),
          value: block['show_controls'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'show_controls', val),
        ),
      ],
    );
  }
}
