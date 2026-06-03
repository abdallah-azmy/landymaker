import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HomeTemplateStrip extends StatelessWidget {
  final Function(String templateId) onGetStartedPressed;

  const HomeTemplateStrip({
    super.key,
    required this.onGetStartedPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    final templates = [
      {
        'id': 'store',
        'name': 'متجر إلكتروني / Store',
        'desc': 'Lux-Earth Palette',
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500',
        'tag': 'رائج'
      },
      {
        'id': 'personal',
        'name': 'موقع شخصي / Portfolio',
        'desc': 'Butter & Sky Palette',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
        'tag': 'مصممون'
      },
      {
        'id': 'real_estate',
        'name': 'عقارات / Real Estate',
        'desc': 'Royal Gold Theme',
        'image': 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=500',
        'tag': 'جديد'
      },
      {
        'id': 'event',
        'name': 'فعالية ومؤتمر / Event',
        'desc': 'Coral Neon Theme',
        'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500',
        'tag': 'جديد'
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ابدأ بقالب مصمم مسبقاً",
                style: AppTypography.h2.copyWith(
                  fontSize: isMobile ? 26 : 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "جميع القوالب قابلة للتخصيص بالكامل ومتجاوبة مع الجوال والويب.",
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Horizontal Scroll
              SizedBox(
                height: 420,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: templates.length,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    final t = templates[index];
                    return TemplateCard(
                      template: t,
                      onPressed: () => onGetStartedPressed(t['id']!),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TemplateCard extends StatefulWidget {
  final Map<String, String> template;
  final VoidCallback onPressed;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onPressed,
  });

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 290,
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.cardBgHover : AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? AppColors.secondary.withValues(alpha: 0.6) : AppColors.border,
            width: _isHovered ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : Colors.black26,
              blurRadius: _isHovered ? 24 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Inner Zoom on Hover
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedScale(
                      scale: _isHovered ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: Image.network(
                        widget.template['image']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.template['tag']!,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Info
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template['name']!,
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.template['desc']!,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isHovered ? AppColors.secondary : Colors.transparent,
                        foregroundColor: _isHovered ? Colors.black : AppColors.secondary,
                        side: BorderSide(color: AppColors.secondary, width: _isHovered ? 0.0 : 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _isHovered ? 4 : 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "استخدم هذا القالب",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isHovered ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
