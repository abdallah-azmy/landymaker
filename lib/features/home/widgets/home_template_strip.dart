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
      {'id': 'store', 'name': 'متجر إلكتروني / Store', 'desc': 'Lux-Earth Palette', 'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500', 'tag': 'رائج'},
      {'id': 'personal', 'name': 'موقع شخصي / Portfolio', 'desc': 'Butter & Sky Palette', 'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500', 'tag': 'مصممون'},
      {'id': 'real_estate', 'name': 'عقارات / Real Estate', 'desc': 'Royal Gold Theme', 'image': 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=500', 'tag': 'جديد'},
      {'id': 'event', 'name': 'فعالية ومؤتمر / Event', 'desc': 'Coral Neon Theme', 'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500', 'tag': 'جديد'},
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
                height: 380,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final t = templates[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover Image
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    t['image']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      t['tag']!,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content Info
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['name']!,
                                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t['desc']!,
                                  style: AppTypography.caption,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => onGetStartedPressed(t['id']!),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.secondary,
                                    side: const BorderSide(color: AppColors.secondary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(double.infinity, 44),
                                  ),
                                  child: const Text("استخدم هذا القالب"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
