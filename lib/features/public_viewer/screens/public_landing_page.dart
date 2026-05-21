import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../services/tenant_routing_service.dart';
import '../controllers/public_page_cubit.dart';
import '../controllers/public_page_state.dart';
import '../widgets/section_renderer.dart';

class PublicLandingPage extends StatefulWidget {
  const PublicLandingPage({super.key});

  @override
  State<PublicLandingPage> createState() => _PublicLandingPageState();
}

class _PublicLandingPageState extends State<PublicLandingPage> {
  @override
  void initState() {
    super.initState();
    _loadTenantPage();
  }

  void _loadTenantPage() {
    final identifier = TenantRoutingService.getTenantIdentifier();
    if (identifier != null) {
      final isCustom = TenantRoutingService.isCustomDomain(identifier);
      context.read<PublicPageCubit>().loadByIdentifier(identifier, isCustom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final identifier = TenantRoutingService.getTenantIdentifier();

    return Directionality(
      textDirection: loc.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            identifier?.toUpperCase() ?? 'MYLANDY',
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
              color: AppColors.textSecondary.withOpacity(0.08),
              height: 1,
            ),
          ),
        ),
        body: BlocBuilder<PublicPageCubit, PublicPageState>(
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
                      const Icon(
                        Icons.search_off_rounded,
                        size: 80,
                        color: AppColors.dangerRed,
                      ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 80,
                        color: AppColors.dangerRed,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        loc.isRtl ? "حدث خطأ ما" : "Something Went Wrong",
                        style: AppTypography.h1.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _loadTenantPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SectionRenderer(
                      blocks: state.blocks,
                      pageId: pageId,
                    ),
                    _buildFooter(loc),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFooter(LocalizationCubit loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.05),
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
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "MYLANDY",
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
                  ? "صنع بفخر باستخدام منصة ماي لاندي لبناء الصفحات الهابطة."
                  : "Proudly powered by MyLandy SaaS Landing Page Builder.",
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
