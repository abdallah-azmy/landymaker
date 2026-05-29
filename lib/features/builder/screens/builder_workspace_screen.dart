import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/widgets/molecules/element_property_editor.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/utils/toast_service.dart';
import '../../public_viewer/widgets/section_renderer.dart';
import '../controllers/builder_cubit.dart';
import '../controllers/builder_state.dart';
import '../widgets/editors/block_properties_editor.dart';
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
      builder: (context) {
        return BlocBuilder<LandingPageBuilderCubit, BuilderState>(
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
        );
      },
    );
  }

  void _showAddBlockMenu(BuildContext context, LandingPageBuilderCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("إضافة أقسام للصفحة", style: AppTypography.h3),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildAddBlockItem(
                      icon: Icons.auto_awesome_rounded,
                      label: "هيرو",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('hero');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.list_alt_rounded,
                      label: "مميزات",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('features');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "واتساب",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('whatsapp');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.shopping_bag_outlined,
                      label: "منتجات",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('products');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.qr_code_2_rounded,
                      label: "QR كود",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('qr_code');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.share_rounded,
                      label: "روابط تواصل",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('social_qr');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.payments_rounded,
                      label: "الأسعار",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('pricing');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.question_answer_rounded,
                      label: "الأسئلة الشائعة",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('faq');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.reviews_rounded,
                      label: "آراء العملاء",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('testimonials');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.contact_mail_rounded,
                      label: "معلومات الاتصال",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('contact_info');
                      },
                    ),
                    _buildAddBlockItem(
                      icon: Icons.collections_rounded,
                      label: "معرض الصور",
                      onTap: () {
                        Navigator.pop(context);
                        cubit.addBlock('gallery');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: "إلغاء",
                  isSecondary: true,
                  width: double.infinity,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
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
      builder: (context) {
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
              Flexible(child: TemplatesTab(cubit: cubit)),
            ],
          ),
        );
      },
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
      builder: (context) {
        return BlocBuilder<LandingPageBuilderCubit, BuilderState>(
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
        );
      },
    );
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
                onPressed: () {
                  builderCubit.loadForCurrentUser();
                },
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
    final subdomain = loadedState.subdomain;
    final isSaving = loadedState.isSaving;
    final String? pageId = loadedState.pageId;
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
        appBar: AppBar(
          backgroundColor: AppColors.cardBg,
          title: Text(
            isMobile
                ? loc.translate('workspace')
                : loc.translate('workspace_full'),
            style: AppTypography.h3,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
            ), // Material handles mirroring if configured
            onPressed: widget.onBackToDashboard,
          ),
          actions: [
            if (isMobile) ...[
              IconButton(
                icon: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                ),
                onPressed: () => _showTemplatesMenu(context, builderCubit),
                tooltip: loc.translate('templates'),
              ),
              IconButton(
                icon: const Icon(
                  Icons.color_lens_rounded,
                  color: AppColors.secondary,
                ),
                onPressed: () => _showDesignMenu(context, loc, builderCubit),
                tooltip: loc.translate('design'),
              ),
            ],
            if (!isMobile)
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.smartphone_rounded,
                      color: _isMobilePreview
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _isMobilePreview = true),
                    tooltip: "Mobile Preview",
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.desktop_windows_rounded,
                      color: !_isMobilePreview
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _isMobilePreview = false),
                    tooltip: "Desktop Preview",
                  ),
                ],
              ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: PrimaryButton(
                text: isMobile ? "Save" : "Save & Deploy",
                icon: Icons.rocket_launch_rounded,
                onPressed: () {
                  builderCubit.saveForCurrentUser();
                },
                isLoading: isSaving,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        floatingActionButton: isMobile
            ? FloatingActionButton(
                onPressed: () => _showAddBlockMenu(context, builderCubit),
                backgroundColor: AppColors.secondary,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              )
            : null,
        body: Row(
          children: [
            if (!isMobile)
              Container(
                width: 380,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    right: BorderSide(color: AppColors.border, width: 1.5),
                  ),
                ),
                child: loadedState.focusedElementId != null
                    ? _buildElementEditor(builderCubit, loadedState)
                    : (_editingBlockIndex != null &&
                              _editingBlockIndex! < blocksList.length
                          ? BlockPropertiesEditor(
                              index: _editingBlockIndex!,
                              state: loadedState,
                              onDone: () =>
                                  setState(() => _editingBlockIndex = null),
                            )
                          : _buildDefaultSidebar(
                              loc,
                              builderCubit,
                              loadedState,
                              blocksList,
                            )),
              ),

            Expanded(
              child: Container(
                color: const Color(0xFF0F172A),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: isMobile
                                ? constraints.maxWidth
                                : (_isMobilePreview
                                      ? 375
                                      : constraints.maxWidth.clamp(
                                          0.0,
                                          1000.0,
                                        )),
                            height: isMobile ? constraints.maxHeight : null,
                            margin: isMobile
                                ? EdgeInsets.zero
                                : const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 24,
                                  ),
                            decoration: BoxDecoration(
                              color: loadedState.theme.background,
                              borderRadius: isMobile
                                  ? BorderRadius.zero
                                  : BorderRadius.circular(12),
                              boxShadow: isMobile
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 36,
                                      ),
                                    ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                size: Size(
                                  isMobile
                                      ? constraints.maxWidth
                                      : (_isMobilePreview
                                            ? 375
                                            : constraints.maxWidth.clamp(
                                                0.0,
                                                1000.0,
                                              )),
                                  isMobile
                                      ? constraints.maxHeight
                                      : MediaQuery.of(context).size.height,
                                ),
                              ),
                              child: Column(
                                children: [
                                  if (!isMobile)
                                    Container(
                                      height: 36,
                                      color: const Color(0xFFE2E8F0),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Row(
                                            children: List.generate(
                                              3,
                                              (i) => Container(
                                                width: 8,
                                                height: 8,
                                                margin: const EdgeInsets.only(
                                                  right: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: i == 0
                                                      ? Colors.red
                                                      : (i == 1
                                                            ? Colors.orange
                                                            : Colors.green),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              alignment: Alignment.centerLeft,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                "https://${subdomain.isEmpty ? 'your-brand' : subdomain}.landymaker.com",
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.grey,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  Expanded(
                                    child: Container(
                                      color: loadedState.theme.background,
                                      child: SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: isMobile
                                                ? constraints.maxHeight
                                                : (constraints.maxHeight - 36),
                                          ),
                                          child: Directionality(
                                            textDirection: loc.isRtl
                                                ? TextDirection.rtl
                                                : TextDirection.ltr,
                                            child: SectionRenderer(
                                              key: ValueKey(
                                                blocksList.hashCode ^
                                                    loadedState.theme.hashCode,
                                              ),
                                              blocks: blocksList,
                                              pageId: pageId ?? 'preview',
                                              theme: loadedState.theme,
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
                                                    _editingBlockIndex = index;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementEditor(LandingPageBuilderCubit cubit, BuilderLoaded state) {
    final section = state.designMap['blocks'][state.focusedSectionIndex];
    final element = (section['elements'] as List).firstWhere(
      (e) => e['id'] == state.focusedElementId,
    );

    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.cardBg,
          title: const Text("تعديل العنصر", style: TextStyle(fontSize: 16)),
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

  Widget _buildDefaultSidebar(
    LocalizationCubit loc,
    LandingPageBuilderCubit builderCubit,
    BuilderLoaded loadedState,
    List<Map<String, dynamic>> blocksList,
  ) {
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
                Tab(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                  text: loc.translate('templates'),
                ),
                Tab(
                  icon: const Icon(Icons.color_lens_rounded, size: 20),
                  text: loc.translate('design'),
                ),
                Tab(
                  icon: const Icon(Icons.layers_rounded, size: 20),
                  text: loc.translate('content'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                TemplatesTab(cubit: builderCubit),
                DesignTab(loc: loc, cubit: builderCubit, state: loadedState),
                ContentTab(
                  cubit: builderCubit,
                  loc: loc,
                  blocks: blocksList,
                  onEditBlock: (index) =>
                      setState(() => _editingBlockIndex = index),
                  onAddBlock: _showAddBlockMenu,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
