import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/landy_maker_logo.dart';

/// ======================================================
/// FEATURE: Home Footer
/// PURPOSE: Responsive footer containing brand info, links, and social media.
/// ARCHITECTURE: Renders [_DesktopFooter] or [_MobileFooter] based on layout width.
/// ======================================================
class HomeFooter extends StatelessWidget {
  final String? copyrightText;
  const HomeFooter({super.key, this.copyrightText});

  static const _socialLinks = [
    _SocialLinkData(
      icon: Icons.facebook_rounded,
      label: 'Facebook',
      url: 'https://www.facebook.com/profile.php?id=61590693741943',
    ),
    _SocialLinkData(
      icon: Icons.camera_alt_outlined,
      label: 'Instagram',
      url:
          'https://www.instagram.com/landymaker?fbclid=IwY2xjawSNJZdleHRuA2FlbQIxMABicmlkETFVcGlPQnBwc3JJdUxqbVpuc3J0YwZhcHBfaWQQMjIyMDM5MTc4ODIwMDg5MgABHiEHxo2N0Z-pvEP9GTaje8Tg03N1pKh5hFNn8Vdaqtiwhj-26-2Fzsf3ySe2_aem_RtR4tJB0TRboWLJaUb8k5w',
    ),
    _SocialLinkData(
      icon: Icons.music_note_rounded,
      label: 'TikTok',
      url: 'https://www.tiktok.com/@landymaker.com?_r=1&_t=ZS-96uDLu5yuKi',
    ),
    _SocialLinkData(
      icon: Icons.chat_rounded,
      label: 'WhatsApp',
      url: 'https://wa.me/201557497830',
    ),
    _SocialLinkData(
      icon: Icons.play_circle_filled_rounded,
      label: 'YouTube',
      url: 'https://www.youtube.com/@LandyMaker',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 60, horizontal: isMobile ? 16 : 64),
          child: Column(
            children: [
              if (isMobile)
                const _MobileFooter(socialLinks: _socialLinks)
              else
                const _DesktopFooter(socialLinks: _socialLinks),
              SizedBox(height: 48),
              Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
                height: 1,
              ),
              SizedBox(height: 24),
              const _BottomRow(),
            ],
          ),
        );
      },
    );
  }
}

/// Desktop version of the Footer with multi-column links.
class _DesktopFooter extends StatelessWidget {
  final List<_SocialLinkData> socialLinks;

  const _DesktopFooter({required this.socialLinks});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandSection(),
              SizedBox(height: 16),
              Text(
                "ابنِ حضورك الرقمي\nباحترافية وبساطة.",
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 20),
              // Social links
              Row(
                children: socialLinks
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: _SocialBtn(
                          icon: s.icon,
                          label: s.label,
                          url: s.url,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        // Links
        const Expanded(
          child: _FooterLinks(
            title: "روابط هامة",
            items: [
              _FooterLinkData(label: "من نحن", path: '/about'),
              _FooterLinkData(label: "سياسة الخصوصية", path: '/privacy-policy'),
              _FooterLinkData(label: "شروط الخدمة", path: '/terms'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mobile version of the Footer with centered content and collapsed links.
class _MobileFooter extends StatelessWidget {
  final List<_SocialLinkData> socialLinks;

  const _MobileFooter({required this.socialLinks});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BrandSection(center: true),
        SizedBox(height: 12),
        Text(
          "ابنِ حضورك الرقمي باحترافية وبساطة.",
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        const Wrap(
          spacing: 16,
          children: [
            _MobileFooterLink(label: "من نحن", path: '/about'),
            _MobileFooterLink(label: "سياسة الخصوصية", path: '/privacy-policy'),
            _MobileFooterLink(label: "شروط الخدمة", path: '/terms'),
          ],
        ),
        SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: socialLinks
              .map((s) => _SocialBtn(icon: s.icon, label: s.label, url: s.url))
              .toList(),
        ),
      ],
    );
  }
}

/// Shared Brand Section with Logo.
class _BrandSection extends StatelessWidget {
  final bool center;

  const _BrandSection({this.center = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo_small.webp', height: 30, width: 30),
        const SizedBox(width: 8),
        const LandyMakerLogo(fontSize: 20),
      ],
    );
  }
}

/// Footer copyright and version row.
class _BottomRow extends StatelessWidget {
  const _BottomRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 8,
      children: [
        Text(
          copyrightText ?? "© 2026 Landymaker. جميع الحقوق محفوظة.",
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "V 1.0.9",
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialLinkData {
  final IconData icon;
  final String label;
  final String url;
  const _SocialLinkData({
    required this.icon,
    required this.label,
    required this.url,
  });
}

class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;
  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _hovered = false;

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _launchUrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovered
                ? Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.4)
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovered
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _FooterLinkData {
  final String label;
  final String path;
  const _FooterLinkData({required this.label, required this.path});
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () {
                if (item.path == '/blog' || item.path.startsWith('/blog/')) {
                  final String url;
                  if (kIsWeb) {
                    final origin = Uri.base.origin;
                    if (origin.contains('localhost') ||
                        origin.contains('127.0.0.1')) {
                      url = 'https://landymaker.com${item.path}';
                    } else {
                      url = '$origin${item.path}';
                    }
                  } else {
                    url = 'https://landymaker.com${item.path}';
                  }
                  launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
                } else {
                  context.go(item.path);
                }
              },
              child: Text(
                item.label,
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
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
      onTap: () {
        if (path == '/blog' || path.startsWith('/blog/')) {
          final String url;
          if (kIsWeb) {
            final origin = Uri.base.origin;
            if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
              url = 'https://landymaker.com$path';
            } else {
              url = '$origin$path';
            }
          } else {
            url = 'https://landymaker.com$path';
          }
          launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
        } else {
          context.go(path);
        }
      },
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
