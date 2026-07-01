# خطة تحسين القيم الافتراضية للأقسام
## Default Values Enhancement Plan for All Sections

---

## 1. الهدف (Goal)

جعل كل قسم يظهر بشكل كامل وجاهز فور إضافته إلى الصفحة، بحيث:
- **أي حقل صورة** يستخدم رابط الصورة الافتراضية `https://zajcnkpcdsvswfmsmqpt.supabase.co/storage/v1/object/public/landing-assets/app_icon_source.png`
- **أي حقل نص** يستخدم نصًا افتراضيًا مناسبًا (وصفياً) بدلاً من أن يكون فارغًا
- **أي عنصر داخل قسم** (sub-item) له قيم افتراضية واضحة

---

## 2. التحليل الحالي (Current State Analysis)

### 2.1 الموجود بالفعل ✅
- الرابط الافتراضي للصورة مستخدم في **22 مكان** عبر:
  - `builder_cubit_blocks.dart` — 12 occurrence
  - `builder_cubit_blocks_items.dart` — 3 occurrences
  - `section_data.dart` — 7 occurrences
- معظم أنواع البلوكات لها قيم افتراضية أساسية (title, subtitle, button_text)

### 2.2 المشاكل الموجودة ❌
1. **الرابط الافتراضي مكرر كـ string** في 22 مكان — لا يوجد constant مركزي
2. **4 أنواع بلوكات مفقودة من `addBlock()`** — ليس لها قيم افتراضية عند الإضافة
3. **بعض الحقول النصية فارغة** أو ليس لها قيم افتراضية مناسبة
4. **بعض sub-items ليس لها صور افتراضية** أو نصوص وصفية
5. **قيم `block_schema.dart` الافتراضية** تحتاج تحديث لتتوافق مع القيم الجديدة

### 2.3 أنواع البلوكات المفقودة من `addBlock()`
- `statistics_grid`
- `service_steps`
- `cta_banner`
- `comparison_table`

### 2.4 الحقول التي قد تكون فارغة أو تحتاج تحسين

| Block Type | الحقل المشكوك فيه | الحالة |
|---|---|---|
| `whatsapp` | `phone_number: ''` | فارغ — يحتاج نص وصفي |
| `social_qr` | `links[].url` | يحتاج قيم URLs افتراضية أوضح |
| `basic_section` | `elements` | لا يوجد عناصر افتراضية |
| `trust_logos` | `items` | يستخدم SVG URLs حقيقية (مقبول) |
| `hero` / `hero_saas` | `tech_logos` | غير موجود في defaults |
| `location_map` | `address` | موجود لكن يمكن تحسينه |
| `contact_info` | `email`, `phone` | موجود لكن يمكن تحسينه |

---

## 3. خطة التنفيذ (Execution Plan)

### المرحلة 1: إنشاء Constant مركزي للصورة الافتراضية
**الملف:** `lib/core/constants/app_constants.dart` (جديد)

```dart
const String kPlaceholderImageUrl = 
  'https://zajcnkpcdsvswfmsmqpt.supabase.co/storage/v1/object/public/landing-assets/app_icon_source.png';
```

**التأثير:** استبدال الرابط المكرر في 22 مكان بالـ constant

---

### المرحلة 2: تحسين `addBlock()` في `builder_cubit_blocks.dart`
**الملف:** `lib/features/builder/controllers/builder_cubit_blocks.dart`

#### 2.1 logo_header (السبب المباشر للطلب)
- ✅ `logo_url` موجود بالفعل مع الصورة الافتراضية
- ✅ `title` موجود باسم "اسم العلامة التجارية"
- لا تغيير مطلوب

#### 2.2 hero
- ✅ موجود بالفعل
- إضافة: `badge_text: 'جديد'` لعرض شارة النص

#### 2.3 hero_saas
- ✅ موجود بالفعل
- إضافة: `tech_logos` كقائمة روابط شعارات تقنية افتراضية
- إضافة: `badge_text: 'مميز'`

#### 2.4 whatsapp
- تعديل: `phone_number` من `''` إلى `'+201234567890'` (رقم وصفي)

#### 2.5 إضافة البلوكات الأربعة المفقودة:

**statistics_grid:**
```dart
blockToAdd = {
  'type': 'statistics_grid',
  'title': 'إحصائياتنا',
  'layout_style': 'horizontal',
  'items': [
    {'value': '٥٠٠+', 'label': 'عميل سعيد', 'icon': 'people'},
    {'value': '١٢', 'label': 'سنة خبرة', 'icon': 'star'},
    {'value': '٢٤/٧', 'label': 'دعم فني', 'icon': 'speed'},
    {'value': '١٠٠٪', 'label': 'جودة', 'icon': 'check'},
  ],
};
```

**service_steps:**
```dart
blockToAdd = {
  'type': 'service_steps',
  'title': 'خطوات العمل',
  'subtitle': 'ثلاث خطوات بسيطة للبدء',
  'items': [
    {'title': 'الخطوة الأولى', 'description': 'سجل أو تواصل معنا'},
    {'title': 'الخطوة الثانية', 'description': 'اختر باقتك المفضلة'},
    {'title': 'الخطوة الثالثة', 'description': 'انطلق مع خدمتك الجديدة'},
  ],
};
```

**cta_banner:**
```dart
blockToAdd = {
  'type': 'cta_banner',
  'title': 'هل أنت جاهز للبدء؟',
  'subtitle': 'انضم إلينا اليوم واحصل على عرض خاص.',
  'button_text': 'سجل الآن',
  'layout_style': 'centeredGradient',
};
```

**comparison_table:**
```dart
blockToAdd = {
  'type': 'comparison_table',
  'title': 'جدول المقارنة',
  'subtitle': 'قارن بين الباقات',
  'plans': [
    {'name': 'الأساسية', 'price': 'مجاني'},
    {'name': 'الاحترافية', 'price': '٩٩\$'},
  ],
  'features': [
    {'name': 'الميزة الأولى', 'values': [true, true]},
    {'name': 'الميزة الثانية', 'values': [false, true]},
  ],
};
```

#### 2.6 تحسين باقي البلوكات
- **features** — إضافة `badge_text: 'مميزات'`
- **products** — التأكد من وجود `category: 'عام'` في item
- **basic_section** — إضافة عناصر افتراضية (مثلاً `html_content: 'اكتب محتوى القسم هنا'`)
- **contact_info** — تحسين القيم الافتراضية
- **location_map** — تحسين العنوان الافتراضي
- **social_qr** — تحسين قيم الروابط

---

### المرحلة 3: تحسين `builder_cubit_blocks_items.dart`
**الملف:** `lib/features/builder/controllers/builder_cubit_blocks_items.dart`

استبدال كل الـ image_url strings بالـ constant الجديد

#### 3.1 addFaqItem
- ✅ موجود بالفعل: `{'question': 'سؤال جديد؟', 'answer': 'الإجابة هنا.'}`

#### 3.2 addTestimonialItem
- ✅ الصورة موجودة
- تحسين النصوص لتكون أكثر وصفًا

#### 3.3 addGalleryImage
- ✅ الصورة موجودة

#### 3.4 addProductItem
- ✅ الصورة موجودة
- تحسين النصوص الافتراضية

---

### المرحلة 4: تحسين `section_data.dart` (قيم Variants)
**الملف:** `lib/features/builder/widgets/modals/section_library/section_data.dart`

- استبدال كل روابط الصور بالـ constant الجديد
- التأكد من أن كل variant له `image_url` أو `logo_url` افتراضي
- إضافة قيم افتراضية للحقول النصية المفقودة في بعض الـ variants
- إضافة variants للبلوكات المفقودة الأربعة

---

### المرحلة 5: تحديث `block_schema.dart`
**الملف:** `lib/features/builder/ai/block_schema.dart`

- إضافة `defaultValue` لبعض الحقول النصية (مثل `title` و `subtitle`)
- جعل القيم الافتراضية تتوافق مع القيم في `addBlock()`

---

### المرحلة 6: مراجعة Renderers
**الملفات:** كل widget في `lib/features/public_viewer/widgets/`

- التأكد من أن كل renderer يعرض الصورة الافتراضية بشكل صحيح
- التحقق من أن `CustomNetworkImage` يتعامل مع رابط الصورة الافتراضية
- التأكد من أن `CustomLogoHeaderWidget` يعرض `logo_url` حتى لو كان الرابط الافتراضي

---

## 4. قائمة التغييرات التفصيلية (Detailed Changes List)

### ملفات سيتم تعديلها:

