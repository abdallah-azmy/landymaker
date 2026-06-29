import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import 'editor_utils.dart';
import '../../../../../core/localization/app_localizations.dart';

class FeaturesEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;

  const FeaturesEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return buildDropdown(
      context,
      block,
      context.translate('layout_style'),
      'layout_style',
      ['grid', 'bento'],
      (val) => cubit.updateBlockProperty(index, 'layout_style', val),
    );
  }
}
