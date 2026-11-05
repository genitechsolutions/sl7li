import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/gql_proposal_actions.dart';
import 'package:khaled_flutter/data/repositories/requests_repository.dart';

void main() {
  test('متغيرات تقييم الزبون = عدد النجوم بكل المحاور', () {
    final v = customerFeedbackVariables(
      'j1',
      proposalId: 'p1',
      professionalId: 'u1',
      stars: 5,
      comment: '  ممتاز ',
      now: DateTime.utc(2026, 11, 5, 10),
    );
    expect(v['jobId'], 'j1');
    expect(v['overallRating'], 5);
    expect(v['platformRating'], 5);
    expect(v['recommendProfessional'], true);
    expect(v['writtenFeedback'], 'ممتاز');
    expect(v['submittedAt'], '2026-11-05T10:00:00.000Z');
  });

  test('تعليق فاضي وتقييم منخفض', () {
    final v = customerFeedbackVariables(
      'j1',
      stars: 2,
      comment: ' ',
      now: DateTime.utc(2026),
    );
    expect(v['writtenFeedback'], isNull);
    expect(v['recommendProfessional'], false);
    expect(v['proposalId'], isNull);
  });

  test('مستند سحب العرض فيه isWithdrawal', () {
    expect(GqlProposalActions.withdrawProposal, contains(r'$isWithdrawal'));
  });
}
