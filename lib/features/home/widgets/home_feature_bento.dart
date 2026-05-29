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
                    _buildBentoCard(
                      icon: Icons.dashboard_customize_rounded,
                      title: "محرر مرن وسريع",
                      desc: "أضف الأقسام التي تريدها ورتبها بسهولة. تحكم كامل في النصوص والصور والأزرار.",
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 20),
                    _buildBentoCard(
                      icon: Icons.palette_rounded,
                      title: "قوالب وتصاميم ممتازة",
                      desc: "اختر من بين لوحات الألوان الجاهزة لتناسب هويتك التجارية بلمسة زر واحدة.",
                      color: const Color(0xFF06B6D4),
                    ),
                    const SizedBox(height: 20),
                    _buildBentoCard(
                      icon: Icons.analytics_rounded,
                      title: "إحصائيات فورية وتتبع العملاء",
                      desc: "اعرف عدد الزوار وتابع طلبات العملاء والرسائل مباشرة من لوحة التحكم الخاصة بك.",
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 20),
                    _buildBentoCard(
                      icon: Icons.qr_code_2_rounded,
                      title: "روابط ذكية وكود QR مخصص",
                      desc: "شارك موقعك بروابط مخصصة وكود QR فوري وسهل للمشاركة الميدانية والمطبوعات.",
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildBentoCard(
                            icon: Icons.dashboard_customize_rounded,
                            title: "محرر مرن وسريع",
                            desc: "أضف الأقسام التي تريدها ورتبها بسهولة. تحكم كامل في النصوص والصور والأزرار والروابط.",
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: _buildBentoCard(
                            icon: Icons.palette_rounded,
                            title: "قوالب وتصاميم ممتازة",
                            desc: "اختر من بين لوحات الألوان والخطوط الجاهزة لتناسب هويتك التجارية في ثوانٍ معدودة.",
                            color: const Color(0xFF06B6D4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildBentoCard(
                            icon: Icons.analytics_rounded,
                            title: "إحصائيات فورية وتتبع العملاء",
                            desc: "اعرف عدد الزوار وتفاعلهم وتابع طلبات العملاء والرسائل الواردة مباشرة.",
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 3,
                          child: _buildBentoCard(
                            icon: Icons.qr_code_2_rounded,
                            title: "روابط ذكية وكود QR مخصص",
                            desc: "شارك موقعك مع عملائك بروابط مخصصة، نطاق فرعي، أو كود QR تفاعلي سهل المسح والمشاركة المباشرة.",
                            color: const Color(0xFFF59E0B),
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

  Widget _buildBentoCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
