/// ======================================================
/// FEATURE: Public Site Renderer
/// PURPOSE: Maps JSON block arrays into visual Flutter widgets
/// USED BY: PublicLandingPage, BuilderCanvas
/// DEPENDENCIES:
/// - BlockRegistry
/// - SectionToolbarOverlay (Builder only)
/// ======================================================

import 'package:flutter/material.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../builder/registries/block_registry.dart';

import '../../builder/widgets/molecules/section_toolbar_overlay.dart';

class SectionRenderer extends StatelessWidget {
  final List<Map<String, dynamic>> blocks;
  final String pageId;
  final LandingPageTheme? theme;
  final Function(int index)? onBlockTapped;
  final Map<String, GlobalKey>? productKeys;
  final int? selectedIndex;
  final bool isBuilder;

  const SectionRenderer({
    super.key,
    required this.blocks,
    required this.pageId,
    this.theme,
    this.onBlockTapped,
    this.productKeys,
    this.selectedIndex,
    this.isBuilder = false,
  });

  @override
  Widget build(BuildContext context) {
    // Filter visible blocks for public viewer, keep all for builder
    final List<Map<String, dynamic>> visibleBlocks = isBuilder
        ? blocks
        : blocks.where((block) {
            final val = block['is_visible'];
            if (val is bool) return val;
            if (val is String) return val.toLowerCase() != 'false';
            return true;
          }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleBlocks.length,
      itemBuilder: (context, index) {
        final block = visibleBlocks[index];
        final String type = (block['type'] ?? '').toString().toLowerCase();
        
        // Find original index for builder actions
        final int originalIndex = isBuilder ? index : blocks.indexOf(block);
        
        final Key sectionKey = ValueKey("${type}_${originalIndex}_${block.hashCode}");

        Widget section = BlockRegistry.render(
          type,
          block,
          theme,
          pageId,
          originalIndex,
          key: sectionKey,
          productKeys: productKeys,
        );

        if (isBuilder && onBlockTapped != null) {
          return SectionToolbarOverlay(
            index: originalIndex,
            isSelected: selectedIndex == originalIndex,
            onEdit: () => onBlockTapped!(originalIndex),
            child: GestureDetector(
              onTap: () => onBlockTapped!(originalIndex),
              behavior: HitTestBehavior.opaque,
              child: section,
            ),
          );
        }

        return section;
      },
    );
  }
}

