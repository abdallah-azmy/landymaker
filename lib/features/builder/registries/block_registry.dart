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
import '../models/landing_page_theme.dart';

typedef BlockBuilder = Widget Function(Map<String, dynamic> data, LandingPageTheme? theme, String pageId, Key? key, Map<String, GlobalKey>? productKeys, int sectionIndex);

class BlockRegistry {
  static final Map<String, BlockBuilder> _registry = {
    'logo_header': (data, theme, _, key, __, ___) => CustomLogoHeaderWidget(
      key: key,
      title: data['title'] ?? '',
      logoUrl: data['logo_url'],
      logoHeight: (data['logo_height'] ?? 40.0).toDouble(),
      alignment: data['alignment'] ?? 'center',
    ),
    'hero': (data, theme, _, key, __, ___) => CustomHeroWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['button_text'] ?? '',
      imageUrl: data['image_url'] ?? '',
      theme: theme,
    ),
    'features': (data, theme, _, key, __, ___) => CustomFeaturesWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      layoutStyle: data['layout_style'] ?? 'grid',
      theme: theme,
    ),
    'lead_form': (data, theme, pageId, key, __, ___) => CustomLeadFormWidget(
      key: key,
      title: data['title'] ?? '',
      buttonText: data['button_text'] ?? '',
      pageId: pageId,
      theme: theme,
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
    ),
    'pricing': (data, theme, _, key, __, ___) => CustomPricingWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      theme: theme,
    ),
    'faq': (data, theme, _, key, __, ___) => CustomFaqWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      theme: theme,
    ),
    'testimonials': (data, theme, _, key, __, ___) => CustomTestimonialsWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      theme: theme,
    ),
    'contact_info': (data, theme, _, key, __, ___) => CustomContactInfoWidget(
      key: key,
      title: data['title'] ?? '',
      email: data['email'],
      phone: data['phone'],
      location: data['location'],
      theme: theme,
    ),
    'gallery': (data, theme, _, key, __, ___) => CustomGalleryWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<String>.from(data['items'] ?? []),
      displayMode: data['display_mode'] ?? 'grid',
      gridColumns: data['grid_columns'] ?? 3,
      theme: theme,
    ),
    'qr_code': (data, theme, _, key, __, ___) => CustomQrWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      qrSize: (data['qr_size'] ?? 200.0).toDouble(),
      theme: theme,
    ),
    'social_qr': (data, theme, _, key, __, ___) => CustomSocialQrWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      links: List<Map<String, dynamic>>.from(data['links'] ?? []),
      theme: theme,
    ),
    'basic_section': (data, theme, _, key, __, index) => BasicSectionRenderer(
      key: key,
      sectionData: data,
      theme: theme ?? LandingPageTheme.palettes.last,
      sectionIndex: index,
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
