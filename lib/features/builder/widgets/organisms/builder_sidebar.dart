import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(right: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: state.focusedElementId != null
          ? _buildElementEditor()
          : (editingBlockIndex != null && editingBlockIndex! < blocksList.length
              ? BlockPropertiesEditor(
                  index: editingBlockIndex!,
                  state: state,
                  onDone: onDoneEditing,
                )
              : _buildTabs()),
    );
  }

  Widget _buildElementEditor() {
    final section = state.designMap['blocks'][state.focusedSectionIndex];
    final element = (section['elements'] as List).firstWhere((e) => e['id'] == state.focusedElementId);

    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.cardBg,
          title: Text(loc.translate('edit_element'), style: const TextStyle(fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => cubit.focusElement(0, null),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ElementPropertyEditor(
              type: element['type'],
              styleOverrides: element['style_overrides'] ?? {},
              onUpdate: (key, val) => cubit.updateElementProperty(state.focusedSectionIndex!, state.focusedElementId!, key, val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: AppColors.cardBg,
            child: TabBar(
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.secondary,
              tabs: [
                Tab(icon: const Icon(Icons.auto_awesome_rounded, size: 20), text: loc.translate('templates')),
                Tab(icon: const Icon(Icons.color_lens_rounded, size: 20), text: loc.translate('design')),
                Tab(icon: const Icon(Icons.layers_rounded, size: 20), text: loc.translate('content')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                TemplatesTab(cubit: cubit),
                DesignTab(loc: loc, cubit: cubit, state: state),
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
