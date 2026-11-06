# الإشعارات الفورية (Push) — الخطة والمطلوب

## شو اللي موجود هلق
- **داخل التطبيق (شغّال):** إشعارات الخلفية بتتخزّن (`getUserNotifications`)، شارة العدّاد على الجرس، وتتحدّث لما التطبيق يرجع من الخلفية. **ما في إشعار برّا التطبيق.**
- **الخلفية جاهزة جزئياً:** نموذج `User` فيه `push_device_tokens` (مصفوفة نصوص JSON) و`notification_preferences.push`. الموقع/تطبيق الـ WebView الحالي بيسجّل التوكن بهالصيغة بالضبط:
  `{"token":"...","platform":"android","deviceId":"...","appVersion":"1.0.0","registeredAt":"<ISO>"}`
  عبر `updateUser(input:{user_id, push_device_tokens:[...]})`. جرّبناها بحساب الاختبار (انضاف توكن وانحذف) — الخلفية بتقبلها.
- **جاهز بالتطبيق:** `lib/data/repositories/push_token_repository.dart` (`PushTokenRepository.register/unregister` + دمج التوكنات بدون ما نمسح أجهزة المستخدم التانية) + اختبارات وحدة. مسجّل بـ `AppDependencies.pushTokens`. ما حدا بينادي عليه لسا لأنه ما في توكن.

## شو ناقص (بترتيب)
### 1) من عندك / فريق الباك (مش ممكن أعملها أنا)
1. **مشروع Firebase** + تطبيق أندرويد بـ package name:
   `com.salehli.customer` و`com.salehli.craftsman` (للتجريبي)، والأسماء النهائية للإنتاج. تنزيل `google-services.json` لكل واحد.
2. **من يبعت الإشعار؟** لازم Lambda/AppSync resolver عند الباك يبعت عبر FCM لما:
   - تنكتب رسالة جديدة (`createMessage`) ← للطرف التاني.
   - يوصل عرض جديد (`createJobProposal`) ← للزبون.
   - يتغيّر حالة الطلب/المطالبة (`updateJobStatus`, `claim*`, `resolveProposalClaim`).
   - يتقبّل/يترفض عرض ترويجي أو يتوثّق الحساب.
   وهو بيقرا `push_device_tokens` ويحترم `notification_preferences.push`.
3. **تأكيد نوع التوكن:** تطبيق الـ React Native الحالي بيبعت `token` — هل هو **FCM token** أو **Expo push token**؟ إذا Expo لازم نعرف (الإرسال مختلف). الخطة هون بتفترض FCM.
4. **مفتاح خدمة FCM** (service account) بيكون عند الباك فقط، مش بالتطبيق ولا بالريبو.

### 2) من عندي (بعد ما توصل الأشياء فوق وبموافقتك على الـ packages)
- إضافة `firebase_core` + `firebase_messaging` (بدّها موافقتك) + `flutter_local_notifications` لعرض الإشعار والتطبيق مفتوح.
- إعداد Gradle: plugin `com.google.gms.google-services` + `google-services.json` (بمجلد الملفات المحلية للبناء، مش بالريبو العام للتجريبي).
- طلب إذن الإشعارات (أندرويد 13+ `POST_NOTIFICATIONS`) بأول دخول بعد تسجيل الدخول.
- بعد تسجيل الدخول: `FirebaseMessaging.getToken()` ← `pushTokens.register(token)`؛ عند `onTokenRefresh` نعيد التسجيل؛ عند تسجيل الخروج `unregister` (ما بيوصل إشعارات لحساب مسجّل خروج).
- فتح الشاشة الصح لما تضغط الإشعار: رسالة ← المحادثة، عرض ← تفاصيل الطلب، إلخ (بالاعتماد على `entityType/entityId` بحقل `data` بالإشعار — لازم الباك يبعتها).
- ملاحظة أندرويد: الإشعار والتطبيق مسكّر بيجي من نظام الأندرويد نفسه (FCM) بدون كود إضافي من التطبيق.

## تقدير
- جهة الباك: Lambda إرسال FCM على أحداث الرسائل/العروض/الحالة — الجزء الأكبر.
- جهة التطبيق: ~يوم شغل بعد وصول `google-services.json` وموافقة الـ packages.

## الاختبار
- من Firebase Console: "Send test message" لتوكن الجهاز (بعد التسجيل) ← لازم يوصل والتطبيق مسكّر.
- ثم رسالة حقيقية من حساب لحساب والتطبيق بالخلفية.
