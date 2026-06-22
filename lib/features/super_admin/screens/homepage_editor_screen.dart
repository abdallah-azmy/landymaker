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
import 'section_renderer_config_sheet.dart';

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

    void buildSheet({
      required Widget child,
    }) {
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
      case 'section_renderer':
        buildSheet(
          child: SectionRendererConfigSheet(
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
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${sections.length} أقسام',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text('معاينة حية'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(16),
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
