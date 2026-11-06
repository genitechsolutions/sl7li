import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/arabic_search.dart';

void main() {
  test('تجاهل التشكيل وتوحيد الألف', () {
    expect(arabicContains('أحمد النجّار', 'احمد'), isTrue);
    expect(arabicContains('إسراء', 'اسراء'), isTrue);
    expect(arabicContains('مَاهِر', 'ماهر'), isTrue);
    expect(arabicContains('محمد', 'خالد'), isFalse);
    expect(arabicContains('محمد', '  '), isTrue);
  });
}
