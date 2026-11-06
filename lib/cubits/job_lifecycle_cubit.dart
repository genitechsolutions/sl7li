import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/job_lifecycle_repository.dart';
import 'feature_cubits.dart';

/// إجراءات دورة حياة الطلب (زبون + مهني). الحالة = شغّال بعملية أو لا.
class JobLifecycleCubit extends Cubit<bool> {
  JobLifecycleCubit(this._repo) : super(false);

  final JobLifecycleRepository _repo;

  Future<void> _busy(Future<void> Function() run) async {
    emit(true);
    try {
      await run();
    } finally {
      emit(false);
    }
  }

  Future<void> markDone(String jobId, {String? proposalId, String? professionalId}) =>
      _busy(() => _repo.markDone(jobId, proposalId: proposalId, professionalId: professionalId));

  Future<void> resolveClaim(String proposalId, {required bool approve}) =>
      _busy(() => _repo.resolveClaim(proposalId, approve: approve));

  Future<void> reopen(String jobId) => _busy(() => _repo.reopen(jobId));

  Future<void> claimSelected(String jobId, String proposalId) =>
      _busy(() => _repo.claimSelected(jobId, proposalId));

  Future<void> startWork(String jobId) => _busy(() => _repo.startWork(jobId));

  Future<void> claimDone(String jobId, String proposalId, CompletionInput input) =>
      _busy(() => _repo.claimDone(jobId, proposalId, input));
}

/// تحديث القوائم بعد إجراء بدورة الحياة؛ المهني بيحدّث كمان الأرباح.
Future<void> refreshAfterLifecycle(BuildContext context, {required bool professional}) async {
  if (professional) {
    context.read<EarningsCubit>().load(force: true);
    await context.read<CraftsmanJobsCubit>().load(force: true);
  } else {
    await context.read<MyRequestsCubit>().load(force: true);
  }
}
