import 'package:flutter/material.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import 'magic_image_swapper.dart';
import 'design_colors_tab.dart';
import 'design_fonts_tab.dart';

class DesignTab extends StatelessWidget {
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;

  const DesignTab({
    super.key,
    required this.loc,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MagicImageSwapper(),
          const SizedBox(height: 32),
          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 24),
          DesignColorsTab(loc: loc, cubit: cubit, state: state),
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 24),
          DesignFontsTab(loc: loc, cubit: cubit, state: state),
        ],
      ),
    );
  }
}
