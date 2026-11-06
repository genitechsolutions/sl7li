import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/gql_job_lifecycle.dart';
import 'package:khaled_flutter/cubits/job_lifecycle_cubit.dart';
import 'package:khaled_flutter/data/repositories/job_lifecycle_repository.dart';
import 'package:khaled_flutter/data/repositories/requests_repository.dart';
import 'package:khaled_flutter/screens/craftsman/requests/task_dialogs.dart';

class _Recorder extends FakeJobLifecycleRepository {
  final calls = <String>[];

  @override
  Future<void> markDone(String jobId, {String? proposalId, String? professionalId}) async =>
      calls.add('done:$jobId:$proposalId');

  @override
  Future<void> resolveClaim(String proposalId, {required bool approve}) async =>
      calls.add('resolve:$proposalId:$approve');

  @override
  Future<void> startWork(String jobId) async => throw Exception('x');
}

void main() {
  test('متغيرات إنجاز المهني بنفس أسماء الخلفية', () {
    final v = claimCompletedVariables(
      'j1',
      'p1',
      const CompletionInput(
        earnings: 100000,
        clientRating: 4,
        accuracy: JobAccuracy.somewhatDifferent,
        notes: '  تمام ',
      ),
      DateTime.utc(2026, 11, 6, 9),
    );
    expect(v['actualEarnings'], 100000);
    expect(v['earningsCurrency'], 'SYP');
    expect(v['userRating'], 4);
    expect(v['jobAccuracy'], 'somewhat_different');
    expect(v['recommendClient'], true);
    expect(v['notes'], 'تمام');
    expect(v['completedAt'], '2026-11-06T09:00:00.000Z');
  });

  test('قيم دقة العمل مطابقة للخلفية', () {
    expect(JobAccuracy.values.map((a) => a.code), ['close', 'somewhat_different', 'very_different']);
  });

  test('تقييم منخفض = ما بنوصي بالزبون وتعليق فاضي = null', () {
    final v = claimCompletedVariables(
      'j',
      'p',
      const CompletionInput(earnings: 1, clientRating: 2, notes: ' '),
      DateTime.utc(2026),
    );
    expect(v['recommendClient'], false);
    expect(v['notes'], isNull);
  });

  test('رسائل أخطاء الدورة بالعربي', () {
    expect(lifecycleErrorMessage('CLAIM_ERR:ALREADY_APPROVED_OTHER_PRO'), contains('مهني آخر'));
    expect(
      lifecycleErrorMessage('Can only reopen jobs with status professional_selected'),
      contains('تعيد فتح'),
    );
    expect(lifecycleErrorMessage('شي غير معروف'), 'شي غير معروف');
  });

  test('العرض بيحمل الطلب المعلّق من المهني', () {
    final o = requestOfferFromJson({
      'proposal_id': 'p1',
      'status': 'approved',
      'claim_state': 'pending',
      'claim_status': 'completed',
      'quote_amount': 100000,
    });
    expect(o.pendingClaim, 'completed');
    expect(o.isApproved, true);
    final none = requestOfferFromJson({'proposal_id': 'p2', 'status': 'submitted', 'claim_state': 'rejected'});
    expect(none.pendingClaim, isNull);
  });

  test('اسم المهني المختار من عروض الطلب', () {
    final r = myRequestFromJson({
      'job_id': 'j1',
      'status': 'professional_selected',
      'selected_professional_id': 'u2',
      'proposals': [
        {'professional_id': 'u1', 'professional_name': 'أول'},
        {'professional_id': 'u2', 'professional_name': 'ثاني'},
      ],
    });
    expect(r.craftsmanName, 'ثاني');
    expect(r.stage, 1);
    expect(myRequestFromJson({'job_id': 'j2', 'status': 'open'}).hasCraftsman, false);
  });

  test('المبلغ الافتراضي من سعر العرض', () {
    final fixed = requestOfferFromJson({'quote_amount': 100000, 'pricing_type': 'fixed'});
    expect(quoteAmountOf(fixed), '100000');
    final range = requestOfferFromJson({
      'quote_amount': 50000,
      'quote_amount_max': 80000,
      'pricing_type': 'range',
    });
    expect(quoteAmountOf(range), '80000');
    expect(quoteAmountOf(null), '');
  });

  test('مستندات الدورة فيها كل العمليات', () {
    expect(GqlJobLifecycle.updateJobStatus, contains('updateJobStatusSecure'));
    expect(GqlJobLifecycle.claimJobCompleted, contains(r'$jobAccuracy: String!'));
    expect(GqlJobLifecycle.resolveProposalClaim, contains(r'$decision'));
    expect(GqlJobLifecycle.reopenJobSelection, contains('reopenJobSelectionSecure'));
  });

  test('الـ cubit بيمرّر الإجراءات وبيرجّع busy=false حتى مع الخطأ', () async {
    final repo = _Recorder();
    final cubit = JobLifecycleCubit(repo);
    await cubit.markDone('j', proposalId: 'p');
    await cubit.resolveClaim('p', approve: false);
    expect(repo.calls, ['done:j:p', 'resolve:p:false']);
    await expectLater(cubit.startWork('j'), throwsException);
    expect(cubit.state, false);
    await cubit.close();
  });
}
