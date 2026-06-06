import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/landy_maker_logo.dart';
import '../../../core/localization/app_localizations.dart';

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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const LandyMakerLogo(fontSize: 22),
                              const SizedBox(width: 10),
                              Image.asset(
                                'assets/images/logo_small.webp',
                                height: 34,
                                width: 34,
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
                        items: [
                          _FooterLinkData(label: "المميزات", path: '/'),
                          _FooterLinkData(label: "القوالب", path: '/templates'),
                          _FooterLinkData(label: "الأسعار", path: '/'),
                          _FooterLinkData(label: "الأمان", path: '/'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _FooterLinks(
                        title: "الشركة",
                        items: [
                          _FooterLinkData(label: "من نحن", path: '/'),
                          _FooterLinkData(label: "المدونة", path: '/blog'),
                          _FooterLinkData(label: "تواصل معنا", path: '/'),
                          _FooterLinkData(label: context.translate('privacy_policy'), path: '/privacy-policy'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _FooterLinks(
                        title: "الدعم",
                        items: [
                          _FooterLinkData(label: "مركز المساعدة", path: '/'),
                          _FooterLinkData(label: context.translate('terms_of_service'), path: '/terms'),
                          _FooterLinkData(label: "الإبلاغ عن مشكلة", path: '/'),
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
                            const LandyMakerLogo(fontSize: 20),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/logo_small.webp',
                          height: 30,
                          width: 30,
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
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      children: [
                        _MobileFooterLink(label: context.translate('privacy_policy'), path: '/privacy-policy'),
                        _MobileFooterLink(label: context.translate('terms_of_service'), path: '/terms'),
                      ],
                    )
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

class _FooterLinkData {
  final String label;
  final String path;
  _FooterLinkData({required this.label, required this.path});
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<_FooterLinkData> items;

  const _FooterLinks({required this.title, required this.items});

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
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => context.go(item.path),
            child: Text(
              item.label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        )),
      ],
    );
  }
}

class _MobileFooterLink extends StatelessWidget {
  final String label;
  final String path;
  const _MobileFooterLink({required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(path),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
