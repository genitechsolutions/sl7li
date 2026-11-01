import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/backend/backend_exception.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  /// لسا ما تحقّقنا من جلسة محفوظة.
  unknown,
  signedOut,
  sendingCode,
  codeSent,
  verifying,
  authenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.phone, this.session, this.error});

  final AuthStatus status;

  /// الرقم بصيغة دولية (+963...) بعد طلب الرمز.
  final String? phone;
  final AuthSession? session;
  final String? error;

  bool get busy => status == AuthStatus.sendingCode || status == AuthStatus.verifying;

  @override
  List<Object?> get props => [status, phone, session?.userId, error];
}

/// تسجيل الدخول: رقم الهاتف ← رمز SMS ← جلسة.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  /// بيستعيد جلسة محفوظة عند الإقلاع.
  Future<void> restore() async {
    final session = await _repo.restore();
    emit(
      session == null
          ? const AuthState(status: AuthStatus.signedOut)
          : AuthState(status: AuthStatus.authenticated, session: session),
    );
  }

  /// [phone] بصيغة دولية بدون فراغات: `+963993930716`.
  Future<void> requestCode(String phone) async {
    emit(AuthState(status: AuthStatus.sendingCode, phone: phone));
    try {
      await _repo.requestCode(phone);
      emit(AuthState(status: AuthStatus.codeSent, phone: phone));
    } on BackendException catch (e) {
      emit(AuthState(status: AuthStatus.failure, phone: phone, error: e.message));
    }
  }

  Future<void> verifyCode(String code) async {
    emit(AuthState(status: AuthStatus.verifying, phone: state.phone));
    try {
      final session = await _repo.verifyCode(code);
      emit(AuthState(status: AuthStatus.authenticated, phone: state.phone, session: session));
    } on BackendException catch (e) {
      // بنرجع لـ codeSent مع رسالة الخطأ ليقدر المستخدم يعيد المحاولة.
      emit(AuthState(status: AuthStatus.failure, phone: state.phone, error: e.message));
    }
  }

  Future<void> resendCode() async {
    try {
      await _repo.resendCode();
      emit(AuthState(status: AuthStatus.codeSent, phone: state.phone));
    } on BackendException catch (e) {
      emit(AuthState(status: AuthStatus.failure, phone: state.phone, error: e.message));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthState(status: AuthStatus.signedOut));
  }
}
