import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';

/// Editor for the location_map block type.
/// Exposes title, address, map_iframe_url, lat, lng, and zoom.
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
        SizedBox(height: 16),
        FormGroup(
          label: "العنوان التفصيلي (Address)",
          child: CustomTextField(
            controller: getController("${index}_address", block['address'] ?? ''),
            focusNode: getFocusNode("${index}_address"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'address', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "رابط خريطة جوجل (Google Maps Embed Iframe URL)",
          helperText: "قم بنسخ رابط الـ iframe من خرائط جوجل والصقه هنا.",
          child: CustomTextField(
            controller: getController("${index}_map_iframe_url", block['map_iframe_url'] ?? ''),
            focusNode: getFocusNode("${index}_map_iframe_url"),
            onChanged: (val) {
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
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FormGroup(
                label: "خط العرض (Latitude)",
                child: CustomTextField(
                  controller: getController("${index}_lat", (block['lat'] ?? '').toString()),
                  focusNode: getFocusNode("${index}_lat"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null) cubit.updateBlockProperty(index, 'lat', parsed);
                  },
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: FormGroup(
                label: "خط الطول (Longitude)",
                child: CustomTextField(
                  controller: getController("${index}_lng", (block['lng'] ?? '').toString()),
                  focusNode: getFocusNode("${index}_lng"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null) cubit.updateBlockProperty(index, 'lng', parsed);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "مستوى التكبير (Zoom): ${((block['zoom'] ?? 15) as num).toInt()}",
          child: Slider(
            value: ((block['zoom'] ?? 15) as num).toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => cubit.updateBlockProperty(index, 'zoom', val.round()),
          ),
        ),
      ],
    );
  }
}
