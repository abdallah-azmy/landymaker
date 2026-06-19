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
import '../../public_viewer/widgets/custom_whatsapp_widget.dart';
import '../../public_viewer/widgets/custom_statistics_grid_widget.dart';
import '../../public_viewer/widgets/custom_team_members_widget.dart';
import '../../public_viewer/widgets/custom_service_steps_widget.dart';
import '../../public_viewer/widgets/custom_cta_banner_widget.dart';
import '../../public_viewer/widgets/custom_comparison_table_widget.dart';
import '../../public_viewer/widgets/featured_product_widget.dart';
import '../../public_viewer/widgets/bento_store_widget.dart';
import '../../../core/widgets/block_animation_wrapper.dart';
import '../../../core/widgets/atoms/glass_container.dart';
import '../../../core/responsive/card_layout_mode.dart';

typedef BlockBuilder = Widget Function(
  Map<String, dynamic> data,
  LandingPageTheme? theme,
  String pageId,
  Key? key,
  Map<String, GlobalKey>? productKeys,
  int sectionIndex,
  String lang,
);

class BlockRegistry {
  static final Map<String, BlockBuilder> _registry = {
    'multi_step_lead_form': (data, theme, pageId, key, __, ___, lang) =>
        CustomMultiStepFormWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
          pageId: pageId,
        ),
    'video_embed': (data, theme, _, key, __, ___, lang) =>
        CustomVideoEmbedWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
        ),
    'logo_header': (data, theme, _, key, __, ___, lang) => CustomLogoHeaderWidget(
          key: key,
          title: data['title'] ?? '',
          logoUrl: data['logo_url'],
          logoHeight: (data['logo_height'] ?? 40.0).toDouble(),
          alignment: data['alignment'] ?? 'center',
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: data['bg_blur']?.toDouble(),
        ),
    'hero': (data, theme, pageId, key, __, ___, lang) => CustomHeroWidget(
          key: key,
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          buttonText: data['button_text'] ?? '',
          imageUrl: data['image_url'] ?? '',
          pageId: pageId,
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          buttonUrl: data['button_url'],
          variant: data['variant'] ?? 0,
          layoutStyle: data['layout_style'],
        ),
    'hero_saas': (data, theme, pageId, key, __, ___, lang) => CustomHeroSaasWidget(
          key: key,
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          buttonText: data['button_text'] ?? '',
          imageUrl: data['image_url'] ?? '',
          pageId: pageId,
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          buttonUrl: data['button_url'],
          layoutStyle: data['layout_style'],
        ),
    'features': (data, theme, _, key, __, ___, lang) => CustomFeaturesWidget(
          key: key,
          title: data['title'] ?? '',
          items: List<Map<String, dynamic>>.from(data['items'] ?? []),
          layoutStyle: data['layout_style'] ?? 'grid',
          cardLayoutMode: CardLayoutModeExt.fromString(data['card_layout_mode']),
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
          variant: data['variant'] ?? 0,
        ),
    'lead_form': (data, theme, pageId, key, __, ___, lang) => CustomLeadFormWidget(
          key: key,
          block: data,
          title: data['title'] ?? '',
          buttonText: data['button_text'] ?? '',
          pageId: pageId,
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'lead_magnet': (data, theme, pageId, key, __, ___, lang) =>
        CustomLeadMagnetWidget(
          key: key,
          block: data,
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          buttonText: data['button_text'] ?? '',
          imageUrl: data['image_url'] ?? '',
          pageId: pageId,
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'whatsapp': (data, theme, pageId, key, __, ___, lang) => CustomWhatsappWidget(
          key: key,
          title: data['title'] ?? '',
          phoneNumber: data['phone_number'] ?? '',
          message: data['message'] ?? '',
          buttonText: data['button_text'] ?? '',
          pageId: pageId,
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'working_hours': (data, theme, _, key, __, ___, lang) =>
        CustomWorkingHoursWidget(
          key: key,
          blockData: data,
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'location_map': (data, theme, _, key, __, ___, lang) => CustomLocationMapWidget(
          key: key,
          title: data['title'] ?? 'موقعنا',
          address: data['address'] ?? '',
          mapIframeUrl: data['map_iframe_url'] ?? '',
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
        ),
    'products': (data, theme, _, key, productKeys, __, lang) => CustomProductsWidget(
          key: key,
          title: data['title'] ?? '',
          items: List<Map<String, dynamic>>.from(data['items'] ?? []),
          layoutStyle: data['layout_style'] ?? 'grid',
          mobileColumns: data['mobile_columns'] ?? 2,
          theme: _getTheme(data, theme),
          productKeys: productKeys,
          whatsappNumber: data['whatsapp_number'],
          showCategoryFilter: data['show_category_filter'] ?? true,
          customCategories: data['categories'] != null
              ? List<String>.from(data['categories'])
              : null,
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
        ),
    'pricing': (data, theme, pageId, key, __, ___, lang) => CustomPricingWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
          pageId: pageId,
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
          lang: lang,
          variant: data['variant'] ?? 0,
        ),
    'faq': (data, theme, _, key, __, ___, lang) => CustomFaqWidget(
          key: key,
          title: data['title'] ?? '',
          items: List<Map<String, dynamic>>.from(data['items'] ?? []),
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'testimonials': (data, theme, _, key, __, ___, lang) => CustomTestimonialsWidget(
          key: key,
          title: data['title'] ?? '',
          items: List<Map<String, dynamic>>.from(data['items'] ?? []),
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          layoutStyle: data['layout_style'],
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'contact_info': (data, theme, _, key, __, ___, lang) => CustomContactInfoWidget(
          key: key,
          title: data['title'] ?? '',
          email: data['email'],
          phone: data['phone'],
          location: data['location'],
          phoneIcon: data['phone_icon'],
          emailIcon: data['email_icon'],
          locationIcon: data['location_icon'],
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'gallery': (data, theme, _, key, __, ___, lang) => CustomGalleryWidget(
          key: key,
          title: data['title'] ?? '',
          items: List<String>.from(data['items'] ?? []),
          galleryLinks: data['gallery_links'] != null
              ? List<String>.from(data['gallery_links'])
              : null,
          displayMode: data['display_mode'] ?? 'grid',
          gridColumns: data['grid_columns'] ?? 3,
          mobileColumns: data['mobile_columns'] ?? 1,
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'qr_code': (data, theme, _, key, __, ___, lang) => CustomQrWidget(
          key: key,
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          qrPayload: data['qr_payload'],
          qrSize: (data['qr_size'] ?? 200.0).toDouble(),
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'social_qr': (data, theme, _, key, __, ___, lang) => CustomSocialQrWidget(
          key: key,
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          links: List<Map<String, dynamic>>.from(data['links'] ?? []),
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'basic_section': (data, theme, _, key, __, index, lang) => BasicSectionRenderer(
          key: key,
          sectionData: data,
          theme: _getTheme(data, theme) ?? LandingPageTheme.palettes.last,
          sectionIndex: index,
        ),
    'trust_logos': (data, theme, _, key, __, ___, lang) => CustomTrustLogosWidget(
          key: key,
          title: data['title'] ?? 'شركاء النجاح',
          logoUrls: List<String>.from(data['items'] ?? []),
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'animated_counter': (data, theme, _, key, __, ___, lang) =>
        CustomAnimatedCounterWidget(
          key: key,
          title: data['title'] ?? '',
          items: List<Map<String, dynamic>>.from(data['items'] ?? []),
          theme: _getTheme(data, theme),
          bgImageUrl: data['bg_image_url'],
          bgOverlayColor: data['bg_overlay_color'],
          bgOverlayOpacity:
              (data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?)
                  ?.toDouble(),
          backgroundColorHex: data['bg_color'] ?? data['background_color'],
          bgBlur: (data['bg_blur'] as num?)?.toDouble(),
          verticalPadding: (data['vertical_padding'] as num?)?.toDouble(),
        ),
    'statistics_grid': (data, theme, _, key, __, ___, lang) =>
        CustomStatisticsGridWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
        ),
    'team_members': (data, theme, _, key, __, ___, lang) => CustomTeamMembersWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
        ),
    'service_steps': (data, theme, _, key, __, ___, lang) =>
        CustomServiceStepsWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
        ),
    'cta_banner': (data, theme, _, key, __, ___, lang) => CustomCtaBannerWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
        ),
    'comparison_table': (data, theme, _, key, __, ___, lang) =>
        CustomComparisonTableWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
        ),
    'featured_product': (data, theme, _, key, __, ___, lang) =>
        FeaturedProductWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
          whatsappNumber: data['whatsapp_number'],
        ),
    'bento_store': (data, theme, _, key, __, ___, lang) => BentoStoreWidget(
          key: key,
          block: data,
          theme: _getTheme(data, theme),
          whatsappNumber: data['whatsapp_number'],
        ),
  };

  static LandingPageTheme? _getTheme(Map<String, dynamic> data, LandingPageTheme? globalTheme) {
    final themeName = data['theme_override'];
    if (themeName != null && themeName is String) {
      try {
        return LandingPageTheme.palettes.firstWhere((p) => p.name == themeName);
      } catch (_) {}
    }
    return globalTheme;
  }

  static Widget render(
    String type,
    Map<String, dynamic> data,
    LandingPageTheme? theme,
    String pageId,
    int sectionIndex, {
    Key? key,
    Map<String, GlobalKey>? productKeys,
    String lang = 'ar',
  }) {
    final builder = _registry[type.toLowerCase()];
    if (builder != null) {
      Widget blockWidget = builder(data, theme, pageId, key, productKeys, sectionIndex, lang);

      final int variant = data['variant'] ?? 0;

      // Apply Global Style Variants (3-9)
      blockWidget = _applyGlobalVariant(blockWidget, variant, theme);

      // Wrap with animation
      final animationData = data['animation'];
      return BlockAnimationWrapper(
        settings: animationData != null
            ? BlockAnimationSettings.fromJson(animationData)
            : const BlockAnimationSettings(
                type: BlockAnimationType.fadeIn,
                duration: Duration(milliseconds: 800),
              ),
        child: blockWidget,
      );
    }
    return SizedBox.shrink();
  }

  static Widget _applyGlobalVariant(Widget child, int variant, LandingPageTheme? theme) {
    if (variant < 3) return child; // 0-2 are widget-specific layouts

    switch (variant) {
      case 3: // Glassmorphism
        return GlassContainer(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
          child: child,
        );
      case 4: // Neumorphism (Soft shadows)
        return Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme?.background ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(5, 5),
                blurRadius: 10,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                offset: const Offset(-5, -5),
                blurRadius: 10,
              ),
            ],
          ),
          child: child,
        );
      case 6: // Outline / Bordered
        return Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: (theme?.secondary ?? Colors.blue).withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        );
      case 9: // Floating / Elevated
        return Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme?.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (theme?.primary ?? Colors.black).withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        );
      case 5: // Modern Gradient Border
        return Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme?.secondary ?? Colors.cyan,
                (theme?.primary ?? Colors.indigo).withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme?.background ?? Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        );
      case 7: // Soft Premium Gradient
        return Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (theme?.secondary ?? Colors.amber).withValues(alpha: 0.1),
                (theme?.primary ?? Colors.brown).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: (theme?.secondary ?? Colors.amber).withValues(alpha: 0.2)),
          ),
          child: child,
        );
      case 8: // Dark Contrast Card
        return Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Specifically dark for contrast
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        );
      default:
        return child;
    }
  }
}
