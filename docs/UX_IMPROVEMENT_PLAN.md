# 🚀 LandyMaker — خطة تطوير تجربة المستخدم الشاملة (UX Master Plan v1)

> **ملف مرجعي للمطورين والنماذج الذكية.**
> يجب تنفيذ كل مرحلة بشكل مستقل والتحقق منها قبل الانتقال إلى التالية.

---

## 🎯 الأهداف الرئيسية

1. **تجربة مستخدم سلسة واحترافية** عبر كل الصفحات
2. **تصميم متجاوب مثالي** على الموبايل والديسكتوب
3. **عرض الخصائص بترتيب الأولوية** في واجهة المستخدم
4. **Routing صحيح** في كل صفحة مع URL واضح
5. **تناغم Animations مع الأداء** بدون تأثير على السرعة
6. **تباين الألوان الصحيح** — النصوص واضحة على كل خلفية
7. **صور حقيقية** لكل القوالب في `TemplateRegistry`
8. **Layouts متعددة** لكل قسم من أقسام صفحة الهبوط
9. **Layout Picker تفاعلي** مع Widget Selector

---

## 🗂️ جرد الوضع الحالي

### الملفات الأساسية المتأثرة:
| الملف | الدور |
|-------|-------|
| `lib/features/home/screens/landymaker_home_screen.dart` | صفحة الهبوط الرئيسية |
| `lib/features/home/widgets/home_hero_section.dart` | قسم Hero |
| `lib/features/home/widgets/home_feature_bento.dart` | قسم الخصائص |
| `lib/features/home/widgets/home_luxurious_template_slider.dart` | قسم القوالب |
| `lib/features/home/widgets/home_stats_section.dart` | قسم الإحصائيات |
| `lib/features/home/widgets/home_cta_section.dart` | قسم الـ CTA |
| `lib/features/home/widgets/home_navbar.dart` | شريط التنقل |
| `lib/features/home/widgets/home_footer.dart` | الـ Footer |
| `lib/features/home/screens/template_picker_screen.dart` | شاشة اختيار القالب |
| `lib/features/builder/registries/template_registry.dart` | سجل القوالب |
| `lib/core/router/app_router.dart` | نظام التوجيه |

---

## 📦 المراحل التفصيلية

---

### 📍 المرحلة الأولى: إصلاح تباين الألوان (Color Contrast Fixes)
**الأولوية: حرجة ⚠️**
**الزمن المقدر: يوم واحد**

#### المشكلات المعروفة:
- نصوص فاتحة على خلفيات فاتحة في بعض variants للـ sections
- overlay الخلفية في hero قد لا يكون كافياً للنصوص البيضاء
- ألوان `AppColors.textSecondary` قد تختلط مع بعض خلفيات الـ cards

#### المهام:
- [ ] **Task 1.1**: مراجعة كل `home_*.dart` والتأكد من WCAG contrast ratio ≥ 4.5:1 للنصوص العادية و ≥ 3:1 للعناوين
- [ ] **Task 1.2**: كل section فيه `bg_image` يجب أن يكون `bg_overlay_opacity` افتراضيه ≥ 0.45
- [ ] **Task 1.3**: مراجعة ألوان النصوص في `home_feature_bento.dart` على كل الـ themes
- [ ] **Task 1.4**: مراجعة `home_stats_section.dart` — الأرقام والنصوص على خلفية غامقة
- [ ] **Task 1.5**: مراجعة `home_cta_section.dart` — نص الـ CTA على الخلفية المتدرجة

#### قواعد الإصلاح:
```dart
// ✅ صحيح — نص أبيض على خلفية داكنة
Text('...', style: TextStyle(color: Colors.white))

// ✅ صحيح — نص داكن على خلفية فاتحة
Text('...', style: TextStyle(color: AppColors.textPrimary)) // #0F172A

// ❌ خطأ — نص رمادي فاتح على خلفية رمادي فاتح
Text('...', style: TextStyle(color: AppColors.textSecondary)) // فقط على bg داكن
```

---

### 📍 المرحلة الثانية: تحديث صور القوالب بصور حقيقية
**الأولوية: عالية**
**الزمن المقدر: يوم واحد**

#### المشكلة:
- معظم القوالب تستخدم صور متكررة أو غير مناسبة للـ category
- بعض القوالب مثل `fashion_store` تستخدم نفس صورة المرأة في 6 أماكن

#### الملف المستهدف:
`lib/features/builder/registries/template_registry.dart`

#### جدول تحديث الصور:

