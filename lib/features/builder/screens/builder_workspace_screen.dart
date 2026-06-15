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
      // Preserve memory state if already loaded (e.g. guest AI generation session from home page)
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

  void _showAiWizard(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIChatModal(currentPath: currentPath),
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
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
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
          if (state.subdomain.isNotEmpty && (currentPath == '/builder' || currentPath == '/builder/new')) {
            final expectedPath = '/builder/${state.subdomain}';
            if (currentPath != expectedPath) {
              // Use a small delay to avoid redirecting during a build phase
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
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.black,
          appBar: isMobile || _previewMode == PreviewMode.fullscreen
              ? null // Hide AppBar on mobile or in fullscreen preview
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
          bottomNavigationBar:
              isMobile && _previewMode != PreviewMode.fullscreen
              ? BuilderMobileToolbar(
                  cubit: builderCubit,
                  state: loadedState,
                  loc: loc,
                  onBack: widget.onBackToDashboard,
                  onShowAi: () => _showAiWizard(context),
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
                  onChangePreview: (mode) =>
                      setState(() => _previewMode = mode),
                  onAddBlock: () => _showAddBlockMenu(context, builderCubit),
                  onPublish: () {
                    builderCubit.updateSettings(isPublished: true);
                    builderCubit.saveForCurrentUser();
                  },
                )
              : null,
          floatingActionButton:
              isMobile || _previewMode == PreviewMode.fullscreen
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: () => _showAiWizard(context),
                      heroTag: 'ai_fab',
                      backgroundColor: AppColors.primary,
                      icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                      label: const Text(
                        "مساعد الذكاء الاصطناعي",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      onPressed: () => _showAddBlockMenu(context, builderCubit),
                      heroTag: 'add_fab',
                      backgroundColor: AppColors.secondary,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text(
                        "إضافة قسم جديد",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
          body: Stack(
            children: [
              Row(
                children: [
                  if (!isMobile && _previewMode != PreviewMode.fullscreen)
                    _buildProfessionalSidebar(
                      loc, 
                      builderCubit, 
                      loadedState, 
                      blocksList
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        if (!isMobile && _previewMode != PreviewMode.fullscreen)
                          _buildCanvasToolbar(loc, builderCubit),
                        Expanded(
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                              width: _getCanvasWidth(isMobile),
                              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
                              decoration: _previewMode == PreviewMode.fullscreen 
                                ? null 
                                : BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      )
                                    ],
                                    border: Border.all(color: const Color(0xFF1E293B), width: 8),
                                  ),
                              clipBehavior: Clip.antiAlias,
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
                                    setState(() {
                                      _sidebarTabIndex = 0; // Focus Sections tab
                                      _editingBlockIndex = index;
                                    });
                                    // Also notify Cubit to highlight the section if needed
                                    builderCubit.selectSection(index);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_previewMode == PreviewMode.fullscreen)
                Positioned(
                  top: 24,
                  left: loc.isRtl ? null : 24,
                  right: loc.isRtl ? 24 : null,
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),

                          color: Colors.white,
                          iconSize: 22,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _previewMode = isMobile
                                  ? PreviewMode.mobile
                                  : PreviewMode.desktop;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              // Global Upload Manager
              Positioned(
                top: isMobile ? 80 : 24, // Below mobile appbar or canvas top
                right: loc.isRtl ? null : (isMobile ? 16 : 350 + 24), // Clears the 350px sidebar
                left: loc.isRtl ? (isMobile ? 16 : 350 + 24) : null,
                child: const GlobalUploadManagerWidget(),
              ),
              // Auth Gate Overlay (guest users with a non-empty design)
              if (context.watch<AuthCubit>().state is Unauthenticated &&
                  blocksList.isNotEmpty)
                _buildAuthGate(),
            ],
          ),
        ),
      ),
    );
  }

  double? _getCanvasWidth(bool isMobile) {
    if (_previewMode == PreviewMode.fullscreen) return double.infinity;
    if (_previewMode == PreviewMode.mobile) return 390.0; // Standard Mobile Width
    if (_previewMode == PreviewMode.tablet) return 820.0; // Standard Tablet Width
    return null; // Flexible desktop
  }

  Widget _buildAuthGate() {
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.translate('auth_gate_title'),
                      style: AppTypography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.translate('auth_gate_desc'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loc.translate('auth_gate_login'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/register'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loc.translate('auth_gate_register'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalSidebar(
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    BuilderLoaded state,
    List<Map<String, dynamic>> blocks,
  ) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Slate 900
        border: Border(
          right: loc.isRtl
              ? BorderSide.none
              : const BorderSide(color: Color(0xFF1E293B)),
          left: loc.isRtl
              ? const BorderSide(color: Color(0xFF1E293B))
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          // Sidebar Tabs
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E293B), // Slate 800
            child: Row(
              children: [
                _buildSidebarTab(0, Icons.layers_rounded, "الأقسام"),
                _buildSidebarTab(1, Icons.palette_rounded, "التصميم"),
                _buildSidebarTab(2, Icons.settings_suggest_rounded, "الإعدادات"),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _sidebarTabIndex,
              children: [
                BuilderSidebar(
                  editingBlockIndex: _editingBlockIndex,
                  state: state,
                  loc: loc,
                  cubit: cubit,
                  blocksList: blocks,
                  onEditBlock: (index) =>
                      setState(() {
                        _sidebarTabIndex = 0;
                        _editingBlockIndex = index;
                      }),
                  onAddBlock: _showAddBlockMenu,
                  onDoneEditing: () =>
                      setState(() => _editingBlockIndex = null),
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

  Widget _buildSidebarTab(int index, IconData icon, String label) {
    final isSelected = _sidebarTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _sidebarTabIndex = index;
          if (index != 0) _editingBlockIndex = null;
        }),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white24,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white24,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasToolbar(
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
  ) {
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
              _buildDeviceButton(
                PreviewMode.mobile,
                Icons.smartphone_rounded,
                "Mobile",
              ),
              const SizedBox(width: 8),
              _buildDeviceButton(
                PreviewMode.tablet,
                Icons.tablet_android_rounded,
                "Tablet",
              ),
              const SizedBox(width: 8),
              _buildDeviceButton(
                PreviewMode.desktop,
                Icons.desktop_windows_rounded,
                "Desktop",
              ),
              const SizedBox(width: 8),
              _buildDeviceButton(
                PreviewMode.fullscreen,
                Icons.visibility_rounded,
                "Full Screen",
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo_rounded, size: 20),
                onPressed:
                    (cubit.state as BuilderLoaded).canUndo ? cubit.undo : null,
                color: Colors.white70,
              ),
              IconButton(
                icon: const Icon(Icons.redo_rounded, size: 20),
                onPressed:
                    (cubit.state as BuilderLoaded).canRedo ? cubit.redo : null,
                color: Colors.white70,
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => cubit.saveForCurrentUser(),
                icon: const Icon(Icons.cloud_done_rounded, size: 18),
                label: const Text("حفظ التغييرات"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceButton(PreviewMode mode, IconData icon, String tooltip) {
    final isSelected = _previewMode == mode;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _previewMode = mode),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00E5FF).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white24,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showAddBlockMenu(BuildContext context, LandingPageBuilderCubit cubit) {
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

  void _showDesignMenu(
    BuildContext context,
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
  ) {
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
            onAddBlock: () => _showAddBlockMenu(context, cubit),
            onPublish: () {
              cubit.updateSettings(isPublished: true);
              cubit.saveForCurrentUser();
            },
          );
        },
      ),
    );
  }

  void _showSeoMenu(BuildContext context, LandingPageBuilderCubit cubit) {
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
}
