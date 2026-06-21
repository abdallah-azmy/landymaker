import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../features/dashboard/controllers/landing_pages_cubit.dart';
import '../../../features/dashboard/controllers/landing_pages_state.dart';
import '../../../features/dashboard/controllers/active_website_cubit.dart';
import '../particles/loading_logo_modified.dart';

class WebsiteSwitcher extends StatefulWidget {
  const WebsiteSwitcher({super.key});

  @override
  State<WebsiteSwitcher> createState() => _WebsiteSwitcherState();
}

class _WebsiteSwitcherState extends State<WebsiteSwitcher> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveWebsiteCubit, ActiveWebsiteState>(
      builder: (context, activeState) {
        final activeSite = activeState.website;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _showSwitcherModal(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.2),
                ),
                child: Row(
                  children: [
                    _buildTypeIcon(activeState.websiteType),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activeSite?['subdomain'] ?? "Select Website",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: activeSite != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.unfold_more_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeIcon(String? type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'store':
        icon = Icons.shopping_bag_rounded;
        color = Colors.green;
        break;
      case 'cv':
        icon = Icons.person_rounded;
        color = Theme.of(context).colorScheme.secondary;
        break;
      default:
        icon = Icons.language_rounded;
        color = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  void _showSwitcherModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Switch Website", style: AppTypography.h3),
                    SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Search websites...",
                        prefixIcon: Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: BlocBuilder<LandingPagesCubit, LandingPagesState>(
                        builder: (context, state) {
                          if (state is LandingPagesLoaded) {
                            final filtered = state.pages.where((p) {
                              final name = (p['subdomain'] as String).toLowerCase();
                              return name.contains(_searchQuery);
                            }).toList();

                            if (filtered.isEmpty) {
                              return _buildEmptyResults();
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final site = filtered[index];
                                return _buildSiteItem(context, site);
                              },
                            );
                          }
                          return const Center(child: LoadingLogo(size: 80));
                        },
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

  Widget _buildSiteItem(BuildContext context, Map<String, dynamic> site) {
    final activeCubit = context.read<ActiveWebsiteCubit>();
    final isActive = activeCubit.state.websiteId == site['id'];

    return InkWell(
      onTap: () {
        activeCubit.selectWebsite(site);
        Navigator.pop(context);
        context.go('/dashboard');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            _buildTypeIcon(site['website_type']),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site['subdomain'],
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    (site['website_type'] ?? 'landing_page').toString().toUpperCase(),
                    style: AppTypography.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            SizedBox(height: 12),
            Text("No websites found", style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}
