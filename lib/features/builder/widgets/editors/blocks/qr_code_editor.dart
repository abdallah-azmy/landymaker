import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../controllers/builder_state.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';

class QrCodeEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const QrCodeEditor({
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
    final state = cubit.state;
    final String subdomain = state is BuilderLoaded ? state.subdomain : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: "رابط صفحتك المباشر (Live Page URL)",
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: getController("${index}_qrurl_live", "https://landymaker.com/$subdomain"),
                  readOnly: true,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "https://landymaker.com/$subdomain"));
                  ToastService.showSuccess(context, message: "تم نسخ الرابط بنجاح!");
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "العنوان الفرعي (Subtitle)",
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "رابط مخصص للـ QR (Custom QR Link) (اختياري)",
          child: CustomTextField(
            controller: getController("${index}_qr_payload", block['qr_payload'] ?? ''),
            focusNode: getFocusNode("${index}_qr_payload"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'qr_payload', val),
          ),
        ),
        SizedBox(height: 16),
        Text(
          "حجم الكود: ${((block['qr_size'] ?? 200.0) as num).toStringAsFixed(0)}px",
          style: AppTypography.caption,
        ),
        Slider(
          value: ((block['qr_size'] ?? 200.0) as num).toDouble(),
          min: 100.0,
          max: 350.0,
          divisions: 25,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) => cubit.updateBlockProperty(index, 'qr_size', val),
        ),
      ],
    );
  }
}
