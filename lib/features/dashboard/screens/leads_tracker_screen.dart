import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
// Removed sl/AuthService imports to maintain architectural boundary
import '../controllers/leads_analytics_cubit.dart';
import '../controllers/leads_analytics_state.dart';

class LeadsTrackerScreen extends StatefulWidget {
  const LeadsTrackerScreen({super.key});

  @override
  State<LeadsTrackerScreen> createState() => _LeadsTrackerScreenState();
}

class _LeadsTrackerScreenState extends State<LeadsTrackerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeadsAnalyticsCubit>().fetchStatsForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final cubit = context.watch<LeadsAnalyticsCubit>();
    final state = cubit.state;

    if (state is LeadsAnalyticsLoading || state is LeadsAnalyticsInitial) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    if (state is LeadsAnalyticsFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Failed to load leads list", style: AppTypography.h2),
            const SizedBox(height: 8),
            Text(state.message, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cubit.fetchStatsForCurrentUser();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final loadedState = state as LeadsAnalyticsLoaded;
    final List<Map<String, dynamic>> leadsList = loadedState.leads;
    final String? errorMessage = loadedState.errorMessage;

    // Columns headers
    final headers = [
      loc.translate('visitor_name'),
      loc.translate('visitor_email'),
      loc.translate('visitor_message'),
      "Submitted Date"
    ];

    // Rows preparation
    final rows = leadsList.map((lead) {
      final formData = lead['form_data'] is Map 
          ? lead['form_data'] 
          : {};
      final String name = formData['name'] ?? '';
      final String email = formData['email'] ?? '';
      final String message = formData['message'] ?? '';
      
      // Format timestamp
      final String rawDate = lead['created_at'] ?? '';
      String formattedDate = '';
      if (rawDate.isNotEmpty) {
        try {
          final parsed = DateTime.parse(rawDate).toLocal();
          formattedDate = "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
        } catch (_) {
          formattedDate = rawDate;
        }
      }

      return [
        Text(name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        Text(email, style: AppTypography.bodyMedium),
        Text(message, style: AppTypography.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        Text(formattedDate, style: AppTypography.caption),
      ];
    }).toList();

    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('leads'),
                    style: AppTypography.h1.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track visitor signups captured from your public landing pages.",
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  cubit.fetchStatsForCurrentUser();
                },
                icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
                tooltip: "Reload Leads List",
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (errorMessage != null) ...[
            Text(errorMessage, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
            const SizedBox(height: 16),
          ],

          Expanded(
            child: ResponsiveDataTable(
              headers: headers,
              rows: rows,
              emptyMessage: loc.translate('no_data'),
            ),
          ),
        ],
      ),
    );
  }
}
