import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';

class WorkingHoursEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const WorkingHoursEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.pickAndUploadImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: "عنوان القسم (Title)",
          child: CustomTextField(
            controller: getController("${index}_working_hours_title", block['title'] ?? 'مواعيد العمل'),
            focusNode: getFocusNode("${index}_working_hours_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "جدول المواعيد (Schedule)",
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                final Map<String, dynamic> schedule = Map.from(block['schedule'] ?? {});
                schedule['يوم جديد'] = '10:00 ص - 10:00 م';
                cubit.updateBlockProperty(index, 'schedule', schedule);
              },
              icon: Icon(Icons.add_rounded, size: 16),
              label: const Text("إضافة يوم"),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...((block['schedule'] as Map<String, dynamic>?) ?? {}).entries.map((entry) {
          final sKey = entry.key;
          final sVal = entry.value.toString();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: "اليوم",
                    controller: getController("${index}_schedule_key_$sKey", sKey),
                    focusNode: getFocusNode("${index}_schedule_key_$sKey"),
                    onChanged: (newKey) {
                      final Map<String, dynamic> schedule = Map.from(block['schedule'] ?? {});
                      if (newKey != sKey && newKey.isNotEmpty) {
                        schedule[newKey] = schedule.remove(sKey);
                        cubit.updateBlockProperty(index, 'schedule', schedule);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    hintText: "الوقت",
                    controller: getController("${index}_schedule_val_$sKey", sVal),
                    focusNode: getFocusNode("${index}_schedule_val_$sKey"),
                    onChanged: (newVal) {
                      final Map<String, dynamic> schedule = Map.from(block['schedule'] ?? {});
                      schedule[sKey] = newVal;
                      cubit.updateBlockProperty(index, 'schedule', schedule);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed),
                  onPressed: () {
                    final Map<String, dynamic> schedule = Map.from(block['schedule'] ?? {});
                    schedule.remove(sKey);
                    cubit.updateBlockProperty(index, 'schedule', schedule);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