| القالب | الـ ID | حالة الصورة |
|--------|--------|------------|
| Empty Page | `empty` | ✅ مقبولة |
| SaaS Startup | `saas_startup` | ✅ مناسبة |
| Modern Store | `store` | ⚠️ صورة طالب — يجب تغييرها |
| Personal Brand | `personal` | ✅ مناسبة |
| Professional | `professional` | ✅ مناسبة |
| Real Estate | `real_estate` | ✅ مناسبة |
| Digital Course | `digital_course` | ✅ مناسبة |
| Event Landing | `event` | ✅ مناسبة |
| Restaurant | `restaurant` | ✅ مناسبة |
| Clinic | `clinic` | ⚠️ صورة طالب — يجب تغييرها |
| Beauty Salon | `beauty_salon` | ✅ مناسبة |
| Gym Fitness | `gym_fitness` | ✅ مناسبة |
| Mobile App SaaS | `mobile_app_saas` | ✅ مناسبة |
| Creative Agency | `creative_agency` | ✅ مناسبة |
| Nonprofit | `nonprofit_campaign` | ✅ مناسبة |
| Book Launch | `book_launch` | ✅ مناسبة |
| Solar Energy | `solar_energy` | ✅ مناسبة |
| Luxury Resort | `luxury_resort` | ✅ مناسبة |
| Fintech Crypto | `fintech_crypto` | ✅ مناسبة |
| Architecture | `architecture` | ✅ مناسبة |
| Fashion Store | `fashion_store` | ✅ مناسبة |

#### المهام:
- [ ] **Task 2.1**: تحديث صورة `clinic` إلى صورة طبية: `https://cdn.pixabay.com/photo/2014/12/10/21/01/doctor-563428_1280.jpg`
- [ ] **Task 2.2**: تحديث صورة `store` إلى صورة تسوق حقيقية
- [ ] **Task 2.3**: تحديث الصور الداخلية في بيانات القوالب (`_getXxxTemplate()`) لتعكس محتوى كل section بدلاً من الصور المكررة
- [ ] **Task 2.4**: التأكد من أن كل صورة template تظهر بنسبة عرض/ارتفاع مناسبة في `template_picker_screen.dart`

---

### 📍 المرحلة الثالثة: Layouts متعددة لأقسام صفحة الهبوط
**الأولوية: عالية جداً**
**الزمن المقدر: 3-5 أيام**

#### المفهوم:
كل قسم من أقسام صفحة الهبوط يجب أن يدعم **variant layouts** متعددة.

#### الأقسام وLayoutsها المقترحة:

##### أ. Hero Section
| Layout | Desktop | Mobile |
|--------|---------|--------|
| `split` (حالي) | نص يسار + صورة يمين | نص فوق + صورة تحت |
| `centered` | محتوى وسط + صورة خلفية كاملة | نفسه مع overlay |
| `gradientOnly` | نص وسط + gradient bg بلا صورة | نفسه |
| `mockupPhone` | نص يسار + موبايل mockup يمين | نص + موبايل صغير |

##### ب. Features Section
| Layout | Desktop | Mobile |
|--------|---------|--------|
| `bentoGrid` (حالي) | شبكة bento غير منتظمة | بطاقات عمودية |
| `threeCols` | 3 أعمدة متساوية مع أيقونات | بطاقة واحدة |
| `iconLeft` | أيقونة يسار + نص يمين (list) | نفسه عمودياً |
| `tabs` | tabs أعلى والمحتوى أسفل | dropdown بدلاً من tabs |

##### ج. Templates Slider
| Layout | Desktop | Mobile |
|--------|---------|--------|
| `horizontalSlider` (حالي) | slider أفقي | swipe |
| `masonryGrid` | masonry grid | 1 عمود |
| `twoColsGrid` | شبكة 2 عمود | 1 عمود |

##### د. Stats Section
| Layout | Desktop | Mobile |
|--------|---------|--------|
| `horizontal` (حالي) | 4 أرقام في صف | 2×2 grid |
| `withIcons` | رقم + أيقونة + وصف | نفسه |
| `progressBars` | progress bars مع animation | نفسه |

##### ه. CTA Section
| Layout | Desktop | Mobile |
|--------|---------|--------|
| `centeredGradient` (حالي) | نص وسط + زر | نفسه |
| `split` | نص يسار + زر يمين | نص فوق + زر تحت |
| `imageBackground` | صورة خلفية + CTA overlay | نفسه |

