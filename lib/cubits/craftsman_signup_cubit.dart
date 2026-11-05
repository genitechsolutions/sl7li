import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/backend/backend_exception.dart';
import '../data/craftsman_signup.dart';
import '../data/repositories/craftsman_signup_repository.dart';

enum SignupStatus { idle, submitting, success, failure }

class CraftsmanSignupState extends Equatable {
  const CraftsmanSignupState({this.status = SignupStatus.idle, this.error});

  final SignupStatus status;
  final String? error;

  @override
  List<Object?> get props => [status, error];
}

/// إرسال تسجيل المهني (زر "تأكيد إنشاء الحساب").
class CraftsmanSignupCubit extends Cubit<CraftsmanSignupState> {
  CraftsmanSignupCubit(this._repo) : super(const CraftsmanSignupState());

  final CraftsmanSignupRepository _repo;

  Future<void> submit(CraftsmanSignupDraft draft) async {
    if (state.status == SignupStatus.submitting) return;
    emit(const CraftsmanSignupState(status: SignupStatus.submitting));
    try {
      await _repo.submit(draft);
      emit(const CraftsmanSignupState(status: SignupStatus.success));
    } on BackendException catch (e) {
      emit(CraftsmanSignupState(status: SignupStatus.failure, error: e.message));
    } on Object {
      emit(
        const CraftsmanSignupState(
          status: SignupStatus.failure,
          error: 'تعذّر إنشاء الحساب، حاول مرة ثانية',
        ),
      );
    }
  }
}
