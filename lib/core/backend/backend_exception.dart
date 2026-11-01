/// خطأ من الخلفية بصيغة جاهزة للعرض بالعربي.
class BackendException implements Exception {
  const BackendException(this.message, {this.code});

  final String message;

  /// رمز تقني (مثل `UsernameExistsException` أو `UNAUTHENTICATED`) للاستعمال بالكود.
  final String? code;

  static const unauthenticated = BackendException(
    'يرجى تسجيل الدخول أولاً',
    code: 'UNAUTHENTICATED',
  );

  @override
  String toString() => 'BackendException($code): $message';
}
