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
    'logo_header': (data, theme, _, key, productKeys, __) => CustomLogoHeaderWidget(
      key: key,
      title: data['title'] ?? '',
      logoUrl: data['logo_url'],
      logoHeight: (data['logo_height'] ?? 40.0).toDouble(),
      alignment: data['alignment'] ?? 'center',
    ),
    'hero': (data, theme, _, key, productKeys, __) => CustomHeroWidget(
      key: key,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['button_text'] ?? '',
      imageUrl: data['image_url'] ?? '',
      theme: theme,
    ),
    'basic_section': (data, theme, _, key, productKeys, index) => BasicSectionRenderer(
      key: key,
      sectionData: data,
      theme: theme ?? LandingPageTheme.palettes.last,
      sectionIndex: index,
    ),
    // ... products, features etc follow same pattern
  };

  static Widget render(String type, Map<String, dynamic> data, LandingPageTheme? theme, String pageId, int sectionIndex, {Key? key, Map<String, GlobalKey>? productKeys}) {
    final builder = _registry[type.toLowerCase()];
    if (builder != null) {
      return builder(data, theme, pageId, key, productKeys, sectionIndex);
    }
    return const SizedBox.shrink();
  }
}