#### المهام:
- [ ] **Task 3.1**: إنشاء `lib/features/home/models/home_layouts.dart` مع enums
- [ ] **Task 3.2**: تعديل `HomeHeroSection` ليقبل `HeroLayout layout`
- [ ] **Task 3.3**: تعديل `HomeFeatureBento` ليقبل `FeatureLayout layout`
- [ ] **Task 3.4**: تعديل `HomeLuxuriousTemplateSlider` ليقبل `TemplateSliderLayout layout`
- [ ] **Task 3.5**: تعديل `HomeStatsSection` ليقبل `StatsLayout layout`
- [ ] **Task 3.6**: تعديل `HomeCtaSection` ليقبل `CtaLayout layout`
- [ ] **Task 3.7**: تعديل `LandyMakerHomeScreen` لتخزين وتمرير الـ layouts

---

### 📍 المرحلة الرابعة: Layout Picker تفاعلي
**الأولوية: عالية**
**الزمن المقدر: 3-4 أيام**

#### الوصف:
Panel صغير في Builder يتيح للمستخدم:
1. اختيار الـ layout لكل section
2. معاينة Desktop + Mobile preview
3. الضغط على كل "slot" في الـ layout لاختيار Widget نوعه

#### الملفات الجديدة:
```
lib/features/builder/widgets/layout_picker/
├── layout_picker_panel.dart
├── layout_option_card.dart
├── layout_slot_grid.dart
└── slot_widget_selector.dart
```

#### تدفق المستخدم:
```
اختيار Layout → Preview Desktop+Mobile → Slots Grid → اضغط Slot → اختر Widget Type → تطبيق
```

#### أنواع Widgets المتاحة للـ Slots:
- صورة (image)
- عنوان (heading)
- وصف (paragraph)
- زر (button)
- أيقونة (icon)
- فيديو (video)

#### المهام:
- [ ] **Task 4.1**: إنشاء `LayoutPickerPanel`
- [ ] **Task 4.2**: إنشاء `LayoutOptionCard` مع Desktop + Mobile preview
- [ ] **Task 4.3**: إنشاء `LayoutSlotGrid` مع hover effects
- [ ] **Task 4.4**: إنشاء `SlotWidgetSelector` modal
- [ ] **Task 4.5**: ربط الـ Picker بـ `LandingPageBuilderCubit.updateBlockProperty`

---

### 📍 المرحلة الخامسة: إصلاحات الـ Routing والـ URL
**الأولوية: حرجة**
**الزمن المقدر: نصف يوم**

#### الإصلاحات:
| المسار | المشكلة | الإصلاح |
|--------|---------|---------|
| `/builder` | Workspace فارغ | Redirect → `/dashboard` |
| `/dashboard/products` | `Text("Products")` placeholder | ربطه بـ `ProductFeedScreen` |
| لا يوجد | لا 404 page | إضافة `GoRouter.errorBuilder` |

#### المهام:
- [ ] **Task 5.1**: إصلاح `/builder` بدون pageId
- [ ] **Task 5.2**: ربط `/dashboard/products` بـ `ProductFeedScreen`
- [ ] **Task 5.3**: إضافة 404 error page عبر `GoRouter.errorBuilder`

---

### 📍 المرحلة السادسة: تحسين الـ Animations
**الأولوية: متوسطة**
**الزمن المقدر: 2 أيام**

#### المهام:
- [ ] **Task 6.1**: إضافة `RepaintBoundary` حول animated sections في `home_luxurious_template_slider.dart`
- [ ] **Task 6.2**: إضافة `RepaintBoundary` حول counters في `home_stats_section.dart`
- [ ] **Task 6.3**: التحقق من `AnimationController.dispose()` في كل `State`
- [ ] **Task 6.4**: استخدام `Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0))`

---

### 📍 المرحلة السابعة: تحسين التصميم على الموبايل
**الأولوية: عالية**
**الزمن المقدر: 3 أيام**

#### المشاكل المحتملة:
| الملف | المشكلة | الإصلاح |
|-------|---------|---------|
| `home_hero_section.dart` | Phone mockup overflow | `FittedBox(fit: BoxFit.scaleDown)` |
| `home_feature_bento.dart` | Bento layout على 320px | تبسيط الـ layout |
| `home_navbar.dart` | لا hamburger menu | إضافة Drawer للموبايل |
| `template_picker_screen.dart` | `childAspectRatio: 0.8` overflow | استبدال بـ `LayoutBuilder` |

#### المهام:
- [ ] **Task 7.1**: إضافة hamburger menu لـ `home_navbar.dart`
- [ ] **Task 7.2**: مراجعة `home_hero_section.dart` على الموبايل
- [ ] **Task 7.3**: مراجعة `template_picker_screen.dart`
- [ ] **Task 7.4**: تطبيق Padding صحيح: 80px Desktop، 40px Mobile
- [ ] **Task 7.5**: اختبار على 320px، 375px، 768px، 1024px، 1440px

