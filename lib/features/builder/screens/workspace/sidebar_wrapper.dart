import 'package:flutter/material.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/draggable_modal_sheet.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../widgets/modals/section_library_modal.dart';
import '../../widgets/organisms/builder_sidebar.dart';

class SidebarWrapper extends StatelessWidget {
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;
  final int? editingBlockIndex;
  final List<Map<String, dynamic>> blocksList;
  final Function(int?) onSetEditingBlock;

  const SidebarWrapper({
    required this.loc,
    required this.cubit,
    required this.state,
    this.editingBlockIndex,
    required this.blocksList,
    required this.onSetEditingBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: loc.isRtl ? BorderSide.none : BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          left: loc.isRtl ? BorderSide(color: Theme.of(context).colorScheme.outlineVariant) : BorderSide.none,
        ),
      ),
      child: BuilderSidebar(
        editingBlockIndex: editingBlockIndex,
        state: state,
        loc: loc,
        cubit: cubit,
        blocksList: blocksList,
        onEditBlock: (index) {
          onSetEditingBlock(index);
        },
        onAddBlock: (context, cubit) => DraggableModalSheet.show(
          context: context,
          title: "مكتبة الأقسام",
          initialChildSize: 0.8,
          child: const SectionLibraryModal(),
        ),
        onDoneEditing: () => onSetEditingBlock(null),
      ),
    );
  }
}
