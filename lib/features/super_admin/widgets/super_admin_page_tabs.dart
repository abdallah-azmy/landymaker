import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/particles/loading_logo.dart';
import '../../../services/database_service.dart';
import '../../../injection_container.dart' as di;
import '../controllers/homepage_editor_cubit.dart';
import 'home_previews_tab.dart';
import '../screens/homepage_editor_screen.dart';

class SuperAdminHomepageTab extends StatelessWidget {
  const SuperAdminHomepageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomepageEditorCubit(di.sl<DatabaseService>()),
      child: const HomepageEditorScreen(),
    );
  }
}

class SuperAdminHomePreviewsTab extends StatelessWidget {
  const SuperAdminHomePreviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePreviewsTab();
  }
}

class SuperAdminLandingPagesTab extends StatelessWidget {
  const SuperAdminLandingPagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: di.sl<DatabaseService>().fetchAllLandingPages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingLogo());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.web_asset_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('لا توجد صفحات هبوط', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        final pages = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final page = pages[index];
            final id = page['id']?.toString() ?? '';
            final name = page['name'] as String? ?? 'بدون اسم';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.web_rounded, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(name),
                subtitle: Text(id.length > 12 ? '${id.substring(0, 12)}...' : id, style: Theme.of(context).textTheme.bodySmall),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new_rounded),
                  onPressed: () => context.go('/builder/$id'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
