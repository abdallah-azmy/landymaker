import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:html' as html;
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/utils/toast_service.dart';
import '../../../core/widgets/draggable_modal_sheet.dart';
import '../controllers/builder_cubit.dart';
import '../controllers/builder_state.dart';
import '../widgets/editors/block_properties_editor.dart';
import '../widgets/modals/builder_options_modal.dart';
import '../widgets/modals/section_library_modal.dart';
import '../widgets/modals/seo_settings_modal.dart';
import '../widgets/organisms/builder_app_bar.dart';
import '../widgets/organisms/builder_canvas.dart';
import '../widgets/organisms/builder_sidebar.dart';
import '../widgets/organisms/global_upload_manager_widget.dart';
import '../widgets/tabs/builder_sidebar_tabs.dart';
import '../widgets/molecules/builder_mobile_toolbar.dart';
import '../../dashboard/widgets/empty_workspace_state.dart';
import '../models/preview_mode.dart';
import '../widgets/modals/ai_chat_modal.dart';

/// ======================================================
/// FEATURE: Builder Workspace Screen
/// PURPOSE: The primary visual editor for creating and modifying landing pages.
/// ARCHITECTURE: 
/// - State Hoisting: All workspace state (_editingBlockIndex, _previewMode, _sidebarTabIndex) 
///   is managed in the parent [BuilderWorkspaceScreen] state.
/// - Layout Delegation: Renders [_DesktopBuilderWorkspace] or [_MobileBuilderWorkspace]
///   based on responsive constraints.
/// ======================================================
class BuilderWorkspaceScreen extends StatefulWidget {
  final VoidCallback onBackToDashboard;
  final String? pageId;

  const BuilderWorkspaceScreen({
    super.key,
    required this.onBackToDashboard,
    this.pageId,
  });

  @override
  State<BuilderWorkspaceScreen> createState() => _BuilderWorkspaceScreenState();
}

class _BuilderWorkspaceScreenState extends State<BuilderWorkspaceScreen> {
  int? _editingBlockIndex;
  PreviewMode _previewMode = PreviewMode.desktop;
  int _sidebarTabIndex = 0; // 0: Sections, 1: Global Theme, 2: Page Settings

  @override
  void initState() {
    super.initState();
    final builderCubit = context.read<LandingPageBuilderCubit>();
    if (widget.pageId != null && widget.pageId != 'new') {
      builderCubit.loadPageById(widget.pageId!);
    } else {
      if (builderCubit.state is! BuilderLoaded) {
        builderCubit.loadForCurrentUser();
      }
    }
    _setupBrowserWarning();
  }

