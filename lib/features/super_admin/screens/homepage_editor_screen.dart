import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/particles/loading_logo.dart';
import '../controllers/homepage_editor_cubit.dart';
import '../controllers/homepage_editor_state.dart';
import '../widgets/homepage_section_card.dart';
import 'hero_config_sheet.dart';
import 'feature_config_sheet.dart';
import 'cta_config_sheet.dart';
import 'template_config_sheet.dart';
import 'desktop_preview_config_sheet.dart';
import 'footer_config_sheet.dart';
import 'navbar_config_sheet.dart';

class HomepageEditorScreen extends StatefulWidget {
  const HomepageEditorScreen({super.key});

  @override
  State<HomepageEditorScreen> createState() => _HomepageEditorScreenState();
}

class _HomepageEditorScreenState extends State<HomepageEditorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageEditorCubit>().loadSections();
    });
  }

  void _showConfigSheet(Map<String, dynamic> section) {
    final key = section['section_key'] as String? ?? '';
    final config = section['config'] as Map<String, dynamic>? ?? {};
    final id = section['id'] as String? ?? '';
    final cubit = context.read<HomepageEditorCubit>();

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    void buildSheet({
      required Widget child,
    }) {
      if (isDesktop) {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Config Panel',
          barrierColor: Colors.black.withValues(alpha: 0.45),
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (ctx, animation, secondaryAnimation) {
            final theme = Theme.of(ctx);
            return Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 500,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: child,
                  ),
                ),
              ),
            );
          },
          transitionBuilder: (ctx, animation, secondaryAnimation, childWidget) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: childWidget,
            );
          },
        );
      } else {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(24),
              topEnd: Radius.circular(24),
            ),
          ),
          builder: (_) => child,
        );
      }
    }

    switch (key) {
      case 'hero':
        buildSheet(
          child: HeroConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
      case 'features':
        buildSheet(
          child: FeatureConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
      case 'templates':
        buildSheet(
          child: TemplateConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
      case 'desktop_preview':
        buildSheet(
          child: DesktopPreviewConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
      case 'cta':
        buildSheet(
          child: CtaConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
      case 'footer':
        buildSheet(
          child: FooterConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
      case 'navbar':
        buildSheet(
          child: NavbarConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HomepageEditorCubit, HomepageEditorState>(
      builder: (context, state) {
        if (state is HomepageEditorLoading) {
          return const Center(child: LoadingLogo(size: 48, initialState: LoadingLogoState.loading));
        }
        if (state is HomepageEditorFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(state.message, style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.read<HomepageEditorCubit>().loadSections(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is! HomepageEditorLoaded || state.sections.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.web_asset_off_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('لا توجد أقسام بعد', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        final sections = List<Map<String, dynamic>>.from(state.sections);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ترتيب وإدارة أقسام الصفحة الرئيسية',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'قم بتفعيل، إخفاء أو إعادة ترتيب أقسام الصفحة الرئيسية والتعديل على محتوياتها.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '${sections.length} أقسام',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'تحديث البيانات',
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                        ),
                        onPressed: () => context.read<HomepageEditorCubit>().loadSections(),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('معاينة حية'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 24),
                child: ReorderableListView.builder(
                  itemCount: sections.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final item = sections.removeAt(oldIndex);
                    sections.insert(newIndex, item);
                    final ordered = sections.asMap().entries.map((e) {
                      return {...e.value, 'sort_order': e.key};
                    }).toList();
                    context.read<HomepageEditorCubit>().reorder(ordered);
                  },
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    final isVisible = section['is_visible'] == true;
                    final id = section['id'] as String? ?? '';

                    return HomepageSectionCard(
                      key: ValueKey(section['id'] ?? '$index'),
                      section: section,
                      isVisible: isVisible,
                      index: index,
                      onToggle: () {
                        context.read<HomepageEditorCubit>().toggleVisibility(id, !isVisible);
                      },
                      onEditConfig: () => _showConfigSheet(section),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
