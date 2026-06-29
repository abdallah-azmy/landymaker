import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/dynamic_font_service.dart';
import '../../../core/theme/app_typography.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/cube_refresh_indicator.dart';
import '../../../services/tenant_routing_service.dart';
import '../controllers/public_page_cubit.dart';
import '../controllers/public_page_state.dart';
import '../controllers/cart_cubit.dart';
import '../widgets/floating_cart_widget.dart';
import '../widgets/global/sticky_cta_bar.dart';
import '../widgets/section_renderer.dart';
import '../../../core/seo/app_seo.dart';
import '../../../core/services/pixel_bootstrap_service.dart';
import '../../../core/services/pixel_event_service.dart';
import '../widgets/cookie_consent_banner.dart';

class PublicLandingPage extends StatefulWidget {
  final String? identifier;
  const PublicLandingPage({super.key, this.identifier});

  @override
  State<PublicLandingPage> createState() => _PublicLandingPageState();
}

class _PublicLandingPageState extends State<PublicLandingPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isStickyVisible = ValueNotifier(false);
  bool _isLoadingFonts = true;

  /// Shared map of product keys populated by CustomProductsWidget.
  /// Supports both UUID keys ("abc-123-...") and slug keys ("smart-watch-pro").
  final Map<String, GlobalKey> _productKeys = {};

  @override
  void initState() {
    super.initState();
    _loadTenantPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadTenantPage() {
    final identifier =
        widget.identifier ?? TenantRoutingService.getTenantIdentifier();
    if (identifier != null) {
      final isCustom = TenantRoutingService.isCustomDomain(identifier);
      context.read<PublicPageCubit>().loadByIdentifier(identifier, isCustom);
    }
  }

  /// Called after PublicPageLoaded — reads `?product=` query param.
  /// Supports both UUIDs and human-readable slugs (e.g. "smart-watch-pro").
  void _handleDeepLinking() {
    final uri = Uri.base;
    final String? productParam = uri.queryParameters['product'];
    if (productParam == null || productParam.trim().isEmpty) return;

    // Small delay ensures the widget tree has been laid out.
    Timer(const Duration(milliseconds: 600), () {
      _scrollToProduct(productParam.trim());
    });
  }

  /// Scrolls to a product using its registered GlobalKey (UUID or slug).
  void _scrollToProduct(String idOrSlug) {
    // Normalize to lowercase slug for slug lookups
    final slug = idOrSlug.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9\u0600-\u06ff]+'),
      '-',
    );

    // Try UUID first, then slug
    final GlobalKey? key = _productKeys[idOrSlug] ?? _productKeys[slug];
    if (key == null) return;

    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      alignment: 0.1, // slight offset from top for visual comfort
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    return Directionality(
      textDirection: loc.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: BlocProvider(
        create: (_) => CartCubit(),
        child: Scaffold(
          backgroundColor: Colors.black,

          body: Stack(
            children: [
              BlocConsumer<PublicPageCubit, PublicPageState>(
                listener: (context, state) {
                  if (state is PublicPageLoaded) {
                    final designJson = state.designJson;

                    // Apply SEO Meta Tags for browser title/OG info
                    final seoTitle = designJson['meta_title'] ?? "${state.pageData['subdomain'] ?? 'Page'} | LandyMaker";
                    final seoDesc = designJson['meta_description'] ?? "Created with LandyMaker - The Ultimate AI Landing Page Builder";
                    final seoImage = designJson['og_image_url'] ?? "https://landymaker.com/logo_social.webp";
                    final seoKeywords = (designJson['keywords'] as String?) ?? '';
                    
                    final Map<String, dynamic> seoStructuredData = {
                      '@context': 'https://schema.org',
                      '@type': 'WebPage',
                      'name': seoTitle,
                      'description': seoDesc,
                      'url': Uri.base.toString(),
                      'image': seoImage,
                      'keywords': seoKeywords,
                    };
                    if (designJson['meta_title'] != null || designJson['meta_description'] != null) {
                      seoStructuredData['about'] = <String, dynamic>{
                        '@type': 'Thing',
                        'name': seoTitle,
                        'description': seoDesc,
                      };
                    }

                    AppSEO.updateMeta(
                      title: seoTitle,
                      description: seoDesc,
                      image: seoImage,
                      keywords: seoKeywords,
                      structuredData: seoStructuredData,
                    );

                    PixelBootstrapService.initialize(designJson);
                    PixelEventService.trackPageView();

                    // Font Preloading for the specific font chosen by the user
                    _preloadFontsForPage(designJson);

                    // Wait one frame for widgets to mount before attempting scroll
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _handleDeepLinking(),
                    );
                  } else if (state is PublicPageNotFound || state is PublicPageFailure) {
                    if (mounted) {
                      setState(() => _isLoadingFonts = false);
                    }
                    _removeHtmlLoader();
                  }
                },
                builder: (context, state) {
                  if (state is PublicPageLoading ||
                      state is PublicPageInitial) {
                    return _buildPlatformLoader();
                  }

                  if (state is PublicPageLoaded && _isLoadingFonts) {
                    return _buildPlatformLoader();
                  }

                  if (state is PublicPageNotFound) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 80,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            SizedBox(height: 24),
                            Text(
                              loc.isRtl
                                  ? "الصفحة غير موجودة"
                                  : "404 - Page Not Found",
                              style: AppTypography.h1.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              loc.isRtl
                                  ? "الصفحة المطلوبة '${state.identifier}' غير متوفرة أو لم يتم نشرها بعد."
                                  : "The requested page '${state.identifier}' could not be found or is not published.",
                              style: AppTypography.bodyLarge.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () =>
                                  launchUrl(Uri.parse(Uri.base.origin)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                loc.isRtl
                                    ? "الذهاب إلى بوابة المنصة"
                                    : "Go to Platform Portal",
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is PublicPageFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 80,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            SizedBox(height: 24),
                            Text(
                              loc.isRtl ? "حدث خطأ ما" : "Something Went Wrong",
                              style: AppTypography.h1.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              state.message,
                              style: AppTypography.bodyLarge.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _loadTenantPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                loc.isRtl ? "إعادة المحاولة" : "Retry Loading",
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is PublicPageLoaded) {
                    final pageId = state.pageData['id'] as String;
                    final bool isActive = state.pageData['is_active'] ?? true;

                    if (!isActive) {
                      return _buildSuspendedState(context, loc);
                    }

                    final designJson = state.designJson;

                    final themeJson =
                        designJson['theme'] as Map<String, dynamic>? ?? {};
                    final theme = LandingPageTheme.fromJson(themeJson);

                    final globalFont = theme.defaultFont ?? 'Cairo';
                    final globalBgImage = theme.globalBgImageUrl;
                    final globalBgColorHex = theme.globalBgColorHex;

                    Color? globalBgColor;
                    if (globalBgColorHex != null &&
                        globalBgColorHex.isNotEmpty) {
                      final hexStr = globalBgColorHex.replaceAll('#', '');
                      if (hexStr.length == 6) {
                        final parsed = int.tryParse('FF$hexStr', radix: 16);
                        if (parsed != null) globalBgColor = Color(parsed);
                      } else if (hexStr.length == 8) {
                        final parsed = int.tryParse(hexStr, radix: 16);
                        if (parsed != null) globalBgColor = Color(parsed);
                      }
                    }

                    Widget content = CubeRefreshIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      onRefresh: () async {
                        final identifier = widget.identifier ??
                            TenantRoutingService.getTenantIdentifier();
                        if (identifier != null) {
                          final isCustom = TenantRoutingService.isCustomDomain(identifier);
                          await context.read<PublicPageCubit>().loadByIdentifier(identifier, isCustom);
                        }
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            SectionRenderer(
                              blocks: state.blocks,
                              pageId: pageId,
                              theme: theme,
                              productKeys: _productKeys,
                            ),
                            _buildFooter(loc),
                          ],
                        ),
                      ),
                    );

                    try {
                      content = DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: globalFont,
                          fontFamilyFallback: const ['Cairo'],
                          color: theme.textPrimary,
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textTheme: Theme.of(context).textTheme.apply(
                              fontFamily: globalFont,
                              fontFamilyFallback: const ['Cairo'],
                            ),
                          ),
                          child: content,
                        ),
                      );
                    } catch (_) {
                      // Fallback
                    }

                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: globalBgColor ?? Colors.black,
                        image:
                            (globalBgImage != null && globalBgImage.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(globalBgImage),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: content,
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
              BlocBuilder<PublicPageCubit, PublicPageState>(
                builder: (context, state) {
                  if (state is PublicPageLoaded) {
                    final designJson = state.designJson;
                    if (designJson['sticky_cta']?['is_enabled'] == true) {
                      final themeJson = designJson['theme'] as Map<String, dynamic>? ?? {};
                      final theme = LandingPageTheme.fromJson(themeJson);
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: StickyCtaBar(
                          config: Map<String, dynamic>.from(designJson['sticky_cta']),
                          pageId: state.pageData['id']?.toString() ?? '',
                          lang: loc.isRtl ? 'ar' : 'en',
                          primaryColor: theme.primary,
                          scrollController: _scrollController,
                          visibilityNotifier: _isStickyVisible,
                        ),
                      );
                    }
                  }
                  return SizedBox.shrink();
                },
              ),
              FloatingCartWidget(isStickyVisible: _isStickyVisible),
              BlocBuilder<PublicPageCubit, PublicPageState>(
                builder: (context, state) {
                  if (state is PublicPageLoaded) {
                    final designJson = state.designJson;
                    final themeJson = designJson['theme'] as Map<String, dynamic>? ?? {};
                    final theme = LandingPageTheme.fromJson(themeJson);
                    return CookieConsentBanner(designJson: designJson, theme: theme);
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformLoader() {
    return const Scaffold(
      backgroundColor: Color(0xFF030712), // Match index.html background color
      body: SizedBox.shrink(),
    );
  }

  void _removeHtmlLoader() {
    if (kIsWeb) {
      try {
        js.context.callMethod('removeLandyMakerLoader');
      } catch (e) {
        debugPrint("Error removing HTML loader: $e");
      }
    }
  }

  Future<void> _preloadFontsForPage(Map<String, dynamic> designJson) async {
    try {
      await DynamicFontService.loadFontsFromDesign(designJson)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint("Font preloading error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingFonts = false);
        _removeHtmlLoader();
      }
    }
  }

  Widget _buildFooter(LocalizationCubit loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "LANDYMAKER",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              loc.isRtl
                  ? "صنع بفخر باستخدام منصة لاندي ميكر لبناء الصفحات الهابطة."
                  : "Proudly powered by LandyMaker SaaS Landing Page Builder.",
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSuspendedState(BuildContext context, LocalizationCubit loc) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block_rounded, color: Theme.of(context).colorScheme.error, size: 64),
          SizedBox(height: 24),
          Text(
            loc.isRtl ? "الصفحة معطلة حالياً" : "Page Currently Suspended",
            style: AppTypography.h2,
          ),
          SizedBox(height: 8),
          Text(
            loc.isRtl
                ? "نعتذر، هذه الصفحة لم تعد متاحة حالياً. ربما انتهت فترة الاشتراك أو تم إيقافها يدوياً."
                : "We apologize, this page is no longer available. The subscription might have expired or it was manually disabled.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => launchUrl(Uri.parse(Uri.base.origin)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              loc.isRtl
                  ? "ابدأ بناء صفحتك الخاصة"
                  : "Start building your own page",
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
