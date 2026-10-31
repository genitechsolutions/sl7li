// قالب لرسم شاشة لصورة PNG ومقارنتها بالتصميم (مش test حقيقي، ما بيشتغل لحاله).
//
// الاستعمال:
//   1. انسخه لـ test/_tmp/x_test.dart
//   2. عدّل الـ Size (طول صورة التصميم) وخطوات التنقل تحت "التنقل للشاشة".
//   3. flutter test test/_tmp/x_test.dart --update-goldens   ← بيطلع test/_tmp/shot.png بـ 2x
//   4. قارن بـ tool/design_check/measure.py (مع --scale 2 للـ render)
//   5. امسح مجلد test/ بعد ما تخلص.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/main.dart';

Future<void> _precacheImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('screenshot', (tester) async {
    // الخطوط الحقيقية (بدونها الـ test بيرسم مربعات).
    final plex = FontLoader('IBMPlexSansArabic');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      plex.addFont(rootBundle.load('assets/fonts/IBMPlexSansArabic-$w.ttf'));
    }
    await plex.load();
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
    await icons.load();

    // عرض 412 متل Figma، والطول = طول صورة التصميم. شريط الحالة 32 تحت 16.
    tester.view.physicalSize = const Size(412 * 2, 893 * 2);
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding(top: 64, bottom: 32);

    await tester.runAsync(() => tester.pumpWidget(const App()));
    await _precacheImages(tester);

    // ── التنقل للشاشة ── مثال: كرت "الدهانات" بيفتح تفاصيل الخدمة.
    await tester.tap(find.text('الدهانات').first);
    await tester.pumpAndSettle();
    await _precacheImages(tester);

    await expectLater(find.byType(App), matchesGoldenFile('shot.png'));
  });
}
