# khaled_flutter — تطبيق "صلّحلي"

تطبيق Flutter (أندرويد) لربط الزبائن بالحرفيين/المهنيين. **UI فقط** مبني من تصميم Figma، والهدف **تطابق التصميم بالبكسل**.
تواصل مع المستخدم **بالعربي (لهجة شامية)**. شوف قسم "طريقة الشغل" تحت قبل ما تبلّش أي شاشة.

## الوضع الحالي (آخر تحديث: 2026-10-31)
- **انبنت كل أقسام تصميم Figma تقريباً:** سبلاش/Onboarding، تسجيل الدخول (مع حالات التحقق)، الزبون الضيف، طلب خدمة، طلباتي (قوائم + تفاصيل + عروض + نوافذ)، الرسائل والدردشة، الإشعارات، الإعدادات. `flutter analyze` نظيف.
- الفحص: اختبار overflow على 25 شاشة × 4 مقاسات (320/360/412/600) × فاتح/داكن = صفر مشاكل. وجرّبنا التطبيق على الويب (Chromium): التنقل وRTL والداكن شغّالين.
- **بناء الويب للفحص بس:** المشروع أندرويد (ما فيه مجلد web). للفحص: انسخ المشروع لمجلد مؤقت، `flutter create . --platforms web`، `flutter build web --no-web-resources-cdn`. لا تضيف `web/` للريبو.
- الناقص: شوف "معلّق / TODOs" تحت.

## نطاق المشروع
- UI + تنقل بين الصفحات فقط. لا API، لا backend، لا قواعد بيانات.
- البيانات وهمية في `lib/data/dummy_data.dart`. الاستثناء: [request_draft.dart](lib/data/request_draft.dart) — كائن عادي بيتمرّر بين خطوات "طلب خدمة" (المستخدم طلبه صراحةً) — مش state management.
- صورة النجار `assets/images/offer_carpentry.jpg` هي الـ placeholder المعتمد لكل صور العروض/الأعمال/الطلبات (المستخدم موافق).
- **لا packages إضافية بدون موافقة.** الموجود: `flutter_localizations`, `flutter_svg` بس.

## اللغة والاتجاه
- **عربي فقط، RTL بالكامل.** لا إنجليزي، لا `intl`. النصوص بتنكتب مباشرة بالـ widgets حرفياً متل التصميم.
- `EdgeInsetsDirectional` / `AlignmentDirectional` / `PositionedDirectional` / `start`/`end` دائماً. `left`/`right` بس إذا التصميم بيفرضها (وعلّق ليش).

## State & Navigation
- **لا state management.** `StatelessWidget` افتراضياً، `StatefulWidget` + `setState` لحالة محلية.
- التنقل: `Navigator.push(context, MaterialPageRoute(...))` و`pop`. لا `go_router`.
- استثناء: خطوات الطلب بتنفتح بـ `NewRequestScreen.route()` (فيها `RouteSettings(name)`) مشان `NewRequestScreen.cancelFlow(context)` يسكّر كل الخطوات. صفحة النجاح بتنفتح بـ `RequestSentScreen.open(context)` (بتمسح كل شي فوق الرئيسية).

