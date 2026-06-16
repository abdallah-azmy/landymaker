import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/molecules/data_card.dart';
import '../controllers/leads_analytics_cubit.dart';
import '../controllers/leads_analytics_state.dart';

class AnalyticsOverviewWidget extends StatefulWidget {
  final int totalViews;
  final int totalLeads;

  const AnalyticsOverviewWidget({
    super.key,
    required this.totalViews,
    required this.totalLeads,
  });

  @override
  State<AnalyticsOverviewWidget> createState() => _AnalyticsOverviewWidgetState();
}

class _AnalyticsOverviewWidgetState extends State<AnalyticsOverviewWidget> {
  @override
  void initState() {
    super.initState();
    context.read<LeadsAnalyticsCubit>().fetchStatsForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final isMobile = ResponsiveLayout.isMobile(context);

    return BlocBuilder<LeadsAnalyticsCubit, LeadsAnalyticsState>(
      builder: (context, state) {
        final bool loading = state is LeadsAnalyticsLoading || state is LeadsAnalyticsInitial;

        final int uniqueVisitors;
        final int conversions;
        if (state is LeadsAnalyticsLoaded) {
          uniqueVisitors = state.uniqueVisitors;
          conversions = state.conversions;
        } else {
          uniqueVisitors = widget.totalViews > 0 ? (widget.totalViews * 0.8).toInt() : 0;
          conversions = widget.totalLeads;
        }

        final conversionRate = widget.totalViews == 0
            ? "0%"
            : "${((widget.totalLeads / widget.totalViews) * 100).toStringAsFixed(1)}%";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(
              loc, isMobile, loading,
              widget.totalViews, uniqueVisitors, conversions, conversionRate,
            ),
            SizedBox(height: 24),
            _buildChartSection(loc),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(
    LocalizationCubit loc,
    bool isMobile,
    bool loading,
    int totalViews,
    int uniqueVisitors,
    int conversions,
    String conversionRate,
  ) {
    final stats = [
      (loc.translate('views'), '$totalViews', Icons.visibility_rounded, AppColors.secondary, null),
      (loc.translate('total_unique_visitors'), '$uniqueVisitors', Icons.person_search_rounded, Colors.orange, null),
      (loc.translate('conversions'), '$conversions', Icons.shopping_bag_rounded, AppColors.activeGreen, null),
      (loc.translate('conversion_rate'), conversionRate, Icons.analytics_rounded, AppColors.primary, null),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCard(stats[0], loading)),
              SizedBox(width: 16),
              Expanded(child: _buildCard(stats[1], loading)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCard(stats[2], loading)),
              SizedBox(width: 16),
              Expanded(child: _buildCard(stats[3], loading)),
            ],
          ),
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.map((s) => SizedBox(width: 230, child: _buildCard(s, loading))).toList(),
    );
  }

  Widget _buildCard((String, String, IconData, Color, bool?) stat, bool loading) {
    final (title, value, icon, color, _) = stat;
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return DataCard(
      title: title,
      value: value,
      icon: icon,
      iconColor: color,
    );
  }

  Widget _buildChartSection(LocalizationCubit loc) {
    final List<double> barRatios = [0.4, 0.6, 0.5, 0.85, 0.7, 0.9, 0.45];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('daily_performance_trend'), style: AppTypography.h3),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final ratio = barRatios[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                    Text(days[index], style: AppTypography.caption),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
