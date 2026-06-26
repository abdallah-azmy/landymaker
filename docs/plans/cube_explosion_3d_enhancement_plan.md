# Task Progress — تحسين انفجار المكعبات وتوحيد التفاعل

## ✅ STEP 1 — فهم المتطلبات

**المطلوب:**
1. **إخفاء المكعبات الزائدة**: المكعبات التي تزيد عن 27 (المكونة للوجو) يجب أن تكون مخفية غير مرئية خلف المكعب الكبير، وعند الانفجار تظهر وتنطلق مع باقي المكعبات
2. **انفجار واقعي ثلاثي الأبعاد**: جعل الانفجار أكثر واقعية مع انتشار المكعبات في مختلف أنحاء الصفحة مع دوران وديناميكية أفضل
3. **توحيد تفاعل الضغط**: جعل تأثير الضغط متطابقاً بين `_isPreviewMode == true` و `_isPreviewMode == false`، مع استثناء واحد: في وضع المعاينة إذا ضغط المستخدم على شكل الوجو ينفجر
4. **انتشار المكعبات في كامل الصفحة في وضع المعاينة**: جعل `topExclusion = 0` في وضع `_isPreviewMode` للسماح للمكعبات بالانتشار في كامل الشاشة، مع انتقال سلس عند التبديل بين الوضعين بدون قفز

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

## * [x] Phase 4 — انتشار المكعبات في كامل الشاشة في وضع المعاينة مع انتقال سلس

### Goal
جعل `topExclusion = 0` في وضع `_isPreviewMode` للمكعبات لتنتشر في كامل الصفحة، وعند العودة للوضع العادي تعود `topExclusion` لقيمتها الأصلية، مع انتقال سلس بدون قفز.

### What changed
1. `landymaker_home_screen.dart:936`: `topExclusion` الآن `0.0` عندما `_isPreviewMode == true` وإلا القيمة المحسوبة
2. `floating_cube_background.dart:1824-1830`: استبدال الـ hard clamp (`y = topExclusion`) بـ push ناعم (`vy += deficit * 3.0; y += deficit * 0.25`) — المكعبات تنزلق إلى خارج منطقة الإقصاء خلال 0.3-0.5 ثانية بدلاً من القفز الفوري

### Files involved
- `lib/features/home/screens/landymaker_home_screen.dart`
- `lib/core/widgets/particles/floating_cube_background.dart`

### Risks
- في وضع الجاذبية (gravity mode) المكعبات قد تبقى في المنطقة المستثناة لفترة أطول لأنها تحتاج لقوة كافية للنزول
- التأثير على سلوك الكرات في merge mode (تم اختبارها — المنطقة الناعمة في `cy < topExclusion + repZone` تضمن التوجيه اللطيف)

### Validation steps
- في وضع المعاينة: المكعبات تنتشر في كل مكان (حتى خلف الـ navbar)
- عند الخروج من المعاينة: المكعبات تنتقل بسلاسة بدون قفز
- عند الدخول للمعاينة: المكعبات تنتشر في كل الشاشة بسلاسة
- `flutter analyze` بدون أخطاء

## * [x] Phase 5 — تفكيك المكعبات المندمجة + انفجار كروي/اتجاهي

### Goal
عند تفجير الوجو في وضع المعاينة:
1. **تفكيك كل المكعبات المندمجة** إلى أفراد قبل الانفجار (حتى لو كان الوضع Merge Mode، يبدأ الاندماج من البداية)
2. **انفجار كروي** إذا نقر المستخدم على الوجو نفسه (المساحة حول مركز الشاشة) — زوايا عشوائية موحّدة لانتشار متساوٍ في كل الاتجاهات
3. **انفجار اتجاهي** إذا نقر المستخدم في مساحة فارغة — المكعبات تطير في اتجاه معاكس لنقطة النقر بمخروط ±54° ثم تنتشر طبيعياً

### What changed
1. `floating_cube_background.dart:387-388`: استدعاء `_splitMergedEntities()` و `_resetMergeState()` قبل حلقة الانفجار
2. `floating_cube_background.dart:398-399`: تحديد `isLogoClick` — المسافة من نقطة النقر إلى مركز الشاشة < 0.12
3. `floating_cube_background.dart:401-412`: حساب الاتجاه الأساسي للانفجار الاتجاهي (من نقطة النقر بعيداً عن المركز)
4. `floating_cube_background.dart:439-443`: الانفجار الكروي — `cos(angle) * force` و `sin(angle) * force` مع زاوية عشوائية
5. `floating_cube_background.dart:444-453`: الانفجار الاتجاهي — `dirX/dirY` مع `spreadAngle ±54°` + تشويش إضافي
6. `floating_cube_background.dart:422`: تصحيح استخدام `firstIdx >= 27` بدلاً من `i >= 27` للكشف عن المكعبات الزائدة بعد التفكيك

