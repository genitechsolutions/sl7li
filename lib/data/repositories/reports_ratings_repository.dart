import 'dart:convert';

import '../../core/backend/gql_reports_ratings.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';

/// فئات الإبلاغ وأسبابها (نفس قيم الموقع).
enum ReportCategory {
  pricing('pricing', 'مشكلة في السعر'),
  reliability('reliability', 'مشكلة في الالتزام');

  const ReportCategory(this.value, this.label);
  final String value;
  final String label;
}

class ReportReason {
  const ReportReason(this.value, this.label);
  final String value;
  final String label;

  bool get needsDetails => value == 'other';
}

const reportDetailsMin = 10;
const reportDetailsMax = 1000;

const reportReasons = {
  ReportCategory.pricing: [
    ReportReason('price_far_above_market', 'السعر أعلى بكثير من سعر السوق'),
    ReportReason('price_suspiciously_low', 'السعر منخفض بشكل مريب'),
    ReportReason('price_changed_after_agreement', 'تم تغيير السعر بعد الاتفاق'),
    ReportReason('hidden_extra_fees', 'رسوم إضافية لم يتم ذكرها'),
    ReportReason('other', 'سبب آخر (يرجى التوضيح)'),
  ],
  ReportCategory.reliability: [
    ReportReason('did_not_show_up', 'لم يحضر إطلاقاً'),
    ReportReason('arrived_late', 'تأخر عن الموعد'),
    ReportReason('cancelled_last_minute', 'ألغى في اللحظة الأخيرة'),
    ReportReason('unresponsive', 'لا يرد على التواصل'),
    ReportReason('unprofessional_conduct', 'سلوك غير مهني'),
    ReportReason('other', 'سبب آخر (يرجى التوضيح)'),
  ],
};

class ReportEligibility {
  const ReportEligibility({this.canReport = true, this.reportedCategories = const []});
  final bool canReport;
  final List<String> reportedCategories;
}

/// الإبلاغ عن عرض مهني (الهدف `proposal` أو `offer`).
abstract class ServiceReportsRepository {
  Future<ReportEligibility> eligibility(String targetType, String targetId);

  Future<void> create({
    required String targetType,
    required String targetId,
    required ReportCategory category,
    required ReportReason reason,
    String details = '',
  });
}

class FakeServiceReportsRepository implements ServiceReportsRepository {
  const FakeServiceReportsRepository();

  @override
  Future<ReportEligibility> eligibility(String targetType, String targetId) async =>
      const ReportEligibility();

  @override
  Future<void> create({
    required String targetType,
    required String targetId,
    required ReportCategory category,
    required ReportReason reason,
    String details = '',
  }) async {}
}

class RemoteServiceReportsRepository implements ServiceReportsRepository {
  const RemoteServiceReportsRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<ReportEligibility> eligibility(String targetType, String targetId) async {
    final data = await _gateway.run(
      GqlReportsRatings.eligibility,
      variables: {'targetType': targetType, 'targetId': targetId},
    );
    final res = asMap(data['getServiceReportEligibility']);
    throwIfBackendError(res);
    return reportEligibilityFromJson(res);
  }

  @override
  Future<void> create({
    required String targetType,
    required String targetId,
    required ReportCategory category,
    required ReportReason reason,
    String details = '',
  }) async {
    final data = await _gateway.run(
      GqlReportsRatings.createReport,
      variables: {
        'input': reportInput(
          targetType: targetType,
          targetId: targetId,
          category: category,
          reason: reason,
          details: details,
        ),
      },
      mutation: true,
    );
    throwIfBackendError(asMap(data['createServiceReportSecure']));
  }
}

ReportEligibility reportEligibilityFromJson(Map<String, dynamic> m) =>
    ReportEligibility(
      canReport: m['canReport'] != false,
      reportedCategories: [
        for (final c in (m['reportedCategories'] as List? ?? const []))
          if (c != null) '$c',
      ],
    );

/// نص AWSJSON لمدخل `createServiceReportSecure`.
String reportInput({
  required String targetType,
  required String targetId,
  required ReportCategory category,
  required ReportReason reason,
  String details = '',
}) => jsonEncode({
  'targetType': targetType,
  'targetId': targetId,
  'category': category.value,
  'reason': reason.value,
  'details': details.trim(),
});

/// تقييم واحد وصل للمهني.
class ProfessionalRating {
  const ProfessionalRating({
    required this.reviewer,
    required this.stars,
    required this.text,
    required this.date,
    this.id,
    this.jobTitle,
  });

  final String? id;
  final String reviewer;
  final int stars;
  final String text;
  final String date;
  final String? jobTitle;
}

abstract class ProfessionalRatingsRepository {
  Future<List<ProfessionalRating>> load();
}

class FakeProfessionalRatingsRepository implements ProfessionalRatingsRepository {
  const FakeProfessionalRatingsRepository();

  @override
  Future<List<ProfessionalRating>> load() async => const [
    ProfessionalRating(
      reviewer: 'أحمد محمد',
      stars: 5,
      text: 'شغل ممتاز والتزام بالموعد، أنصح فيه.',
      date: '5 آب 2026',
    ),
    ProfessionalRating(
      reviewer: 'سارة علي',
      stars: 4,
      text: 'تعامل راقي، والنتيجة حلوة.',
      date: '28 تموز 2026',
    ),
  ];
}

class RemoteProfessionalRatingsRepository implements ProfessionalRatingsRepository {
  const RemoteProfessionalRatingsRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<List<ProfessionalRating>> load() async {
    final data = await _gateway.run(GqlReportsRatings.ratings, variables: {'limit': 50});
    final res = asMap(data['getRatingsForProfessional']);
    throwIfBackendError(res);
    return [for (final r in ratingItems(res['ratings'])) professionalRatingFromJson(r)];
  }
}

/// `ratings` ممكن يجي قائمة أو كائن فيه `ratings`/`items`.
List<Map<String, dynamic>> ratingItems(Object? raw) {
  final list = asMapList(raw);
  if (list.isNotEmpty) return list;
  final nested = asMap(raw)['ratings'];
  return nested == null ? const [] : asMapList(nested);
}

/// JSON (نموذج CustomerFeedback + اسم الزبون) ← تقييم للعرض.
ProfessionalRating professionalRatingFromJson(Map<String, dynamic> m) {
  final stars = (intOf(m, 'overall_rating') ?? intOf(m, 'rating') ?? 0).clamp(0, 5);
  return ProfessionalRating(
    id: str(m, 'feedback_id'),
    reviewer:
        str(m, 'customer_name') ?? str(m, 'reviewer_name') ?? str(m, 'customerName') ?? 'زبون',
    stars: stars,
    text: str(m, 'written_feedback') ?? str(m, 'comment') ?? '',
    date: arabicDate(str(m, 'submitted_at') ?? str(m, 'createdAt')),
    jobTitle: str(m, 'job_title'),
  );
}
