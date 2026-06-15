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
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final String currentLang = isRtl ? 'ar' : 'en';

    // Filter visible blocks + track original indices (O(n), not O(n²))
    final List<Map<String, dynamic>> visibleBlocks = [];
    final List<int> originalIndices = [];
    if (isBuilder) {
      for (int i = 0; i < blocks.length; i++) {
        visibleBlocks.add(blocks[i]);
        originalIndices.add(i);
      }
    } else {
      for (int i = 0; i < blocks.length; i++) {
        final block = blocks[i];
        final val = block['is_visible'];
        final bool isVisible = val is bool ? val : (val is String ? val.toLowerCase() != 'false' : true);
        if (isVisible) {
          visibleBlocks.add(block);
          originalIndices.add(i);
        }
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleBlocks.length,
      itemBuilder: (context, index) {
        final block = visibleBlocks[index];
        final String type = (block['type'] ?? '').toString().toLowerCase();
        
        // Use pre-computed original index (O(1) instead of O(n))
        final int originalIndex = originalIndices[index];
        
        final Key sectionKey = ValueKey("${type}_${originalIndex}_${block.hashCode}");

        Widget section = BlockRegistry.render(
          type,
          block,
          theme,
          pageId,
          originalIndex,
          key: sectionKey,
          productKeys: productKeys,
          lang: currentLang,
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

