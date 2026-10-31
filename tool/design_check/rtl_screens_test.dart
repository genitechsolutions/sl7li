// يرسم شاشات التطبيق لـ test/_tmp/rtl/*.png بنفس حجم صور التصميم، وبعدين tool/design_check/run_rtl.sh بيقارنهم.
// بيشتغل بس عبر run_rtl.sh (بينسخه لـ test/_tmp).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/theme/app_theme.dart';
import 'package:khaled_flutter/screens/auth/customer_login_screen.dart';
import 'package:khaled_flutter/screens/auth/login_screen.dart';
import 'package:khaled_flutter/screens/auth/phone_login_screen.dart';
import 'package:khaled_flutter/screens/home/home_screen.dart';
import 'package:khaled_flutter/screens/offers/offers_screen.dart';
import 'package:khaled_flutter/screens/search/search_screen.dart';

/// (اسم الصورة بـ design/، الـ widget). أضف شاشات هون.
final _screens = <(String, Widget Function())>[
  ('01_home', () => const HomeScreen()),
  ('03_offers', () => const OffersScreen()),
  ('07_search_suggestions', () => const SearchScreen()),
  ('17_login_account_type', () => const LoginScreen()),
  ('18_customer_login_empty', () => const CustomerLoginScreen()),
  ('23_phone_login', () => const PhoneLoginScreen()),
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
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('rtl/$name.png'),
      );
    });
  }
}
