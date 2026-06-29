import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/core/widgets/atoms/custom_text_field.dart';
import '../../../../core/theme/app_typography.dart';
import '../../controllers/builder_cubit.dart';

class MagicImageSwapper extends StatefulWidget {
  const MagicImageSwapper({super.key});

  @override
  State<MagicImageSwapper> createState() => _MagicImageSwapperState();
}

class _MagicImageSwapperState extends State<MagicImageSwapper> {
  final TextEditingController _categoryController = TextEditingController();

  final List<String> _presets = [
    'مطاعم',
    'تقنية',
    'عقارات',
    'أزياء',
    'طب',
    'رياضة',
    'أثاث',
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "المبدل السحري للصور",
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "غيّر تخصص كل صور الصفحة بضغطة واحدة من Pixabay.",
          style: AppTypography.caption,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _categoryController,
          hintText: "مثلاً: مقهى، نادي رياضي، برمجة...",
          suffixIcon: IconButton(
            icon: Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.primary),
            onPressed: () => _applyMagic(context),
          ),
          onSubmitted: (_) => _applyMagic(context),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets
              .map(
                (preset) => InkWell(
                  onTap: () {
                    _categoryController.text = preset;
                    _applyMagic(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Text(
                      preset,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _applyMagic(BuildContext context) {
    if (_categoryController.text.isEmpty) return;

    context.read<LandingPageBuilderCubit>().magicReplaceImages(
      _categoryController.text,
    );
    FocusScope.of(context).unfocus();
  }
}
