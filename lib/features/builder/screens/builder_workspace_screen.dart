import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:html' as html;
import '../../../core/router/router_extensions.dart';
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
import '../../dashboard/controllers/media_gallery_cubit.dart';
import '../models/preview_mode.dart';
import '../../home/screens/landymaker_home_screen.dart';
import '../../../core/widgets/organisms/tech_loading_screen.dart';
import '../widgets/modals/ai_chat_modal.dart';
import 'workspace/sidebar_wrapper.dart';
import 'workspace/canvas_container.dart';
import 'workspace/desktop_fab.dart';
import 'workspace/fullscreen_close_button.dart';
import 'workspace/upload_manager_wrapper.dart';
import 'workspace/auth_gate.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ResponsiveLayout.isMobile(context)) {
        setState(() => _previewMode = PreviewMode.mobile);
      }
    });
    LandyMakerHomeScreen.resetScrollPosition();
    final builderCubit = context.read<LandingPageBuilderCubit>();
    context.read<MediaGalleryCubit>().loadImages();
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: const Text("تنبيه: تغييرات غير محفوظة"),
        content: const Text("لديك تعديلات لم يتم حفظها بعد. هل تريد الحفظ قبل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'exit'),
            child: Text("خروج بدون حفظ", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
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

  void _setEditingBlock(int? index) {
    setState(() => _editingBlockIndex = index);
  }

  void _showAiWizard(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    DraggableModalSheet.show(
      context: context,
      child: AIChatModal(currentPath: currentPath),
      initialChildSize: 0.85,
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
    final authState = context.read<AuthCubit>().state;
    final isSuperAdmin = authState is Authenticated && authState.role == 'super_admin';
    DraggableModalSheet.show(
      context: context,
      title: "القوالب الجاهزة",
      initialChildSize: 0.7,
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, state) {
          if (state is! BuilderLoaded) return SizedBox.shrink();
          return TemplatesTab(cubit: cubit, state: state, isSuperAdmin: isSuperAdmin);
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
          if (state is! BuilderLoaded) return SizedBox.shrink();
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
      child: Padding(
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
          if (dynamicState is! BuilderLoaded) return SizedBox.shrink();
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
      child: BlocSelector<LandingPageBuilderCubit, BuilderState, int>(
        selector: (s) {
          if (s is! BuilderLoaded) return -1;
          final blocks = s.designMap['blocks'] as List? ?? [];
          if (index >= blocks.length) return -2;
          return blocks[index].hashCode;
        },
        builder: (context, blockHash) {
          if (blockHash < 0) {
            if (blockHash == -2) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(context)) Navigator.pop(context);
              });
            }
            return SizedBox.shrink();
          }
          final currentState = context.read<LandingPageBuilderCubit>().state as BuilderLoaded;
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
      return const TechLoadingScreen();
    }

    if (state is BuilderEmptyWorkspace) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: EmptyWorkspaceState(),
      );
    }

    if (state is BuilderFailure) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error loading builder canvas", style: AppTypography.h2),
              SizedBox(height: 8),
              Text(state.message, style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.error)),
              SizedBox(height: 20),
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
              loc: loc,
              cubit: builderCubit,
              onBack: widget.onBackToDashboard,
              onSetPreviewMode: _setPreviewMode,
              onSetEditingBlock: _setEditingBlock,
              onShowTemplates: () => _showTemplatesMenu(context, builderCubit),
              onShowDesign: () => _showDesignMenu(context, loc, builderCubit),
              onShowSeo: () => _showSeoMenu(context),
              onShowFonts: () => _showBuilderOptionsModal(context, loc, builderCubit, loadedState, initialView: BuilderOptionView.fonts),
              onShowAi: () => _showAiWizard(context),
              onAddBlock: () => _showAddBlockMenu(context),
              editingBlockIndex: _editingBlockIndex,
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
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final VoidCallback onBack;
  final Function(PreviewMode) onSetPreviewMode;
  final int? editingBlockIndex;
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
    required this.loc,
    required this.cubit,
    required this.onBack,
    required this.onSetPreviewMode,
    required this.editingBlockIndex,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        : DesktopFab(onShowAi: onShowAi, onAddBlock: onAddBlock),
      body: Stack(
        children: [
          Row(
            children: [
              if (previewMode != PreviewMode.fullscreen)
                SidebarWrapper(
                  loc: loc,
                  cubit: cubit,
                  state: state,
                  editingBlockIndex: editingBlockIndex,
                  blocksList: blocksList,
                  onSetEditingBlock: onSetEditingBlock,
                ),
              Expanded(
                child: Center(
                  child: CanvasContainer(
                    previewMode: previewMode,
                    isMobile: false,
                    state: state,
                    loc: loc,
                    onBlockTapped: (index) {
                      onSetEditingBlock(index);
                      cubit.selectSection(index);
                    },
                  ),
                ),
              ),
            ],
          ),
          if (previewMode == PreviewMode.fullscreen)
            FullscreenCloseButton(loc: loc, onBack: () => onSetPreviewMode(PreviewMode.desktop)),
          UploadManagerWrapper(loc: loc, isMobile: false),
          if (context.watch<AuthCubit>().state is Unauthenticated && blocksList.isNotEmpty)
            const BuilderAuthGate(),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            child: CanvasContainer(
              previewMode: previewMode,
              isMobile: true,
              state: state,
              loc: loc,
              onBlockTapped: onBlockTapped,
            ),
          ),
          if (previewMode == PreviewMode.fullscreen)
            FullscreenCloseButton(loc: loc, onBack: () => onSetPreviewMode(PreviewMode.mobile)),
          UploadManagerWrapper(loc: loc, isMobile: true),
          if (context.watch<AuthCubit>().state is Unauthenticated && blocksList.isNotEmpty)
            const BuilderAuthGate(),
        ],
      ),
    );
  }
}


