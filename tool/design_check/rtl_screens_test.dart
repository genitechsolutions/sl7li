// يرسم شاشات التطبيق لـ test/_tmp/rtl/*.png بنفس حجم صور التصميم، وبعدين tool/design_check/run_rtl.sh بيقارنهم.
// بيشتغل بس عبر run_rtl.sh (بينسخه لـ test/_tmp).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:khaled_flutter/core/widgets/form/app_checkbox.dart';
import 'package:khaled_flutter/data/craftsman_verification.dart';
import 'package:khaled_flutter/screens/craftsman/offers/create_offer_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/app_dependencies.dart';
import 'package:khaled_flutter/app_providers.dart';
import 'package:khaled_flutter/core/theme/app_colors.dart';
import 'package:khaled_flutter/core/theme/app_theme.dart';
import 'package:khaled_flutter/data/craftsman_data.dart';
import 'package:khaled_flutter/data/craftsman_signup.dart';
import 'package:khaled_flutter/data/dummy_data.dart';
import 'package:khaled_flutter/data/request_draft.dart';
import 'package:khaled_flutter/screens/auth/otp_screen.dart';
import 'package:khaled_flutter/screens/craftsman/craftsman_home_screen.dart';
import 'package:khaled_flutter/screens/craftsman/profile/craftsman_profile_tab.dart';
import 'package:khaled_flutter/screens/craftsman/requests/craftsman_request_details_screen.dart';
import 'package:khaled_flutter/screens/craftsman/signup/signup_review_screen.dart';
import 'package:khaled_flutter/screens/craftsman/signup/signup_step1_screen.dart';
import 'package:khaled_flutter/screens/craftsman/signup/signup_step3_screen.dart';
import 'package:khaled_flutter/screens/craftsman/signup/signup_step4_screen.dart';
import 'package:khaled_flutter/screens/craftsman_profile/craftsman_profile_screen.dart';
import 'package:khaled_flutter/screens/messages/chat_screen.dart';
import 'package:khaled_flutter/screens/new_request/craftsman_targeting_screen.dart';
import 'package:khaled_flutter/screens/new_request/new_request_screen.dart';
import 'package:khaled_flutter/screens/new_request/request_details_screen.dart'
    as nr;
import 'package:khaled_flutter/screens/new_request/request_location_screen.dart';
import 'package:khaled_flutter/screens/new_request/request_sent_screen.dart';
import 'package:khaled_flutter/screens/my_requests/my_requests_screen.dart';
import 'package:khaled_flutter/screens/my_requests/request_details_screen.dart'
    as mr;
import 'package:khaled_flutter/screens/messages/messages_screen.dart' as msgs;
import 'package:khaled_flutter/screens/settings/profile_screen.dart';
import 'package:khaled_flutter/screens/notifications/notifications_screen.dart';
import 'package:khaled_flutter/screens/offer_details/offer_details_screen.dart';
import 'package:khaled_flutter/screens/service_details/service_details_screen.dart';
import 'package:khaled_flutter/screens/settings/notification_settings_screen.dart';
import 'package:khaled_flutter/screens/auth/customer_login_screen.dart';
import 'package:khaled_flutter/screens/craftsman/offers/my_offers_tab.dart';
import 'package:khaled_flutter/screens/craftsman/profile/edit_profile_screen.dart';
import 'package:khaled_flutter/screens/craftsman/signup/signup_step2_screen.dart';
import 'package:khaled_flutter/screens/settings/settings_screen.dart';
import 'package:khaled_flutter/screens/auth/login_screen.dart';
import 'package:khaled_flutter/screens/auth/phone_login_screen.dart';
import 'package:khaled_flutter/screens/home/home_screen.dart';
import 'package:khaled_flutter/screens/offers/offers_screen.dart';
import 'package:khaled_flutter/screens/search/search_screen.dart';

/// (اسم الصورة بـ design/، الـ widget). أضف شاشات هون.
CraftsmanSignupDraft _draft() => CraftsmanSignupDraft()
  ..businessName = 'رضا'
  ..city = 'دمشق'
  ..districts.addAll(['المزة'])
  ..services.addAll(['التكييف'])
  ..specialties['التكييف'] = {'تصليح براد'}
  ..years = '4'
  ..transport = craftsmanTransportOptions.first
  ..workshopAddress = 'عنوان'
  ..bio = 'نبذة';