  void _setupBrowserWarning() {
    html.window.onBeforeUnload.listen((event) {
      final state = context.read<LandingPageBuilderCubit>().state;
      if (state is BuilderLoaded && state.hasUnsavedChanges) {
        if (event is html.BeforeUnloadEvent) {
          event.returnValue = 'You have unsaved changes. Are you sure you want to leave?';
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
        content: const Text("لديك تعديلات لم يتم حفظها بعد. هل تريد الحفظ قبل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'exit'),
            child: const Text("خروج بدون حفظ", style: TextStyle(color: AppColors.dangerRed)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.activeGreen),
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

  void _setPreviewMode(PreviewMode mode) {
    setState(() => _previewMode = mode);
  }

  void _setSidebarTab(int index) {
    setState(() {
      _sidebarTabIndex = index;
      if (index != 0) _editingBlockIndex = null;
    });
  }

  void _setEditingBlock(int? index) {
    setState(() => _editingBlockIndex = index);
  }

  void _showAiWizard(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIChatModal(currentPath: currentPath),
    );
  }

  void _showAddBlockMenu(BuildContext context) {
    DraggableModalSheet.show(
      context: context,
      title: "مكتبة الأقسام",
      initialChildSize: 0.8,
      child: const SectionLibraryModal(),
    );
  }

  void _showTemplatesMenu(BuildContext context, LandingPageBuilderCubit cubit) {
    DraggableModalSheet.show(
      context: context,
      title: "القوالب الجاهزة",
      initialChildSize: 0.7,
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, state) {
          if (state is! BuilderLoaded) return const SizedBox.shrink();
          return TemplatesTab(cubit: cubit, state: state);
        },
      ),
    );
  }

  void _showDesignMenu(BuildContext context, LocalizationCubit loc, LandingPageBuilderCubit cubit) {
    DraggableModalSheet.show(
      context: context,
      title: "تصميم الصفحة",
      initialChildSize: 0.6,
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, state) {
          if (state is! BuilderLoaded) return const SizedBox.shrink();
          return DesignTab(loc: loc, cubit: cubit, state: state);
        },
      ),
    );
  }

  void _showSeoMenu(BuildContext context) {
    DraggableModalSheet.show(
      context: context,
      title: "إعدادات SEO",
      initialChildSize: 0.8,
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        child: SingleChildScrollView(child: SeoSettingsModal()),
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
    DraggableModalSheet.show(
      context: context,
      title: "خيارات المحرر",
      initialChildSize: 0.5,
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, dynamicState) {
          if (dynamicState is! BuilderLoaded) return const SizedBox.shrink();
          return BuilderOptionsModal(
            loc: loc,
            cubit: cubit,
            state: dynamicState,
            initialView: initialView,
            onAddBlock: () => _showAddBlockMenu(context),
            onPublish: () {
              cubit.updateSettings(isPublished: true);
              cubit.saveForCurrentUser();
            },
          );
        },
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
    DraggableModalSheet.show(
      context: context,
      title: "تعديل القسم",
      initialChildSize: 0.8,
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, currentState) {
          if (currentState is! BuilderLoaded) return const SizedBox.shrink();
          final blocks = currentState.designMap['blocks'] as List? ?? [];
          if (index >= blocks.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) Navigator.pop(context);
            });
            return const SizedBox.shrink();
          }
          return BlockPropertiesEditor(
            index: index,
            state: currentState,
            isBottomSheet: true,
            onDone: () => Navigator.pop(context),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final builderCubit = context.watch<LandingPageBuilderCubit>();
    final state = builderCubit.state;

    if (state is BuilderLoading || state is BuilderInitial) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    if (state is BuilderEmptyWorkspace) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: EmptyWorkspaceState(),
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
              Text(state.message, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => builderCubit.loadForCurrentUser(), child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    final loadedState = state as BuilderLoaded;

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
          final currentPath = GoRouterState.of(context).uri.path;
          if (state.subdomain.isNotEmpty && (currentPath == '/builder' || currentPath == '/builder/new')) {
            final expectedPath = '/builder/${state.subdomain}';
            if (currentPath != expectedPath) {
              Future.microtask(() {
                if (mounted) context.replace(expectedPath);
              });
            }
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = ResponsiveLayout.isMobile(context, width: constraints.maxWidth);

            if (isMobile) {
              return _MobileBuilderWorkspace(
                state: loadedState,
                previewMode: _previewMode,
                loc: loc,
                cubit: builderCubit,
                onBack: widget.onBackToDashboard,
                onSetPreviewMode: _setPreviewMode,
                onShowAi: () => _showAiWizard(context),
                onShowOptions: () => _showBuilderOptionsModal(context, loc, builderCubit, loadedState),
                onShowColors: () => _showBuilderOptionsModal(context, loc, builderCubit, loadedState, initialView: BuilderOptionView.colors),
                onShowFonts: () => _showBuilderOptionsModal(context, loc, builderCubit, loadedState, initialView: BuilderOptionView.fonts),
                onAddBlock: () => _showAddBlockMenu(context),
                onBlockTapped: (index) => _openEditBottomSheet(context, loc, builderCubit, loadedState, index),
              );
            }

            return _DesktopBuilderWorkspace(
              state: loadedState,
              previewMode: _previewMode,
              sidebarTabIndex: _sidebarTabIndex,
              editingBlockIndex: _editingBlockIndex,
              loc: loc,
              cubit: builderCubit,
              onBack: widget.onBackToDashboard,
              onSetPreviewMode: _setPreviewMode,
              onSetSidebarTab: _setSidebarTab,
              onSetEditingBlock: _setEditingBlock,
              onShowTemplates: () => _showTemplatesMenu(context, builderCubit),
              onShowDesign: () => _showDesignMenu(context, loc, builderCubit),
              onShowSeo: () => _showSeoMenu(context),
              onShowFonts: () => _showBuilderOptionsModal(context, loc, builderCubit, loadedState, initialView: BuilderOptionView.fonts),
              onShowAi: () => _showAiWizard(context),
              onAddBlock: () => _showAddBlockMenu(context),
            );
          },
        ),
      ),
    );
  }
}

