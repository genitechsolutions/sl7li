---
name: figma-to-flutter
description: تحويل شاشة أو مكوّن من تصميم Figma (رابط Frame عبر Figma MCP أو screenshot) إلى Flutter UI مطابق، عربي RTL. استخدمه كلما طلب المستخدم بناء شاشة أو مكوّن من التصميم.
---

# Figma → Flutter (عربي RTL، UI فقط)

اقرأ `CLAUDE.md` أولاً — قواعده إلزامية هنا.

## 1. اجمع معلومات التصميم
- **رابط Figma + MCP متاح:** اسحب design context والـ variables والـ screenshot للـ Frame. اعتمد القيم الحرفية (px, hex, font weight, line height, letter spacing).
- **screenshot فقط:** استخرج القيم بأدق ما يمكن، واسأل المستخدم عن أي قيمة غير واضحة (لون، حجم خط، مسافة) بدل التخمين.
- حدد: النصوص الحرفية، الصور/الأيقونات المطلوبة، والعناصر التفاعلية (أزرار، حقول، تابات) ووين بتودّي.

## 2. طابق مع الموجود
- قارن الألوان والـ text styles مع `AppColors` و`AppTextStyles`. أضف الجديد هناك فقط، بأسماء وصفية (`primary`, `textSecondary`, `headingLarge`...).
- استخدم مكوّنات `core/widgets` الموجودة. إذا عنصر بيتكرر بأكثر من شاشة → انقله إلى `core/widgets`.

## 3. حوّل الـ Layout
- Auto Layout عمودي → `Column`، أفقي → `Row`، gap → `SizedBox` أو `spacing`، padding → `EdgeInsetsDirectional` بنفس القيم.
- Fill container → `Expanded`/`double.infinity`، Hug → حجم طبيعي، Fixed → `SizedBox` بالقيمة.
- انتبه: Figma يعرض التصميم كما هو بصرياً؛ في RTL أول عنصر بـ `Row` يظهر على اليمين — تحقق أن الترتيب البصري يطابق التصميم.
- radius، border، shadow → `BoxDecoration` بنفس القيم (حوّل Figma shadow: x, y, blur, spread, color+opacity).
- المحتوى الطويل → `SingleChildScrollView` أو `ListView`، وانتبه للكيبورد في شاشات الإدخال.
- لا تثبّت عرض/ارتفاع الشاشة؛ التصميم لازم يشتغل على أحجام أصغر وأكبر من الـ Frame المرجعي.

## 4. الأصول
- الأيقونات SVG في `assets/icons`، الصور في `assets/images`. إذا أصل ناقص، اطلبه من المستخدم بالاسم — لا تستبدله بأيقونة Material إلا مؤقتاً مع تعليق `// TODO: asset`.

## 5. التنقل والحالة
- الأزرار اللي بتودّي لشاشة موجودة → `Navigator.push`. لشاشة لسا ما انبنت → `onPressed: () {}` مع `// TODO: navigate to X`.
- حالة محلية فقط بـ `setState`.

## 6. تحقق (إلزامي قبل التسليم)
- **قيس التصميم:** `python3 -I tool/design_check/measure.py spans|lines|colors <png> ...` (شوف أول الملف للاستعمال). استعمله لأخذ الـ hex والمسافات بدل التخمين.
- **ارسم الشاشة:** انسخ `tool/design_check/render_test_template.dart` لـ `test/_tmp/x_test.dart`، خلّي الطول = طول صورة التصميم، أضف خطوات التنقل للشاشة، و`flutter test test/_tmp/x_test.dart --update-goldens`.
- **قارن:** اقرا الـ PNG الناتج بعينك، وقيسه بنفس الأوامر مع `--scale 2`. صلّح لحتى الفرق ≤ 2–3px (أسطر النصوص، حدود الكروت، أعرض الأسطر).
- **جرّب التفاعل** بنفس الاختبار: الكبسات، التنقل، الرجوع، الحالات (فاضي/معبّى/خطأ).
- امسح مجلد `test/` بعد ما تخلص، و`flutter analyze` بدون مشاكل.
- راجع: النصوص حرفياً؟ RTL صح (أرقام، أيقونات اتجاهية)؟ لا ألوان hardcoded؟ شوف "دروس من الشغل" بـ CLAUDE.md.
