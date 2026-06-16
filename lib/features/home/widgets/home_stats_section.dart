import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../models/home_layouts.dart';

class HomeStatsSection extends StatefulWidget {
  final bool isVisible;
  final StatsLayout layout;

  const HomeStatsSection({
    super.key,
    required this.isVisible,
    this.layout = StatsLayout.horizontal,
  });

  @override
  State<HomeStatsSection> createState() => _HomeStatsSectionState();
}

class _HomeStatsSectionState extends State<HomeStatsSection>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  late List<Animation<double>> _statFades;
  late List<Animation<Offset>> _statSlides;

  static const _stats = [
    _StatData(
      value: "١٥,٠٠٠+",
      label: "صفحة هبوط نشطة",
      desc: "تم تصميمها وإطلاقها بنجاح عبر المنصة.",
      color: Color(0xFF6366F1),
    ),
    _StatData(
      value: "١.٢ مليون+",
      label: "زيارة وتفاعل",
      desc: "زيارات حقيقية تم تسجيلها لصفحات عملائنا.",
      color: Color(0xFF06B6D4),
    ),
    _StatData(
      value: "٩٩.٤٪",
      label: "معدل الرضا والتشغيل",
      desc: "استقرار تام وسرعة استجابة فائقة للصفحات.",
      color: Color(0xFF10B981),
    ),
    _StatData(
      value: "٢٤/٧",
      label: "دعم فني متواصل",
      desc: "فريق متخصص معك في كل خطوة لضمان نجاحك.",
      color: Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.fastOutSlowIn,
    ));

    _statFades = List.generate(_stats.length, (i) {
      return CurvedAnimation(
        parent: _statsController,
        curve: Interval((i * 0.15).clamp(0.0, 1.0), ((i * 0.15) + 0.5).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    _statSlides = List.generate(_stats.length, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _statsController,
        curve: Interval((i * 0.15).clamp(0.0, 1.0), ((i * 0.15) + 0.6).clamp(0.0, 1.0), curve: Curves.fastOutSlowIn),
      ));
    });
  }

  @override
  void didUpdateWidget(HomeStatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _statsController.forward();
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = HomeBreakpoint.isMobile(constraints.maxWidth);
        switch (widget.layout) {
          case StatsLayout.withIcons:
            return _buildWithIconsLayout(context, isMobile);
          case StatsLayout.horizontal:
            return _buildHorizontalLayout(context, isMobile);
        }
      },
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSectionHeader(isMobile),
              const SizedBox(height: 64),
              if (isMobile)
                Column(
                  children: List.generate(_stats.length, (i) => Column(
                    children: [
                      RepaintBoundary(
                        child: FadeTransition(
                          opacity: _statFades[i],
                          child: SlideTransition(
                            position: _statSlides[i],
                            child: _StatCard(stat: _stats[i]),
                          ),
                        ),
                      ),
                      if (i < _stats.length - 1) const SizedBox(height: 16),
                    ],
                  )),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _stats.length,
                  itemBuilder: (context, i) {
                    return RepaintBoundary(
                      child: FadeTransition(
                        opacity: _statFades[i],
                        child: SlideTransition(
                          position: _statSlides[i],
                          child: _StatCard(stat: _stats[i]),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isMobile) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _headerFade,
        child: SlideTransition(
          position: _headerSlide,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  "📈 إحصائيات",
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF34D399),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "لاندي ميكر في أرقام",
                style: AppTypography.h2.copyWith(
                  fontSize: isMobile ? 28 : 42,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "ثقة متزايدة وأرقام قياسية تعكس التزامنا بنجاح مشروعك الرقمي وتسهيل وصولك لجمهورك.",
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithIconsLayout(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildSectionHeader(isMobile),
              const SizedBox(height: 64),
              isMobile
                ? Column(
                    children: List.generate(_stats.length, (i) => Padding(
                      padding: EdgeInsets.only(bottom: i < _stats.length - 1 ? 16 : 0),
                      child: _buildIconStatCard(_stats[i], i),
                    )),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_stats.length, (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(end: i < _stats.length - 1 ? 20 : 0),
                        child: _buildIconStatCard(_stats[i], i),
                      ),
                    )),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconStatCard(_StatData stat, int index) {
    final icons = [Icons.pages_rounded, Icons.people_rounded, Icons.verified_rounded, Icons.support_agent_rounded];
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _statFades[index],
        child: SlideTransition(
          position: _statSlides[index],
        child: Container(
          padding: const EdgeInsetsDirectional.all(28),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsetsDirectional.all(14),
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icons[index], color: stat.color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                stat.value,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: stat.color, fontFamily: 'Cairo'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(stat.label, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 4),
                Text(stat.desc, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Class
// ─────────────────────────────────────────────────────────────────────────────
class _StatData {
  final String value;
  final String label;
  final String desc;
  final Color color;

  const _StatData({
    required this.value,
    required this.label,
    required this.desc,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Isolated Stat Card Widget to prevent rebuilding the entire Stats Section
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatefulWidget {
  final _StatData stat;

  const _StatCard({required this.stat});


  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.stat;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // AnimatedSlide = GPU compositing, not Dart-side lerp
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -0.015) : Offset.zero,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          // Only animate color + border — no boxShadow blur changes (expensive)
          decoration: BoxDecoration(
            color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hovered ? s.color.withValues(alpha: 0.55) : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                s.value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: s.color,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                s.label,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                s.desc,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
