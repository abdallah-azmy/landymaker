import 'package:flutter/material.dart';
import '../../models/preview_mode.dart';
import '../../controllers/builder_state.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../widgets/organisms/builder_canvas.dart';

class CanvasContainer extends StatelessWidget {
  final PreviewMode previewMode;
  final bool isMobile;
  final BuilderLoaded state;
  final LocalizationCubit loc;
  final Function(int) onBlockTapped;

  const CanvasContainer({
    required this.previewMode,
    required this.isMobile,
    required this.state,
    required this.loc,
    required this.onBlockTapped,
  });

  @override
  Widget build(BuildContext context) {
    double? width;
    if (previewMode == PreviewMode.mobile)
      width = 383.0; // 375 screen + 8 bezel padding
    else if (previewMode == PreviewMode.tablet)
      width = 776.0; // 768 screen + 8 bezel padding
    else if (previewMode == PreviewMode.fullscreen)
      width = double.infinity;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: width,
      height: (previewMode == PreviewMode.fullscreen || isMobile)
          ? double.infinity
          : null,
      margin: (previewMode == PreviewMode.fullscreen || isMobile)
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: previewMode == PreviewMode.fullscreen
          ? null
          : BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 2,
              ),
            ),
      clipBehavior: previewMode == PreviewMode.fullscreen
          ? Clip.none
          : Clip.antiAlias,
      child: RepaintBoundary(
        child: BuilderCanvas(
          isMobile: isMobile,
          previewMode: previewMode,
          state: state,
          loc: loc,
          onBlockTapped: onBlockTapped,
        ),
      ),
    );
  }
}
