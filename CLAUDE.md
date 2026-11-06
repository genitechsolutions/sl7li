# khaled_flutter — تطبيق "صلّحلي"

تطبيق Flutter (أندرويد) لربط الزبائن بالحرفيين/المهنيين. **UI فقط** مبني من تصميم Figma، والهدف **تطابق التصميم بالبكسل**.
تواصل مع المستخدم **بالعربي (لهجة شامية)**. شوف قسم "طريقة الشغل" تحت قبل ما تبلّش أي شاشة.

## الوضع الحالي (آخر تحديث: 2026-10-31)
- **انبنت كل أقسام تصميم Figma تقريباً:** سبلاش/Onboarding، تسجيل الدخول (مع حالات التحقق)، الزبون الضيف، طلب خدمة، طلباتي (قوائم + تفاصيل + عروض + نوافذ)، الرسائل والدردشة، الإشعارات، الإعدادات. `flutter analyze` نظيف.
- الفحص: اختبار overflow على 25 شاشة × 4 مقاسات (320/360/412/600) × فاتح/داكن = صفر مشاكل. وجرّبنا التطبيق على الويب (Chromium): التنقل وRTL والداكن شغّالين.
- **بناء الويب للفحص بس:** المشروع أندرويد (ما فيه مجلد web). للفحص: انسخ المشروع لمجلد مؤقت، `flutter create . --platforms web`، `flutter build web --no-web-resources-cdn`. لا تضيف `web/` للريبو.
- الناقص: شوف "معلّق / TODOs" تحت.

## نطاق المشروع
- UI + تنقل + **ربط بالخلفية الحقيقية** (AWS Amplify: Cognito + AppSync GraphQL) عبر Cubit — بطلب المستخدم صراحةً. شوف قسم "الخلفية والـ Cubits" تحت.
- البيانات الوهمية بـ `lib/data/dummy_data.dart` و`craftsman_data.dart` لسا موجودة: هي اللي بيرجعها وضع `fake` (الافتراضي، للتصميم والاختبارات). [request_draft.dart](lib/data/request_draft.dart) كائن عادي بيتمرّر بين خطوات "طلب خدمة".
- صورة النجار `assets/images/offer_carpentry.jpg` هي الـ placeholder المعتمد لكل صور العروض/الأعمال/الطلبات (المستخدم موافق).
- **لا packages إضافية بدون موافقة.** معتمدة بآخر موافقة: `image_picker`, `share_plus`, `geolocator`. الموجود: `flutter_localizations`, `flutter_svg`، ومعتمدة بطلب المستخدم للخلفية: `flutter_bloc`, `equatable`, `amplify_flutter`, `amplify_auth_cognito`, `amplify_api`. ومعتمدة للرسائل الصوتية: `record`, `just_audio`. (للرفع/تشغيل التسجيلات المستلمة: `amplify_storage_s3` أو `aws_signature_v4` بموافقة.)

## اللغة والاتجاه
- **عربي فقط، RTL بالكامل.** لا إنجليزي، لا `intl`. النصوص بتنكتب مباشرة بالـ widgets حرفياً متل التصميم.
- `EdgeInsetsDirectional` / `AlignmentDirectional` / `PositionedDirectional` / `start`/`end` دائماً. `left`/`right` بس إذا التصميم بيفرضها (وعلّق ليش).

## التعليقات
- **قليلة وقصيرة:** سطر واحد كحد أقصى، وبس للـ "ليش" (مش للـ "شو"). لا فقرات ولا تعليقات داخل الـ widget trees. الاستثناءات: `// rtl-ok`، `// TODO`، `// ignore:`.

