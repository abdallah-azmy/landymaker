import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../services/tenant_routing_service.dart';
import '../controllers/public_page_cubit.dart';
import '../controllers/public_page_state.dart';
import '../controllers/cart_cubit.dart';
import '../widgets/floating_cart_widget.dart';
import '../widgets/section_renderer.dart';

class PublicLandingPage extends StatefulWidget {
  final String? identifier;
  const PublicLandingPage({super.key, this.identifier});

  @override
  State<PublicLandingPage> createState() => _PublicLandingPageState();
}

class _PublicLandingPageState extends State<PublicLandingPage> {
  final ScrollController _scrollController = ScrollController();

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
    final identifier = widget.identifier ?? TenantRoutingService.getTenantIdentifier();
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
    final slug = idOrSlug.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff]+'), '-');

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
    final identifier = TenantRoutingService.getTenantIdentifier();

    return Directionality(
      textDirection: loc.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: BlocProvider(
        create: (_) => CartCubit(),
        child: Scaffold(
          backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            identifier?.toUpperCase() ?? 'LANDYMAKER',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => loc.toggleLanguage(),
              icon: const Icon(Icons.language_rounded, color: AppColors.secondary, size: 18),
              label: Text(
                loc.translate('switch_language'),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: AppColors.textSecondary.withValues(alpha: 0.08),
              height: 1,
            ),
          ),
        ),
        body: Stack(
          children: [
            BlocConsumer<PublicPageCubit, PublicPageState>(
              listener: (context, state) {
            if (state is PublicPageLoaded) {
              // Wait one frame for widgets to mount before attempting scroll
              WidgetsBinding.instance.addPostFrameCallback((_) => _handleDeepLinking());
            }
          },
          builder: (context, state) {
            if (state is PublicPageLoading || state is PublicPageInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            }

            if (state is PublicPageNotFound) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 80, color: AppColors.dangerRed),
                      const SizedBox(height: 24),
                      Text(
                        loc.isRtl ? "الصفحة غير موجودة" : "404 - Page Not Found",
                        style: AppTypography.h1.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.isRtl
                            ? "الصفحة المطلوبة '${state.identifier}' غير متوفرة أو لم يتم نشرها بعد."
                            : "The requested page '${state.identifier}' could not be found or is not published.",
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => launchUrl(Uri.parse(Uri.base.origin)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          loc.isRtl ? "الذهاب إلى بوابة المنصة" : "Go to Platform Portal",
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
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
                      const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.dangerRed),
                      const SizedBox(height: 24),
                      Text(
                        loc.isRtl ? "حدث خطأ ما" : "Something Went Wrong",
                        style: AppTypography.h1.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Text(state.message,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _loadTenantPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          loc.isRtl ? "إعادة المحاولة" : "Retry Loading",
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
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
                return _buildSuspendedState(loc);
              }

              final designJson = state.pageData['design_json'] as Map<String, dynamic>? ?? {};
              final themeJson = designJson['theme'] as Map<String, dynamic>? ?? {};
              final theme = LandingPageTheme.fromJson(themeJson);

              final globalFont = theme.defaultFont ?? 'Cairo';
              final globalBgImage = theme.globalBgImageUrl;
              final globalBgColorHex = theme.globalBgColorHex;
              
              Color? globalBgColor;
              if (globalBgColorHex != null && globalBgColorHex.isNotEmpty) {
                 try {
                   final hexStr = globalBgColorHex.replaceAll('#', '');
                   if (hexStr.length == 6) globalBgColor = Color(int.parse('FF$hexStr', radix: 16));
                   else if (hexStr.length == 8) globalBgColor = Color(int.parse(hexStr, radix: 16));
                 } catch (_) {}
              }

              Widget content = SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    SectionRenderer(
                      blocks: state.blocks,
                      pageId: pageId,
                      productKeys: _productKeys,
                    ),
                    _buildFooter(loc),
                  ],
                ),
              );

              try {
                content = DefaultTextStyle(
                  style: GoogleFonts.getFont(globalFont).copyWith(color: theme.textPrimary),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: GoogleFonts.getTextTheme(globalFont, Theme.of(context).textTheme),
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
                  image: (globalBgImage != null && globalBgImage.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(globalBgImage), fit: BoxFit.cover)
                      : null,
                ),
                child: content,
              );
            }

                return const SizedBox.shrink();
              },
            ),
            const FloatingCartWidget(),
          ],
        ),
      ),
    ));
  }

  Widget _buildFooter(LocalizationCubit loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.05),
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
                const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "LANDYMAKER",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              loc.isRtl
                  ? "صنع بفخر باستخدام منصة لاندي ميكر لبناء الصفحات الهابطة."
                  : "Proudly powered by LandyMaker SaaS Landing Page Builder.",
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

  Widget _buildSuspendedState(LocalizationCubit loc) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.dangerRed.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block_rounded, color: AppColors.dangerRed, size: 64),
            const SizedBox(height: 24),
            Text(loc.isRtl ? "الصفحة معطلة حالياً" : "Page Currently Suspended", style: AppTypography.h2),
            const SizedBox(height: 8),
            Text(
              loc.isRtl 
                  ? "نعتذر، هذه الصفحة لم تعد متاحة حالياً. ربما انتهت فترة الاشتراك أو تم إيقافها يدوياً."
                  : "We apologize, this page is no longer available. The subscription might have expired or it was manually disabled.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(Uri.base.origin)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                loc.isRtl ? "ابدأ بناء صفحتك الخاصة" : "Start building your own page",
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
