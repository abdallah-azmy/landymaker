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
import '../models/landing_page_theme.dart';

typedef BlockBuilder = Widget Function(Map<String, dynamic> data, LandingPageTheme? theme, String pageId, Key? key);

class BlockRegistry {
  static final Map<String, BlockBuilder> _registry = {
    'logo_header': (data, theme, _, key) => CustomLogoHeaderWidget(
      key: key,
      title: data['title'] ?? '',
      logoUrl: data['logo_url'],
      logoHeight: (data['logo_height'] ?? 40.0).toDouble(),
      alignment: data['alignment'] ?? 'center',
    ),
    'hero': (data, theme, _, key) => CustomHeroWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['button_text'] ?? '',
      imageUrl: data['image_url'] ?? '',
      theme: theme,
    ),
    'features': (data, theme, _, key) => CustomFeaturesWidget(
      key: key,
      title: data['title'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      layoutStyle: data['layout_style'] ?? 'grid',
      theme: theme,
    ),
    'lead_form': (data, theme, pageId, key) => CustomLeadFormWidget(
      key: key,
      title: data['title'] ?? '',
      buttonText: data['button_text'] ?? '',
      pageId: pageId,
      theme: theme,
    ),
    'working_hours': (data, theme, _, key) => CustomWorkingHoursWidget(
      key: key,
      blockData: data,
    ),
    'location_map': (data, theme, _, key) => CustomLocationMapWidget(
      key: key,
      title: data['title'] ?? 'موقعنا',
      address: data['address'] ?? '',
      mapIframeUrl: data['map_iframe_url'] ?? '',
    ),
    // ... add more as needed following the pattern
  };

  static Widget render(String type, Map<String, dynamic> data, LandingPageTheme? theme, String pageId, {Key? key}) {
    final builder = _registry[type.toLowerCase()];
    if (builder != null) {
      return builder(data, theme, pageId, key);
    }
    return const SizedBox.shrink();
  }
}