---

### 📍 المرحلة الثامنة: إعادة ترتيب الأقسام
**الأولوية: متوسطة**
**الزمن المقدر: يوم واحد**

#### الترتيب المقترح:
```
1. Hero ✅ حالي
2. Trust Logos (جديد) — ثقة فورية
3. Features Bento ✅ حالي
4. Templates Slider ✅ حالي
5. Stats ✅ حالي
6. Testimonials (جديد) — آراء العملاء
7. CTA ✅ حالي
8. Footer ✅ حالي
```

#### المهام:
- [ ] **Task 8.1**: إنشاء قسم Trust Logos جديد بعد Hero
- [ ] **Task 8.2**: إنشاء قسم Testimonials جديد بعد Stats
- [ ] **Task 8.3**: تحديث `LandyMakerHomeScreen` بالترتيب الجديد

---

## ✅ قواعد التحقق العامة

قبل اعتبار أي مهمة مكتملة، يجب التحقق من:

1. **لا Overflow** — اختبار على 320px عرض
2. **تباين الألوان** — كل نص مرئي بوضوح على خلفيته
3. **LayoutBuilder** — لا `MediaQuery.of(context).size` داخل block widgets
4. **RTL/LTR** — استخدام `EdgeInsetsDirectional` فقط
5. **CustomNetworkImage** — لا `Image.network` مباشرة
6. **RepaintBoundary** — حول كل animated widget
7. **dispose()** — كل AnimationController له dispose صحيح
8. **لا Hardcoded Heights** — لا `height: 300` لـ containers تحتوي نصوص
9. **Routing صحيح** — كل URL يؤدي للصفحة الصحيحة
10. **Bilingual** — كل مفتاح ترجمة موجود في AR وEN

---

## 🤖 AI Execution Prompts — جاهزة للنسخ والتنفيذ

---

### ═══ PROMPT 1: إصلاح تباين الألوان ═══

```
أنت مطور Flutter متخصص في مشروع LandyMaker.

═══ قواعد المشروع الحرجة (يجب اتباعها بدقة تامة) ═══
1. استخدم `LayoutBuilder` دائماً لتحديد isMobile (constraints.maxWidth < 600)
2. لا تستخدم `MediaQuery.of(context).size` داخل الـ widgets
3. استخدم `EdgeInsetsDirectional` بدلاً من `EdgeInsets.only(left/right)`
4. استخدم `CustomNetworkImage` فقط لعرض الصور (لا Image.network)
5. لا تحذف أي تعليق أو docstring موجود
6. لا تنشئ ملفات مؤقتة للـ debugging
7. لا تغير أي ملفات خارج القائمة المحددة

═══ المهمة ═══
افحص كل `Text` widget في الملفات التالية وأصلح تباين الألوان:
- lib/features/home/widgets/home_hero_section.dart
- lib/features/home/widgets/home_feature_bento.dart
- lib/features/home/widgets/home_stats_section.dart
- lib/features/home/widgets/home_cta_section.dart
- lib/features/home/widgets/home_footer.dart

═══ معايير الإصلاح ═══
- نص على خلفية داكنة (hex < #808080) → لون النص يكون أبيض أو فاتح جداً
- نص على خلفية فاتحة (hex > #808080) → لون النص يكون AppColors.textPrimary (#0F172A)
- AppColors.textSecondary يُستخدم فقط على خلفيات داكنة
- كل Section فيها background_image تحتاج overlay: Container(color: Colors.black.withValues(alpha: 0.50)) فوق الصورة

═══ لكل مشكلة ═══
اذكر: اسم الملف + line number + اللون الحالي + تقدير خلفيته + اللون الصحيح + طبّق الإصلاح

═══ التحقق الإلزامي ═══
بعد الإصلاح: شغّل `flutter analyze` وتأكد أنه نظيف تماماً
```

---

### ═══ PROMPT 2: تحديث صور القوالب ═══

