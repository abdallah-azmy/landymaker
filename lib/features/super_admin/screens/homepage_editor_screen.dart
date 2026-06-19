import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/homepage_editor_cubit.dart';
import '../controllers/homepage_editor_state.dart';
import '../widgets/homepage_section_card.dart';
import 'hero_config_sheet.dart';
import 'feature_config_sheet.dart';
import 'cta_config_sheet.dart';

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

    switch (key) {
      case 'hero':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(24),
              topEnd: Radius.circular(24),
            ),
          ),
          builder: (_) => HeroConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
        break;
      case 'features':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(24),
              topEnd: Radius.circular(24),
            ),
          ),
          builder: (_) => FeatureConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
        break;
      case 'cta':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(24),
              topEnd: Radius.circular(24),
            ),
          ),
          builder: (_) => CtaConfigSheet(
            config: config,
            onSave: (updated) => cubit.updateConfig(id, updated),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HomepageEditorCubit, HomepageEditorState>(
      builder: (context, state) {
        if (state is HomepageEditorLoading) {
          return const Center(child: CircularProgressIndicator());
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

        return Padding(
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
        );
      },
    );
  }
}
