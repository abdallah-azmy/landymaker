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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        final String type = (block['type'] ?? '').toString().toLowerCase();
        final Key sectionKey = ValueKey("${type}_${index}_${block.hashCode}");

        Widget section = BlockRegistry.render(
          type,
          block,
          theme,
          pageId,
          index,
          key: sectionKey,
          productKeys: productKeys,
        );

        if (isBuilder && onBlockTapped != null) {
          return SectionToolbarOverlay(
            index: index,
            isSelected: selectedIndex == index,
            onEdit: () => onBlockTapped!(index),
            child: GestureDetector(
              onTap: () => onBlockTapped!(index),
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