## State & Navigation
- **state management = Cubit (`flutter_bloc`)** للبيانات اللي جاية من الخلفية (قوائم، جلسة). حالة الواجهة المحلية (تاب مختار، حقول) تضل `StatefulWidget` + `setState`. `StatelessWidget` افتراضياً.
- التنقل: `Navigator.push(context, MaterialPageRoute(...))` و`pop`. لا `go_router`.
- استثناء: خطوات الطلب بتنفتح بـ `NewRequestScreen.route()` (فيها `RouteSettings(name)`) مشان `NewRequestScreen.cancelFlow(context)` يسكّر كل الخطوات. صفحة النجاح بتنفتح بـ `RequestSentScreen.open(context)` (بتمسح كل شي فوق الرئيسية).

## الخلفية والـ Cubits
- **الطبقات:** `core/backend/` (إعداد البيئة، تهيئة Amplify، `GraphQlGateway`، مستندات GraphQL `Gql`، أدوات JSON) ← `data/repositories/` (كل ميزة: واجهة abstract + `Fake*` ببيانات وهمية + `Remote*`/`Amplify*` للحقيقي + دوال تحويل JSON←نماذج الواجهة) ← `cubits/` ← الشاشات.
- **الأوضاع:** `AppConfig.mode`: `fake` (افتراضي، بدون شبكة) أو `amplify`. التشغيل الحقيقي:
  `flutter run --dart-define=BACKEND=amplify --dart-define=APP_ENV=devqa --dart-define=APPSYNC_API_KEY=<المفتاح>` (البيئة `production` بـ `APP_ENV=production`). **مفتاح AppSync ما بينكتب بالكود/الريبو أبداً.** إذا فشلت تهيئة Amplify بالإقلاع بنكمّل بـ fake وبنسجّل السبب.