Future<void> _tap(
  WidgetTester t,
  String text, {
  bool scrollChips = false,
}) async {
  if (scrollChips) {
    await t.scrollUntilVisible(
      find.textContaining(text),
      150,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.left,
      ),
    );
  }
  await t.tap(find.textContaining(text).first);
  await t.pumpAndSettle();
}

Future<void> _tapExact(WidgetTester t, String text) async {
  await t.tap(find.text(text).first);
  await t.pumpAndSettle();
}

Future<void> _field(WidgetTester t, int i, String v) async {
  await t.enterText(find.byType(TextField).at(i), v);
  await t.pump();
}

Future<void> _coStep1(WidgetTester t) async {
  await _field(t, 0, 'عرض خاص');
  await _field(t, 1, 'وصف العرض');
  await _tapExact(t, 'اختر نوع الخدمة');
  await t.tap(find.text('الكهرباء').last);
  await t.pumpAndSettle();
  await _tapExact(t, 'المتابعة');
}

Future<void> _coStep2(WidgetTester t) async {
  await _coStep1(t);
  await _field(t, 0, '100');
  await _tapExact(t, 'إضغط لإضافة صور');
  await _tapExact(t, 'المتابعة');
}

Future<void> _coStep3(WidgetTester t) async {
  await _coStep2(t);
  await t.tap(find.byType(AppCheckbox).first);
  await t.pumpAndSettle();
  await _tapExact(t, 'المتابعة');
}

Future<void> _sendOfferSheet(WidgetTester t) async {
  verificationNotifier.value = VerificationStatus.verified;
  await _tapExact(t, 'تقديم عرض');
}

/// خطوات بعد فتح الشاشة (تابات/فلاتر)، بالاسم.
final _prep = <String, Future<void> Function(WidgetTester)>{
  '24_dark_craftsman_profile': (t) => _tap(t, 'معرض الأعمال'),
  '41_cr_sending_offer': _sendOfferSheet,
  '42_cr_confirm_offer': (t) async {
    await _sendOfferSheet(t);
    await _field(t, 0, '100');
    await _tapExact(t, 'إرسال العرض');
  },
  '60_cr_ignore_dialog': (t) => _tapExact(t, 'التواصل عبر واتساب'),
  '47_cr_update_status': (t) => _tapExact(t, 'تحديث الحالة'),
  '56_cr_verification_needed': (t) => _tapExact(t, 'توثيق حسابي'),
  '57_cr_verification_uploaded': (t) async {
    await _tapExact(t, 'توثيق حسابي');
    await _tapExact(t, 'ارفع صورة الوجه الأمامي للهوية');
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
  },
  '58_cr_logout': (t) => _tapExact(t, 'تسجيل الخروج'),
  '48_cr_create_offer_step2': _coStep1,
  '49_cr_create_offer_step3': _coStep2,
  '50_cr_date_picking': (t) async {
    await _coStep1(t);
    await _tapExact(t, 'يوم / شهر / سنة');
  },
  '76_cr_create_offer_step4': _coStep3,
  '51_cr_create_offer_done': (t) async {
    await _coStep3(t);
    await _tapExact(t, 'إنشاء العرض');
  },
  '72_rating_dialog': (t) => _tapExact(t, 'تقييم الخدمة'),
  '75_update_status_dialog': (t) => _tapExact(t, 'تحديث الحالة'),
  '73_cancel_request_dialog': (t) async {
    await _tapExact(t, 'تحديث الحالة');
    await _tapExact(t, 'إلغاء الطلب');
  },
  '68_my_requests_done': (t) => _tap(t, 'مكتملة', scrollChips: true),
  '69_my_requests_canceled': (t) => _tap(t, 'ملغاة', scrollChips: true),
  '06_craftsman_profile_works': (t) => _tap(t, 'معرض الأعمال'),
  '55_cr_public_profile': (t) => _tap(t, 'معرض الأعمال'),
  '39_cr_available_requests': (t) => _tap(t, 'الطلبات المتاحة'),
  '44_cr_requests_completed': (t) => _tap(t, 'مكتمل (', scrollChips: true),
  '45_cr_requests_cancelled': (t) => _tap(t, 'ملغاة', scrollChips: true),
};

