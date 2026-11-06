import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/data/repositories/reports_ratings_repository.dart';

void main() {
  test('reportInput بيبني JSON بنفس مفاتيح الموقع', () {
    final json = jsonDecode(
      reportInput(
        targetType: 'proposal',
        targetId: 'p1',
        category: ReportCategory.reliability,
        reason: reportReasons[ReportCategory.reliability]!.first,
        details: '  تأخر كتير  ',
      ),
    );
    expect(json, {
      'targetType': 'proposal',
      'targetId': 'p1',
      'category': 'reliability',
      'reason': 'did_not_show_up',
      'details': 'تأخر كتير',
    });
  });

  test('الأهلية: canReport والفئات المبلّغ عنها', () {
    final e = reportEligibilityFromJson({
      'canReport': true,
      'reportedCategories': ['pricing', null],
    });
    expect(e.canReport, isTrue);
    expect(e.reportedCategories, ['pricing']);
    expect(reportEligibilityFromJson({'canReport': false}).canReport, isFalse);
  });

  test('تحويل التقييم', () {
    final r = professionalRatingFromJson({
      'feedback_id': 'f1',
      'overall_rating': 9,
      'written_feedback': 'ممتاز',
      'customer_name': 'سعيد',
      'submitted_at': '2026-08-05T10:00:00Z',
    });
    expect(r.stars, 5);
    expect(r.reviewer, 'سعيد');
    expect(r.text, 'ممتاز');
    expect(r.date, contains('2026'));
    expect(professionalRatingFromJson({}).reviewer, 'زبون');
  });

  test('ratingItems بيقبل قائمة أو كائن متداخل أو نص فاضي', () {
    expect(ratingItems('[]'), isEmpty);
    expect(ratingItems(jsonEncode([{'feedback_id': 'a'}])).length, 1);
    expect(ratingItems(jsonEncode({'ratings': [{'feedback_id': 'a'}]})).length, 1);
  });
}
