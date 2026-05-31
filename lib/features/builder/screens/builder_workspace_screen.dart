import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/core/widgets/atoms/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/utils/toast_service.dart';
import '../controllers/builder_cubit.dart';
import '../controllers/builder_state.dart';
import '../widgets/editors/block_properties_editor.dart';
import '../widgets/modals/section_library_modal.dart';
import '../widgets/modals/seo_settings_modal.dart';
import '../widgets/organisms/builder_app_bar.dart';
import '../widgets/organisms/builder_canvas.dart';
import '../widgets/organisms/builder_sidebar.dart';
import '../widgets/tabs/builder_sidebar_tabs.dart';

class BuilderWorkspaceScreen extends StatefulWidget {
  final VoidCallback onBackToDashboard;

  const BuilderWorkspaceScreen({super.key, required this.onBackToDashboard});

  @override
  State<BuilderWorkspaceScreen> createState() => _BuilderWorkspaceScreenState();
}

class _BuilderWorkspaceScreenState extends State<BuilderWorkspaceScreen> {
  int? _editingBlockIndex;
  bool _isMobilePreview = true;

  @override
  void initState() {
    super.initState();
    context.read<LandingPageBuilderCubit>().loadForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final builderCubit = context.watch<LandingPageBuilderCubit>();
    final state = builderCubit.state;

    if (state is BuilderLoading || state is BuilderInitial) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    if (state is BuilderFailure) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error loading builder canvas", style: AppTypography.h2),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.dangerRed,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => builderCubit.loadForCurrentUser(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final loadedState = state as BuilderLoaded;
    final List<Map<String, dynamic>> blocksList =
        (loadedState.designMap['blocks'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return BlocListener<LandingPageBuilderCubit, BuilderState>(
      listener: (context, state) {
        if (state is BuilderLoaded) {
          if (state.successMessage != null) {
            ToastService.showSuccess(context, message: state.successMessage!);
            builderCubit.clearMessages();
          }
          if (state.errorMessage != null) {
            ToastService.showError(context, message: state.errorMessage!);
            builderCubit.clearMessages();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: BuilderAppBar(
          isMobile: isMobile,
          isMobilePreview: _isMobilePreview,
          loc: loc,
          cubit: builderCubit,
          state: loadedState,
          onBack: widget.onBackToDashboard,
          onTogglePreview: () =>
              setState(() => _isMobilePreview = !_isMobilePreview),
          onShowTemplates: () => _showTemplatesMenu(context, builderCubit),
          onShowDesign: () => _showDesignMenu(context, loc, builderCubit),
          onShowSeo: () => _showSeoMenu(context, builderCubit),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddBlockMenu(context, builderCubit),
          backgroundColor: AppColors.secondary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text("إضافة قسم جديد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Row(
          children: [
            if (!isMobile)
              BuilderSidebar(
                editingBlockIndex: _editingBlockIndex,
                state: loadedState,
                loc: loc,
                cubit: builderCubit,
                blocksList: blocksList,
                onEditBlock: (index) =>
                    setState(() => _editingBlockIndex = index),
                onAddBlock: _showAddBlockMenu,
                onDoneEditing: () => setState(() => _editingBlockIndex = null),
              ),
            Expanded(
              child: BuilderCanvas(
                isMobile: isMobile,
                isMobilePreview: _isMobilePreview,
                state: loadedState,
                loc: loc,
                onBlockTapped: (index) {
                  if (isMobile) {
                    _openEditBottomSheet(
                      context,
                      loc,
                      builderCubit,
                      loadedState,
                      index,
                    );
                  } else {
                    setState(() => _editingBlockIndex = index);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBlockMenu(BuildContext context, LandingPageBuilderCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SectionLibraryModal(),
    );
  }

  Widget _buildAddBlockItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplatesMenu(BuildContext context, LandingPageBuilderCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(child: TemplatesTab(cubit: cubit)),
          ],
        ),
      ),
    );
  }

  void _showDesignMenu(
    BuildContext context,
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, state) {
          if (state is! BuilderLoaded) return const SizedBox.shrink();
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: DesignTab(loc: loc, cubit: cubit, state: state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSeoMenu(BuildContext context, LandingPageBuilderCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SeoSettingsModal(),
    );
  }

  void _openEditBottomSheet(
    BuildContext context,
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    BuilderLoaded state,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, currentState) {
          if (currentState is! BuilderLoaded) return const SizedBox.shrink();
          final blocks = currentState.designMap['blocks'] as List? ?? [];
          if (index >= blocks.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) Navigator.pop(context);
            });
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Flexible(
                    child: BlockPropertiesEditor(
                      index: index,
                      state: currentState,
                      isBottomSheet: true,
                      onDone: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
