# Unified Brick Building Plan

## الفكرة الأساسية
مكعبات HTML تطير من أطراف الشاشة → تختفي ورا اللوجو (CSS glow 6s ramp, density تزيد مع الوقت) → تستمر للأبد
مكعبات Flutter تظهر كإمتداد → تتجمع في مجموعات → كل مجموعة = طوبة (brick) → **كل الطوب يتكون بالتوازي** → المكعب الكبير 3×3×3 يكتمل (~2 ثانية مرئي)
اللوجو image يفضل موجود على الشاشة بشكل دائم — المستخدم يشوف المكعبات وهي بتتجمع

---

## ✅ Phase 1: HTML — إخفاء المكعبات وراء اللوجو + التوهج التدريجي (مكتمل)

### 1.1 المكعبات تختفي وراء اللوجو
**الآن**: `#gathering-squares` له `z-index: 1` والـ `<img>` له `z-index: 2` → المكعبات تختفي ورا اللوجو

### 1.2 التوهج CSS pure (6s ramp)
- `logo-ramp` animation: 6s, `cubic-bezier(0.4, 0, 0.2, 1) forwards`
- تبدأ من `brightness(0.6) drop-shadow(0 0 0px rgba(0, 229, 255, 0))`
- تنتهي عند `brightness(1.4) drop-shadow(0 0 20px rgba(0, 229, 255, 0.7))`
- لا يوجد JS tracking للتوهج — pure CSS

### 1.3 كثافة التجمع تزيد مع الوقت
- أول 27 cube: `duration=8s, delay=1.2s range`
- بعد 1.5 ثانية: 12 cube إضافية `duration=5s`
- بعد 3 ثواني: 12 cube إضافية `duration=3.5s`

### 1.4 المكعبات تستمر للأبد
مفعلة بالفعل (`animation-iteration-count: infinite`)

### 1.5 81 edge position مخزنة في `window._htmlCubeEdgePositions`
لكي يقرأها Flutter ويستخدم نفس نقاط الانطلاق

### 1.6 الـ HTML cubes يتكاثرون بلا نهاية
- حالياً: 51 cube (27 + 12 + 12) وبعد كده بتوقف
- المطلوب: **توليد مستمر** — كل ~500ms-1s مكعب جديد ينضاف
- ما فيش حد أقصى — طول ما الصفحة مفتوحة، مكعبات جديدة تتولد
- المكعبات القديمة تتشال من الـ DOM بعد ما الـ animation تخلص عشان ما يتراكمش عدد لا نهائي
- أو ممكن نحافظ على pool ~100-200 مكعب ونعيد استخدامهم

**ملفات متأثرة**: `web/index.html`

---

## ✅ Phase 2: Flutter — نظام الـ Brick Building المتوازي (مكتمل)

### 2.1 هيكل البيانات الجديد

**المتغيرات الجديدة في `floating_cube_background.dart`**:
```dart
static const int _bricksPerGroup = 3;     // 3 cubes لكل brick
static const int _totalBricks = 27;        // 27 bricks = 27 position في الـ 3×3×3
static const double _brickTotalDuration = 36.0;  // 36 unit = ~2 ثانية
int _totalBuildCubes = 81;
List<double> _brickStartX;     // [81] — edge start X لكل cube
List<double> _brickStartY;     // [81] — edge start Y لكل cube
List<int> _entityBrickIndex;   // [81] — لكل cube، رقم الـ brick اللي تبعها (0-26)
List<bool> _brickPlaced;       // [27] — هل الـ brick اتحطت ولا لا
double _brickRevealProgress;   // 0.0 → 36.0
```

### 2.2 تعديل `_startBuildIntoLogo()`
- تقرأ `_htmlCubeEdgePositions` من JS interop لو متاحة
- ترص كل 81 cube على أطراف الشاشة (مع fallback عشوائي لو مش متاحة)
- كل cube يتحدد له brick index: `_entityBrickIndex[i] = i ~/ _bricksPerGroup`
- تخزين start positions

### 2.3 الـ Building Loop المتوازي
**المنطق الجديد (كل bricks تتكون مع بعض بالتوازي)**:
```
for each cube i (0..80):
  brickIdx = _entityBrickIndex[i]
  cubeInBrick = i % _bricksPerGroup  // 0, 1, 2
  target = gridPosition[brickIdx]
  cubeOffset = cubeInBrick * 0.33    // stagger بسيط (~18ms)
  raw = _brickRevealProgress - cubeOffset
  
  if raw <= 0:          // مخفي في الحافة (لسه ما بدأش)
  if 0 < raw < 1.5:    // يطير من الحافة للـ target (cubic ease-out)
  if raw >= 1.5:       // وصل: cube 0 = البريك visible, cubes 1,2 = absorbed
```

