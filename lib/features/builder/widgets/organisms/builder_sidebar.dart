import 'package:flutter/material.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../editors/block_properties_editor.dart';
import '../tabs/builder_sidebar_tabs.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../molecules/element_property_editor.dart';

class BuilderSidebar extends StatelessWidget {
  final int? editingBlockIndex;
  final BuilderLoaded state;
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final List<Map<String, dynamic>> blocksList;
  final Function(int) onEditBlock;
  final Function(BuildContext, LandingPageBuilderCubit) onAddBlock;
  final VoidCallback onDoneEditing;

  const BuilderSidebar({
    super.key,
    this.editingBlockIndex,
    required this.state,
    required this.loc,
    required this.cubit,
    required this.blocksList,
    required this.onEditBlock,
    required this.onAddBlock,
    required this.onDoneEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: loc.isRtl
              ? BorderSide.none
              : BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
          left: loc.isRtl
              ? BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: state.focusedElementId != null
          ? _buildElementEditor(context)
          : (editingBlockIndex != null && editingBlockIndex! < blocksList.length
                ? BlockPropertiesEditor(
                    index: editingBlockIndex!,
                    state: state,
                    onDone: onDoneEditing,
                  )
                : _buildTabs(context)),
    );
  }

  Widget _buildElementEditor(BuildContext context) {
    final section = state.designMap['blocks'][state.focusedSectionIndex];
    final element = (section['elements'] as List).firstWhere(
      (e) => e['id'] == state.focusedElementId,
    );

    return Column(
      children: [
        AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          title: Text(
            loc.translate('edit_element'),
            style: TextStyle(fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(Icons.close_rounded),
            onPressed: () => cubit.selectSection(null),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ElementPropertyEditor(
              type: element['type'],
              styleOverrides: element['style_overrides'] ?? {},
              onUpdate: (key, val) => cubit.updateElementProperty(
                state.focusedSectionIndex!,
                state.focusedElementId!,
                key,
                val,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              isScrollable: true,
              tabs: [
                Tab(
                  icon: Icon(Icons.layers_rounded, size: 20),
                  text: loc.translate('added_sections'),
                ),
                Tab(
                  icon: Icon(Icons.edit_note_rounded, size: 20),
                  text: loc.translate('content'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                OutlineTab(
                  cubit: cubit,
                  loc: loc,
                  blocks: blocksList,
                  onEditBlock: onEditBlock,
                  onAddBlock: onAddBlock,
                  selectedIndex: state.focusedSectionIndex,
                ),
                ContentTab(
                  cubit: cubit,
                  loc: loc,
                  blocks: blocksList,
                  onEditBlock: onEditBlock,
                  onAddBlock: onAddBlock,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
