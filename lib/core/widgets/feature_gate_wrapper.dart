import 'package:flutter/material.dart';
import '../../services/subscription_service.dart';
import '../../services/auth_service.dart';
import '../../injection_container.dart';
import '../theme/app_colors.dart';
import '../../features/subscription/widgets/mission_upgrade_modal.dart';

enum GatingType {
  blur,
  opacity,
  hidden,
}

class FeatureGateWrapper extends StatefulWidget {
  final Widget child;
  final Future<bool> Function(SubscriptionService, String) check;
  final String featureName;
  final GatingType gatingType;

  const FeatureGateWrapper({
    super.key,
    required this.child,
    required this.check,
    this.featureName = 'Premium Feature',
    this.gatingType = GatingType.opacity,
  });

  @override
  State<FeatureGateWrapper> createState() => _FeatureGateWrapperState();
}

class _FeatureGateWrapperState extends State<FeatureGateWrapper> {
  bool _isAllowed = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final auth = sl<AuthService>();
    final subscription = sl<SubscriptionService>();
    final userId = auth.currentUserId;

    if (userId == null) {
      setState(() {
        _isAllowed = false;
        _isLoading = false;
      });
      return;
    }

    final result = await widget.check(subscription, userId);
    if (mounted) {
      setState(() {
        _isAllowed = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_isAllowed) return widget.child;

    switch (widget.gatingType) {
      case GatingType.hidden:
        return const SizedBox.shrink();
      case GatingType.opacity:
        return Stack(
          children: [
            Opacity(
              opacity: 0.4,
              child: AbsorbPointer(child: widget.child),
            ),
            Positioned.fill(
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.lock_rounded, color: AppColors.warningOrange),
                  onPressed: _showUpgradePrompt,
                ),
              ),
            ),
          ],
        );
      case GatingType.blur:
        return Stack(
          children: [
            ImageFiltered(
              imageFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.1),
                BlendMode.darken,
              ),
              child: AbsorbPointer(child: widget.child),
            ),
            Positioned.fill(
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _showUpgradePrompt,
                  icon: const Icon(Icons.star_rounded, size: 16),
                  label: const Text("ترقية"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warningOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  void _showUpgradePrompt() {
    final userId = sl<AuthService>().currentUserId;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MissionUpgradeModal(userId: userId),
    );
  }
}
