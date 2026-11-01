import 'dart:math';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../../core/backend/backend_exception.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';

/// جلسة المستخدم المسجّل.
class AuthSession {
  const AuthSession({required this.userId, required this.phone});

  final String userId;
  final String phone;
}

/// تسجيل الدخول برقم الهاتف + رمز SMS (Cognito custom auth، متل موقع الويب).
abstract class AuthRepository {
  /// معرّف المستخدم الحالي (null إذا غير مسجّل).
  String? get currentUserId;

  Future<AuthSession?> restore();

  /// بيبعت الرمز: مستخدم جديد → signUp، موجود → signIn (CUSTOM_WITHOUT_SRP).
  Future<void> requestCode(String phone);

  Future<AuthSession> verifyCode(String code);

  Future<void> resendCode();

  Future<void> signOut();
}

/// بدون شبكة: أي رمز من 6 خانات بيمشي. للاختبارات والتصميم.
class FakeAuthRepository implements AuthRepository {
  AuthSession? _session;
  String? _phone;

  @override
  String? get currentUserId => _session?.userId;

  @override
  Future<AuthSession?> restore() async => _session;

  @override
  Future<void> requestCode(String phone) async => _phone = phone;

  @override
  Future<AuthSession> verifyCode(String code) async {
    if (code.length != 6) {
      throw const BackendException('رمز التحقق غير صحيح', code: 'CodeMismatchException');
    }
    return _session = AuthSession(userId: 'fake-user', phone: _phone ?? '');
  }

  @override
  Future<void> resendCode() async {}

  @override
  Future<void> signOut() async => _session = null;
}

class AmplifyAuthRepository implements AuthRepository {
  AmplifyAuthRepository(this._gateway);

  final GraphQlGateway _gateway;

  String? _phone;
  String? _tempPassword;
  bool _isNew = false;
  AuthSession? _session;

  @override
  String? get currentUserId => _session?.userId;

  @override
  Future<AuthSession?> restore() async {
    try {
      final auth = await Amplify.Auth.fetchAuthSession();
      if (!auth.isSignedIn) return null;
      final user = await Amplify.Auth.getCurrentUser();
      return _session = AuthSession(userId: user.userId, phone: user.username);
    } on AuthException {
      return null;
    }
  }

  @override
  Future<void> requestCode(String phone) async {
    _phone = phone;
    try {
      final password = _randomPassword();
      final result = await Amplify.Auth.signUp(
        username: phone,
        password: password,
        options: SignUpOptions(
          userAttributes: {AuthUserAttributeKey.phoneNumber: phone},
        ),
      );
      _isNew = true;
      _tempPassword = password;
      // الحساب انأكّد تلقائياً (pre-signup): الموقع بيطلب إرسال الرمز عبر resendOtpSecure.
      if (result.isSignUpComplete) await _sendOtpViaApi(phone);
    } on UsernameExistsException {
      _isNew = false;
      _tempPassword = null;
      await _signInCustom(phone);
    } on AuthException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> _signInCustom(String phone) async {
    try {
      await Amplify.Auth.signIn(
        username: phone,
        options: const SignInOptions(
          pluginOptions: CognitoSignInPluginOptions(
            authFlowType: AuthenticationFlowType.customAuthWithoutSrp,
          ),
        ),
      );
    } on AuthException catch (e) {
      throw _wrap(e);
    }
  }

  @override
  Future<AuthSession> verifyCode(String code) async {
    final phone = _phone;
    if (phone == null) throw const BackendException('ابدأ من إدخال رقم الهاتف');
    try {
      if (_isNew) {
        await Amplify.Auth.confirmSignUp(username: phone, confirmationCode: code);
        await Amplify.Auth.signIn(username: phone, password: _tempPassword);
      } else {
        await Amplify.Auth.confirmSignIn(confirmationValue: code);
      }
      final user = await Amplify.Auth.getCurrentUser();
      return _session = AuthSession(userId: user.userId, phone: phone);
    } on AuthException catch (e) {
      throw _wrap(e);
    }
  }

  @override
  Future<void> resendCode() async {
    final phone = _phone;
    if (phone == null) return;
    try {
      await _sendOtpViaApi(phone);
    } on BackendException catch (e) {
      if (e.message != 'NO_ACTIVE_OTP') rethrow;
      // ما في رمز فعّال: نعيد توليده (متل الموقع).
      if (_isNew) {
        await Amplify.Auth.resendSignUpCode(username: phone);
      } else {
        await _signInCustom(phone);
      }
    } on AuthException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> _sendOtpViaApi(String phone) async {
    final data = await _gateway.run(
      Gql.resendOtp,
      variables: {'phoneNumber': phone},
      mutation: true,
      guest: true,
    );
    final res = asMap(data['resendOtpSecure']);
    if (res['success'] != true) {
      throw BackendException(str(res, 'error') ?? 'RESEND_OTP_FAILED');
    }
  }

  @override
  Future<void> signOut() async {
    await Amplify.Auth.signOut();
    _session = null;
  }

  BackendException _wrap(AuthException e) {
    final message = switch (e) {
      CodeMismatchException() => 'رمز التحقق غير صحيح',
      ExpiredCodeException() => 'انتهت صلاحية الرمز، اطلب رمزاً جديداً',
      LimitExceededException() || TooManyRequestsException() =>
        'محاولات كثيرة، حاول لاحقاً',
      NetworkException() => 'تعذّر الاتصال بالإنترنت',
      InvalidParameterException() => 'رقم الهاتف غير صالح',
      _ => e.message,
    };
    return BackendException(message, code: e.runtimeType.toString());
  }

  /// كلمة سر مؤقتة قوية (المستخدم ما بيشوفها؛ الدخول بالرمز).
  static String _randomPassword() {
    const chars =
        'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#%^&*';
    final r = Random.secure();
    return List.generate(20, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
