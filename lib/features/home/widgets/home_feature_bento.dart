import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HomeFeatureBento extends StatelessWidget {
  const HomeFeatureBento({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: AppColors.background,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "كل ما تحتاجه للنمو في مكان واحد",
                style: AppTypography.h2.copyWith(
                  fontSize: isMobile ? 26 : 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "أدوات ذكية متكاملة مصممة خصيصاً لمساعدتك على النجاح.",
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Bento Grid Layout
              if (isMobile)
                Column(
                  children: [
                    const BentoCard(
                      icon: Icons.dashboard_customize_rounded,
                      title: "محرر مرن وسريع",
                      desc: "أضف الأقسام التي تريدها ورتبها بسهولة. تحكم كامل في النصوص والصور والأزرار.",
                      color: Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 20),
                    const BentoCard(
                      icon: Icons.palette_rounded,
                      title: "قوالب وتصاميم ممتازة",
                      desc: "اختر من بين لوحات الألوان الجاهزة لتناسب هويتك التجارية بلمسة زر واحدة.",
                      color: Color(0xFF06B6D4),
                    ),
                    const SizedBox(height: 20),
                    const BentoCard(
                      icon: Icons.analytics_rounded,
                      title: "إحصائيات فورية وتتبع العملاء",
                      desc: "اعرف عدد الزوار وتابع طلبات العملاء والرسائل مباشرة من لوحة التحكم الخاصة بك.",
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(height: 20),
                    const BentoCard(
                      icon: Icons.qr_code_2_rounded,
                      title: "روابط ذكية وكود QR مخصص",
                      desc: "شارك موقعك بروابط مخصصة وكود QR فوري وسهل للمشاركة الميدانية والمطبوعات.",
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: BentoCard(
                            icon: Icons.dashboard_customize_rounded,
                            title: "محرر مرن وسريع",
                            desc: "أضف الأقسام التي تريدها ورتبها بسهولة. تحكم كامل في النصوص والصور والأزرار والروابط.",
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          flex: 2,
                          child: BentoCard(
                            icon: Icons.palette_rounded,
                            title: "قوالب وتصاميم ممتازة",
                            desc: "اختر من بين لوحات الألوان والخطوط الجاهزة لتناسب هويتك التجارية في ثوانٍ معدودة.",
                            color: Color(0xFF06B6D4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: BentoCard(
                            icon: Icons.analytics_rounded,
                            title: "إحصائيات فورية وتتبع العملاء",
                            desc: "اعرف عدد الزوار وتفاعلهم وتابع طلبات العملاء والرسائل الواردة مباشرة.",
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          flex: 3,
                          child: BentoCard(
                            icon: Icons.qr_code_2_rounded,
                            title: "روابط ذكية وكود QR مخصص",
                            desc: "شارك موقعك مع عملائك بروابط مخصصة، نطاق فرعي، أو كود QR تفاعلي سهل المسح والمشاركة المباشرة.",
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BentoCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const BentoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(_isHovered ? -2.0 : 0.0, _isHovered ? -4.0 : 0.0)
          ..scale(_isHovered ? 1.02 : 1.0),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.cardBgHover : AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? widget.color.withValues(alpha: 0.6) : AppColors.border,
            width: _isHovered ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.15)
                  : widget.color.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 30 : 15,
              spreadRadius: _isHovered ? 4 : 1,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isHovered ? widget.color.withValues(alpha: 0.2) : widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.desc,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
