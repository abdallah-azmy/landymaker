import 'package:flutter/material.dart';
import '../../public_viewer/widgets/custom_hero_widget.dart';
import '../../public_viewer/widgets/custom_features_widget.dart';
import '../../public_viewer/widgets/custom_lead_form_widget.dart';
import '../../public_viewer/widgets/custom_products_widget.dart';
import '../../public_viewer/widgets/custom_pricing_widget.dart';
import '../../public_viewer/widgets/custom_faq_widget.dart';
import '../../public_viewer/widgets/custom_testimonials_widget.dart';
import '../../public_viewer/widgets/custom_contact_info_widget.dart';
import '../../public_viewer/widgets/custom_gallery_widget.dart';
import '../../public_viewer/widgets/custom_qr_widget.dart';
import '../../public_viewer/widgets/custom_social_qr_widget.dart';
import '../../public_viewer/widgets/custom_working_hours_widget.dart';
import '../../public_viewer/widgets/custom_location_map_widget.dart';
import '../../public_viewer/widgets/custom_logo_header_widget.dart';
import '../../public_viewer/widgets/basic_section_renderer.dart';
import '../../public_viewer/widgets/custom_trust_logos_widget.dart';
import '../../public_viewer/widgets/custom_animated_counter_widget.dart';
import '../../public_viewer/widgets/custom_hero_saas_widget.dart';
import '../../public_viewer/widgets/custom_lead_magnet_widget.dart';
import '../models/landing_page_theme.dart';
import '../../public_viewer/widgets/custom_video_embed_widget.dart';
import '../../public_viewer/widgets/custom_multi_step_form_widget.dart';

typedef BlockBuilder = Widget Function(Map<String, dynamic> data, LandingPageTheme? theme, String pageId, Key? key, Map<String, GlobalKey>? productKeys, int sectionIndex);

class BlockRegistry {
  static final Map<String, BlockBuilder> _registry = {
    'multi_step_lead_form': (data, theme, pageId, key, __, ___) => CustomMultiStepFormWidget(
      key: key,
      block: data,
      theme: theme,
      pageId: pageId,
    ),
    'video_embed': (data, theme, _, key, __, ___) => CustomVideoEmbedWidget(
      key: key,
      block: data,
      theme: theme,
    ),
    'logo_header': (data, theme, _, key, __, ___) => CustomLogoHeaderWidget(
      key: key,
      title: data['title'] ?? '',
      logoUrl: data['logo_url'],
      logoHeight: (data['logo_height'] ?? 40.0).toDouble(),
      alignment: data['alignment'] ?? 'center',
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: data['bg_blur']?.toDouble(),
    ),
    'hero': (data, theme, _, key, __, ___) => CustomHeroWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['button_text'] ?? '',
      imageUrl: data['image_url'] ?? '',
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
      buttonUrl: data['button_url'],
    ),
    'hero_saas': (data, theme, _, key, __, ___) => CustomHeroSaasWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['button_text'] ?? '',
      imageUrl: data['image_url'] ?? '',
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
      buttonUrl: data['button_url'],
    ),
    'features': (data, theme, _, key, __, ___) => CustomFeaturesWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      layoutStyle: data['layout_style'] ?? 'grid',
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'lead_form': (data, theme, pageId, key, __, ___) => CustomLeadFormWidget(
      key: key,
      block: data,
      title: data['title'] ?? '',
      buttonText: data['button_text'] ?? '',
      pageId: pageId,
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'lead_magnet': (data, theme, pageId, key, __, ___) => CustomLeadMagnetWidget(
      key: key,
      block: data,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['button_text'] ?? '',
      imageUrl: data['image_url'] ?? '',
      pageId: pageId,
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'working_hours': (data, theme, _, key, __, ___) => CustomWorkingHoursWidget(
      key: key,
      blockData: data,
    ),
    'location_map': (data, theme, _, key, __, ___) => CustomLocationMapWidget(
      key: key,
      title: data['title'] ?? 'موقعنا',
      address: data['address'] ?? '',
      mapIframeUrl: data['map_iframe_url'] ?? '',
    ),
    'products': (data, theme, _, key, productKeys, __) => CustomProductsWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      layoutStyle: data['layout_style'] ?? 'grid',
      theme: theme,
      productKeys: productKeys,
      whatsappNumber: data['whatsapp_number'],
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'pricing': (data, theme, lang, key, __, ___) => CustomPricingWidget(
      key: key,
      block: data,
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
      lang: lang,
    ),
    'faq': (data, theme, _, key, __, ___) => CustomFaqWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'testimonials': (data, theme, _, key, __, ___) => CustomTestimonialsWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'contact_info': (data, theme, _, key, __, ___) => CustomContactInfoWidget(
      key: key,
      title: data['title'] ?? '',
      email: data['email'],
      phone: data['phone'],
      location: data['location'],
      phoneIcon: data['phone_icon'],
      emailIcon: data['email_icon'],
      locationIcon: data['location_icon'],
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'gallery': (data, theme, _, key, __, ___) => CustomGalleryWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<String>.from(data['items'] ?? []),
      galleryLinks: data['gallery_links'] != null ? List<String>.from(data['gallery_links']) : null,
      displayMode: data['display_mode'] ?? 'grid',
      gridColumns: data['grid_columns'] ?? 3,
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'qr_code': (data, theme, _, key, __, ___) => CustomQrWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      qrPayload: data['qr_payload'],
      qrSize: (data['qr_size'] ?? 200.0).toDouble(),
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'social_qr': (data, theme, _, key, __, ___) => CustomSocialQrWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      links: List<Map<String, dynamic>>.from(data['links'] ?? []),
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'basic_section': (data, theme, _, key, __, index) => BasicSectionRenderer(
      key: key,
      sectionData: data,
      theme: theme ?? LandingPageTheme.palettes.last,
      sectionIndex: index,
    ),
    'trust_logos': (data, theme, _, key, __, ___) => CustomTrustLogosWidget(
      key: key,
      title: data['title'] ?? 'شركاء النجاح',
      logoUrls: List<String>.from(data['items'] ?? []),
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
    'animated_counter': (data, theme, _, key, __, ___) => CustomAnimatedCounterWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      theme: theme,
      bgImageUrl: data['bg_image_url'],
      bgOverlayColor: data['bg_overlay_color'],
      bgOverlayOpacity: (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)?.toDouble(),
      bgBlur: (data['bg_blur'] as num?)?.toDouble(),
    ),
  };

  static Widget render(String type, Map<String, dynamic> data, LandingPageTheme? theme, String pageId, int sectionIndex, {Key? key, Map<String, GlobalKey>? productKeys}) {
    final builder = _registry[type.toLowerCase()];
    if (builder != null) {
      return builder(data, theme, pageId, key, productKeys, sectionIndex);
    }
    return const SizedBox.shrink();
  }
}
