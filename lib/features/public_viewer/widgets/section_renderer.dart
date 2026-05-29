import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../builder/models/landing_page_theme.dart';
import 'custom_hero_widget.dart';
import 'custom_features_widget.dart';
import 'custom_lead_form_widget.dart';
import 'custom_products_widget.dart';
import 'custom_pricing_widget.dart';
import 'custom_faq_widget.dart';
import 'custom_testimonials_widget.dart';
import 'custom_contact_info_widget.dart';
import 'custom_gallery_widget.dart';
import 'custom_qr_widget.dart';
import 'custom_social_qr_widget.dart';
import '../../../core/widgets/section_background.dart';

class SectionRenderer extends StatelessWidget {
  final List<Map<String, dynamic>> blocks;
  final String pageId;
  final LandingPageTheme? theme;
  final Function(int index)? onBlockTapped;
  /// Shared map of product GlobalKeys for deep-link scrolling.
  /// Populated by CustomProductsWidget; used by PublicLandingPage.
  final Map<String, GlobalKey>? productKeys;

  const SectionRenderer({
    super.key,
    required this.blocks,
    required this.pageId,
    this.theme,
    this.onBlockTapped,
    this.productKeys,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        final String type = (block['type'] ?? '').toString().toLowerCase();
        // Create a unique key for each section based on its type and properties to force rebuild on changes
        final Key sectionKey = ValueKey("${type}_${index}_${block.hashCode}");

        // Parse section background properties
        final String? bgImageUrl = block['bg_image_url'] != null ? block['bg_image_url'].toString() : null;
        final String? bgOverlayColor = block['bg_overlay_color'] != null ? block['bg_overlay_color'].toString() : null;
        final double? bgOverlayOpacity = block['bg_overlay_opacity'] != null 
            ? (block['bg_overlay_opacity'] as num).toDouble() 
            : null;
        final double? bgBlur = block['bg_blur'] != null 
            ? (block['bg_blur'] as num).toDouble() 
            : null;

        Widget section;
        switch (type) {
          case 'hero':
            section = CustomHeroWidget(
              key: sectionKey,
              title: block['title'] ?? 'Stunning Landing Page Title',
              subtitle: block['subtitle'] ?? 'This is your value proposition subtitle.',
              buttonText: block['button_text'] ?? 'Get Started',
              imageUrl: block['image_url'] ?? 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'features':
            final List rawItems = block['items'] ?? [];
            final List<Map<String, dynamic>> items = rawItems
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            section = CustomFeaturesWidget(
              key: sectionKey,
              title: block['title'] ?? 'Why Choose Us',
              items: items,
              layoutStyle: block['layout_style'] ?? 'grid',
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'lead_form':
            section = CustomLeadFormWidget(
              key: sectionKey,
              title: block['title'] ?? 'Get In Touch',
              buttonText: block['button_text'] ?? 'Submit',
              pageId: pageId,
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'products':
            final List rawItems = block['items'] ?? [];
            final List<Map<String, dynamic>> items = rawItems
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            final String layoutStyle = block['layout_style'] ?? 'grid_2';
            final String safeLayoutStyle = layoutStyle == 'grid' ? 'grid_2' : layoutStyle;
            final bool showCategoryFilter = block['show_category_filter'] ?? true;
            final List<String> customCategories = (block['categories'] as List?)?.map((e) => e.toString()).toList() ?? [];

            section = CustomProductsWidget(
              key: sectionKey,
              title: block['title'] ?? 'Our Products',
              items: items,
              layoutStyle: safeLayoutStyle,
              theme: theme,
              productKeys: productKeys,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
              whatsappNumber: block['whatsapp_number']?.toString(),
              showCategoryFilter: showCategoryFilter,
              customCategories: customCategories,
            );
            break;

          case 'qr_code':
            section = CustomQrWidget(
              key: sectionKey,
              title: block['title'] ?? 'QR Code',
              subtitle: block['subtitle'] ?? 'Scan to visit our website',
              qrSize: (block['qr_size'] ?? 200.0).toDouble(),
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'social_qr':
            final List rawLinks = block['links'] ?? [];
            final List<Map<String, dynamic>> links = rawLinks
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            section = CustomSocialQrWidget(
              key: sectionKey,
              title: block['title'] ?? 'Connect With Us',
              subtitle: block['subtitle'] ?? 'Scan the QR or use the links below',
              links: links,
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'pricing':
            final List rawItems = block['items'] ?? [];
            final List<Map<String, dynamic>> items = rawItems
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            section = CustomPricingWidget(
              key: sectionKey,
              title: block['title'] ?? 'Our Pricing Plans',
              items: items,
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'faq':
            final List rawItems = block['items'] ?? [];
            final List<Map<String, dynamic>> items = rawItems
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            section = CustomFaqWidget(
              key: sectionKey,
              title: block['title'] ?? 'Frequently Asked Questions',
              items: items,
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'testimonials':
            final List rawItems = block['items'] ?? [];
            final List<Map<String, dynamic>> items = rawItems
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            section = CustomTestimonialsWidget(
              key: sectionKey,
              title: block['title'] ?? 'What Our Clients Say',
              items: items,
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'contact_info':
            section = CustomContactInfoWidget(
              key: sectionKey,
              title: block['title'] ?? 'Get In Touch',
              email: block['email'],
              phone: block['phone'],
              location: block['location'],
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'gallery':
            final List rawItems = block['items'] ?? [];
            final List<String> items = rawItems.map((e) => e.toString()).toList();

            section = CustomGalleryWidget(
              key: sectionKey,
              title: block['title'] ?? 'Our Gallery',
              items: items,
              displayMode: block['display_mode'] ?? 'grid',
              gridColumns: block['grid_columns'] ?? 3,
              theme: theme,
              bgImageUrl: bgImageUrl,
              bgOverlayColor: bgOverlayColor,
              bgOverlayOpacity: bgOverlayOpacity,
              bgBlur: bgBlur,
            );
            break;

          case 'whatsapp':
            section = _buildWhatsAppSection(block, theme, sectionKey);
            break;

          default:
            section = const SizedBox.shrink();
        }

        if (onBlockTapped != null) {
          return GestureDetector(
            onTap: () => onBlockTapped!(index),
            behavior: HitTestBehavior.opaque,
            child: section,
          );
        }

        return section;
      },
    );
  }

  Widget _buildWhatsAppSection(Map<String, dynamic> block, LandingPageTheme? theme, Key? key) {
    final String title = block['title'] ?? 'تواصل معنا';
    final String phone = block['phone_number'] ?? '';
    final String message = block['message'] ?? '';
    final String btnText = block['button_text'] ?? 'واتساب';

    final Color bgColor = theme?.background ?? const Color(0xFFE8F5E9);
    final Color primaryColor = theme?.primary ?? const Color(0xFF25D366);
    final Color textColor = theme?.textPrimary ?? const Color(0xFF1B5E20);

    // Support section background for WhatsApp too if set
    final String? bgImageUrl = block['bg_image_url'] != null ? block['bg_image_url'].toString() : null;
    final String? bgOverlayColor = block['bg_overlay_color'] != null ? block['bg_overlay_color'].toString() : null;
    final double? bgOverlayOpacity = block['bg_overlay_opacity'] != null 
        ? (block['bg_overlay_opacity'] as num).toDouble() 
        : null;
    final double? bgBlur = block['bg_blur'] != null 
        ? (block['bg_blur'] as num).toDouble() 
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

        return SectionBackground(
          key: key,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: isMobile ? 24 : 32),
              ElevatedButton.icon(
                onPressed: () async {
                  if (phone.isEmpty) return;
                  final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
                  final encodedMsg = Uri.encodeComponent(message);
                  final url = "https://wa.me/$cleanPhone?text=$encodedMsg";
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
                icon: Icon(Icons.chat_bubble_outline_rounded, size: isMobile ? 20 : 24),
                label: Text(
                  btnText,
                  style: TextStyle(fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 40, vertical: isMobile ? 14 : 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