final _screens = <(String, Widget Function())>[
  // زبون (صور design/ الموجودة)
  (
    '02_service_details',
    () => const ServiceDetailsScreen(details: sampleServiceDetails),
  ),
  (
    '04_offer_details',
    () => const OfferDetailsScreen(),
  ),
  (
    '06_craftsman_profile_works',
    () => const CraftsmanProfileScreen(profile: sampleCraftsmanProfile),
  ),
  ('09_request_step1_empty', () => const NewRequestScreen()),
  (
    '11_request_step2_empty',
    () => nr.RequestDetailsScreen(draft: RequestDraft()),
  ),
  (
    '13_request_step3_location',
    () => RequestLocationScreen(draft: RequestDraft()),
  ),
  (
    '15_craftsman_targeting',
    () => const CraftsmanTargetingScreen(craftsmen: targetableCraftsmen),
  ),
  ('16_request_sent', () => const RequestSentScreen()),
  ('22_otp_verify', () => const OtpScreen(phone: '+963 993 930 716')),
  ('62_notif_settings', () => const NotificationSettingsScreen()),
  ('63_notifications', () => const NotificationsScreen()),
  ('64_messages', () => const msgs.MessagesScreen()),
  ('65_chat', () => ChatScreen(conversation: sampleConversations[1])),
  (
    '66_chat_first',
    () => ChatScreen(conversation: sampleConversations[1], firstTime: true),
  ),
  ('67_profile', () => const ProfileScreen()),
  ('68_my_requests_done', () => const MyRequestsScreen()),
  ('69_my_requests_canceled', () => const MyRequestsScreen()),
  (
    '70_request_offers_tab',
    () => mr.RequestDetailsScreen(
      request: sampleActiveRequests[0],
      initialTab: 1,
    ),
  ),
  (
    '71_request_details_open',
    () => mr.RequestDetailsScreen(request: sampleActiveRequests[0]),
  ),
  (
    '72_rating_dialog',
    () => mr.RequestDetailsScreen(request: sampleDoneRequests[0]),
  ),
  ('75_update_status_dialog', () => const MyRequestsScreen()),
  ('73_cancel_request_dialog', () => const MyRequestsScreen()),
  (
    '24_dark_craftsman_profile',
    () => const CraftsmanProfileScreen(profile: sampleCraftsmanProfile),
  ),
  ('25_dark_request_step1', () => const NewRequestScreen()),
  // مهني
  (
    '41_cr_sending_offer',
    () => CraftsmanRequestDetailsScreen(request: sampleAvailableRequests.first),
  ),
  (
    '42_cr_confirm_offer',
    () => CraftsmanRequestDetailsScreen(request: sampleAvailableRequests.first),
  ),
  (
    '60_cr_ignore_dialog',
    () => CraftsmanRequestDetailsScreen(request: sampleAvailableRequests.first),
  ),
  ('47_cr_update_status', () => const CraftsmanHomeScreen(initialTab: 1)),
  (
    '56_cr_verification_needed',
    () => Builder(
      builder: (c) => Scaffold(
        backgroundColor: Theme.of(c).extension<AppColors>()!.pageAlt,
        body: const CraftsmanProfileTab(),
      ),
    ),
  ),
  (
    '57_cr_verification_uploaded',
    () => Builder(
      builder: (c) => Scaffold(
        backgroundColor: Theme.of(c).extension<AppColors>()!.pageAlt,
        body: const CraftsmanProfileTab(),
      ),
    ),
  ),
  ('58_cr_logout', () => const SettingsScreen(craftsmanMode: true)),
  ('48_cr_create_offer_step2', () => const CreateOfferScreen()),
  ('49_cr_create_offer_step3', () => const CreateOfferScreen()),
  ('50_cr_date_picking', () => const CreateOfferScreen()),
  ('51_cr_create_offer_done', () => const CreateOfferScreen()),
  ('76_cr_create_offer_step4', () => const CreateOfferScreen()),
  ('74_cr_home', () => const CraftsmanHomeScreen()),
  ('34_cr_signup1', () => const SignupStep1Screen()),
  ('36_cr_signup3', () => SignupStep3Screen(draft: _draft())),
  ('37_cr_signup4', () => SignupStep4Screen(draft: _draft())),
  ('38_cr_signup_review', () => SignupReviewScreen(draft: _draft())),
  ('39_cr_available_requests', () => const CraftsmanHomeScreen(initialTab: 1)),
  (
    '40_cr_request_details',
    () => CraftsmanRequestDetailsScreen(request: sampleAvailableRequests.first),
  ),
  ('43_cr_my_requests', () => const CraftsmanHomeScreen(initialTab: 1)),
  ('44_cr_requests_completed', () => const CraftsmanHomeScreen(initialTab: 1)),
  ('45_cr_requests_cancelled', () => const CraftsmanHomeScreen(initialTab: 1)),
  (
    '46_cr_task_details',
    () => CraftsmanRequestDetailsScreen(
      request: sampleCraftsmanTasks.first,
      offerSent: true,
    ),
  ),
  (
    '52_cr_chat',
    () => ChatScreen(
      conversation: sampleCustomerConversations.first,
      craftsmanMode: true,
    ),
  ),
  (
    '53_cr_chat_first',
    () => ChatScreen(
      conversation: sampleCustomerConversations.first,
      firstTime: true,
      craftsmanMode: true,
    ),
  ),
  (
    '54_cr_profile',
    () => Builder(
      builder: (c) => Scaffold(
        backgroundColor: Theme.of(c).extension<AppColors>()!.pageAlt,
        body: const CraftsmanProfileTab(),
      ),
    ),
  ),
  (
    '55_cr_public_profile',
    () => const CraftsmanProfileScreen(
      profile: sampleCraftsmanProfile,
      selfView: true,
    ),
  ),
  ('59_cr_notif_settings', () => const NotificationSettingsScreen()),
  ('61_cr_notifications', () => const NotificationsScreen()),
  ('01_home', () => const HomeScreen()),
  ('03_offers', () => const OffersScreen()),
  ('07_search_suggestions', () => const SearchScreen()),
  ('17_login_account_type', () => const LoginScreen()),
  ('18_customer_login_empty', () => const CustomerLoginScreen()),
  ('23_phone_login', () => const PhoneLoginScreen()),
  ('32_settings', () => const SettingsScreen()),
  ('33_my_requests_active', () => const MyRequestsScreen()),
  // المهني
  (
    '26_cr_my_offers_empty',
    () => Builder(
      builder: (c) => Scaffold(
        backgroundColor: Theme.of(c).extension<AppColors>()!.pageAlt,
        body: const MyOffersTab(),
      ),
    ),
  ),
  ('27_cr_messages', () => const msgs.MessagesScreen(craftsmanMode: true)),
  ('28_cr_create_offer_step1', () => const CreateOfferScreen()),
  ('29_cr_settings', () => const SettingsScreen(craftsmanMode: true)),
  ('30_cr_edit_profile', () => const EditCraftsmanProfileScreen()),
  (
    '31_cr_edit_services',
    () => SignupStep2Screen(
      draft: CraftsmanSignupDraft()
        ..services.addAll(['التكييف', 'الكهرباء', 'السباكة'])
        ..specialties['التكييف'] = {'تبديل وصيانة الضواغط'},
      editing: true,
    ),
  ),
];

