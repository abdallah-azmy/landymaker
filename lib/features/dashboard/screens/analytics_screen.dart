import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/molecules/data_card.dart';
import '../../../core/widgets/molecules/page_context_banner.dart';
// Removed sl/AuthService imports to maintain architectural boundary
import '../controllers/leads_analytics_cubit.dart';
import '../controllers/leads_analytics_state.dart';
import '../controllers/landing_pages_cubit.dart';
import '../controllers/landing_pages_state.dart';
import '../widgets/empty_workspace_state.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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

    final pagesState = context.watch<LandingPagesCubit>().state;
    if (pagesState is LandingPagesLoaded && pagesState.pages.isEmpty) {
      return const EmptyWorkspaceState();
    }

    if (state is LeadsAnalyticsLoading || state is LeadsAnalyticsInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (state is LeadsAnalyticsFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Failed to load analytics data", style: AppTypography.h2),
            SizedBox(height: 8),
            Text(
              state.message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.dangerRed,
              ),
            ),
            SizedBox(height: 16),
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
    final int views = loadedState.views;
    final int conversions = loadedState.conversions;
    final String? errorMessage = loadedState.errorMessage;

    // Calculate Conversion Rate
    final double conversionRate = views > 0 ? (conversions / views) * 100 : 0.0;

    return SingleChildScrollView(
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
                    loc.translate('analytics'),
                    style: AppTypography.h1.copyWith(fontSize: 28),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Track landing page views and capture conversions.",
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  cubit.fetchStatsForCurrentUser();
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.secondary,
                ),
                tooltip: "Reload Analytics Data",
              ),
            ],
          ),
          SizedBox(height: 24),
          const PageContextBanner(
            title: "إحصائيات الصفحة",
            description: "تابع أداء صفحة الهبوط المحددة حالياً من زيارات وتحويلات لمعرفة مدى نجاح حملاتك.",
            icon: Icons.analytics_rounded,
          ),
          SizedBox(height: 16),

          if (errorMessage != null) ...[
            Text(
              errorMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.dangerRed,
              ),
            ),
            SizedBox(height: 16),
          ],

          // Metric Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
              context,
              desktop: 3,
              tablet: 2,
              mobile: 1,
            ),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              DataCard(
                title: loc.translate('views'),
                value: '$views',
                subtitle: '+18% vs last week',
                trendUp: true,
                icon: Icons.visibility_rounded,
                iconColor: AppColors.secondary,
              ),
              DataCard(
                title: loc.translate('conversions'),
                value: '$conversions',
                subtitle: '+8% vs last week',
                trendUp: true,
                icon: Icons.ads_click_rounded,
                iconColor: AppColors.primary,
              ),
              DataCard(
                title: loc.translate('conversion_rate'),
                value: "${conversionRate.toStringAsFixed(1)}%",
                subtitle: 'Optimizing performance',
                icon: Icons.percent_rounded,
                iconColor: AppColors.activeGreen,
              ),
            ],
          ),
          SizedBox(height: 32),

          // Custom Animated Bar Chart Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Daily Performance Trend", style: AppTypography.h3),
                SizedBox(height: 24),
                SizedBox(
                  height: 240,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _buildChartBars(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Returns beautiful reactive bar columns simulating dynamic activity spikes
  List<Widget> _buildChartBars() {
    final List<double> barRatios = [0.4, 0.6, 0.5, 0.85, 0.7, 0.9, 0.45];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (index) {
      final ratio = barRatios[index];
      final label = days[index];

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar Column
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                width: 32,
                height: 180 * ratio,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(label, style: AppTypography.caption),
        ],
      );
    });
  }
}
