import '../../core/backend/backend_exception.dart';
import '../../core/backend/gql_job_lifecycle.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';

/// قيم `job_accuracy` عند المهني (مطابقة للخلفية).
enum JobAccuracy {
  close('close', 'قريب من الوصف'),
  somewhatDifferent('somewhat_different', 'مختلف قليلاً'),
  veryDifferent('very_different', 'مختلف كثيراً');

  const JobAccuracy(this.code, this.label);

  final String code;
  final String label;
}

/// بيانات إنجاز المهمة اللي بيرسلها المهني.
class CompletionInput {
  const CompletionInput({
    required this.earnings,
    this.currency = 'SYP',
    this.clientRating = 5,
    this.accuracy = JobAccuracy.close,
    this.notes,
  });

  final int earnings;
  final String currency;

  /// تقييم المهني للزبون (1-5).
  final int clientRating;
  final JobAccuracy accuracy;
  final String? notes;
}

/// دورة حياة الطلب: اتفاق، تنفيذ، إنجاز (مع تأكيد الطرف التاني)، إعادة فتح.
abstract class JobLifecycleRepository {
  /// الزبون: "تم إنجاز المهمة" بدون انتظار المهني (بيكمّل الطلب فوراً).
  Future<void> markDone(String jobId, {String? proposalId, String? professionalId});

  /// الزبون: قبول/رفض طلب تأكيد من المهني (اتفاق أو إنجاز).
  Future<void> resolveClaim(String proposalId, {required bool approve});

  /// الزبون: إلغاء اختيار المهني وإرجاع الطلب مفتوح.
  Future<void> reopen(String jobId);

  /// المهني: "تم الاتفاق مع الزبون" (بانتظار تأكيد الزبون).
  Future<void> claimSelected(String jobId, String proposalId);

  /// المهني: "المهمة قيد التنفيذ".
  Future<void> startWork(String jobId);

  /// المهني: "تم إنجاز المهمة" (بانتظار تأكيد الزبون، وبيسجّل الأرباح).
  Future<void> claimDone(String jobId, String proposalId, CompletionInput input);
}

class FakeJobLifecycleRepository implements JobLifecycleRepository {
  const FakeJobLifecycleRepository();

  @override
  Future<void> markDone(String jobId, {String? proposalId, String? professionalId}) async {}

  @override
  Future<void> resolveClaim(String proposalId, {required bool approve}) async {}

  @override
  Future<void> reopen(String jobId) async {}

  @override
  Future<void> claimSelected(String jobId, String proposalId) async {}

  @override
  Future<void> startWork(String jobId) async {}

  @override
  Future<void> claimDone(String jobId, String proposalId, CompletionInput input) async {}
}

class RemoteJobLifecycleRepository implements JobLifecycleRepository {
  const RemoteJobLifecycleRepository(this._gateway);

  final GraphQlGateway _gateway;

  Future<void> _run(String doc, String field, Map<String, dynamic> vars) async {
    final data = await _gateway.run(doc, variables: vars, mutation: true);
    final res = asMap(data[field]);
    final error = str(res, 'error');
    if (error != null) throw BackendException(lifecycleErrorMessage(error));
  }

  @override
  Future<void> markDone(String jobId, {String? proposalId, String? professionalId}) => _run(
    GqlJobLifecycle.markJobManualAccepted,
    'markJobManualAcceptedSecure',
    {'jobId': jobId, 'proposalId': proposalId, 'professionalId': professionalId},
  );

  @override
  Future<void> resolveClaim(String proposalId, {required bool approve}) => _run(
    GqlJobLifecycle.resolveProposalClaim,
    'resolveProposalClaimSecure',
    {'proposalId': proposalId, 'decision': approve ? 'approve' : 'reject'},
  );

  @override
  Future<void> reopen(String jobId) =>
      _run(GqlJobLifecycle.reopenJobSelection, 'reopenJobSelectionSecure', {'jobId': jobId});

  @override
  Future<void> claimSelected(String jobId, String proposalId) => _run(
    GqlJobLifecycle.claimProfessionalSelected,
    'claimProfessionalSelectedSecure',
    {'jobId': jobId, 'proposalId': proposalId},
  );

  @override
  Future<void> startWork(String jobId) => _run(
    GqlJobLifecycle.updateJobStatus,
    'updateJobStatusSecure',
    {'jobId': jobId, 'status': 'in_progress', 'updateType': 'professional'},
  );

  @override
  Future<void> claimDone(String jobId, String proposalId, CompletionInput input) => _run(
    GqlJobLifecycle.claimJobCompleted,
    'claimJobCompletedSecure',
    claimCompletedVariables(jobId, proposalId, input, DateTime.now().toUtc()),
  );
}

/// متغيرات claimJobCompletedSecure.
Map<String, dynamic> claimCompletedVariables(
  String jobId,
  String proposalId,
  CompletionInput input,
  DateTime now,
) {
  final notes = input.notes?.trim();
  return {
    'jobId': jobId,
    'proposalId': proposalId,
    'actualEarnings': input.earnings,
    'earningsCurrency': input.currency,
    'actualEarningsIncludeMaterial': false,
    'userRating': input.clientRating.clamp(1, 5),
    'jobAccuracy': input.accuracy.code,
    'notes': notes == null || notes.isEmpty ? null : notes,
    'recommendClient': input.clientRating >= 4,
    'completedAt': now.toIso8601String(),
  };
}

/// رسائل الخلفية التقنية ← عربي مفهوم.
String lifecycleErrorMessage(String error) {
  const known = {
    'ALREADY_APPROVED_OTHER_PRO': 'تم الاتفاق مع مهني آخر على هذا الطلب',
    'JOB_ALREADY_COMPLETED': 'تم إكمال هذا الطلب مسبقاً',
    'Can only reopen jobs': 'ما بتقدر تعيد فتح الطلب بعد ما يبدأ التنفيذ',
    'already closed': 'هذا الطلب مسكّر',
  };
  for (final e in known.entries) {
    if (error.contains(e.key)) return e.value;
  }
  return error;
}
