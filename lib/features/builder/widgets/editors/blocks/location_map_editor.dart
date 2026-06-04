import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';

class LocationMapEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const LocationMapEditor({
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
          label: "العنوان (Title)",
          child: CustomTextField(
            controller: getController("${index}_location_title", block['title'] ?? 'موقعنا'),
            focusNode: getFocusNode("${index}_location_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "العنوان التفصيلي (Address)",
          child: CustomTextField(
            controller: getController("${index}_address", block['address'] ?? ''),
            focusNode: getFocusNode("${index}_address"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'address', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "رابط خريطة جوجل (Google Maps Embed Iframe URL)",
          helperText: "قم بنسخ رابط الـ iframe من خرائط جوجل والصقه هنا.",
          child: CustomTextField(
            controller: getController("${index}_map_iframe_url", block['map_iframe_url'] ?? ''),
            focusNode: getFocusNode("${index}_map_iframe_url"),
            onChanged: (val) {
              // Basic check to see if user pasted full iframe instead of src url
              String cleanUrl = val;
              if (val.contains('src="')) {
                final match = RegExp(r'src="([^"]+)"').firstMatch(val);
                if (match != null) {
                  cleanUrl = match.group(1) ?? val;
                }
              }
              cubit.updateBlockProperty(index, 'map_iframe_url', cleanUrl);
            },
          ),
        ),
      ],
    );
  }
}