### Files involved
- `lib/core/widgets/particles/floating_cube_background.dart`

### Risks
- `_splitMergedEntities()` يخلق إنتيتيز جديدة بمواضع متفرقة عشوائياً — قد تظهر المكعبات في غير مكانها للحظة قبل الانفجار
- الانفجار الاتجاهي بزاوية ±54° قد لا يغطي كامل الشاشة إذا كانت القوة ضعيفة — الـ burstBoost 2s يعوض ذلك

### Validation steps
- في وضع المعاينة والـ Merge Mode: تفجير الوجو → كل المكعبات تظهر مفردة بدون تجميعات
- النقر على الوجو → انفجار كروي منتشر في كل الاتجاهات
- النقر في الزاوية → المكعبات تطير بعيداً عن الزاوية في شكل مخروط
- `flutter analyze` بدون أخطاء

## * [x] Phase 6 — HTML-to-Cubes seamless transition + auto-detect load timing

### Goal
ربط تحميل الصفحة HTML مع الـ 3D cube logo في تجربة واحدة سلسة:
- HTML loader → persistent logo (الخلفية تختفي، اللوجو يفضل ظاهر)
- الـ 3D cube logo في preBrust تحت اللوجو HTML (نفس الموقع)
- المحتوى مخفي (`_burstTriggered = false`)، المكعب المرئي شغال كـ loading view
- لما API الـ sections يخلص → auto-burst + content fade + HTML logo fade في وقت واحد
- تداخل زمني: الانفجار يحصل والمحتوى يظهر تدريجياً والـ HTML logo يختفي

### The cascade (all three fire simultaneously):
1. T=0: `_burstTriggered = true` → Content starts fading in (AnimatedOpacity 800ms)
2. T=0: `triggerLogoBurst(center)` → Cubes explode spherically, burstBoost scatters them across screen
3. T=0: `removePersistentLogo()` → HTML logo fades out (CSS 0.5s)
4. T=500ms: HTML logo fully gone → scattered cubes visible against content
5. T=800ms: Content fully visible → page is interactive

### What changed
1. `landymaker_home_screen.dart:107-122`: `_waitForLoadingThenRevealCubes` — polls `_sectionsLoaded`, then fires burst + content + logo removal simultaneously
2. `landymaker_home_screen.dart:96`: `_burstTriggered = false` on first load (content hidden, cube logo as loading view)
3. `landymaker_home_screen.dart:307-309`: `_onPointerDown` guarded with `_persistentLogoRemoved` to prevent premature burst during loading
4. `landymaker_home_screen.dart:988`: `initialPreBurst: _isThisTheFirstLoad` (cubes start as formed logo on first load)
5. `web/index.html`: Persistent logo mode (class `persistent-mode`, CSS `logo-persistent` with breathing animation, `transitionToPersistentLogo()` / `removePersistentLogo()` JS functions)

### Files involved
- `lib/features/home/screens/landymaker_home_screen.dart`
- `lib/core/widgets/particles/floating_cube_background.dart`
- `web/index.html`
- `lib/core/utils/js_helper.dart` (NEW)
- `lib/core/utils/js_helper_web.dart` (NEW)
- `lib/core/utils/js_helper_stub.dart` (NEW)

### Risks
- Content might appear before API data is ready (`_burstTriggered = true` before `_sectionsLoaded` is set — mitigated by polling loop)
- On non-web platforms (mobile, desktop), `callJs` is a no-op so the persistent HTML phase is skipped entirely → cubes start in preBurst → auto-burst when sections load → content appears. The transition is less dramatic but still functional.
- If sections load very fast (< 100ms), the persistent logo phase is barely visible. Mitigated by minimum delay? Not implemented — letting it be fast is actually better UX.

### Validation steps
- First load (web): HTML logo → bg fades → logo breathes → loading → burst + content + logo fade cascade → cubes scattered, page interactive
- First load (non-web): Cubes in preBurst → loading → auto-burst → content appears
- Subsequent visits: Cubes scattered, content visible immediately, normal interaction
