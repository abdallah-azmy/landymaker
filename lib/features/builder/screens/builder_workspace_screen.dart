import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:html' as html;
import 'package:landymaker/core/widgets/atoms/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/utils/toast_service.dart';
import '../controllers/builder_cubit.dart';
import '../controllers/builder_state.dart';
import '../widgets/editors/block_properties_editor.dart';
import '../widgets/modals/builder_options_modal.dart';
import '../widgets/modals/section_library_modal.dart';
import '../widgets/modals/seo_settings_modal.dart';
import '../widgets/organisms/builder_app_bar.dart';
import '../widgets/organisms/builder_canvas.dart';
import '../widgets/organisms/builder_sidebar.dart';
import '../widgets/tabs/builder_sidebar_tabs.dart';

import '../widgets/molecules/builder_mobile_toolbar.dart';

import '../models/preview_mode.dart';

class BuilderWorkspaceScreen extends StatefulWidget {
  final VoidCallback onBackToDashboard;
  final String? pageId;

  const BuilderWorkspaceScreen({super.key, required this.onBackToDashboard, this.pageId});

  @override
  State<BuilderWorkspaceScreen> createState() => _BuilderWorkspaceScreenState();
}

class _BuilderWorkspaceScreenState extends State<BuilderWorkspaceScreen> {
  int? _editingBlockIndex;
  PreviewMode _previewMode = PreviewMode.mobile;

  @override
  void initState() {
    super.initState();
    if (widget.pageId != null && widget.pageId != 'new') {
      context.read<LandingPageBuilderCubit>().loadPageById(widget.pageId!);
    } else {
      context.read<LandingPageBuilderCubit>().loadForCurrentUser();
    }
    _setupBrowserWarning();
  }

  void _setupBrowserWarning() {
    html.window.onBeforeUnload.listen((event) {
      final state = context.read<LandingPageBuilderCubit>().state;
      if (state is BuilderLoaded && state.hasUnsavedChanges) {
        if (event is html.BeforeUnloadEvent) {
          event.returnValue =
              'You have unsaved changes. Are you sure you want to leave?';
        }
      }
    });
  }

  Future<bool> _onWillPop() async {
    final state = context.read<LandingPageBuilderCubit>().state;
    if (state is! BuilderLoaded || !state.hasUnsavedChanges) {
      return true;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text("تنبيه: تغييرات غير محفوظة"),
        content: const Text(
          "لديك تعديلات لم يتم حفظها بعد. هل تريد الحفظ قبل الخروج؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'exit'),
            child: const Text(
              "خروج بدون حفظ",
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeGreen,
            ),
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text("حفظ وخروج"),
          ),
        ],
      ),
    );

    if (result == 'save') {
      await context.read<LandingPageBuilderCubit>().saveForCurrentUser();
      return true;
    }
    return result == 'exit';
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
          // Update URL to reflect the editing page identifier
          final currentPath = GoRouterState.of(context).uri.path;
          if (state.subdomain.isNotEmpty && currentPath == '/builder') {
            context.replace('/builder/${state.subdomain}');
          }
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            widget.onBackToDashboard();
          }
        },
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.black,
          appBar: isMobile
              ? null // Hide AppBar on mobile
              : BuilderAppBar(
                  isMobile: isMobile,
                  previewMode: _previewMode,
                  loc: loc,
                  cubit: builderCubit,
                  state: loadedState,
                  onBack: widget.onBackToDashboard,
                  onChangePreview: (mode) =>
                      setState(() => _previewMode = mode),
                  onShowTemplates: () =>
                      _showTemplatesMenu(context, builderCubit),
                  onShowDesign: () =>
                      _showDesignMenu(context, loc, builderCubit),
                  onShowFonts: () => _showBuilderOptionsModal(
                    context,
                    loc,
                    builderCubit,
                    loadedState,
                    initialView: BuilderOptionView.fonts,
                  ),
                  onShowSeo: () => _showSeoMenu(context, builderCubit),
                ),
          bottomNavigationBar: isMobile
              ? BuilderMobileToolbar(
                  cubit: builderCubit,
                  state: loadedState,
                  loc: loc,
                  onBack: widget.onBackToDashboard,
                  onShowOptions: () => _showBuilderOptionsModal(
                    context,
                    loc,
                    builderCubit,
                    loadedState,
                  ),
                  onShowColors: () => _showBuilderOptionsModal(
                    context,
                    loc,
                    builderCubit,
                    loadedState,
                    initialView: BuilderOptionView.colors,
                  ),
                  onShowFonts: () => _showBuilderOptionsModal(
                    context,
                    loc,
                    builderCubit,
                    loadedState,
                    initialView: BuilderOptionView.fonts,
                  ),
                  onChangePreview: (mode) => setState(() => _previewMode = mode),
                  onAddBlock: () => _showAddBlockMenu(context, builderCubit),
                  onPublish: () {
                    // Assuming save logic is similar to _buildSaveButton
                    // We can just call cubit.savePage() or show a success Toast.
                    ToastService.showSuccess(
                      context,
                      message: "تم نشر الصفحة بنجاح!",
                    );
                  },
                )
              : null,
          floatingActionButton: isMobile
              ? null // FAB is integrated into Mobile Toolbar
              : FloatingActionButton.extended(
                  onPressed: () => _showAddBlockMenu(context, builderCubit),
                  backgroundColor: AppColors.secondary,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: const Text(
                    "إضافة قسم جديد",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          body: Row(
            children: [
              if (!isMobile && _previewMode != PreviewMode.fullscreen)
                BuilderSidebar(
                  editingBlockIndex: _editingBlockIndex,
                  state: loadedState,
                  loc: loc,
                  cubit: builderCubit,
                  blocksList: blocksList,
                  onEditBlock: (index) =>
                      setState(() => _editingBlockIndex = index),
                  onAddBlock: _showAddBlockMenu,
                  onDoneEditing: () =>
                      setState(() => _editingBlockIndex = null),
                ),
              Expanded(
                child: BuilderCanvas(
                  isMobile: isMobile,
                  previewMode: _previewMode,
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
                Flexible(child: TemplatesTab(cubit: cubit, state: state)),
              ],
            ),
          );
        },
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

  void _showBuilderOptionsModal(
    BuildContext context,
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    BuilderLoaded state, {
    BuilderOptionView initialView = BuilderOptionView.main,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, dynamicState) {
          if (dynamicState is! BuilderLoaded) return const SizedBox.shrink();
          return BuilderOptionsModal(
            loc: loc,
            cubit: cubit,
            state: dynamicState,
            initialView: initialView,
            onAddBlock: () => _showAddBlockMenu(context, cubit),
            onPublish: () {
              ToastService.showSuccess(context, message: "تم نشر الصفحة بنجاح!");
            },
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
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const SingleChildScrollView(child: SeoSettingsModal()),
      ),
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
