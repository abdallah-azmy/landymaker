# خطة تطوير نافذة رفع الصور العائمة (Floating Upload Manager)

## المشكلة الحالية
1. `GlobalUploadManagerWidget` هو مجرد لوحة جانبية صغيرة (PositionedDirectional) غير بارزة
2. عند محاولة الحفظ مع وجود صور قيد الرفع، يظهر خطأ فقط ولا يُوجّه المستخدم لمتابعة الرفع
3. زر الحفظ في شريط الأدوات لا يتفاعل مع حالة الرفع (غير معطل أثناء الرفع)
4. لا توجد نافذة عائمة احترافية تسمح للمستخدم بمتابعة التصفح أثناء الرفع

## الحل المطلوب
نافذة عائمة (Floating Overlay) ذات حالتين (مصغّرة/موسّعة) تظهر عند رفع الصور، مع تعطيل زر الحفظ أثناء الرفع، وإظهار إشعار عند اكتمال الرفع.

## خطة التنفيذ

### 1. تحسين `GlobalUploadManagerWidget` ← نافذة عائمة احترافية
- **الملف**: `lib/features/builder/widgets/organisms/global_upload_manager_widget.dart`
- **التغييرات**:
  - إعادة تصميم كامل ليكون Overlay عائم بحالتين (مصغّر/موسّع)
  - الحالة المصغّرة: FloatingActionButton صغير بعدد الصور قيد الرفع
  - الحالة الموسّعة: لوحة كاملة بقائمة المهام مع أشرطة التقدم
  - استخدام `AnimatedContainer` للانتقال السلس بين الحالتين
  - استخدام `CubeProgress` بدلاً من `CircularProgressIndicator`
  - دعم RTL واللغة العربية/الإنجليزية
  - إضافة زر إلغاء لكل مهمة
  - إضافة إمكانية إعادة المحاولة للمهام الفاشلة
  - إظهار إشعار عند اكتمال جميع المهام
  - إضافة Material elevation للظهور العائم

### 2. تعديل `UploadManagerWrapper`
- **الملف**: `lib/features/builder/screens/workspace/upload_manager_wrapper.dart`
- **التغييرات**:
  - تحديث التموضع ليكون في أسفل يمين الشاشة
  - إضافة `Material` للظل والارتفاع البصري

### 3. تعديل `BuilderAppBar` لتعطيل زر الحفظ أثناء الرفع
- **الملف**: `lib/features/builder/widgets/organisms/builder_app_bar.dart`
- **التغييرات**:
  - إضافة `UploadManagerCubit` كـ bloc للاستماع لحالة الرفع
  - تعطيل زر الحفظ/النشر عند وجود مهام رفع نشطة
  - إظهار نص "جاري رفع الصور..." بدلاً من "حفظ" عند تعطيل الزر
  - استخدام `CubeProgress` بدلاً من `CircularProgressIndicator`
  - تعطيل مفتاح Draft/Live أثناء الرفع

### 4. تحسين رسالة الخطأ عند محاولة الحفظ مع وجود رفع قيد التنفيذ
- **الملف**: `lib/features/builder/controllers/builder_cubit_persistence.dart`
- **التغييرات**:
  - تحسين رسالة الخطأ لتوجيه المستخدم لمتابعة الرفع في النافذة العائمة

### 5. إضافة مفاتيح الترجمة الجديدة
- **الملفات**: `translations_ar.dart`, `translations_en.dart`
- **المفاتيح**:
  - `upload_in_progress`: "رفع الصور..." / "Uploading images..."
  - `upload_complete`: "تم رفع جميع الصور!" / "All images uploaded!"
  - `upload_failed`: "فشل الرفع" / "Upload failed"
  - `upload_pending`: "معلق" / "Pending"
  - `upload_retry`: "إعادة المحاولة" / "Retry"
  - `upload_cancel`: "إلغاء" / "Cancel"
  - `upload_wait_msg`: "يرجى الانتظار حتى اكتمال رفع جميع الصور." / "Please wait for all uploads to complete."
  - `uploads_active`: "جاري رفع {count} صور" / "Uploading {count} images"
  - `upload_progress`: "{percent}%" / "{percent}%"
  - `minimize`: "تصغير" / "Minimize"
  - `expand`: "توسيع" / "Expand"

## الملفات المتأثرة
| الملف | نوع التعديل |
|-------|-------------|
| `global_upload_manager_widget.dart` | إعادة تصميم كامل |
| `upload_manager_wrapper.dart` | تحديث تموضع |
| `builder_app_bar.dart` | إضافة منطق تعطيل الأزرار |
| `builder_cubit_persistence.dart` | تحسين رسالة الخطأ |
| `translations_ar.dart` | إضافة مفاتيح جديدة |
| `translations_en.dart` | إضافة مفاتيح جديدة |

## سير العمل الجديد
1. يختار المستخدم صورة (من الجهاز أو Pixabay)
2. تبدأ عملية الرفع عبر `UploadManagerCubit`
3. تظهر النافذة العائمة في أسفل يمين الشاشة بشكل مصغّر
4. المستخدم يستطيع تكبيرها لمتابعة التقدم
5. زر الحفظ في شريط الأدوات يُعطل ويظهر "جاري رفع الصور..."
6. عند اكتمال الرفع، تظهر رسالة نجاح وتختفي النافذة بعد 3 ثوانٍ
7. يمكن للمستخدم حفظ الصفحة الآن
