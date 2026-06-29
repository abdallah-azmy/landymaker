import 'package:flutter/material.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';
import '../../controllers/builder_cubit.dart';
import 'editor_types.dart';

List<Widget> buildActionsTab({
  required LocalizationCubit loc,
  required LandingPageBuilderCubit cubit,
  required Map<String, dynamic> block,
  required String type,
  required int index,
  required GetController getController,
  required GetFocusNode getFocusNode,
}) {
  final List<Widget> list = [];

  if (type == 'hero' || type == 'hero_saas') {
    list.addAll([
      FormGroup(
        label: loc.translate('button_text'),
        child: CustomTextField(
          controller: getController("${index}_button_text", block['button_text'] ?? ''),
          focusNode: getFocusNode("${index}_button_text"),
          onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
        ),
      ),
      SizedBox(height: 16),
      FormGroup(
        label: loc.translate('button_url'),
        helperText: "https://...",
        child: CustomTextField(
          controller: getController("${index}_button_url", block['button_url'] ?? ''),
          focusNode: getFocusNode("${index}_button_url"),
          onChanged: (val) => cubit.updateBlockProperty(index, 'button_url', val),
        ),
      ),
    ]);
  }

  if (type == 'whatsapp') {
    list.addAll([
      FormGroup(
        label: loc.translate('phone_number'),
        child: CustomTextField(
          controller: getController("${index}_phone", block['phone_number'] ?? ''),
          focusNode: getFocusNode("${index}_phone"),
          onChanged: (val) => cubit.updateBlockProperty(index, 'phone_number', val),
        ),
      ),
    ]);
  }

  if (type == 'cta_banner') {
    list.addAll([
      FormGroup(
        label: loc.translate('button_text'),
        child: CustomTextField(
          controller: getController("${index}_btn_text", block['button_text'] ?? ''),
          focusNode: getFocusNode("${index}_btn_text"),
          onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
        ),
      ),
      SizedBox(height: 16),
      FormGroup(
        label: loc.translate('button_url'),
        child: CustomTextField(
          controller: getController("${index}_btn_url", block['button_url'] ?? ''),
          focusNode: getFocusNode("${index}_btn_url"),
          onChanged: (val) => cubit.updateBlockProperty(index, 'button_url', val),
        ),
      ),
      SizedBox(height: 16),
      FormGroup(
        label: loc.translate('secondary_button_text'),
        child: CustomTextField(
          controller: getController("${index}_sec_btn_text", block['secondary_button_text'] ?? ''),
          focusNode: getFocusNode("${index}_sec_btn_text"),
          onChanged: (val) => cubit.updateBlockProperty(index, 'secondary_button_text', val),
        ),
      ),
      SizedBox(height: 16),
      FormGroup(
        label: loc.translate('secondary_button_url'),
        child: CustomTextField(
          controller: getController("${index}_sec_btn_url", block['secondary_button_url'] ?? ''),
          focusNode: getFocusNode("${index}_sec_btn_url"),
          onChanged: (val) => cubit.updateBlockProperty(index, 'secondary_button_url', val),
        ),
      ),
    ]);
  }

  if (list.isEmpty) {
    list.add(Center(child: Text(loc.translate('no_actions_available'))));
  }

  return list;
}
