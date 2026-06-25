# Task Progress — تحسين انفجار المكعبات وتوحيد التفاعل

## ✅ STEP 1 — فهم المتطلبات

**المطلوب:**
1. **إخفاء المكعبات الزائدة**: المكعبات التي تزيد عن 27 (المكونة للوجو) يجب أن تكون مخفية غير مرئية خلف المكعب الكبير، وعند الانفجار تظهر وتنطلق مع باقي المكعبات
2. **انفجار واقعي ثلاثي الأبعاد**: جعل الانفجار أكثر واقعية مع انتشار المكعبات في مختلف أنحاء الصفحة مع دوران وديناميكية أفضل
3. **توحيد تفاعل الضغط**: جعل تأثير الضغط متطابقاً بين `_isPreviewMode == true` و `_isPreviewMode == false`، مع استثناء واحد: في وضع المعاينة إذا ضغط المستخدم على شكل الوجو ينفجر

## * [x] Phase 1 — إخفاء المكعبات الزائدة خلف الوجو وجعلها تنفجر

### Goal
إخفاء المكعبات الإضافية (i >= 27) عندما يكون الوجو مكتملاً (في حالة `_isPreBurst`) بحيث لا تكون مرئية، وعند حدوث الانفجار (`_triggerLogoBurst`) تظهر هذه المكعبات وتنطلق مع بقية المكعبات.

### Files involved
- `lib/core/widgets/particles/floating_cube_background.dart`

### Risks
- قد تتسبب invisible entities في مشاكل في التصادم أو الفيزياء
- يجب التأكد من أن `targetSize` و `renderSize` يتم إعادتها بشكل صحيح عند الانفجار

### Validation steps
- التأكد من أن المكعبات الزائدة غير مرئية عندما يكون الوجو مكتملاً (pre-burst)
- عند النقر على الوجو في وضع المعاينة، تظهر المكعبات الزائدة وتنطلق مع بقية المكعبات
- `flutter analyze` بدون أخطاء

## * [x] Phase 2 — تحسين الانفجار ثلاثي الأبعاد

### Goal
جعل الانفجار أكثر واقعية من خلال:
1. توزيع سرعات أكثر تنوعاً بحسب البعد عن المركز (Z-depth) ✓
2. إضافة `burstBoost` timer لتمكين سرعة أعلى مؤقتاً بعد الانفجار ✓
3. جعل المكعبات تتطاير في مسارات أكثر تشويشاً وواقعية ✓
4. تحسين التدوير (tumbling) ليكون أكثر درامية ✓

### Files involved
- `lib/core/widgets/particles/floating_cube_background.dart`

### What changed
1. `_triggerLogoBurst`: Depth-aware velocity — cubes في الأمام تطير أسرع، الخلفية أبطأ
2. `_triggerLogoBurst`: Vertical spread based on depth — مكعبات الخلفية تطير للأعلى والأمامية للأسفل
3. `_triggerLogoBurst`: Tumble intensity scales with speed — المكعبات الأسرع تدور أكثر
4. `_MergeEntity.burstBoost` + modified speed cap: سماح بسرعة تصل إلى 1.0 لمدة ثانيتين بعد الانفجار

### Risks
- التأثير على الأداء مع زيادة التعقيد الحسابي
- تغيير سلوك الانفجار الحالي بشكل غير متوقع

### Validation steps
- `flutter analyze` بدون أخطاء
- التأكد من سلاسة الأداء (FPS)

## * [x] Phase 3 — توحيد تفاعل الضغط بين الوضعين

### Goal
جعل تأثير النقر (PointerDown) متطابقاً بين الوضع العادي ووضع المعاينة (`_isPreviewMode`) مع استثناء وحيد: في وضع المعاينة، إذا نقر المستخدم على الوجو (الكائن المركزي) يتم تفجيره.

### What changed
1. إضافة `isLogoFormed` إلى `FloatingCubeBackgroundController` لتتبع حالة تشكيل الوجو
2. إضافة setter `_preBurstValue` يزامن `_isPreBurst` مع `controller.isLogoFormed` تلقائياً
3. تعديل `_onPointerDown` في `landymaker_home_screen.dart`:
   - الوضعان يستخدمان نفس التسلسل: `trySplit` ← (إما `triggerLogoBurst` أو `burstAt`)
   - في وضع المعاينة والوجو مكتمل → `triggerLogoBurst`
   - في كل الحالات الأخرى → `burstAt` (كما هو في الوضع العادي)

### Files involved
- `lib/features/home/screens/landymaker_home_screen.dart`
- `lib/core/widgets/particles/floating_cube_background.dart`

### Risks
- تغيير سلوك التفاعل الحالي

### Validation steps
- نفس تأثير `trySplit` ثم `burstAt` في كلا الوضعين
- الضغط على الوجو في المعاينة يؤدي إلى الانفجار الكبير
- `flutter analyze` بدون أخطاء
