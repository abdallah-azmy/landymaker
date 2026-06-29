import 'package:flutter/material.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/cube_refresh_indicator.dart';
import '../../../core/widgets/atoms/cube_shimmer.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/particles/cube_loader.dart';

Widget _buildSectionHeader(
  BuildContext context,
  String title,
  String subtitle,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        subtitle,
        style: AppTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

Widget _buildShowcaseCard(
  BuildContext context, {
  required Widget child,
  required String title,
  String? desc,
}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        width: 1.2,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (desc != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: AppTypography.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(child: child),
      ],
    ),
  );
}

void showLogoTestDialog(BuildContext context) {
  final variants = CubeLoaderVariant.values;
  final isRtl = context.isRtl;
  final variantLabels = {
    CubeLoaderVariant.logo: isRtl ? "الشعار" : "Brand Logo",
    CubeLoaderVariant.single: isRtl ? "مفرد" : "Single Cube",
    CubeLoaderVariant.cluster: isRtl ? "مجموعة" : "Cluster Orbit",
    CubeLoaderVariant.linear: isRtl ? "خطي" : "Linear Wave",
    CubeLoaderVariant.circular: isRtl ? "دائري" : "Circular Ring",
    CubeLoaderVariant.physics: isRtl ? "فيزيائي" : "Physics Bounce",
    CubeLoaderVariant.logoCornerAxis: isRtl
        ? "شعار زاوية محورية"
        : "Logo Corner Axis",
    CubeLoaderVariant.logoWave: isRtl ? "موجة الشعار" : "Logo Cascade Wave",
    CubeLoaderVariant.singleWobble: isRtl ? "ترنح مفرد" : "Single Wobble",
    CubeLoaderVariant.clusterSpiral: isRtl
        ? "دوامة المجموعة"
        : "Cluster Spiral",
    CubeLoaderVariant.linearBidi: isRtl
        ? "موجة ثنائية الاتجاه"
        : "Bidirectional Wave",
    CubeLoaderVariant.circularDouble: isRtl ? "حلقة مزدوجة" : "Double Ring",
    CubeLoaderVariant.logoPremium: isRtl ? "شعار بريميوم" : "Premium Logo",
    CubeLoaderVariant.logoPremiumCornerAxis: isRtl
        ? "شعار زاوية محور بريميوم"
        : "Premium Corner Axis",
    CubeLoaderVariant.logoPremiumFloat: isRtl ? "شعار عائم" : "Premium Float",
    CubeLoaderVariant.logoPremiumWave: isRtl ? "موجة الشعار" : "Premium Wave",
    CubeLoaderVariant.logoPremiumCorePulse: isRtl
        ? "نبض مركز الشعار"
        : "Premium Core Pulse",
    CubeLoaderVariant.logoPremiumRotate: isRtl
        ? "دوران الشعار"
        : "Premium Rotate",
    CubeLoaderVariant.logoPremiumAura: isRtl ? "هالة الشعار" : "Premium Aura",
  };

  showDialog(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: 700,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl
                              ? "معاينة مؤشرات التحميل"
                              : "Loading Indicator Showcase",
                          style: AppTypography.h3.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRtl
                              ? "جميع أنواع CubeLoader داخل أزرار تفاعلية"
                              : "All CubeLoader variants rendered inside interactive buttons",
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      hoverColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.only(end: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // SECTION 1: Standalone Variant Showcase
                      _buildSectionHeader(
                        dialogContext,
                        isRtl
                            ? "1. عرض الأنواع بشكل منفصل"
                            : "1. Standalone Variant Preview",
                        isRtl
                            ? "كل شكل معروض بحجمه الطبيعي مع وصف مختصر"
                            : "Each variant shown at its natural size with a short description",
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.logo] ?? "Logo",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "شعار العلامة التجارية"
                              : "Brand Logo",
                          desc: isRtl
                              ? "27 مكعباً في شبكة 3×3×3 بإسقاط متساوي القياس وزوايا دائرية"
                              : "27 cubes in 3×3×3 isometric grid with rounded corners",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logo,
                            initialState: CubeLoaderState.breathing,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Tooltip(
                              message:
                                  variantLabels[CubeLoaderVariant.single] ??
                                  "Single",
                              child: _buildShowcaseCard(
                                dialogContext,
                                title: isRtl
                                    ? "مؤشر زر مفرد"
                                    : "Single Cube Spinner",
                                desc: isRtl
                                    ? "مكعب دوار مخصص للأزرار"
                                    : "Rotating cube for button loading states",
                                child: const CubeLoader(
                                  size: 36,
                                  variant: CubeLoaderVariant.single,
                                  initialState: CubeLoaderState.loading,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Tooltip(
                              message:
                                  variantLabels[CubeLoaderVariant.cluster] ??
                                  "Cluster",
                              child: _buildShowcaseCard(
                                dialogContext,
                                title: isRtl
                                    ? "مجموعة مدارية"
                                    : "Orbital Cluster",
                                desc: isRtl
                                    ? "3 مكعبات تدور في مدار مع نسبة مئوية"
                                    : "3 orbiting cubes with progress percentage",
                                child: const CubeLoader(
                                  size: 72,
                                  variant: CubeLoaderVariant.cluster,
                                  value: 0.72,
                                  showPercentage: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Tooltip(
                              message:
                                  variantLabels[CubeLoaderVariant.linear] ??
                                  "Linear",
                              child: _buildShowcaseCard(
                                dialogContext,
                                title: isRtl ? "تموج خطي" : "Linear Wave",
                                desc: isRtl
                                    ? "5 مكعبات بنبض متدرج"
                                    : "5 cubes in a staggered wave pulse",
                                child: const CubeLoader(
                                  size: 110,
                                  variant: CubeLoaderVariant.linear,
                                  initialState: CubeLoaderState.loading,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Tooltip(
                              message:
                                  variantLabels[CubeLoaderVariant.circular] ??
                                  "Circular",
                              child: _buildShowcaseCard(
                                dialogContext,
                                title: isRtl
                                    ? "حلقة دائرية"
                                    : "Circular Ring",
                                desc: isRtl
                                    ? "8 مكعبات في مسار دائري بعمق"
                                    : "8 cubes in a circular depth wave",
                                child: const CubeLoader(
                                  size: 90,
                                  variant: CubeLoaderVariant.circular,
                                  initialState: CubeLoaderState.loading,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.physics] ??
                            "Physics",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl ? "ارتداد فيزيائي" : "Physics Bounce",
                          desc: isRtl
                              ? "سقوط حر وارتداد مع انضغاط"
                              : "Free-fall bounce with squash and stretch",
                          child: const CubeLoader(
                            size: 90,
                            variant: CubeLoaderVariant.physics,
                            initialState: CubeLoaderState.loading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // New logo-corner-axis standalone card
                      _buildSectionHeader(
                        dialogContext,
                        isRtl ? "إضافات جديدة" : "New Additions",
                        isRtl
                            ? "خيارات دوران وزاوية جديدة لكل نوع"
                            : "New rotation and angle options per variant",
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.logoCornerAxis] ??
                            "Logo Corner Axis",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "دوران زاوية الشعار"
                              : "Logo Corner-Axis Rotation",
                          desc: isRtl
                              ? "دوران حول المحور القطري — 3 أوجه مرئية متساوية"
                              : "Body-diagonal axis rotation — 3 equal visible faces",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoCornerAxis,
                            initialState: CubeLoaderState.loading,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.logoWave] ??
                            "Logo Cascade Wave",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "موجة الشعار المتتالية"
                              : "Logo Cascade Wave",
                          desc: isRtl
                              ? "تموج متدرج من المركز عبر 27 مكعباً"
                              : "Wave ripple from center through all 27 cubes",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoWave,
                            initialState: CubeLoaderState.loading,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.singleWobble] ??
                            "Single Wobble",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "ترنح المكعب المفرد"
                              : "Single Cube Wobble",
                          desc: isRtl
                              ? "ترنح على زاوية واحدة بحركة عشوائية"
                              : "Wobbling on one corner with organic motion",
                          child: const CubeLoader(
                            size: 72,
                            variant: CubeLoaderVariant.singleWobble,
                            initialState: CubeLoaderState.loading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.clusterSpiral] ??
                            "Cluster Spiral",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl ? "دوامة المجموعات" : "Cluster Spiral",
                          desc: isRtl
                              ? "8 مكعبات في مسار حلزوني حلزوني"
                              : "8 cubes in a helical spiral orbit",
                          child: const CubeLoader(
                            size: 90,
                            variant: CubeLoaderVariant.clusterSpiral,
                            initialState: CubeLoaderState.loading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.linearBidi] ??
                            "Bidirectional Wave",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "موجة ثنائية الاتجاه"
                              : "Bidirectional Linear Wave",
                          desc: isRtl
                              ? "موجتان تلتقيان في المنتصف من كلا الجانبين"
                              : "Two waves meeting in the middle from both sides",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.linearBidi,
                            initialState: CubeLoaderState.loading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.circularDouble] ??
                            "Double Ring",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "حلقة مزدوجة الدوران"
                              : "Double Counter-Rotating Ring",
                          desc: isRtl
                              ? "حلقتان تدوران بعكس الاتجاه بترددات مختلفة"
                              : "Two rings counter-rotating at different frequencies",
                          child: const CubeLoader(
                            size: 90,
                            variant: CubeLoaderVariant.circularDouble,
                            initialState: CubeLoaderState.loading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SECTION: Premium Logo Variants
                      _buildSectionHeader(
                        dialogContext,
                        isRtl
                            ? "إصدارات الشعار الفاخرة"
                            : "Premium Logo Variants",
                        isRtl
                            ? "إصدارات بريميوم مستوحاة من مكعب روبيك بهندسة محسّنة"
                            : "Premium Rubik-style cube variants with enhanced geometry",
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant.logoPremium] ??
                            "Premium Logo",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl ? "شعار بريميوم" : "Premium Logo",
                          desc: isRtl
                              ? "شعار 3×3×3 مع تنفس خفيف وزوايا محسّنة وحدود داكنة"
                              : "3×3×3 logo with subtle breathing, enhanced spacing, dark Rubik-style borders",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoPremium,
                            initialState: CubeLoaderState.breathing,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant
                                .logoPremiumCornerAxis] ??
                            "Premium Corner Axis",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "دوران زاوية محور بريميوم"
                              : "Premium Corner Axis",
                          desc: isRtl
                              ? "دوران حول المحور القطري للمكعب مع حواف بلون أساسي"
                              : "Corner-diagonal axis rotation with primary color edges",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoPremiumCornerAxis,
                            initialState: CubeLoaderState.loading,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant
                                .logoPremiumFloat] ??
                            "Premium Float",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl ? "شعار عائم" : "Premium Float",
                          desc: isRtl
                              ? "حركة طفو خفيفة جداً للمجموعة بأكملها"
                              : "Very gentle floating motion of the entire cube group",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoPremiumFloat,
                            initialState: CubeLoaderState.breathing,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant
                                .logoPremiumWave] ??
                            "Premium Wave",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl ? "موجة بريميوم" : "Premium Wave",
                          desc: isRtl
                              ? "موجة تمر عبر المكعبات مع الحفاظ على الهيكل"
                              : "Wave passing through cubes while maintaining the outer silhouette",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoPremiumWave,
                            initialState: CubeLoaderState.loading,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant
                                .logoPremiumCorePulse] ??
                            "Premium Core Pulse",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl ? "نبض المركز" : "Premium Core Pulse",
                          desc: isRtl
                              ? "نبض أنيق في المكعبات الداخلية مع الحفاظ على الثبات"
                              : "Elegant pulse of the inner core cubes while outer layer stays stable",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoPremiumCorePulse,
                            initialState: CubeLoaderState.breathing,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant
                                .logoPremiumRotate] ??
                            "Premium Rotate",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl ? "دوران بطيء" : "Premium Slow Rotate",
                          desc: isRtl
                              ? "دوران بطيء جداً حول المحور القطري — دورة كاملة كل 30 ثانية"
                              : "Very slow body-diagonal rotation — one full revolution per ~30 seconds",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoPremiumRotate,
                            initialState: CubeLoaderState.loading,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message:
                            variantLabels[CubeLoaderVariant
                                .logoPremiumAura] ??
                            "Premium Aura",
                        child: _buildShowcaseCard(
                          dialogContext,
                          title: isRtl ? "هالة الشعار" : "Premium Aura",
                          desc: isRtl
                              ? "طبقات تتنفس في طور متعاكس لتأثير هالة ثلاثي الأبعاد"
                              : "Layers breathe in alternating phase for a subtle 3D aura effect",
                          child: const CubeLoader(
                            size: 110,
                            variant: CubeLoaderVariant.logoPremiumAura,
                            initialState: CubeLoaderState.breathing,
                            showGlow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SECTION 2: Variants Inside Primary Buttons
                      _buildSectionHeader(
                        dialogContext,
                        isRtl
                            ? "2. الأنواع داخل الأزرار الرئيسية"
                            : "2. Variants Inside Primary Buttons",
                        isRtl
                            ? "كل نوع داخل زر PrimaryButton مع التحميل — اختر ما يناسب موقعك"
                            : "Each variant rendered inside a PrimaryButton with loading — pick your site-wide loader",
                      ),
                      const SizedBox(height: 12),
                      ...variants.map((v) {
                        final double cubeSize = switch (v) {
                          CubeLoaderVariant.logo => 22,
                          CubeLoaderVariant.single => 16,
                          _ => 18,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PrimaryButton(
                            text: variantLabels[v] ?? v.name,
                            isLoading: true,
                            width: double.infinity,
                            loadingWidget: CubeLoader(
                              size: cubeSize,
                              variant: v,
                              initialState: CubeLoaderState.loading,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // SECTION 3: Determinate Percentage Variants
                      _buildSectionHeader(
                        dialogContext,
                        isRtl
                            ? "3. مؤشرات النسبة المئوية"
                            : "3. Determinate Progress Variants",
                        isRtl
                            ? "Cluster و Linear مع نسبة مئوية داخل زر"
                            : "Cluster & Linear with percentage overlay",
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final v in [
                            CubeLoaderVariant.cluster,
                            CubeLoaderVariant.linear,
                          ])
                            for (final pct in [0.33, 0.72])
                              PrimaryButton(
                                text: "${(pct * 100).toInt()}%",
                                isLoading: true,
                                loadingWidget: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CubeLoader(
                                    size: 22,
                                    variant: v,
                                    value: pct,
                                    showPercentage: true,
                                  ),
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // SECTION 4: Advanced Elements
                      _buildSectionHeader(
                        dialogContext,
                        isRtl ? "4. عناصر إضافية" : "4. Additional Elements",
                        isRtl
                            ? "هيكل الشيمر وسحب التحديث"
                            : "Cube shimmer skeleton and pull-to-refresh",
                      ),
                      const SizedBox(height: 12),
                      _buildShowcaseCard(
                        dialogContext,
                        title: isRtl
                            ? "هيكل الشيمر المكعب (Cube Shimmer)"
                            : "Skeleton Cube Shimmer",
                        desc: isRtl
                            ? "تأثير شيمر متلاشي للواجهات تحت البناء"
                            : "Shimmer grids for structural loading mockups",
                        child: const SizedBox(
                          width: double.infinity,
                          height: 80,
                          child: CubeShimmer(borderRadius: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildShowcaseCard(
                        dialogContext,
                        title: isRtl
                            ? "لوحة التحديث بالسحب (Pull-To-Refresh)"
                            : "Interactive Pull-To-Refresh Sandbox",
                        desc: isRtl
                            ? "اسحب القائمة لأسفل لتنشيط دوران التحديث ثلاثي الأبعاد"
                            : "Pull down inside the card to activate 3D orbit refresh spinner",
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: CubeRefreshIndicator(
                            onRefresh: () async {
                              await Future.delayed(
                                const Duration(seconds: 2),
                              );
                            },
                            color: theme.colorScheme.primary,
                            child: ListView.builder(
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(Icons.dns_rounded),
                                  title: Text(
                                    isRtl
                                        ? "تخزين البيانات السحابي رقم ${index + 1}"
                                        : "Cloud Storage Node #${index + 1}",
                                  ),
                                  subtitle: Text(
                                    isRtl
                                        ? "الحالة: متصل بالخادم الرئيسي"
                                        : "Status: Syncing with central server",
                                  ),
                                  dense: true,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