## خريطة الشاشات والتنقل
| الشاشة | الملف | بتفتح من |
|---|---|---|
| شاشة البداية (Splash) ← 3 صفحات Onboarding | `screens/onboarding/` | `main.dart` (أول شي) |
| تسجيل الدخول: رقم الواتساب | `screens/auth/phone_login_screen.dart` | "تخطي"/"إبدأ الآن" بالـ Onboarding |
| تأكيد الرقم (OTP 6 خانات + عداد، بيعرض الرقم المدخل) | `screens/auth/otp_screen.dart` | "إرسال رمز التحقق" |
| تسجيل الدخول: نوع الحساب | `screens/auth/login_screen.dart` | "تأكيد الرمز" (بتمسح اللي قبل) |
| دخول الزبائن (اسم، مدينة منسدلة، حي ببحث) | `screens/auth/customer_login_screen.dart` | كرت "دخول الزبائن" |
| طلباتي (قائمة + فلتر الحالة + مراحل الطلب) | `screens/my_requests/` | تاب "طلباتي" بالشريط السفلي |
| الرسائل: قائمة المحادثات + الدردشة | `screens/messages/` | تاب "الرسائل" بالشريط السفلي |
| الإشعارات | `screens/notifications/` | أيقونة الجرس بطلباتي/الرسائل |
| الإعدادات (+ الملف الشخصي، تخصيص الإشعارات، خروج/حذف حساب، الوضع المظلم) | `screens/settings/` | تاب "الإعدادات" بالشريط السفلي |
| الرئيسية | `screens/home/home_screen.dart` | "متابعة" بدخول الزبائن (تحميل وهمي 2 ثانية)، أو "الدخول كضيف" — الاتنين بيمسحوا كل اللي قبل |
| البحث (اقتراحات ↔ نتائج بنفس الصفحة) | `screens/search/search_screen.dart` | زر البحث بالرئيسية |
| تفاصيل الخدمة | `screens/service_details/` | كروت "الخدمات الشائعة" |
| العروض الخاصة (قائمة) | `screens/offers/` | "عرض الكل" بالرئيسية |
| تفاصيل العرض (معرض صور يتسحب) | `screens/offer_details/` | كروت العروض (الرئيسية، العروض، صفحة الحرفي) |
| صفحة الحرفي (تابات أعمال/آراء) | `screens/craftsman_profile/` | كروت "حرفيون مميزون"، نتائج البحث، أيقونة الفتح بتفاصيل العرض |
| طلب خدمة 1: تصنيف الطلب | `screens/new_request/new_request_screen.dart` | زر **+** بالشريط السفلي، "إيجاد حل لمشكلتك" (بانر الرئيسية)، "اختيار المهنيين" (بانر البحث)، "أوصف مشكلتك واطلب عرض سعر" (تفاصيل الخدمة)، "اطلب عرض سعر من المهني" (صفحة الحرفي) |
| 2: تفاصيل الطلب | `request_details_screen.dart` | "المتابعة" بالخطوة 1 |
| 3: تحديد الموقع | `request_location_screen.dart` | "المتابعة" بالخطوة 2 |
| 4: تأكيد إرسال الطلب (ملخص من `RequestDraft`) | `request_confirm_screen.dart` | "المتابعة" بالخطوة 3 |
| استهداف المهنيين (حتى 5) | `craftsman_targeting_screen.dart` | سطر "استهداف المحترفين" بملخص الخطوة 4 |
| تم إرسال طلبك بنجاح | `request_sent_screen.dart` | "إرسال الطلب" بالخطوة 4 أو بالاستهداف |

## المكوّنات المشتركة (`lib/core/widgets/`) — استعملها قبل ما تعمل جديد
- `app_icon_button` زر مربع بحدود + SVG (52 افتراضياً، `size`) — رجوع/بحث/مشاركة.
- `header_action_button` زر "إلغاء"/"العودة للصفحة الرئيسية" بزاوية الهيدر.
- `app_bottom_action_bar` شريط سفلي ثابت: زر رئيسي (+ معطّل لما `onPressed: null`)، زر ثانوي اختياري، و`note` فوقهم.
- `app_bottom_nav_bar` الشريط السفلي للرئيسية (مثبّت LTR لأن "الرئيسية" يسار بالتصميم).
- `promo_banner` البانر الكحلي (عنوان/شرح/زر) مع `banner_pattern.svg` بشفافية 0.05.
- `app_segmented_control` تابات/اختيارات متلاصقة (المختار كحلي).
- `app_chip` تاغ بحدود (تخصصات). `filter_chip_button` زر فلتر بسهم.
- `offer_card` كرت العرض الصغير (218). `craftsman_card` كرت الحرفي مع الخدمات (`color` للخلفية).
- `craftsman_avatar` صورة دائرية + شارة Pro (`size`). `craftsman_header` صف الحرفي الكبير (72) مع `trailing`.
- `dashed_border_box` صندوق بحدود متقطعة (رفع الصور).
- `form/field_popup`: `FieldPopup` قائمة لاصقة بالحقل (تحت أو `above`) فوق الصفحة، `FieldPopupPanel`، `FieldPopupItem`. `AppSelectField(isActive)` و`AppTextField(showFocusBorder)` = حدود كحلي 2px برّا.
- `screens/auth/widgets/`: `AuthHeader` (الشعار `logo_mark.svg` + عنوان 30 + زر العودة)، `AuthBottomBar` (زر + `isLoading` + زر أصفر اختياري + note تحته)، `AuthHeroImage`، `OtpInput`.
- `form/`: `PhoneField` (رمز +963، `inline` = شكل التصميم: الرقم جنب الرمز — مستعمل بالدخول وطلب الخدمة، `restrictInput` للتحقق، `PhoneField.format()`)، `FormLabel(starAfterNote, noteSize)`، `FormLabel` (نجمة حمرا / ملاحظة "(اختياري)")، `AppTextField`، `AppSelectField` (معطّل لما `onTap: null`، `hasError`)، `AppToggle` (أحمر مطفي/أخضر شغّال)، `FieldIcons`، `showOptionsSheet()`.