/// Desktop version of the Builder Workspace.
class _DesktopBuilderWorkspace extends StatelessWidget {
  final BuilderLoaded state;
  final PreviewMode previewMode;
  final int sidebarTabIndex;
  final int? editingBlockIndex;
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final VoidCallback onBack;
  final Function(PreviewMode) onSetPreviewMode;
  final Function(int) onSetSidebarTab;
  final Function(int?) onSetEditingBlock;
  final VoidCallback onShowTemplates;
  final VoidCallback onShowDesign;
  final VoidCallback onShowSeo;
  final VoidCallback onShowFonts;
  final VoidCallback onShowAi;
  final VoidCallback onAddBlock;

  const _DesktopBuilderWorkspace({
    required this.state,
    required this.previewMode,
    required this.sidebarTabIndex,
    this.editingBlockIndex,
    required this.loc,
    required this.cubit,
    required this.onBack,
    required this.onSetPreviewMode,
    required this.onSetSidebarTab,
    required this.onSetEditingBlock,
    required this.onShowTemplates,
    required this.onShowDesign,
    required this.onShowSeo,
    required this.onShowFonts,
    required this.onShowAi,
    required this.onAddBlock,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> blocksList = (state.designMap['blocks'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map)).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: previewMode == PreviewMode.fullscreen 
        ? null 
        : BuilderAppBar(
            isMobile: false,
            previewMode: previewMode,
            loc: loc,
            cubit: cubit,
            state: state,
            onBack: onBack,
            onChangePreview: onSetPreviewMode,
            onShowTemplates: onShowTemplates,
            onShowDesign: onShowDesign,
            onShowFonts: onShowFonts,
            onShowSeo: onShowSeo,
          ),
      floatingActionButton: previewMode == PreviewMode.fullscreen
        ? null
        : _DesktopFab(onShowAi: onShowAi, onAddBlock: onAddBlock),
      body: Stack(
        children: [
          Row(
            children: [
              if (previewMode != PreviewMode.fullscreen)
                _SidebarWrapper(
                  loc: loc,
                  cubit: cubit,
                  state: state,
                  sidebarTabIndex: sidebarTabIndex,
                  editingBlockIndex: editingBlockIndex,
                  blocksList: blocksList,
                  onSetSidebarTab: onSetSidebarTab,
                  onSetEditingBlock: onSetEditingBlock,
                ),
              Expanded(
                child: Column(
                  children: [
                    if (previewMode != PreviewMode.fullscreen)
                      _DesktopCanvasToolbar(
                        previewMode: previewMode,
                        onSetPreviewMode: onSetPreviewMode,
                        cubit: cubit,
                        state: state,
                      ),
                    Expanded(
                      child: Center(
                        child: _CanvasContainer(
                          previewMode: previewMode,
                          isMobile: false,
                          state: state,
                          loc: loc,
                          onBlockTapped: (index) {
                            onSetSidebarTab(0);
                            onSetEditingBlock(index);
                            cubit.selectSection(index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (previewMode == PreviewMode.fullscreen)
            _FullscreenCloseButton(loc: loc, onBack: () => onSetPreviewMode(PreviewMode.desktop)),
          _UploadManagerWrapper(loc: loc, isMobile: false),
          if (context.watch<AuthCubit>().state is Unauthenticated && blocksList.isNotEmpty)
            const _AuthGate(),
        ],
      ),
    );
  }
}

/// Mobile version of the Builder Workspace.
class _MobileBuilderWorkspace extends StatelessWidget {
  final BuilderLoaded state;
  final PreviewMode previewMode;
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final VoidCallback onBack;
  final Function(PreviewMode) onSetPreviewMode;
  final VoidCallback onShowAi;
  final VoidCallback onShowOptions;
  final VoidCallback onShowColors;
  final VoidCallback onShowFonts;
  final VoidCallback onAddBlock;
  final Function(int) onBlockTapped;

  const _MobileBuilderWorkspace({
    required this.state,
    required this.previewMode,
    required this.loc,
    required this.cubit,
    required this.onBack,
    required this.onSetPreviewMode,
    required this.onShowAi,
    required this.onShowOptions,
    required this.onShowColors,
    required this.onShowFonts,
    required this.onAddBlock,
    required this.onBlockTapped,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> blocksList = (state.designMap['blocks'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map)).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: previewMode != PreviewMode.fullscreen
        ? BuilderMobileToolbar(
            cubit: cubit,
            state: state,
            loc: loc,
            onBack: onBack,
            onShowAi: onShowAi,
            onShowOptions: onShowOptions,
            onShowColors: onShowColors,
            onShowFonts: onShowFonts,
            onChangePreview: onSetPreviewMode,
            onAddBlock: onAddBlock,
            onPublish: () {
              cubit.updateSettings(isPublished: true);
              cubit.saveForCurrentUser();
            },
          )
        : null,
      body: Stack(
        children: [
          Center(
            child: _CanvasContainer(
              previewMode: previewMode,
              isMobile: true,
              state: state,
              loc: loc,
              onBlockTapped: onBlockTapped,
            ),
          ),
          if (previewMode == PreviewMode.fullscreen)
            _FullscreenCloseButton(loc: loc, onBack: () => onSetPreviewMode(PreviewMode.mobile)),
          _UploadManagerWrapper(loc: loc, isMobile: true),
          if (context.watch<AuthCubit>().state is Unauthenticated && blocksList.isNotEmpty)
            const _AuthGate(),
        ],
      ),
    );
  }
}

/// Shared Desktop FABs.
class _DesktopFab extends StatelessWidget {
  final VoidCallback onShowAi;
  final VoidCallback onAddBlock;

  const _DesktopFab({required this.onShowAi, required this.onAddBlock});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: onShowAi,
          heroTag: 'ai_fab',
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          label: const Text("مساعد الذكاء الاصطناعي", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: onAddBlock,
          heroTag: 'add_fab',
          backgroundColor: AppColors.secondary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text("إضافة قسم جديد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

/// Shared Sidebar Wrapper for Desktop.
class _SidebarWrapper extends StatelessWidget {
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;
  final int sidebarTabIndex;
  final int? editingBlockIndex;
  final List<Map<String, dynamic>> blocksList;
  final Function(int) onSetSidebarTab;
  final Function(int?) onSetEditingBlock;

  const _SidebarWrapper({
    required this.loc,
    required this.cubit,
    required this.state,
    required this.sidebarTabIndex,
    this.editingBlockIndex,
    required this.blocksList,
    required this.onSetSidebarTab,
    required this.onSetEditingBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          right: loc.isRtl ? BorderSide.none : const BorderSide(color: Color(0xFF1E293B)),
          left: loc.isRtl ? const BorderSide(color: Color(0xFF1E293B)) : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                _SidebarTab(index: 0, icon: Icons.layers_rounded, label: "الأقسام", isSelected: sidebarTabIndex == 0, onTap: () => onSetSidebarTab(0)),
                _SidebarTab(index: 1, icon: Icons.palette_rounded, label: "التصميم", isSelected: sidebarTabIndex == 1, onTap: () => onSetSidebarTab(1)),
                _SidebarTab(index: 2, icon: Icons.settings_suggest_rounded, label: "الإعدادات", isSelected: sidebarTabIndex == 2, onTap: () => onSetSidebarTab(2)),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: sidebarTabIndex,
              children: [
                BuilderSidebar(
                  editingBlockIndex: editingBlockIndex,
                  state: state,
                  loc: loc,
                  cubit: cubit,
                  blocksList: blocksList,
                  onEditBlock: (index) {
                    onSetSidebarTab(0);
                    onSetEditingBlock(index);
                  },
                  onAddBlock: (context, cubit) => DraggableModalSheet.show(context: context, title: "مكتبة الأقسام", initialChildSize: 0.8, child: const SectionLibraryModal()),
                  onDoneEditing: () => onSetEditingBlock(null),
                ),
                DesignTab(loc: loc, cubit: cubit, state: state),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: SingleChildScrollView(child: SeoSettingsModal()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared Sidebar Tab.
class _SidebarTab extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTab({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00E5FF) : Colors.white24, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white24, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

/// Shared Canvas Toolbar for Desktop.
class _DesktopCanvasToolbar extends StatelessWidget {
  final PreviewMode previewMode;
  final Function(PreviewMode) onSetPreviewMode;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;

  const _DesktopCanvasToolbar({
    required this.previewMode,
    required this.onSetPreviewMode,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _DeviceButton(mode: PreviewMode.mobile, icon: Icons.smartphone_rounded, tooltip: "Mobile", currentMode: previewMode, onSet: onSetPreviewMode),
              const SizedBox(width: 8),
              _DeviceButton(mode: PreviewMode.tablet, icon: Icons.tablet_android_rounded, tooltip: "Tablet", currentMode: previewMode, onSet: onSetPreviewMode),
              const SizedBox(width: 8),
              _DeviceButton(mode: PreviewMode.desktop, icon: Icons.desktop_windows_rounded, tooltip: "Desktop", currentMode: previewMode, onSet: onSetPreviewMode),
              const SizedBox(width: 8),
              _DeviceButton(mode: PreviewMode.fullscreen, icon: Icons.visibility_rounded, tooltip: "Full Screen", currentMode: previewMode, onSet: onSetPreviewMode),
            ],
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.undo_rounded, size: 20), onPressed: state.canUndo ? cubit.undo : null, color: Colors.white70),
              IconButton(icon: const Icon(Icons.redo_rounded, size: 20), onPressed: state.canRedo ? cubit.redo : null, color: Colors.white70),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => cubit.saveForCurrentUser(),
                icon: const Icon(Icons.cloud_done_rounded, size: 18),
                label: const Text("حفظ التغييرات"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared Device Selector Button.
class _DeviceButton extends StatelessWidget {
  final PreviewMode mode;
  final IconData icon;
  final String tooltip;
  final PreviewMode currentMode;
  final Function(PreviewMode) onSet;

  const _DeviceButton({
    required this.mode,
    required this.icon,
    required this.tooltip,
    required this.currentMode,
    required this.onSet,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == mode;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onSet(mode),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isSelected ? const Color(0xFF00E5FF) : Colors.white24, size: 20),
        ),
      ),
    );
  }
}

/// Shared Canvas Container.
class _CanvasContainer extends StatelessWidget {
  final PreviewMode previewMode;
  final bool isMobile;
  final BuilderLoaded state;
  final LocalizationCubit loc;
  final Function(int) onBlockTapped;

  const _CanvasContainer({
    required this.previewMode,
    required this.isMobile,
    required this.state,
    required this.loc,
    required this.onBlockTapped,
  });

  @override
  Widget build(BuildContext context) {
    double? width;
    if (previewMode == PreviewMode.mobile) width = 390.0;
    else if (previewMode == PreviewMode.tablet) width = 820.0;
    else if (previewMode == PreviewMode.fullscreen) width = double.infinity;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: width,
      margin: previewMode == PreviewMode.fullscreen ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      decoration: previewMode == PreviewMode.fullscreen 
        ? null 
        : BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 10)],
            border: Border.all(color: const Color(0xFF1E293B), width: 8),
          ),
      clipBehavior: Clip.antiAlias,
      child: BuilderCanvas(
        isMobile: isMobile,
        previewMode: previewMode,
        state: state,
        loc: loc,
        onBlockTapped: onBlockTapped,
      ),
    );
  }
}

/// Fullscreen mode close button.
class _FullscreenCloseButton extends StatelessWidget {
  final LocalizationCubit loc;
  final VoidCallback onBack;

  const _FullscreenCloseButton({required this.loc, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      left: loc.isRtl ? null : 24,
      right: loc.isRtl ? 24 : null,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              iconSize: 22,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: onBack,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared Upload Manager Wrapper.
class _UploadManagerWrapper extends StatelessWidget {
  final LocalizationCubit loc;
  final bool isMobile;

  const _UploadManagerWrapper({required this.loc, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isMobile ? 80 : 24,
      right: loc.isRtl ? null : (isMobile ? 16 : 350 + 24),
      left: loc.isRtl ? (isMobile ? 16 : 350 + 24) : null,
      child: const GlobalUploadManagerWidget(),
    );
  }
}

/// Shared Auth Gate Overlay.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 40, offset: const Offset(0, 8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LockIcon(),
                    const SizedBox(height: 20),
                    Text(loc.translate('auth_gate_title'), style: AppTypography.h3, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text(loc.translate('auth_gate_desc'), style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    _AuthButton(label: loc.translate('auth_gate_login'), onPressed: () => context.go('/login'), primary: true),
                    const SizedBox(height: 12),
                    _AuthButton(label: loc.translate('auth_gate_register'), onPressed: () => context.go('/register'), primary: false),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LockIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 40),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  const _AuthButton({required this.label, required this.onPressed, required this.primary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: primary 
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
    );
  }
}
