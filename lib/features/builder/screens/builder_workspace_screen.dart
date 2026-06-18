import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:html' as html;
import 'dart:ui';
import '../../../core/router/router_extensions.dart';
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
import '../../home/screens/landymaker_home_screen.dart';
import '../../../core/widgets/organisms/tech_loading_screen.dart';
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

  @override
  void initState() {
    super.initState();
    LandyMakerHomeScreen.resetScrollPosition();
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
          if (state is! BuilderLoaded) return SizedBox.shrink();
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
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, currentState) {
          if (currentState is! BuilderLoaded) return SizedBox.shrink();
          final blocks = currentState.designMap['blocks'] as List? ?? [];
          if (index >= blocks.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) Navigator.pop(context);
            });
            return SizedBox.shrink();
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
                  editingBlockIndex: editingBlockIndex,
                  blocksList: blocksList,
                  onSetEditingBlock: onSetEditingBlock,
                ),
              Expanded(
                child: Center(
                  child: _CanvasContainer(
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: Icon(Icons.auto_awesome_rounded, color: Colors.white),
          label: const Text("مساعد الذكاء الاصطناعي", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: onAddBlock,
          heroTag: 'add_fab',
          backgroundColor: Theme.of(context).colorScheme.secondary,
          icon: Icon(Icons.add_rounded, color: Colors.white),
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
  final int? editingBlockIndex;
  final List<Map<String, dynamic>> blocksList;
  final Function(int?) onSetEditingBlock;

  const _SidebarWrapper({
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
      height: (previewMode == PreviewMode.fullscreen || isMobile) ? double.infinity : null,
      margin: (previewMode == PreviewMode.fullscreen || isMobile) ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      decoration: previewMode == PreviewMode.fullscreen 
        ? null 
        : BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 10)],
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 8),
          ),
      clipBehavior: previewMode == PreviewMode.fullscreen ? Clip.none : Clip.antiAlias,
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
    return PositionedDirectional(
      top: 24,
      start: 24,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
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
    return PositionedDirectional(
      top: isMobile ? 80 : 24,
      end: isMobile ? 16 : 350 + 24,
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
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 40, offset: const Offset(0, 8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LockIcon(),
                    SizedBox(height: 20),
                    Text(loc.translate('auth_gate_title'), style: AppTypography.h3, textAlign: TextAlign.center),
                    SizedBox(height: 12),
                    Text(loc.translate('auth_gate_desc'), style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                    SizedBox(height: 28),
                    _AuthButton(label: loc.translate('auth_gate_login'), onPressed: () => context.safePop(fallbackPath: '/login'), primary: true),
                    SizedBox(height: 12),
                    _AuthButton(label: loc.translate('auth_gate_register'), onPressed: () => context.safePop(fallbackPath: '/register'), primary: false),
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
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(Icons.lock_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 40),
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
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary, side: BorderSide(color: Theme.of(context).colorScheme.primary), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
    );
  }
}
