import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/widgets/arc_progress.dart';

const _track = Color(0xFFC4C8E5);
const _blue = Color(0xFF2695D0);

/// بيرسم الحلقة وبيرجّع مصفوفة ألوان (RGBA) بحجم 68x68 × [scale].
Future<({List<int> px, int w})> _render(WidgetTester tester, double value, {int scale = 4}) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: ArcProgress(value: value, trackColor: _track, progressColor: _blue),
        ),
      ),
    ),
  );
  late ui.Image image;
  late ByteData data;
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    image = await boundary.toImage(pixelRatio: scale.toDouble());
    data = (await image.toByteData())!;
  });
  final bytes = data.buffer.asUint8List();
  return (px: bytes, w: image.width);
}

bool _isBlue(List<int> b, int i) => (b[i] - 0x26).abs() < 40 && (b[i + 1] - 0x95).abs() < 40 && (b[i + 2] - 0xD0).abs() < 40 && b[i + 3] > 200;
bool _isTrack(List<int> b, int i) => (b[i] - 0xC4).abs() < 20 && (b[i + 1] - 0xC8).abs() < 20 && (b[i + 2] - 0xE5).abs() < 20 && b[i + 3] > 200;

void main() {
  testWidgets('القوس الأزرق بنفس بكسلات المسار (ما بيطلع برّاه)', (tester) async {
    final full = await _render(tester, 1);
    final part = await _render(tester, 0.67);
    final w = full.w;
    var blueInPart = 0;
    var outside = 0;
    for (var i = 0; i < part.px.length; i += 4) {
      if (!_isBlue(part.px, i)) continue;
      blueInPart++;
      final inFull = _isBlue(full.px, i) || !_isTrack(full.px, i) && full.px[i + 3] > 0;
      if (!inFull) outside++;
    }
    expect(blueInPart, greaterThan(500));
    expect(outside, 0, reason: 'بكسلات زرقا برّا شريط المسار');
    expect(w, 68 * 4);
  });

  testWidgets('طول القوس الأزرق = النسبة من المسار (67% ← 0.67 × 270°)', (tester) async {
    const scale = 4;
    final part = await _render(tester, 0.67, scale: scale);
    final w = part.w;
    final c = w / 2;
    final mid = (68 - 8) / 2 * scale; // نصف قطر منتصف السماكة
    var blue = 0;
    var track = 0;
    for (var deg = 0; deg < 360; deg++) {
      final a = deg * math.pi / 180;
      final x = (c + mid * math.cos(a)).round();
      final y = (c + mid * math.sin(a)).round();
      final i = (y * w + x) * 4;
      if (_isBlue(part.px, i)) blue++;
      if (_isTrack(part.px, i)) track++;
    }
    final total = blue + track;
    expect(total, inInclusiveRange(268, 290));
    expect(blue / total, closeTo(0.67, 0.03));
  });

  testWidgets('البداية من أسفل اليسار والفتحة بالأسفل', (tester) async {
    const scale = 4;
    final r = await _render(tester, 0.5, scale: scale);
    final c = r.w / 2;
    final mid = (68 - 8) / 2 * scale;
    bool blueAt(double deg) {
      final a = deg * math.pi / 180;
      final i = ((c + mid * math.sin(a)).round() * r.w + (c + mid * math.cos(a)).round()) * 4;
      return _isBlue(r.px, i);
    }

    bool trackAt(double deg) {
      final a = deg * math.pi / 180;
      final i = ((c + mid * math.sin(a)).round() * r.w + (c + mid * math.cos(a)).round()) * 4;
      return _isTrack(r.px, i);
    }

    expect(blueAt(180), isTrue, reason: 'يسار: أزرق');
    expect(blueAt(225), isTrue, reason: 'أعلى اليسار: أزرق');
    expect(trackAt(0), isTrue, reason: 'يمين: رمادي (بعد 50%)');
    expect(trackAt(315), isTrue, reason: 'أعلى اليمين: رمادي');
    expect(blueAt(90) || trackAt(90), isFalse, reason: 'الفتحة بالأسفل فاضية');
  });

  testWidgets('0 و100 و قيم خارج المدى ما بتكسر', (tester) async {
    for (final v in [-1.0, 0.0, 1.0, 5.0]) {
      final r = await _render(tester, v, scale: 2);
      expect(r.px.length, greaterThan(0));
    }
  });
}
