import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/molecules/status_pill.dart';
import '../../controllers/builder_cubit.dart';

class ContentTab extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final LocalizationCubit loc;
  final List<Map<String, dynamic>> blocks;
  final Function(int) onEditBlock;
  final Function(BuildContext, LandingPageBuilderCubit) onAddBlock;

  const ContentTab({
    super.key,
    required this.cubit,
    required this.loc,
    required this.blocks,
    required this.onEditBlock,
    required this.onAddBlock,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.translate('add_block'), style: AppTypography.h3),
              TextButton.icon(
                onPressed: () => onAddBlock(context, cubit),
                icon: const Icon(Icons.grid_view_rounded, size: 16),
                label: Text(loc.translate('all_blocks')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildQuickAddButton(
                context,
                cubit,
                'hero',
                "+ ${loc.translate('hero_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'features',
                "+ ${loc.translate('features_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'whatsapp',
                "+ ${loc.translate('whatsapp')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'products',
                "+ ${loc.translate('products_short')}",
              ),
              _buildQuickAddButton(context, cubit, 'qr_code', "+ QR"),
              _buildQuickAddButton(
                context,
                cubit,
                'social_qr',
                "+ ${loc.translate('links_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'pricing',
                "+ ${loc.translate('pricing_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'faq',
                "+ ${loc.translate('faq_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'testimonials',
                "+ ${loc.translate('reviews_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'contact_info',
                "+ ${loc.translate('contact_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'gallery',
                "+ ${loc.translate('gallery_short')}",
              ),
            ],
          ),
          const SizedBox(height: 32),
          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 32),
          Text(loc.translate('added_sections'), style: AppTypography.h3),
          const SizedBox(height: 16),
          if (blocks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text("لا توجد أقسام بعد.")),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blocks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final block = blocks[index];
                final String type = block['type'] ?? '';
                final String title = block['title'] ?? 'Section';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusPill(
                              label: type.toUpperCase(),
                              color: _getSectionColor(context, type),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 22),
                        onPressed: index > 0
                            ? () => cubit.moveBlock(index, true)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                        ),
                        onPressed: index < blocks.length - 1
                            ? () => cubit.moveBlock(index, false)
                            : null,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 18,
                        ),
                        onPressed: () => onEditBlock(index),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 18,
                        ),
                        onPressed: () => cubit.deleteBlock(index),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context,
    LandingPageBuilderCubit cubit,
    String type,
    String label,
  ) {
    return Container(
      width: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          elevation: 0,
        ),
        onPressed: () => cubit.addBlock(type),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getSectionColor(BuildContext context, String type) {
    switch (type) {
      case 'hero':
        return Theme.of(context).colorScheme.secondary;
      case 'features':
        return Theme.of(context).colorScheme.primary;
      case 'products':
        return Colors.green;
      case 'pricing':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