```
أنت مطور Flutter متخصص في مشروع LandyMaker.

═══ قواعد صارمة ═══
1. لا تغير أي منطق كود — فقط قيم الـ imageUrl
2. لا تحذف أي template
3. لا تضيف templates جديدة
4. لا تغير أي ملفات خارج الملف المحدد
5. استخدم فقط روابط Pixabay CDN (cdn.pixabay.com)
6. لا تكرر نفس الـ URL أكثر من مرة في نفس الـ template function

═══ الملف المستهدف ═══
lib/features/builder/registries/template_registry.dart

═══ التحديثات المطلوبة في `availableTemplates` ═══

تحديث 1 — clinic:
imageUrl الحالي: 'https://cdn.pixabay.com/photo/2015/07/17/22/43/student-849825_1280.jpg'
imageUrl الجديد: 'https://cdn.pixabay.com/photo/2014/12/10/21/01/doctor-563428_1280.jpg'

تحديث 2 — store (إذا كانت الصورة صورة طالب أو غير مناسبة للـ ecommerce):
غيّر imageUrl إلى صورة shopping/retail مناسبة من Pixabay

═══ التحديثات المطلوبة في template data functions ═══

في `_getLuxuryResortTemplate()`:
- gallery items → 3 روابط مختلفة من Pixabay عن pools/resorts (لا تكرر نفس الرابط)
- team members → صور portraits مختلفة لأشخاص

في `_getFashionStoreTemplate()`:
- products images → صور مختلفة (فستان ≠ حقيبة)
- gallery items → صور fashion مختلفة

في `_getArchitectureTemplate()`:
- gallery items → 3 صور مختلفة من Pixabay عن architecture/buildings

في `_getFintechCryptoTemplate()`:
- hero image_url → استبدل صورة workspace بصورة fintech/bitcoin مناسبة

في `_getLuxuryResortTemplate()` → hero image_url:
- استبدل woman-3040029 بصورة resort/hotel مناسبة

═══ التحقق الإلزامي ═══
1. شغّل: dart analyze lib/features/builder/registries/template_registry.dart
2. تأكد: لا syntax errors
3. تأكد: لا URL مكرر داخل نفس الـ template function
```

---

### ═══ PROMPT 3: Layouts متعددة للـ Hero Section ═══

```
أنت مطور Flutter متخصص في مشروع LandyMaker.

═══ قواعد المشروع الحرجة (يجب اتباعها بدقة تامة) ═══
1. استخدم `LayoutBuilder` لتحديد isMobile (constraints.maxWidth < 600)
2. لا تستخدم `MediaQuery.of(context).size` داخل الـ widgets
3. استخدم `EdgeInsetsDirectional` — لا EdgeInsets.only(left/right)
4. Desktop vertical padding: 80px — Mobile vertical padding: 40px
5. لا تستخدم height ثابت لـ containers تحتوي نصوص
6. احتوِ الـ mockup/decorative widgets في FittedBox(fit: BoxFit.scaleDown) لمنع overflow
7. استخدم RepaintBoundary حول كل animated widget
8. استخدم Interval(start.clamp(0.0,1.0), end.clamp(0.0,1.0)) في الـ animations
9. استخدم AppColors و AppTypography — لا hardcoded colors أو font sizes
10. كل layout يجب أن يدعم RTL و LTR بشكل صحيح

═══ الخطوة 1: أنشئ ملف جديد ═══
الملف: lib/features/home/models/home_layouts.dart

المحتوى:
```dart
/// Enum definitions for home page section layout variants.
/// Used by home screen section widgets to render different structural layouts.
enum HeroLayout {
  /// Default: text left/right + image right/left
  split,
  /// Full-width background image with centered text overlay
  centered,
  /// Gradient background only, no image, centered text
  gradientOnly,
}

enum FeatureLayout {
  /// Irregular bento grid (current default)
  bentoGrid,
  /// Three equal columns with icons
  threeCols,
  /// Icon on the left, text on the right (list style)
  iconLeft,
}

enum StatsLayout {
  /// Horizontal row of numbers (current default)
  horizontal,
  /// Numbers with icons and descriptions
  withIcons,
}

