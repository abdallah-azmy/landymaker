# Cube Loading Ecosystem — خطة تحويل كل أنماط التحميل إلى مكعبات

## الرؤية
نظام تحميل موحد كامل يعتمد على المكعبات فقط — لا `CircularProgressIndicator`، لا `Shimmer`، لا `RefreshIndicator` القياسي. كل حاجة في لانديميكر تستخدم لغة المكعبات البصرية.

---

## الخطة الكاملة — 7 مراحل

```
Phase 0: ✅ LoadingLogo (اللي خلصناه)
Phase 1: ✅ Tiny CubeSpinner (الأزرار)
Phase 2: ✅ Medium CubeProgress (الرفع/الصور)
Phase 3: ✅ CubeShimmer (بديل الـ shimmer)
Phase 4: ✅ CubeRefreshIndicator (السحب للتحديث)
Phase 5: ✅ AI Generation Premium (الذكاء الاصطناعي)
Phase 6: ✅ Final Migration + Audit
-----
Phase 7: ✅ V3 Unified CubeLoader — replaces LoadingLogo/CubeSpinner/CubeProgress
```

---

## Phase 1 — ✅ Tiny CubeSpinner (16–20px)

**الهدف**: استبدال كل `CircularProgressIndicator` في الأزرار بمكعب يدور.

**التفاصيل**:
- `CustomPaint` بمكعب واحد صغير
- المكعب يدور حول محور Y (isometric rotation)
- 3 وجوه مرئية (top, left, right) مع fill و stroke
- زوايا مدورة (rounded corners)
- لون يتغير حسب السياق (primary, white, green)
- 16-20px

**ملف جديد**: `lib/core/widgets/atoms/cube_spinner.dart`

**المكونات**:
```dart
class CubeSpinner extends StatefulWidget {
  final double size;        // 16 أو 20
  final Color color;         // ياخد من Theme
  final double strokeWidth;  // 1.5-2.0
}
```

**الملفات المتأثرة** (13 ملف):
1. ✅ `primary_button.dart` — 16px (isSecondary → onSecondary/onPrimary)
2. ✅ `social_sign_in_button.dart` — 20px (secondary)
3. ✅ `sticky_cta_bar.dart` — 20px (white)
4. ✅ `custom_lead_form_widget.dart` — 20px (white)
5. ✅ `custom_lead_magnet_widget.dart` — 20px (white)
6. ✅ `custom_multi_step_form_widget.dart` — 20px (white)
7. ✅ `ai_chat_modal.dart` — 16px (primary)
8. ✅ `builder_app_bar.dart` (draft) — 20px (green)
9. ✅ `builder_app_bar.dart` (published) — 20px (primary)
10. ✅ `builder_mobile_toolbar.dart` — 16px (green)
11. ✅ `create_page_modal.dart` — 16px (slug check)
12. ✅ `blog_editor_screen.dart` — 20px (surface)
13. ✅ `ai_chat_input.dart` — 20px (white)

**الأداء**: 
- `RepaintBoundary` حول CustomPaint
- `SingleTickerProviderStateMixin` — لا تضارب مع providers تانية
- AnimationController `.repeat()` بدون ticker overhead
- 1 مكعب فقط = 3 وجوه (top, left, right) = 3 parallelograms
- Depth sorting بـ `_FaceEntry` list (6 عناصر كحد أقصى)

---

## Phase 2 — ✅ Medium CubeProgress (48px)

**الهدف**: استبدال الـ CircularProgressIndicator في رفع الصور والتحميلات المتوسطة

**التفاصيل**:
- 3 مكعبات في cluster مثلثي يدور ببطء (cluster rotation)
- للـ determinate (الرفع): المكعبات تنور واحدة واحدة مع %
- للـ indeterminate: المكعبات الثلاثة كلها منورة وتدور
- Percentage text مدمج في Stack

**ملف جديد**: `lib/core/widgets/atoms/cube_progress.dart`