- **التزويد:** `AppDependencies` (`.fake()` / `.amplify()`) + `AppProviders` (فوق `MaterialApp` بـ `main.dart`). **أي اختبار/رسم لشاشة لازم يلفّها بـ `AppProviders(dependencies: AppDependencies.fake(), …)`** وإلا `context.read` بيفشل.
- **Cubits:** `LoadCubit<T>` (قاعدة: `load()` / `load(force: true)` / `reset()`، الحالة `LoadState`) ← `OffersCubit`, `FeaturedOffersCubit`, `MyRequestsCubit`, `CraftsmanJobsCubit`, `ConversationsCubit` (`loadFor(professionalMode:)`), `NotificationsCubit`. `AuthCubit` حالته `AuthState` (رقم ← رمز ← جلسة). الشاشات بتستعمل `LoadView<Cubit, T>` (`cubits/load_view.dart`) اللي بيعرض تحميل/خطأ+إعادة محاولة/فاضي. تسجيل الخروج: `signOutAndReset(context)`.
- **الدخول (متل الموقع):** Cognito، الهاتف هو الـ username. مستخدم جديد: `signUp` بكلمة سر عشوائية ← رمز SMS ← `confirmSignUp` ← `signIn`. موجود: `signIn` بـ `CUSTOM_WITHOUT_SRP` ← `confirmSignIn(code)`. إعادة الإرسال: `resendOtpSecure` (API key). (devqa فيه تجاوز OTP للأرقام المسموحة؛ تفاصيله عند فريق الباك.)
- **GraphQL:** استعلامات `*Secure` بترجع نص JSON (AWSJSON) بحقول نماذج الخلفية؛ التحويل بـ `myRequestFromJson`/`craftsmanRequestFromJson`/`offerFromJson`/`conversationFromJson`/`notificationFromJson`. القائمة الكاملة بـ [docs/backend_api_catalog.md](docs/backend_api_catalog.md)، والبيئة بـ [docs/backend_dev_env.md](docs/backend_dev_env.md).
- **دخول تجريبي (للاختبار فقط):** زر "دخول كمستخدم تجريبي" بصفحة الرقم، بيسجّل الدخول مباشرة بكلمة سر بدون SMS. **مطفي افتراضياً**؛ بينفعّل بس ببناء devqa بـ `--dart-define=ENABLE_TEST_LOGIN=true --dart-define=TEST_LOGIN_PASSWORD=<كلمة السر>` (+ `TEST_LOGIN_PHONE` للمهني). كلمة السر ما بتنكتب بالريبو، وما بيشتغل بـ production. للحذف: امسح `lib/debug/test_login.dart` + السطرين المعلّمين `TEST-LOGIN` بـ `phone_login_screen.dart`. لا تنشر APK فيه كلمة السر علناً.
- **اختبارات الوحدة:** `test/unit/` (بتنحفظ بالريبو): المحوّلات، الـ cubits، تحليل إعداد Amplify. تشغيل: `flutter test test/unit`. (اختبارات الرسم المؤقتة بـ `test/_tmp/` بس وبتنمسح.)
- **مربوط فعلياً:** دخول (رقم/OTP؛ الحساب الموجود بيتجاوز نماذج التسجيل بعد اختيار النوع)، إنشاء طلب، تفاصيل الطلب (وصف/صور/موقع/عروض حقيقية)، ملف الزبون (اسم/رقم)، تفاصيل طلب المهني + عرضه + فتح المحادثة، محفظة النقاط،  العروض (الرئيسية + القائمة)، طلباتي، طلبات/مهام المهني (الرئيسية + التاب)، المحادثات (قائمة + رسائل نص/صوت + إرسال + subscription مباشر `onCreateMessage` + تمييز مقروء)، الإشعارات (+ تمييز الكل)، تسجيل الخروج، إرسال عرض المهني (`createJobProposalSecure` + مزامنة حالة توثيق الهوية)، تجاهل الطلب (`ignoreJobForProfessionalSecure` بسبب `other`)، حفظ اسم الملف الشخصي (`updateUser`)، حذف الحساب (`deleteAccountSecure`، مكتوب وما انجرّب عمداً)، صورة الملف الشخصي للزبون (رفع `profile` + `updateUser`)، إنشاء العرض الترويجي + تاب عروضي (`createOfferSecure`/`listMyOffers`)، سجل المحفظة (آخر حركتين)، توثيق الهوية (اختيار صورة + رفع S3 + `submitGovernmentIdVerificationSecure`، ما انجرّب عمداً)، اختيار صور حقيقي بطلب الخدمة وإنشاء العرض (`image_picker` ← `uploadMedia`)، تحديد الموقع (`geolocator`)، المشاركة (`share_plus`)، تفاصيل العرض (`getOfferDetails` + تتبّع المشاهدة؛ فلاتر المدينة/التصنيف بـ `OffersCubit.applyFilters`)، الصفحة العامة للمهني (`getProfessionalPublicPageSecure` + `listProfessionalPublicOffers`، بـ `openCraftsmanProfile`)، الملف المهني (تحميل/حفظ `updateProfessionalSecure` + صورة + معرض أعمال)، تسجيل المهني (`createProfessionalSecure` — ما انجرّب بحساب جديد)، تسجيل الزبون الجديد (اسم/مدينة/حي) + تفضيلات الإشعارات (`notification_preferences`)، التصنيف التلقائي للطلب (`analyzeServiceRequest` + `service_id` الحقيقي)، سحب العرض عند المهني (`updateProposalStatusSecure`)، الاتفاق والتقييم من الدردشة (`recordCustomerFeedback`). (أرباح المهني وتقييمه بالرئيسية من `getJobCompletionsByProfessional`، الاختبار بحساب فاضي = 0). **مش مربوط لسا (الواجهة وهمية):** الخريطة (بدها `google_maps_flutter` + مفتاح)، الاعتراض على الإنجاز والإبلاغ (`createServiceReportSecure` بدون تصميم)، أزرار واتساب/طلب سعر بتفاصيل العرض (التتبّع جاهز)، تفاصيل الطلب/الحرفي بالفيك مود بتفتح بيانات وهمية.
- ⚠️ **ما انجرّب على الخلفية الحقيقية** (ما في حساب تجريبي): أشكال ردود `*Secure` ومفاتيح JSON مأخوذة من نماذج الخلفية (introspection) وكود الموقع؛ تحقّق منها بأول تشغيل حقيقي (خاصة أسماء حقول المحادثات: `otherParticipantName`...).

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
| **المهني:** تسجيل (4 خطوات + مراجعة) ← واجهة المهني (رئيسية، طلبات، عروضي) | `screens/craftsman/` | كرت "دخول المهنيين" بصفحة نوع الحساب |
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
- **واجهة المهني (Figma ملف جديد `m6JhQu7sjSZJczMdcR37cH`، صفحة Craftsmen app):** انبنى تسجيل المهني (خطوات 1-4 + المراجعة)، الرئيسية، الطلبات (مهامي/المتاحة)، عروضي (الحالة الفاضية). **(قديم — معظمه انبنى لاحقاً؛ المرجع الحالي أسفل الملف).** ناقص: تدفق إرسال عرض (Sending offer flow: تفاصيل الطلب، إرسال، تأكيد)، طلباتي عند المهني (مكتملة/ملغاة/تحديث الحالة)، إنشاء عرض ترويجي (4 خطوات + اختيار تاريخ)، رسائل المهني، الملف الشخصي والإعدادات (تعديل الملف والخدمات)، توثيق الحساب (Account verification flow)، إشعارات المهني، حالات فاضية. شريط المهني السفلي من عندي (ما في تصميم له بالإطارات).
- **حالات التحقق:** رقم الهاتف غير صحيح (حدود حمرا + "رقم الهاتف يجب أن يكون 9 أرقام" بعد ما تطلع من الحقل)، وحي بدون نتيجة ("لا توجد مناطق تطابق البحث" + إضافة الحي).
- **الإعدادات:** انبنت كلها (إعدادات، ملف شخصي، تخصيص إشعارات، نافذتا الخروج والحذف). زر "الوضع المظلم" بيشتغل فعلياً عبر `themeModeNotifier` (`core/theme/theme_mode_notifier.dart`)؛ بالبداية الثيم حسب الجهاز. ناقص: قائمة أسباب الحذف (مش بالتصميم)، قائمة مدن الملف الشخصي، شاشات المساعدة/الأمان/انضم كحرفي (ما في تصاميم).
- **الرسائل:** انبنت القائمة والدردشة (رسائل نص/صورة/بطاقة طلب، شريط كتابة، أول مرة `firstTime`). قائمة الخيارات وزر "العودة للعرض" والنزول والرسالة الطويلة (حتى 5 أسطر) موجودين. ناقص: نقشة خلفية الدردشة، الداكن مش مفحوص.
- **طلباتي:** انبنت: القوائم (نشطة/مكتملة/ملغاة)، تفاصيل الطلب (تابات التفاصيل/العروض)، نوافذ تحديث الحالة/الاتفاق مع مهني/إلغاء الطلب/تقييم الخدمة (`my_requests/dialogs/`). تعديل الطلب (frames Editing = نافذة تحديث الحالة) و تفاصيل الطلب للحالات (310:3007, 319:3273) مفحوصة/مطابقة؛ "تعديل الطلب" بيفتح خطوات الطلب بدون تعبئة مسبقة. ناقص: فتح عرض/حرفي من العروض. لون `warning`/`successDisabled` للداكن مشتق (ما في تصميم داكن مفحوص).
- **Dark mode:** `map_placeholder.png` فاتحة بالداكن كمان (مقبول لأنها خريطة). صورة الطاقية إلها نسختين: `otp_header.png` و`otp_header_dark.png` (3x، `AuthHeroImage` بيختار حسب الثيم).
- **تسجيل الدخول:** الترتيب (قراري، لسا ما تأكّد من المستخدم): رقم ← OTP ← نوع الحساب ← دخول الزبائن ← الرئيسية. "تغيير رقم الهاتف" بيرجع لصفحة الرقم. دخول المهنيين: المستخدم قال خليه ما بيعمل شي هلق. "مشاهدة فيديو توضيحي" TODO. "دخول الزائن" بالتصميم غلط، المعتمد "دخول الزبائن". `otp_header.png` (صفحة الرقم وOTP) هي الصورة الوحيدة 3x (حجمها محدد بالكود).
- **محتاجة packages (بموافقة):** اختيار صور حقيقي `image_picker` (الخطوة 2 بتضيف صورة تجريبية)، خريطة `google_maps_flutter` + مفتاح API (الخطوة 3 صورة ثابتة `map_placeholder.png` بدقة 1x)، الموقع `geolocator`.
- **محتاجة تصاميم:** تابات الشريط السفلي (طلباتي، الرسائل، الإعدادات)، "المزيد" بالخدمات، "معرفة المزيد عن صلحلي"، الفلاتر، المشاركة، رمز الدولة، الشروط/الخصوصية، خدمة العملاء.
- مزوّرات مقصودة: التصنيف التلقائي بالخطوة 1 دايماً بيفشل (متل التصميم)؛ كل الخدمات بتفتح نفس `sampleServiceDetails`، وكل العروض نفس `sampleOfferDetails`، وكل الحرفيين نفس `sampleCraftsmanProfile`.
- ملخص الخطوة 4 بيختلف عن التصميم: شلنا "حجم العمل" (ما في خطوة بتسأل عنه) وضفنا مدى الإلحاح/الوقت/بالنيابة عن/التواصل.