## الثيم (فاتح + داكن)
- **ألوان الداكن بالتصميم نفسه** (مأخوذة من `get_variable_defs` على إطارات Figma الداكنة): فيها توكنات إضافية بـ `AppColors`: `urgent`، `destructive` (زر التحذير)، `accentButton` (الأصفر كأزرار: داكن #EBB409)، `stepNextIcon`، `barrier`، `chatSent`/`chatBarrier`، `notice*`، `chipText`، و**`pageAlt`/`cardAlt`** لصفحات "المعكوسة" (طلباتي، الإشعارات، الإعدادات): بالداكن الصفحة أغمق (#171922) والكروت أفتح (#1F222E).
- **Dark mode حسب إعداد الجهاز** (`ThemeMode.system` بـ `main.dart`). زر التبديل موجود بالإعدادات (الوضع المظلم).
- ألوان: [app_colors.dart](lib/core/theme/app_colors.dart) — `ThemeExtension` فيها `AppColors.light` و`AppColors.dark`. **بالكود دايماً `context.colors.x`** (مش ثابتة → ما بتنحط جوا `const`، وأي helper بدو `BuildContext`).
  - فاتح: `primary #36407E`، `accent #F7C425`، `background #F9F9FB`، `surface #F0F0F5`، `border #C8CDDA`، `textPrimary #171922`، `textSecondary #68719A`، `textHint #989FBA`، `link #2695D0`، `error #EB1809`.
  - داكن (من `design/24_dark_craftsman_profile.png` و`25_dark_request_step1.png`): `background #171922`، `surface #1F222E` (كروت)، `fieldFill #27293A` (حقول الفورم)، `primary #2A3161`، `disabled #262B4D` (كحلي باهت — مشتق، مش بالتصميم)، `border #373B52`، `textPrimary #F9F9FB`، `textSecondary #B0B6CA`، `textHint #989FBA`، `link #43A8DE`، `error #DB3126`، `successLight #2E9D57` (السويتش). الخطوات: `stepActive #36407E`، `stepInactive #27293A`.
  - حقول الفورم (`AppTextField`/`AppSelectField`/`PhoneField`/رفع الصور) بتستعمل **`fieldFill`** مش `surface`.
  - **`primary` = تعبئة** (أزرار، تابات مختارة، بانر). **`primaryContent` = الكحلي كنص/أيقونة/حدود/مؤشر** (العودة، الشيبس، حدود الحقول المفعّلة، OTP) — بالفاتح نفس الكحلي، بالداكن `#F9F9FB`. انتبه تختار الصح.
  - ⚠️ صفحة العروض ونتائج البحث ونوع الحساب **معكوسة**: الخلفية `surface` والكروت `background`.
- خطوط: [app_text_styles.dart](lib/core/theme/app_text_styles.dart) **بدون لون** — اللون الافتراضي `textPrimary` جاي من `textTheme` بـ [app_theme.dart](lib/core/theme/app_theme.dart). الاسم = الحجم + الوزن (`title22Bold`, `body16Medium`...). الخط IBM Plex Sans Arabic محلي، أوزان 100–700.
- شريط الحالة: `AnnotatedRegion(value: AppTheme.overlayStyle(context))`.
- SVG: أيقونة بلون واحد → `colorFilter` بلون من الثيم (زر `AppIconButton` بيعملها لحاله). شعار/رسمة بأكتر من لون → `colorMapper: SvgThemeColors.of(context)` ([svg_theme_colors.dart](lib/core/theme/svg_theme_colors.dart)) بيبدّل `#36407E`→`primary` و`#989FBA`→`textHint`. كلمة "صلّحلي" بـ `logo.svg` صارت `currentColor` (`SvgTheme(currentColor: primaryContent)`).
- **ممنوع ألوان أو text styles hardcoded بالشاشات** (الاستثناء الوحيد: العلم السوري بـ `phone_field.dart`). لون جديد → ضيفه بـ `AppColors` بالـ light والـ dark.
- **التحقق من الداكن:** ارسم نفس الشاشة بالاتنين (`platformBrightnessTestValue` + `themeMode`)، والفاتح لازم يضل مطابق للتصميم.

## دروس من الشغل (أخطاء تكررت — انتبه إلها)
- **أرقام بنص عربي:** رقم الهاتف لازم `textDirection: TextDirection.ltr` + `textAlign: TextAlign.right` وإلا بينقلب. العدادات ("1 / 8"، "(0/5)") بـ `textDirection: ltr`. تحقق من الترتيب البصري مقابل التصميم دايماً (مثلاً الاستهداف مكتوب `'(محدد 5/3)'` عمداً ليطابق).
- **أيقونات Material اتجاهية** (`open_in_new`, `history`, `north_east`) بتنعكس بـ RTL → لفّها بـ `Directionality(ltr)` إذا التصميم مش معكوس.
- `GridView`/`ListView` جوا scroll: حط `padding: EdgeInsets.zero` وإلا بياخد padding شريط الحالة (32px زيادة).
- `Container` ما بيقبل `color` + `clipBehavior` سوا → استعمل `decoration`.
- نصوص بـ `Row` (موقع، تقييم...) لفّها بـ `Flexible` + `ellipsis` مشان ما تطلع overflow على الشاشات الضيقة.
- قيس **عرض** أسطر النصوص كمان مش بس مكانها: نفس الارتفاع مع عرض أصغر يعني حجم الخط أصغر من التصميم.
- `CustomPaint` للحدود فوق خلفية → `foregroundPainter` مش `painter`.
- العناوين الفرعية بالتصميم غالباً **داخلة 12px** عن حواف الكروت (`EdgeInsetsDirectional.symmetric(horizontal: 12)`).
- عرض الـ Frame بـ Figma **412**، والصور المصدّرة 1x (1px = 1 logical px).

## طريقة الشغل مع المستخدم
1. المستخدم بيبعت **شاشة شاشة** (PNG 1x من فيغما)، وأحياناً حالتين لنفس الشاشة.
2. **أنا بطلب الأصول الناقصة بالاسم** (SVG للأيقونات، PNG/JPG للصور)، وبحدد الخط/الألوان من الصورة إذا ما انبعتت.
   - صور التصميم لكل الشاشات الجاهزة محفوظة بـ [design/](design/) (مرقّمة بالترتيب، `01_home.png`...). احفظ أي صورة تصميم جديدة هونيك بنفس الطريقة.
3. قيس من الصورة قبل الكود: `python3 -I tool/design_check/measure.py` (spans / lines / colors / size).
4. ابني متّبع skill `figma-to-flutter` وقواعد هالملف.
5. **تحقق بالرسم:** انسخ [render_test_template.dart](tool/design_check/render_test_template.dart) لـ `test/_tmp/`، عدّل خطوات التنقل، شغّله بـ `--update-goldens`، شوف الصورة وقيسها بـ `--scale 2`، صلّح لحتى الفرق ≤ 2–3px. جرّب التنقل/التفاعلات بنفس الاختبار. **امسح `test/` بعدها.**
6. `flutter analyze` نظيف، وبعدين تقرير قصير بالعربي: شو انعمل، كيف بيشتغل، ملاحظات، وشو ناقص.

## معلّق / TODOs
- **حالات التحقق:** رقم الهاتف غير صحيح (حدود حمرا + "رقم الهاتف يجب أن يكون 9 أرقام" بعد ما تطلع من الحقل)، وحي بدون نتيجة ("لا توجد مناطق تطابق البحث" + إضافة الحي).
- **الإعدادات:** انبنت كلها (إعدادات، ملف شخصي، تخصيص إشعارات، نافذتا الخروج والحذف). زر "الوضع المظلم" بيشتغل فعلياً عبر `themeModeNotifier` (`core/theme/theme_mode_notifier.dart`)؛ بالبداية الثيم حسب الجهاز. ناقص: قائمة أسباب الحذف (مش بالتصميم)، قائمة مدن الملف الشخصي، شاشات المساعدة/الأمان/انضم كحرفي (ما في تصاميم).
- **الرسائل:** انبنت القائمة والدردشة (رسائل نص/صورة/بطاقة طلب، شريط كتابة، أول مرة `firstTime`). ناقص: قائمة الخيارات (frame 382:2389 — timeout بفيغما)، زر "العودة للعرض" والنزول لآخر الدردشة، لوحة المفاتيح/الرسالة الطويلة (339:2170, 339:2346)، نقشة خلفية الدردشة، الداكن مش مفحوص.
- **طلباتي:** انبنت: القوائم (نشطة/مكتملة/ملغاة)، تفاصيل الطلب (تابات التفاصيل/العروض)، نوافذ تحديث الحالة/الاتفاق مع مهني/إلغاء الطلب/تقييم الخدمة (`my_requests/dialogs/`). ناقص: تعديل الطلب (frames Editing)، متغيرات تفاصيل الطلب لحالات تانية (310:3007, 319:3273)، وفتح عرض/حرفي من العروض. لون `warning`/`successDisabled` للداكن مشتق (ما في تصميم داكن مفحوص).
- **Dark mode:** `map_placeholder.png` فاتحة بالداكن كمان (مقبول لأنها خريطة). صورة الطاقية إلها نسختين: `otp_header.png` و`otp_header_dark.png` (3x، `AuthHeroImage` بيختار حسب الثيم).
- **تسجيل الدخول:** الترتيب (قراري، لسا ما تأكّد من المستخدم): رقم ← OTP ← نوع الحساب ← دخول الزبائن ← الرئيسية. "تغيير رقم الهاتف" بيرجع لصفحة الرقم. دخول المهنيين: المستخدم قال خليه ما بيعمل شي هلق. "مشاهدة فيديو توضيحي" TODO. "دخول الزائن" بالتصميم غلط، المعتمد "دخول الزبائن". `otp_header.png` (صفحة الرقم وOTP) هي الصورة الوحيدة 3x (حجمها محدد بالكود).
- **محتاجة packages (بموافقة):** اختيار صور حقيقي `image_picker` (الخطوة 2 بتضيف صورة تجريبية)، خريطة `google_maps_flutter` + مفتاح API (الخطوة 3 صورة ثابتة `map_placeholder.png` بدقة 1x)، الموقع `geolocator`.
- **محتاجة تصاميم:** تابات الشريط السفلي (طلباتي، الرسائل، الإعدادات)، "المزيد" بالخدمات، "معرفة المزيد عن صلحلي"، الفلاتر، المشاركة، رمز الدولة، الشروط/الخصوصية، خدمة العملاء.
- مزوّرات مقصودة: التصنيف التلقائي بالخطوة 1 دايماً بيفشل (متل التصميم)؛ كل الخدمات بتفتح نفس `sampleServiceDetails`، وكل العروض نفس `sampleOfferDetails`، وكل الحرفيين نفس `sampleCraftsmanProfile`.
- ملخص الخطوة 4 بيختلف عن التصميم: شلنا "حجم العمل" (ما في خطوة بتسأل عنه) وضفنا مدى الإلحاح/الوقت/بالنيابة عن/التواصل.