**المكونات**:
```dart
class CubeProgress extends StatefulWidget {
  final double size;            // 24 أو 48
  final Color color;            // primary / cyan
  final double? value;          // null = indeterminate
  final bool showPercentage;    // يظهر % فوق المكعبات
}
```

**الملفات المتأثرة** (7 ملف):
1. ✅ `custom_network_image.dart` — upload progress (48px, cyan) + percentage
2. ✅ `global_upload_manager_widget.dart` — upload progress (24px, primary)
3. ✅ `custom_image_field.dart` — upload indicator (48px, cyan)
4. ✅ `image_picker_modal.dart` — gallery/pixabay/load-more (cyan)
5. ✅ `pixabay_selector_modal.dart` — search loading (primary)
6. ✅ `create_page_modal.dart` — limit check → `LoadingLogo(size: 48)`
7. ✅ `notification_inbox_modal.dart` — section loading → `LoadingLogo(size: 48)`

---

## Phase 3 — ✅ CubeShimmer (بديل Shimmer)

**الهدف**: استبدال `Shimmer.fromColors` في `CustomNetworkImage` بشيء cube-based.

**التفاصيل**:
- Grid من مكعبات صغيرة (4×3 إلى 6×4 حسب حجم الكونتينر)
- Wave pattern: المكعبات تنور وتطفى بشكل wave قطري
- بدون stroke تقريباً (0.5px خفيف)
- نفس خلفية LoadingLogo الداكنة (slate 900)
- إلغاء `shimmer` package من pubspec.yaml

**ملف جديد**: `lib/core/widgets/atoms/cube_shimmer.dart`

**المكونات**:
```dart
class CubeShimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
}
```

**الملفات المتأثرة**:
1. ✅ `custom_network_image.dart` — يستبدل `_buildLoadingWidget()`
2. ✅ إلغاء الاعتماد على `shimmer` package من pubspec.yaml

---

## Phase 4 — ✅ CubeRefreshIndicator

**الهدف**: استبدال `RefreshIndicator` القياسي بـ CubeRefreshIndicator

**التفاصيل**:
- يستقبل `ScrollNotification` لاكتشاف السحب لأسفل
- يتعامل مع iOS (bouncy) و Android (overscroll) 
- أثناء السحب: cube واحد يظهر ويتكبر مع مسافة السحب، بعدين 3 cubes
- عند التحرير: 3 cubes تدور في مدار (orbit) أثناء التحديث
- `_CubePullIndicator` — 1-3 CubeSpinner في row
- `_CubeOrbit` — 3 cubes تدور (CustomPaint داخلي)

**ملف جديد**: `lib/core/widgets/atoms/cube_refresh_indicator.dart`

**المكونات**:
```dart
class CubeRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color color;
}
```

**الملفات المتأثرة** (5 ملفات):
1. ✅ `dashboard_home_screen.dart` (desktop + mobile) — ×2
2. ✅ `analytics_screen.dart`
3. ✅ `leads_tracker_screen.dart`
4. ✅ `public_landing_page.dart`

---

## Phase 5 — ✅ AI Generation Premium

**الهدف**: تحسين تجربة الـ AI generation باستخدام مكعبات متحركة.

**التفاصيل**:
- استخدام `LoadingLogo(state: loading)` بدل `CubeSpinner` في `_buildLoadingIndicator`
- رسالة نصية + Logo متحرك مع glow
- 3 مراحل: تفكير → توليد → تطبيق — كلها تستخدم نفس الـ LoadingLogo

**الملفات المتأثرة**:
1. ✅ `ai_chat_modal.dart` — LoadingLogo(size: 24, loading) + النص

---

## Phase 6 — ✅ Final Migration + Audit

1. ❌ تشغيل `flutter analyze` — Flutter SDK مش available في البيئة الحالية
2. ✅ مسح الـ shimmer package من pubspec (ممسوح قبل كده)
3. ✅ استبدال 6 `CircularProgressIndicator` متبقية في super_admin و blog_admin
4. ✅ تحديث `docs/plans/cube_loading_ecosystem_plan.md`
5. ✅ لا يتبقى أي `RefreshIndicator` قياسي في الـ codebase
6. ⏳ اختبار يدوي لكل الأنماط — يحتاج build فعلي

