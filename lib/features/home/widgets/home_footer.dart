import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF030712),
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Top row
              if (!isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.bolt_rounded,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "landymaker",
                                style: AppTypography.h3.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "ابنِ حضورك الرقمي\nباحترافية وبساطة.",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Social links
                          Row(
                            children: [
                              _SocialBtn(icon: Icons.camera_alt_outlined, onTap: () {}),
                              const SizedBox(width: 8),
                              _SocialBtn(icon: Icons.facebook_rounded, onTap: () {}),
                              const SizedBox(width: 8),
                              _SocialBtn(icon: Icons.link_rounded, onTap: () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),

                    // Links
                    Expanded(
                      child: _FooterLinks(
                        title: "المنتج",
                        links: const [
                          "المميزات", "القوالب", "الأسعار", "الأمان",
                        ],
                      ),
                    ),
                    Expanded(
                      child: _FooterLinks(
                        title: "الشركة",
                        links: const [
                          "من نحن", "المدونة", "تواصل معنا", "الخصوصية",
                        ],
                      ),
                    ),
                    Expanded(
                      child: _FooterLinks(
                        title: "الدعم",
                        links: const [
                          "مركز المساعدة", "الشروط والأحكام", "الإبلاغ عن مشكلة",
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "landymaker",
                          style: AppTypography.h3.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "ابنِ حضورك الرقمي باحترافية وبساطة.",
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

              const SizedBox(height: 48),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 24),

              // Bottom row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    "© 2026 Landymaker. جميع الحقوق محفوظة.",
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "مدعوم بـ",
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.favorite_rounded,
                          color: AppColors.secondary, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        "Supabase & Flutter",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
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

class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialBtn({required this.icon, required this.onTap});

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.secondary.withValues(alpha: 0.15)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? AppColors.secondary.withValues(alpha: 0.4) : AppColors.border,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovered ? AppColors.secondary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterLinks({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            link,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        )),
      ],
    );
  }
}