- **المهني (تحديث):** انضاف تاب الرسائل (`MessagesScreen(craftsmanMode)`) وتاب "حسابي" (`craftsman/profile/`: بطاقة التوثيق عبر `verificationNotifier`، تعديل الملف `EditCraftsmanProfileScreen`، تعديل الخدمات عبر `SignupStep2Screen(editing)`). إرسال عرض بدون توثيق بيفتح `showVerificationDialog`. ناقص: إشعارات المهني، قائمة الثلاث نقاط بكرت الطلب، فحص بصري للتابات الجديدة.

- **المهني (تحديث 2):** الإشعارات = نفس شاشة الزبون (مطابقة للتصميم). `EditCraftsmanProfileScreen` وتعديل الخدمات (`SignupStep2Screen(editing)` + `SignupScaffold(editTitle)`) طابقوا Figma 701:2396/701:2620؛ `AppBottomActionBar(sideBySide)` للزر الثانوي جنب الرئيسي. قائمة ثلاث نقاط بكرت الطلب (`showRequestMoreMenu`، بدون تصميم دقيق). قائمة خيارات دردشة المهني (549:5929) = "إبلاغ" فقط (موجودة).

- **فحص RTL:** `python3 -I tool/rtl_check.py` بيطلّع كل اتجاه ثابت (left/right، Positioned، Alignment، أيقونات اتجاهية). الحالات المقصودة علّم سطرها بـ `// rtl-ok`. بيكشف أخطاء الكود بس، مش أخطاء الترتيب البصري.
- **فحص RTL البصري (تلقائي):** `bash tool/design_check/run_rtl.sh` (بيمسح `test/_tmp` بس) بيرسم الشاشات المعرّفة بـ `tool/design_check/rtl_screens_test.dart` (اسم صورة `design/` + widget) ويشغّل `rtl_diff.py` اللي بيلاقي شرايط أفقية شكلها أقرب لانعكاس التصميم (ترتيب/سهم معكوس). لتغطية شاشة جديدة: احفظ صورة Figma بـ `design/NN_name.png` وضيف سطر بالقائمة. ما بيشوف نصوص/أرقام معكوسة داخل نفس الشريط ولا الصور.
- **فحص ترتيب العناصر (`rtl_order.py`، بيشتغل ضمن `run_rtl.sh`):** بيستخرج لكل صف تسلسل بقع الحبر (أيقونة/كلمة) وبيقارن عروضها مع التصميم؛ إذا نفس البقع بس بترتيب مختلف (أيقونة ونص مبدّلين، سهم بجهة غلط) بيطلّعه. بيلقط متل شارة "7 عروض واردة" (السهم لازم يسار النص). فيه ضجيج على الصور/الأفاتار والنصوص الملتفّة بشكل مختلف؛ راجع كل ملاحظة بصرياً.
- **نتيجة تمرير فحص RTL على كل الشاشات (49 شاشة):** انصلحت: أيقونات/أسهم بجهة غلط (هيدر الطلبات عند المهني والزبون، تاب الحساب عند المهني، بطاقة التعريف بالدردشة، تقييم الحرفي)، وتخطيط الإشعارات. الباقي ضجيج (صور/أفاتار/حالات تصميم مختلفة). تفاصيل ما بقي: شارة Pro أكبر من التصميم على أفاتار 48، ترتيب صور الطلب بالبيانات الوهمية، عنوان/مفتاح الواتساب بإعدادات إشعارات المهني ("إعدادات الإشعارات" + الواتساب مطفي بتصميمه).
- **فحص RTL الكامل:** `run_rtl.sh` بيغطي هلق 66 شاشة/حالة (شاشات، نوافذ، شيتات إرسال العرض، خطوات إنشاء العرض، الداكن). لإضافة شاشة: صورة `design/NN_name.png` + سطر بـ `_screens` + (اختياري) خطوات فتح بـ `_prep`. ملاحظة: `verificationNotifier` عام فبيتصفّر بأول كل اختبار.
- **من لقطات الجهاز (2026-11-01):** انصلح: بطاقة مسار التطور (67% + سطر المسار التالي تحت)، صفوف المحفظة (تخطيط التصميم + سهم نازل للسحب)، أيقونة الأرباح، كرت الطلب الصغير بالرئيسية (171px، سطرين + قراءة المزيد)، قائمة الثلاث نقاط (تجاهل العرض بس، لاصقة بالزر)، أيقونة الواتساب الحقيقية (`ic_whatsapp.svg`)، أيقونة الطيارة بنافذة تأكيد العرض (`cr_send_plane.svg`)، "تحديث حالة الطلب"، فلتر "مكتمل"، كيبورد الحي بإنشاء العرض (نص مش أرقام)، وخطوة تأكيد إنشاء العرض (طبق التصميم 682:2826).
- **اختبار الويب E2E (Playwright):** انسخ المشروع لمجلد مؤقت + `flutter create . --platforms web` + `flutter build web --no-web-resources-cdn` (وضع fake). فعّل الـ semantics بنقرة على `flt-semantics-placeholder`، وابحث عن العناصر بنص `aria-label` (اختار أصغر عنصر مطابق؛ الحاويات الكبيرة بتحمل نص الصفحة كلها). للخلفية الحقيقية: `--dart-define=BACKEND=amplify --dart-define=APPSYNC_API_KEY=...` بالبناء المحلي بس (ما بيتنشر). **لا تجرّب signUp/OTP على devqa بأرقام عشوائية** (بيعمل مستخدمين وبيبعت SMS). `OtpInput` حقله المخفي شفاف النص (مش `Opacity(0)`) لأن الويب ما بيعطيه تركيز.
- **`ArcProgress`** (`core/widgets/arc_progress.dart`): حلقة تقدّم 270° برسم CustomPaint — المسار الرمادي والقوس الأزرق بنفس المركز/النصف قطر/السماكة، وطول الأزرق = النسبة. بتُستعمل بـ `CraftsmanProgressCard(percent:)` (الرئيسية + تاب حسابي). ممنوع ترجع لصور SVG منفصلة للمسار والقوس (كان الأزرق يطلع برّا الرمادي). الاختبار: `test/unit/arc_progress_test.dart` (فحص بكسلات).
