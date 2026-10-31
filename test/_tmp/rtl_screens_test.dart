// يرسم شاشات التطبيق لـ test/_tmp/rtl/*.png بنفس حجم صور التصميم، وبعدين tool/design_check/run_rtl.sh بيقارنهم.
// بيشتغل بس عبر run_rtl.sh (بينسخه لـ test/_tmp).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/theme/app_colors.dart';
import 'package:khaled_flutter/core/theme/app_theme.dart';
import 'package:khaled_flutter/data/chat_data.dart';
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
import 'package:khaled_flutter/screens/new_request/request_confirm_screen.dart';
import 'package:khaled_flutter/screens/new_request/request_details_screen.dart'
    as nr;
import 'package:khaled_flutter/screens/new_request/request_location_screen.dart';
import 'package:khaled_flutter/screens/new_request/request_sent_screen.dart';
import 'package:khaled_flutter/screens/notifications/notifications_screen.dart';
import 'package:khaled_flutter/screens/offer_details/offer_details_screen.dart';
import 'package:khaled_flutter/screens/service_details/service_details_screen.dart';
import 'package:khaled_flutter/screens/settings/notification_settings_screen.dart';
import 'package:khaled_flutter/screens/auth/customer_login_screen.dart';
import 'package:khaled_flutter/screens/craftsman/offers/create_offer_screen.dart';
import 'package:khaled_flutter/screens/craftsman/offers/my_offers_tab.dart';
import 'package:khaled_flutter/screens/craftsman/profile/edit_profile_screen.dart';
import 'package:khaled_flutter/screens/craftsman/signup/signup_step2_screen.dart';
import 'package:khaled_flutter/screens/messages/messages_screen.dart';
import 'package:khaled_flutter/screens/my_requests/my_requests_screen.dart';
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

Future<void> _tap(WidgetTester t, String text) async {
  await t.tap(find.textContaining(text).first);
  await t.pumpAndSettle();
}

/// خطوات بعد فتح الشاشة (تابات/فلاتر)، بالاسم.
final _prep = <String, Future<void> Function(WidgetTester)>{
  '39_cr_available_requests': (t) => _tap(t, 'الطلبات المتاحة'),
  '44_cr_requests_completed': (t) => _tap(t, 'مكتملة'),
  '45_cr_requests_cancelled': (t) => _tap(t, 'ملغاة'),
};

final _screens = <(String, Widget Function())>[
  // زبون (صور design/ الموجودة)
  (
    '02_service_details',
    () => const ServiceDetailsScreen(details: sampleServiceDetails),
  ),
  (
    '04_offer_details',
    () => const OfferDetailsScreen(details: sampleOfferDetails),
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
  // مهني
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
  ('27_cr_messages', () => const MessagesScreen(craftsmanMode: true)),
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
          MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: KeyedSubtree(key: UniqueKey(), child: build()),
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