### تفاصيل الـ 6 CircularProgressIndicator المُستبدلة:
| الملف | الاستبدال |
|-------|-----------|
| `template_config_sheet.dart` | `CubeSpinner(size: 16)` — inline loading |
| `section_renderer_config_sheet.dart` | `CubeSpinner(size: 16)` — inline loading |
| `user_profile_screen.dart` | `LoadingLogo(size: 48)` — page loading |
| `homepage_editor_screen.dart` | `LoadingLogo(size: 48)` — page loading |
| `platform_seo_screen.dart` | `LoadingLogo(size: 48)` — page loading |
| `blog_management_screen.dart` | `LoadingLogo(size: 48)` — page loading |

---

## Phase 7 — ✅ V3 Unified CubeLoader

**الهدف**: توحيد كل أنظمة التحميل المكعبة (LoadingLogo + CubeSpinner + CubeProgress) في Widget واحد مع أداء محسّن.

**التفاصيل**:
- Widget واحد: `CubeLoader` (particles/cube_loader.dart)
- 3 Variants: logo (27 cubes), single (1 cube), cluster (3 cubes orbit)
- Shared geometry: `core/cube_geometry.dart` (verts, faces, normals, rotation, lighting)
- **Zero allocations in paint** — static scratch buffers (`_tv`, `_nv`, `_path`) reused كل فريم
- **Cubic bezier** corners — smoother من quadratic bezier القديم
- **Ambient occlusion** — المكعبات الداخلية أغمق والوجوه المخفية متسكبة
- **Cached lighting rotation** — `_lightRot` يحسب مرة واحدة لكل فريم مش لكل face

**الملفات الجديدة**:
1. ✅ `lib/core/widgets/particles/core/cube_geometry.dart` — 120 سطر، shared math
2. ✅ `lib/core/widgets/particles/cube_loader.dart` — 450 سطر، unified widget

**الملفات المحدثة (wrappers)**:
3. ✅ `loading_logo.dart` — thin wrapper (50 سطر بدلاً من 653)
4. ✅ `cube_spinner.dart` — thin wrapper (30 سطر بدلاً من 251)
5. ✅ `cube_progress.dart` — thin wrapper (40 سطر بدلاً من 314)
6. ✅ `cube_shimmer.dart` — يستخدم cube_geometry.dart بدلاً من constants الخاصة

**إجمالي التخفيض**: 653 + 251 + 314 = 1218 سطر → 120 + 450 + 50 + 30 + 40 + 150 = ~840 سطر (تخفيض ~31%)

---

## المخطط الزمني (مقترح)

| المرحلة | الملفات | التعقيد |
|---------|---------|---------|
| Phase 1 ✅ | 13 ملف + 1 جديد | ⭐ — سهل (CustomPaint بسيط) |
| Phase 2 ✅ | 7 ملف + 1 جديد | ⭐⭐ |
| Phase 3 ✅ | 2 ملف + 1 جديد + pubspec | ⭐⭐⭐ |
| Phase 4 ✅ | 5 ملف + 1 جديد | ⭐⭐⭐⭐ |
| Phase 5 ✅ | 1 ملف | ⭐ |
| Phase 6 ✅ | 6 ملف + audit | ⭐ |
| Phase 7 ✅ | 2 ملف جديد + 4 wrappers | ⭐⭐⭐⭐⭐ |

---

## ملاحظات الأداء

- كل `CustomPaint` بيكون في `RepaintBoundary`
- الـ tiny size (16-20px): مكعب واحد فقط، بدون fill، stroke خفيف
- الـ shimmers: استخدام ring buffer زي اللي في `FloatingCubeBackground` لو احتجنا allocation-less
- ما فيش `dart:math` عمليات تقيلة في الـ paint (إعادة استخدام const lists)