1. **`lib/core/constants/app_constants.dart`** — إنشاء `kPlaceholderImageUrl`
2. **`lib/features/builder/controllers/builder_cubit_blocks.dart`** — إضافة 4 بلوكات + تحسين القيم
3. **`lib/features/builder/controllers/builder_cubit_blocks_items.dart`** — استبدال الرابط بالـ constant
4. **`lib/features/builder/widgets/modals/section_library/section_data.dart`** — تحديث كل الـ image_url
5. **`lib/features/builder/ai/block_schema.dart`** — إضافة بعض الـ default values

---

## 5. النطاق (Scope)

### 29 نوع بلوك (Block Types) الكل يشملها التعديل:
1. ✅ `hero` — موجود، تحسين بسيط
2. ✅ `hero_saas` — موجود، إضافة `tech_logos`
3. ✅ `logo_header` — موجود، لا تغيير
4. ✅ `features` — موجود، تحسين بسيط
5. ✅ `lead_form` — موجود، لا تغيير
6. ✅ `lead_magnet` — موجود، لا تغيير
7. ✅ `whatsapp` — تحسين `phone_number`
8. ✅ `products` — موجود، تحسين بسيط
9. ✅ `qr_code` — موجود، لا تغيير
10. ✅ `social_qr` — موجود، تحسين بسيط
11. ✅ `pricing` — موجود، لا تغيير
12. ✅ `featured_product` — موجود، لا تغيير
13. ✅ `bento_store` — موجود، لا تغيير
14. ✅ `faq` — موجود، لا تغيير
15. ✅ `testimonials` — موجود، تحسين بسيط
16. ✅ `contact_info` — موجود، تحسين بسيط
17. ✅ `working_hours` — موجود، لا تغيير
18. ✅ `location_map` — موجود، تحسين بسيط
19. ✅ `gallery` — موجود، لا تغيير
20. ✅ `multi_step_lead_form` — موجود، لا تغيير
21. ✅ `video_embed` — موجود، لا تغيير
22. ✅ `trust_logos` — موجود، لا تغيير
23. ✅ `animated_counter` — موجود، لا تغيير
24. ✅ `basic_section` — موجود، تحسين بسيط
25. ✅ `team_members` — موجود، لا تغيير
26. ❌ `statistics_grid` — **يحتاج إضافة** كاملة
27. ❌ `service_steps` — **يحتاج إضافة** كاملة
28. ❌ `cta_banner` — **يحتاج إضافة** كاملة
29. ❌ `comparison_table` — **يحتاج إضافة** كاملة

---

## 6. الاختبار (Testing)

بعد التنفيذ، يجب اختبار:
1. إضافة كل نوع بلوك عبر Section Library — التحقق من ظهور كل العناصر
2. التحقق من ظهور الصورة الافتراضية في كل حقل صورة
3. التحقق من ظهور النصوص الافتراضية في كل حقل نص
4. التحقق من عدم وجود أخطاء في الـ console
5. التحقق من أن القيم القديمة (للصفحات المحفوظة) لا تتأثر
6. اختبار الضغط على "اختيار صورة" وتغيير الصورة الافتراضية
7. اختبار في كل من builder view و public view

---

## 7. الأولوية (Priority)

| المرحلة | الأولوية | الوصف |
|---|---|---|
| 1 | عالية | إنشاء constant + استبدال الـ 22 occurrence |
| 2 | عالية جدًا | إضافة الـ 4 بلوكات المفقودة + تحسين `logo_header` |
| 3 | عالية | تحسين sub-items defaults |
| 4 | متوسطة | تحسين section_data variants |
| 5 | منخفضة | تحديث AI schema defaults |

---

## 8. ملاحظة هامة حول الصورة

```
https://zajcnkpcdsvswfmsmqpt.supabase.co/storage/v1/object/public/landing-assets/app_icon_source.png
```
هذه الصورة موجودة في Supabase storage الخاص بالمشروع، ولا يحتاج المستخدم لرفعها في معرض صوره.
يجب استخدام الرابط مباشرة دون محاولة رفعه أو استيراده.

---

*تاريخ الإنشاء: 2026-07-01*
*تم إعداد هذه الخطة بناءً على طلب المستخدم لتحسين القيم الافتراضية في جميع أقسام صفحات الهبوط.*
