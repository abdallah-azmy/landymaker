import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/particles/loading_logo.dart';
import '../../../core/widgets/atoms/cube_refresh_indicator.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';
import '../widgets/super_admin_users_tab.dart';
import '../widgets/super_admin_plans_tab.dart';
import '../widgets/super_admin_security_tab.dart';
import '../widgets/super_admin_audit_tab.dart';
import '../widgets/super_admin_stats_tab.dart';
import '../widgets/super_admin_payments_tab.dart';
import '../widgets/super_admin_affiliates_tab.dart';
import '../widgets/super_admin_templates_tab.dart';
import '../widgets/super_admin_broadcast_tab.dart';
import '../widgets/super_admin_page_tabs.dart';

class SuperAdminPanelScreen extends StatefulWidget {
  const SuperAdminPanelScreen({super.key});

  @override
  State<SuperAdminPanelScreen> createState() => _SuperAdminPanelScreenState();
}

class _SuperAdminPanelScreenState extends State<SuperAdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _lastTabParam;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this);
    context.read<SuperAdminCubit>().fetchAdminMetrics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    if (tabParam != _lastTabParam) {
      _lastTabParam = tabParam;
      if (tabParam != null) {
        final tabIndex = _tabIndexForParam(tabParam);
        if (tabIndex != null && tabIndex != _tabController.index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _tabController.animateTo(tabIndex);
          });
        }
      }
    }
  }

  int? _tabIndexForParam(String tab) {
    switch (tab) {
      case 'users':
        return 0;
      case 'plans':
        return 1;
      case 'security':
        return 2;
      case 'audit':
        return 3;
      case 'stats':
        return 4;
      case 'payments':
        return 5;
      case 'affiliates':
        return 6;
      case 'templates':
        return 7;
      case 'broadcast':
        return 8;
      case 'homepage':
        return 9;
      case 'home-previews':
        return 10;
      case 'landing-pages':
        return 11;
      default:
        return 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalizationCubit>();
    final state = context.watch<SuperAdminCubit>().state;

    return BlocListener<SuperAdminCubit, SuperAdminState>(
      listener: (context, stateListener) {
        if (stateListener is SuperAdminFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(stateListener.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        labelColor: Theme.of(context).colorScheme.secondary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        tabs: const [
          Tab(text: "Users", icon: Icon(Icons.people_rounded)),
          Tab(text: "Plans & Config", icon: Icon(Icons.settings_suggest_rounded)),
          Tab(text: "Security Limits", icon: Icon(Icons.security_rounded)),
          Tab(text: "Audit Logs", icon: Icon(Icons.history_rounded)),
          Tab(text: "Global Stats", icon: Icon(Icons.analytics_rounded)),
          Tab(text: "Payments", icon: Icon(Icons.payments_rounded)),
          Tab(text: "Affiliates", icon: Icon(Icons.group_add_rounded)),
          Tab(text: "Templates", icon: Icon(Icons.dashboard_customize_rounded)),
          Tab(text: "Broadcast", icon: Icon(Icons.campaign_rounded)),
          Tab(text: "Homepage", icon: Icon(Icons.web_rounded)),
          Tab(text: "Home Previews", icon: Icon(Icons.mobile_friendly_rounded)),
          Tab(text: "Landing Pages", icon: Icon(Icons.web_asset_rounded)),
        ],
      ),
      body: CubeRefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () => context.read<SuperAdminCubit>().fetchAdminMetrics(),
        child: state is SuperAdminLoaded
            ? TabBarView(
                controller: _tabController,
                children: const [
                  SuperAdminUsersTab(),
                  SuperAdminPlansTab(),
                  SuperAdminSecurityTab(),
                  SuperAdminAuditTab(),
                  SuperAdminStatsTab(),
                  SuperAdminPaymentsTab(),
                  SuperAdminAffiliatesTab(),
                  SuperAdminTemplatesTab(),
                  SuperAdminBroadcastTab(),
                  SuperAdminHomepageTab(),
                  SuperAdminHomePreviewsTab(),
                  SuperAdminLandingPagesTab(),
                ],
              )
            : const Center(child: LoadingLogo()),
      ),
      ),
    );
  }
}
