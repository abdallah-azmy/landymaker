import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/tenant_routing_service.dart';
import '../../../public_viewer/widgets/section_renderer.dart';
import '../../../auth/controllers/auth_cubit.dart';
import '../../../auth/controllers/auth_state.dart';

class PhonePreview extends StatefulWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> previewPages;
  final ScrollController? parentScrollController;

  const PhonePreview({
    super.key,
    required this.isMobile,
    required this.previewPages,
    this.parentScrollController,
  });

  @override
  State<PhonePreview> createState() => _PhonePreviewState();
}

class _PhonePreviewState extends State<PhonePreview> {
  int _activePreviewIndex = 0;
  Timer? _previewCycleTimer;
  late ScrollController _innerScrollController;

  @override
  void initState() {
    super.initState();
    _innerScrollController = ScrollController();
    _startPreviewCycling();
  }

  @override
  void dispose() {
    _previewCycleTimer?.cancel();
    _innerScrollController.dispose();
    super.dispose();
  }

  void _startPreviewCycling() {
    _previewCycleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _activePreviewIndex =
              (_activePreviewIndex + 1) % widget.previewPages.length;
        });
      }
    });
  }

  Widget _buildUseDesignButton(BuildContext context) {
    final theme = Theme.of(context);
    final currentPage = widget.previewPages[_activePreviewIndex];
    final pageId = currentPage['id']?.toString() ?? '';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          TenantRoutingService.pendingTemplateId = pageId;
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated) {
            context.go('/dashboard');
          } else {
            context.go('/register');
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt_rounded,
                color: theme.colorScheme.onPrimary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'استخدم هذا التصميم',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mockupWidth = widget.isMobile ? 260.0 : 320.0;
    final mockupHeight = widget.isMobile ? 470.0 : 580.0;
    final outerRadius = widget.isMobile ? 32.0 : 38.0;
    final innerRadius = widget.isMobile ? 24.0 : 30.0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Previous template',
            button: true,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  _previewCycleTimer?.cancel();
                  setState(() {
                    _activePreviewIndex =
                        (_activePreviewIndex - 1 + widget.previewPages.length) %
                        widget.previewPages.length;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white60,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),

          Semantics(
            label: 'Template preview',
            container: true,
            child: Container(
              width: mockupWidth,
              height: mockupHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(outerRadius),
                border: Border.all(color: const Color(0xFF475569), width: 8),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(innerRadius),
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 24,
                            color: Theme.of(context).colorScheme.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "9:41",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.signal_cellular_alt_rounded,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.wifi_rounded,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.battery_std_rounded,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification notification) {
                                if (notification is ScrollUpdateNotification) {
                                  final parent = widget.parentScrollController;
                                  if (parent != null && parent.hasClients) {
                                    final double delta =
                                        notification.scrollDelta ?? 0;
                                    final pos = _innerScrollController.position;

                                    if (pos.pixels >= pos.maxScrollExtent &&
                                        delta > 0) {
                                      parent.position.jumpTo(
                                        (parent.offset + delta).clamp(
                                          0.0,
                                          parent.position.maxScrollExtent,
                                        ),
                                      );
                                    } else if (pos.pixels <= 0 && delta < 0) {
                                      parent.position.jumpTo(
                                        (parent.offset + delta).clamp(
                                          0.0,
                                          parent.position.maxScrollExtent,
                                        ),
                                      );
                                    }
                                  }
                                }
                                return false;
                              },
                              child: SingleChildScrollView(
                                controller: _innerScrollController,
                                physics: const ClampingScrollPhysics(),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 600),
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                  child: KeyedSubtree(
                                    key: ValueKey<int>(_activePreviewIndex),
                                    child: Container(
                                      color: widget
                                          .previewPages[_activePreviewIndex]['theme']
                                          .background,
                                      child: SectionRenderer(
                                        pageId: 'demo',
                                        theme: widget
                                            .previewPages[_activePreviewIndex]['theme'],
                                        blocks: List<Map<String, dynamic>>.from(
                                          widget
                                              .previewPages[_activePreviewIndex]['blocks'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.previewPages.length, (
                            index,
                          ) {
                            final isActive = index == _activePreviewIndex;
                            return Semantics(
                              label: 'Template ${index + 1}',
                              button: true,
                              child: GestureDetector(
                                onTap: () {
                                  _previewCycleTimer?.cancel();
                                  setState(() {
                                    _activePreviewIndex = index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: isActive ? 18 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                        : Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: _buildUseDesignButton(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 16),
          Semantics(
            label: 'Next template',
            button: true,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  _previewCycleTimer?.cancel();
                  setState(() {
                    _activePreviewIndex =
                        (_activePreviewIndex + 1) % widget.previewPages.length;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white60,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