### 2.4 تقدُّم الـ Brick Reveal
- `_brickRevealProgress` يزيد بـ `_realSec(dt) * 18.0` (18 unit/sec)
- كل bricks تتقدم مع بعض بالتوازي
- الفرق الوحيد بينهم: stagger 0.33 لكل cube داخل الـ brick
- زمن الطيران لكل cube: 1.5 unit = ~83ms
- الزمن الكلي: `_brickTotalDuration = 36.0` = ~2 ثانية

### 2.5 ظهور الـ Bricks
- في اللحظة اللي raw ≥ 1.5: cube 0 يظهر كـ brick مع pop-in snap animation
- cube 1 و 2: يختفوا (absorbed into the brick)
- كل 27 bricks يظهروا في نفس الـ 2 ثانية

### 2.6 Extra cubes
- الـ extra cubes (index ≥ 81) يتصرفوا نفس الاول: drift toward center, hidden during building → staggered cluster in preBurst

**ملفات متأثرة**:
- `lib/core/widgets/particles/floating_cube_background.dart`

---

## ✅ Phase 3: HTML → Flutter Transition (مكتمل)

### 3.1 اللوجو يفضل موجود — بدون fade/remove
- `_removePersistentLogo()` **ملغي** من first-load flow
- اللوجو image يفضل visible دائمًا
- `transitionToPersistentLogo()`: الخلفية → transparent + pointer-events: none

### 3.2 HTML cubes يستمروا في loop
- gathering squares مستمرين infinite
- المستخدم يشوف الاتنين مع بعض: اللوجو + HTML cubes + Flutter cubes

### 3.3 تخزين مواقع البداية من HTML
- HTML يولد 81 position (normalized 0..1, center = 0.5) ويخزنهم في `window._htmlCubeEdgePositions = JSON.stringify(allPositions)`
- Flutter cubes ينطلقوا من نفس النقط

### 3.4 اللوجو ي fade تدريجيًا أثناء بناء المكعب
- **بدل ما يفضل visible forever** (زي ما كنت كاتب غلط قبل كده)، اللوجو يبدأ **fully visible** و ي fade تدريجيًا مع تقدم بناء الـ bricks
- الـ Flutter building loop يستدعي JS function: `setLogoOpacity(1.0 - _brickRevealProgress / _brickTotalDuration)`
- الموديل الحالي: `_brickTotalDuration = 36.0`, building speed = 18 units/sec → ~2 ثانية fade
- المطلوب إضافة `setLogoOpacity` في JS (web/index.html) و استدعائها من Flutter كل frame أثناء `_isBuilding`

### 3.5 النتيجة
- HTML cubes يطيروا من الأطراف → logo (loop forever, continuous spawning, no limit)
- Flutter cubes يبدأوا بناء متوازي من نفس نقاط الانطلاق → 3×3×3 big cube (~2 ثانية)
- اللوجو image ي fade تدريجيًا (شفافية تتناقص) مع تقدم بناء المكعب
- transition طبيعي: كأن المكعبات الـ HTML طارت ورا اللوجو وخرجت كـ Flutter cubes، واللوجو يتلاشى ليكشف المكعب الكامل

**ملفات متأثرة**: 
- `web/index.html` — تخزين `_htmlCubeEdgePositions`
- `lib/core/utils/js_helper_web.dart` — `readJsArray()`
- `lib/core/utils/js_helper_stub.dart` — `readJsArray()` stub
- `lib/core/widgets/particles/floating_cube_background.dart` — قراءة positions
- `lib/features/home/screens/landymaker_home_screen.dart` — إلغاء `_removePersistentLogo()`

---

## ✅ Phase 4: ضبط التوقيت والظهور

### 4.1 زمن البناء
- `_brickTotalDuration = 36.0` units → ~2 ثانية visible للـ parallel building
- سرعة كافية عشان المستخدم يشوف المكعبات بتطير من الأطراف

### 4.2 اللوجو دائمًا visible
- `removePersistentLogo()` مش بينادى في first-load
- اللوجو يستمر ب `z-index: 99999`

### 4.3 الانتظار قبل burst
- `_waitForLoadingThenRevealCubes()` بيستنى:
  1. sections API تكتمل
  2. building يكتمل (`_gatheringComplete`)
- بعدها: burst + content reveal

---

## Summary of All Changes

| الملف | التغيير |
|-------|---------|
| `web/index.html` | 81 edge positions, CSS pure glow 6s ramp, **continuous spawning (no limit)**, **`setLogoOpacity()` function**, logo يختفي خلفه cubes |
| `floating_cube_background.dart` | Parallel brick building (81 cube → 27 bricks), ~2s visible, **استدعاء `setLogoOpacity()` كل frame أثناء building** |
| `landymaker_home_screen.dart` | **إلغاء `_removePersistentLogo()` في first-load flow** |
| `lib/core/utils/js_helper_web.dart` | `readJsArray()` لقراءة positions |
| `lib/core/utils/js_helper_stub.dart` | `readJsArray()` stub |
| `docs/ai/FLOATING_CUBE_BACKGROUND.md` | تحديث docs (logo fade, parallel building ~2s) |
| `docs/ai/CUBE_ECOSYSTEM.md` | تحديث docs |