Future<ui.Size> _designSize(String name) async {
  final bytes = File('design/$name.png').readAsBytesSync();
  final codec = await ui.instantiateImageCodec(bytes);
  final f = await codec.getNextFrame();
  return ui.Size(f.image.width.toDouble(), f.image.height.toDouble());
}

void main() {
  for (final (name, build) in _screens) {
    testWidgets(name, (tester) async {
      final plex = FontLoader('IBMPlexSansArabic');
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        plex.addFont(rootBundle.load('assets/fonts/IBMPlexSansArabic-$w.ttf'));
      }
      await plex.load();
      verificationNotifier.value = VerificationStatus.none;
      final root = Platform.environment['FLUTTER_ROOT']!;
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File(
                '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
              ).readAsBytesSync(),
            ),
          ),
        );
      await icons.load();
      final size = await tester.runAsync(() => _designSize(name));
      tester.view.physicalSize = Size(size!.width * 2, size.height * 2);
      tester.view.devicePixelRatio = 2;
      tester.view.padding = const FakeViewPadding(top: 64, bottom: 32);
      await tester.runAsync(
        () => tester.pumpWidget(
          AppProviders(
            dependencies: AppDependencies.fake(),
            child: MaterialApp(
              theme: name.contains('_dark_') ? AppTheme.dark : AppTheme.light,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: KeyedSubtree(key: UniqueKey(), child: build()),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final e in find.byType(Image).evaluate()) {
          await precacheImage((e.widget as Image).image, e);
        }
      });
      await tester.pump(const Duration(seconds: 1));
      final prep = _prep[name];
      if (prep != null) await prep(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('rtl/$name.png'),
      );
    });
  }
}
