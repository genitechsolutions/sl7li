import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

import 'app_config.dart';
import 'backend_exception.dart';

/// أي طلب GraphQL بيمر من هون؛ الـ repositories ما بتعرف شي عن Amplify (بتسهّل الاختبار بدون شبكة).
abstract class GraphQlGateway {
  /// بيرجع `data` كاملة. [guest] = true للاستعلامات المسموحة بدون تسجيل دخول (API key).
  Future<Map<String, dynamic>> run(
    String document, {
    Map<String, dynamic> variables = const {},
    bool mutation = false,
    bool guest = false,
  });

  /// اشتراك GraphQL (subscription): بيرجّع `data` لكل حدث.
  Stream<Map<String, dynamic>> subscribe(
    String document, {
    Map<String, dynamic> variables = const {},
  });
}

class AmplifyGraphQlGateway implements GraphQlGateway {
  const AmplifyGraphQlGateway();

  @override
  Stream<Map<String, dynamic>> subscribe(
    String document, {
    Map<String, dynamic> variables = const {},
  }) {
    final request = GraphQLRequest<String>(
      document: document,
      variables: variables,
      authorizationMode: APIAuthorizationType.userPools,
    );
    return Amplify.API
        .subscribe(request)
        .where((e) => e.data != null)
        .map((e) {
          final decoded = jsonDecode(e.data!);
          return decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
        });
  }

  @override
  Future<Map<String, dynamic>> run(
    String document, {
    Map<String, dynamic> variables = const {},
    bool mutation = false,
    bool guest = false,
  }) async {
    var useApiKey = guest;
    var signedIn = false;
    try {
      signedIn = (await Amplify.Auth.fetchAuthSession()).isSignedIn;
    } on AuthException {
      signedIn = false;
    }
    if (!guest && !signedIn) throw BackendException.unauthenticated;
    if (guest && signedIn) useApiKey = false;
    if (useApiKey && AppConfig.apiKey.isEmpty) {
      throw const BackendException('هالقسم بيحتاج تسجيل دخول', code: 'NO_API_KEY');
    }
    final request = GraphQLRequest<String>(
      document: document,
      variables: variables,
      authorizationMode: useApiKey
          ? APIAuthorizationType.apiKey
          : APIAuthorizationType.userPools,
    );
    try {
      final operation = mutation
          ? Amplify.API.mutate(request: request)
          : Amplify.API.query(request: request);
      final response = await operation.response;
      if (response.hasErrors) {
        throw BackendException(response.errors.first.message);
      }
      final raw = response.data;
      if (raw == null) return const {};
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
    } on NetworkException {
      throw const BackendException('تعذّر الاتصال بالإنترنت', code: 'NetworkException');
    } on AuthException catch (e) {
      throw BackendException(e.message, code: e.runtimeType.toString());
    } on AmplifyException catch (e) {
      throw BackendException('تعذّر الاتصال بالخادم، حاول مرة ثانية', code: e.message);
    }
  }
}