enum CtaLayout {
  /// Centered text + button on gradient background (current default)
  centeredGradient,
  /// Text left, button right (splits on desktop)
  split,
}
```

═══ الخطوة 2: عدّل HomeHeroSection ═══
الملف: lib/features/home/widgets/home_hero_section.dart

أضف parameter:
final HeroLayout layout;
const HomeHeroSection({..., this.layout = HeroLayout.split});

نفّذ switch على الـ layout داخل LayoutBuilder:
```dart
LayoutBuilder(builder: (context, constraints) {
  final isMobile = constraints.maxWidth < 600;
  switch (widget.layout) {
    case HeroLayout.split:
      return _buildSplitLayout(context, isMobile, constraints);
    case HeroLayout.centered:
      return _buildCenteredLayout(context, isMobile, constraints);
    case HeroLayout.gradientOnly:
      return _buildGradientLayout(context, isMobile, constraints);
  }
})
```

HeroLayout.centered:
- Stack: صورة خلفية (CustomNetworkImage) + Container overlay أسود 50% + نص أبيض في المنتصف
- نص يكون دائماً Colors.white في هذا الـ layout

HeroLayout.gradientOnly:
- Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary])))
- نص في المنتصف، لون النص يكون متباين مع الـ gradient

═══ الخطوة 3: عدّل LandyMakerHomeScreen ═══
الملف: lib/features/home/screens/landymaker_home_screen.dart

أضف في State:
HeroLayout _heroLayout = HeroLayout.split;

مرّر للـ widget:
HomeHeroSection(
  layout: _heroLayout,
  onGetStartedPressed: () => context.go('/templates'),
  parentScrollController: _scrollController,
)

═══ التحقق الإلزامي ═══
1. flutter analyze → نظيف تماماً
2. اختبر على 320px عرض — لا overflow
3. اختبر على 1440px عرض — تناغم بصري
4. RTL: الـ split layout — نص يمين، صورة يسار
5. LTR: الـ split layout — نص يسار، صورة يمين
6. HeroLayout.centered: النص واضح (أبيض) على الصورة
```

---

### ═══ PROMPT 4: Layout Picker Panel ═══

```
أنت مطور Flutter متخصص في مشروع LandyMaker.

═══ قواعد المشروع الحرجة (يجب اتباعها بدقة تامة) ═══
1. لا تكسر أي نظام موجود (Builder Engine, Rendering Pipeline, Action System)
2. كل تعديل على الـ design يمر عبر LandingPageBuilderCubit فقط
3. استخدم DraggableModalSheet للـ modals المعقدة (موجود في lib/core/widgets/)
4. استخدم LayoutBuilder لتحديد isMobile (constraints.maxWidth < 600)
5. استخدم EdgeInsetsDirectional فقط
6. استخدم CustomNetworkImage للصور
7. لا تنشئ ملفات في /docs/ai/ أو تحذفها
8. أضف كل مفاتيح الترجمة في: lib/core/localization/translations_ar.dart و translations_en.dart
9. اعرض CircularProgressIndicator أثناء الحفظ
10. اعرض رسالة خطأ واضحة عند الفشل

═══ الملفات المستهدفة (إنشاء) ═══
lib/features/builder/widgets/layout_picker/layout_picker_panel.dart
lib/features/builder/widgets/layout_picker/layout_option_card.dart
lib/features/builder/widgets/layout_picker/layout_slot_grid.dart
lib/features/builder/widgets/layout_picker/slot_widget_selector.dart

═══ layout_picker_panel.dart ═══
```dart
/// Layout Picker Panel — allows users to choose a section layout variant.
/// Shows a list of available layouts for the current section type.
/// On Mobile: appears as DraggableScrollableSheet from bottom.
/// On Desktop: appears as a side panel.
class LayoutPickerPanel extends StatefulWidget {
  final String sectionType; // 'hero', 'features', 'stats', 'cta'
  final int blockIndex;
  final Map<String, dynamic> currentBlock;
  final Function(String layoutKey) onLayoutSelected;

  const LayoutPickerPanel({
    super.key,
    required this.sectionType,
    required this.blockIndex,
    required this.currentBlock,
    required this.onLayoutSelected,
  });
}
```

المحتوى:
- قائمة من LayoutOptionCard widgets
- كل layout له اسم، key، وpreview thumbnail بسيط

═══ layout_option_card.dart ═══
```dart
/// A card representing one layout option in the picker.
/// Shows name + simplified desktop preview + mobile preview.
class LayoutOptionCard extends StatelessWidget {
  final String layoutName;
  final String layoutKey;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget desktopThumbnail; // Small Container sketch of the layout
  final Widget mobileThumbnail;  // Small Container sketch of mobile layout
}
```

Design:
- Border/glow عند isSelected
- AnimatedContainer transition 200ms
- اسم الـ layout + أيقونة ✓ عند التحديد

═══ layout_slot_grid.dart ═══
```dart
/// Displays the selected layout divided into interactive slots.
class LayoutSlotGrid extends StatelessWidget {
  final List<LayoutSlot> slots;
  final Function(int slotIndex) onSlotTap;
}

class LayoutSlot {
  final String slotId;
  final String slotLabel; // مثال: 'صورة رئيسية'، 'عنوان'
  final SlotContentType currentType;
  final dynamic currentValue; // String للنص أو URL للصورة
}

