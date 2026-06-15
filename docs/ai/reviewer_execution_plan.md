# خطة التنفيذ التفصيلية (Execution Plan)

هذه الخطة تم تصميمها للبدء بتنفيذ ما فات من الخطة السابقة وإصلاح الأخطاء المتبقية، مقسمة لمراحل دقيقة لضمان عدم الهلوسة.

## Phase A: High Priority Bugs & Missing Implementations
**الخطوة 1: إصلاح تعقيد O(n²) في Builder AI Session**
- الملف: `lib/features/builder/ai/ai_conversation_session.dart`
- التغيير: البحث عن `blocks.map((block)` واستبدالها بحلقة `for (int i=0; i<blocks.length; i++)` واستخدام المتغير `i` مباشرة بدلاً من `blocks.indexOf(block)` الذي يسبب بطء الأداء.

**الخطوة 2: استكمال دعم `mobile_columns` بالكامل**
- الملفات: 
  - `lib/features/builder/registries/block_schema_registry.dart` (إضافة حقل `mobile_columns: 1` افتراضياً ضمن قائمة `products` و `gallery`).
  - `lib/features/public_viewer/parsers/custom_products_parser.dart` (استخراج الحقل من الـ JSON باستخدام `NumericParser`).
  - `lib/features/builder/widgets/editors/blocks/products_editor.dart` (إضافة واجهة تحكم، مثلاً SegmentedButton لاختيار 1 أو 2 أعمدة).

**الخطوة 3: التخلص من استخدام MediaQuery بشكل مباشر**
- الملفات الرئيسية: `lib/features/home/widgets/home_cta_section.dart`, `home_footer.dart`, `home_hero_section.dart`
- التغيير: لف الجزء الذي يستخدم `MediaQuery.of(context).size` بـ `LayoutBuilder` واستخدام `constraints.maxWidth`، التزاماً صارماً بقواعد المشروع.

**الخطوة 4: تحديث `withOpacity` إلى `withValues`**
- الملفات: أينما تم العثور على تحذيرات Deprecation لـ `withOpacity`، استبدلها بـ `.withValues(alpha: x)` لضمان استقرار الكود مع الإصدارات الحديثة من Flutter.

## Phase B: Guest Onboarding & Auth Flow
**الخطوة 5: حصر استخدام AI للضيوف بمحاولة واحدة**
- الملف: `lib/features/dashboard/controllers/auth_cubit.dart` و `lib/features/builder/ai/ai_conversation_session.dart`.
- التغيير: حفظ حالة الاستخدام (مثلاً `hasUsedFreeAIPrompt` في `SharedPreferences`). السماح للضيف بإرسال رسالة واحدة فقط للـ AI لإنشاء الصفحة. في المحاولة الثانية يظهر مودال تسجيل الدخول.

**الخطوة 6: حاجز تسجيل الدخول بعد التوليد**
- الملف: `lib/features/builder/screens/builder_workspace_screen.dart`
- التغيير: بعد نجاح توليد الصفحة للضيف، إظهار واجهة (Overlay/Modal) تمنعه من متابعة التعديل المتقدم حتى يسجل حساباً، مع تخصيص subdomain عشوائي بعد التسجيل لربط التصميم.

## Phase C: AI Agent Enhancements
**الخطوة 7: رفع اللوجو والصور في شات AI**
- الملف: `lib/features/builder/widgets/ai_chat/ai_chat_panel.dart`.
- التغيير: دمج خدمة الرفع المزدوجة (ImgBB + Supabase) لإتاحة رفع صور وشعارات داخل الشات. يتم تمرير رابط الصورة للـ AI (Gemini Vision) كجزء من السياق لتحليل الألوان وتطبيق ثيم مخصص.

**الخطوة 8: تحكم متقدم للخلفيات لكل الأقسام**
- الملف: `supabase/functions/shared/schema_registry.json` و `LandingPageBuilderCubit`.
- التغيير: إضافة قدرات للـ AI لفهم تعليمات مثل "اجعل خلفية القسم الثاني زرقاء داكنة" و "اختر صورة خلفية مناسبة للموقع ككل"، مع تحديث مفاتيح الـ JSON بشكل صحيح.

## Phase D: Template Management
**الخطوة 9: تحديث القوالب والصور المصغرة**
- الملف: `lib/features/builder/registries/template_registry.dart`
- التغيير: التخلص من صورة `workspace-1280538_1280.jpg` المتكررة، وتوفير روابط لصور تمثيلية (Thumbnails) دقيقة وعالية الجودة لكل قالب. إضافة أزرار يمين/يسار للجوال في عارض القوالب لتسهيل التصفح.

## Phase E: Builder Engine Refactoring & Performance (اقتراحات التطوير)
**الخطوة 10: تقسيم Builder Cubit (Code Splitting)**
- الملف: `lib/features/builder/controllers/builder_cubit.dart`
- التغيير: تقسيم الكيوبيت العملاق (2122 سطراً) إلى كيوبتات متخصصة أصغر مثل `BuilderThemeCubit` لإدارة الألوان والخطوط، و `BuilderBlocksCubit` لإدارة البلوكات لتسهيل الصيانة وتحسين الأداء.

**الخطوة 11: تحسين أداء المنتجات (Item Recycling)**
- الملف: `lib/features/public_viewer/widgets/custom_products_widget.dart`
- التغيير: استخدام `ListView.builder` أو `GridView.builder` بدلاً من توليد كل العناصر دفعة واحدة في الذاكرة لتخفيف الضغط وتقليل التقطيع.

## Phase F: Advanced AI Features & Editor UX (اقتراحات التطوير)
**الخطوة 12: تعديل الأقسام الفردية بالـ AI (Section-level AI)**
- الملف: أزرار تحكم الأقسام في Builder.
- التغيير: إضافة زر "تعديل بالذكاء الاصطناعي" لكل قسم على حدة، بحيث يتم إرسال بيانات القسم فقط وتعديله دون المساس ببقية الصفحة.

**الخطوة 13: حفظ تاريخ محادثات الـ AI**
- الملف: `lib/features/builder/ai/ai_conversation_session.dart`
- التغيير: حفظ الجلسة في `localStorage` بناءً على `pageId` لكي يتمكن المستخدم من إغلاق الشات والعودة إليه لاحقاً دون فقدان السياق.

**الخطوة 14: المعاينة الحية للقوالب (Live Preview)**
- الملف: `lib/features/builder/registries/template_registry.dart` و `lib/features/home/widgets/home_luxurious_template_slider.dart`.
- التغيير: إضافة خيار لفتح القالب كصفحة ويب كاملة (Preview) للمعاينة التفاعلية قبل اختيار تطبيقه.

## Phase G: Mobile Experience & SEO (اقتراحات التطوير)
**الخطوة 15: دعم PWA و Offline Mode**
- التغيير: تحديث ملفات `web/` لدعم Service Workers و `manifest.json`، بالإضافة لتخزين بيانات الصفحة مؤقتاً في المتصفح للحماية من انقطاع الإنترنت أثناء التعديل.

**الخطوة 16: تحكم الـ SEO لكل صفحة**
- الملف: `LandingPageTheme`
- التغيير: توفير واجهة لإضافة Meta Title و Meta Description و Keywords ليتم دمجها في نسخة الـ HTML النهائية التي يتم توليدها للـ Crawlers.