enum SlotContentType { image, heading, paragraph, button, icon, video }
```

Design:
- كل slot عبارة عن Container بـ border dashed
- عند hover: border يتحول لـ AppColors.secondary
- داخل كل slot: أيقونة الـ type الحالي + label
- عند tap: يفتح SlotWidgetSelector

═══ slot_widget_selector.dart ═══
```dart
/// Modal for selecting widget type for a layout slot.
class SlotWidgetSelector extends StatelessWidget {
  final int slotIndex;
  final SlotContentType currentType;
  final Function(SlotContentType newType) onTypeSelected;
}
```

يعرض Grid 2×3 من الخيارات:
- صورة (Icons.image)
- عنوان (Icons.title)
- وصف (Icons.text_fields)
- زر (Icons.smart_button)
- أيقونة (Icons.emoji_emotions)
- فيديو (Icons.play_circle)

═══ مفاتيح الترجمة المطلوبة ═══
translations_ar.dart:
'choose_layout': 'اختر التخطيط',
'layout_preview': 'معاينة التخطيط',
'slot_type_image': 'صورة',
'slot_type_heading': 'عنوان',
'slot_type_paragraph': 'وصف',
'slot_type_button': 'زر',
'slot_type_icon': 'أيقونة',
'slot_type_video': 'فيديو',
'desktop_preview': 'معاينة ديسكتوب',
'mobile_preview': 'معاينة موبايل',

translations_en.dart:
'choose_layout': 'Choose Layout',
'layout_preview': 'Layout Preview',
'slot_type_image': 'Image',
'slot_type_heading': 'Heading',
'slot_type_paragraph': 'Paragraph',
'slot_type_button': 'Button',
'slot_type_icon': 'Icon',
'slot_type_video': 'Video',
'desktop_preview': 'Desktop Preview',
'mobile_preview': 'Mobile Preview',

═══ التحقق الإلزامي ═══
1. flutter analyze → نظيف تماماً
2. الـ Panel يفتح ويغلق بشكل صحيح
3. اختيار layout لا يكسر الـ builder أو الـ rendering
4. كل تعديل slot يُحفظ عبر LandingPageBuilderCubit
5. يعمل صح على RTL و LTR
6. لا Overflow على 320px
```

---

### ═══ PROMPT 5: إصلاحات الـ Routing ═══

```
أنت مطور Flutter متخصص في مشروع LandyMaker.

═══ قواعد صارمة ═══
1. كل navigation عبر context.go يُغلّف في WidgetsBinding.instance.addPostFrameCallback
2. لا تحذف أي route موجود
3. لا تضيف routes خارج نطاق المهمة
4. لا تغير أي ملف خارج app_router.dart
5. لا تغير منطق الـ Authentication أو الـ TenantRoutingService

═══ الملف المستهدف ═══
lib/core/router/app_router.dart

═══ الإصلاح 1: /builder بدون pageId ═══
ابحث عن:
GoRoute(
  path: '/builder',
  builder: (context, state) { ... },
  routes: [...],
),

استبدل الـ builder المباشر بـ redirect:
GoRoute(
  path: '/builder',
  redirect: (context, state) {
    // إذا كان المسار بالضبط /builder بدون pageId، اذهب للـ dashboard
    if (state.uri.toString() == '/builder') return '/dashboard';
    return null; // السماح للـ sub-routes تمر
  },
  routes: [
    GoRoute(
      path: ':pageId',
      builder: ... // يبقى كما هو
    ),
  ],
),

═══ الإصلاح 2: /dashboard/products ═══
ابحث عن:
GoRoute(
  path: '/dashboard/products',
  builder: (context, state) => const Center(child: Text("Products")),
),

استبدل بـ:
GoRoute(
  path: '/dashboard/products',
  builder: (context, state) => const ProductFeedScreen(),
),
(تأكد أن ProductFeedScreen مستورد — هو موجود بالفعل في imports الملف)

═══ الإصلاح 3: إضافة 404 Page ═══
في تعريف GoRouter، أضف errorBuilder:

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off, size: 64, color: AppColors.secondary),
              const SizedBox(height: 24),
              Text(
                '404',
                style: AppTypography.h1.copyWith(color: AppColors.secondary),
              ),
              const SizedBox(height: 8),
              Text(
                context.translate('page_not_found'),
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => WidgetsBinding.instance.addPostFrameCallback(
                  (_) => context.go('/'),
                ),
                icon: const Icon(Icons.home),
                label: Text(context.translate('back_to_home')),
              ),
            ],
          ),
        ),
      ),
    );
  },
  routes: [...], // يبقى كما هو
);

أضف مفاتيح الترجمة:
translations_ar.dart: 'page_not_found': 'الصفحة غير موجودة', 'back_to_home': 'العودة للرئيسية'
translations_en.dart: 'page_not_found': 'Page Not Found', 'back_to_home': 'Back to Home'

═══ التحقق الإلزامي ═══
1. flutter analyze → نظيف
2. افتح /builder مباشرة → يذهب لـ /dashboard
3. افتح /dashboard/products → يُظهر ProductFeedScreen
4. افتح /any-random-path → يُظهر صفحة 404
5. زر "العودة للرئيسية" في 404 يعمل
```

---

### ═══ PROMPT 6: Mobile Navbar مع Hamburger Menu ═══

```
أنت مطور Flutter متخصص في مشروع LandyMaker.

═══ قواعد المشروع الحرجة ═══
1. استخدم LayoutBuilder أو constraints للتمييز بين Mobile/Desktop
2. استخدم EdgeInsetsDirectional
3. استخدم AppColors و AppTypography فقط
4. لا تغير واجهة HomeNavbar constructor — المعاملات تبقى كما هي:
   - onLoginPressed: VoidCallback
   - onGetStartedPressed: VoidCallback
5. لا تغير أي ملفات خارج home_navbar.dart
6. أضف مفاتيح الترجمة في translations_ar.dart و translations_en.dart

═══ الملف المستهدف ═══
lib/features/home/widgets/home_navbar.dart

═══ المهمة ═══
أضف دعم الموبايل للـ Navbar:

على Desktop (عرض ≥ 768px) — يبقى كما هو بالضبط

على Mobile (عرض < 768px):
- يُظهر: Logo يسار (RTL: يمين) + زر Hamburger (☰) يمين (RTL: يسار)
- عند الضغط على Hamburger → AnimatedContainer ينزل من الـ navbar
- محتوى الـ Drawer المنسدل:
  - روابط التنقل عمودياً
  - زر "تسجيل الدخول" (onLoginPressed)
  - زر "ابدأ مجاناً" (onGetStartedPressed)
- يُغلق عند الضغط على أي رابط أو خارج الـ menu

كود التنفيذ:
```dart
// في State
bool _mobileMenuOpen = false;

// زر الـ hamburger
IconButton(
  icon: AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    child: Icon(
      _mobileMenuOpen ? Icons.close : Icons.menu,
      key: ValueKey(_mobileMenuOpen),
      color: AppColors.textPrimary,
    ),
  ),
  onPressed: () => setState(() => _mobileMenuOpen = !_mobileMenuOpen),
)

// الـ menu المنسدل
AnimatedContainer(
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  height: _mobileMenuOpen ? _menuHeight : 0,
  child: ClipRect(
    child: Column(
      children: [
        // روابط
        // أزرار
      ],
    ),
  ),
)
```

RTL behavior:
- RTL: Hamburger يكون على اليسار، Logo على اليمين
- LTR: Hamburger يكون على اليمين، Logo على اليسار
- استخدم context.isRtl للتمييز

مفاتيح الترجمة:
translations_ar.dart: 'open_menu': 'فتح القائمة', 'close_menu': 'إغلاق القائمة'
translations_en.dart: 'open_menu': 'Open Menu', 'close_menu': 'Close Menu'

═══ التحقق الإلزامي ═══
1. flutter analyze → نظيف
2. اختبر على 320px — لا overflow، الـ Hamburger ظاهر
3. الـ menu يفتح ويغلق بسلاسة
4. RTL: الـ hamburger على اليسار
5. LTR: الـ hamburger على اليمين
6. كل رابط في الـ menu يُغلق القائمة بعد النقر
```

---

## 📋 ملاحظات التنفيذ

### ترتيب التنفيذ الموصى به:
```
Prompt 5 (Routing) → Prompt 1 (Colors) → Prompt 2 (Images) →
Prompt 6 (Mobile Navbar) → Prompt 3 (Hero Layouts) →
Prompt 4 (Layout Picker)
```

### الأنظمة المحمية — لا تلمسها إطلاقاً:
- ❌ BuilderEngine و SectionRenderer
- ❌ ActionHandlerService
- ❌ lead-submit Edge Function
- ❌ middleware.js
- ❌ /docs/ai/ files
- ❌ Authentication system

### الأنظمة القابلة للتعديل:
- ✅ home_*.dart widgets
- ✅ template_registry.dart (imageUrl فقط)
- ✅ app_router.dart (إصلاحات محددة)
- ✅ ملفات جديدة في lib/features/builder/widgets/layout_picker/
- ✅ ملفات جديدة في lib/features/home/models/
- ✅ translations_ar.dart و translations_en.dart (إضافة فقط)
