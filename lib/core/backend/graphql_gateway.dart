import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

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
}

class AmplifyGraphQlGateway implements GraphQlGateway {
  const AmplifyGraphQlGateway();

  @override
  Future<Map<String, dynamic>> run(
    String document, {
    Map<String, dynamic> variables = const {},
    bool mutation = false,
    bool guest = false,
  }) async {
    final request = GraphQLRequest<String>(
      document: document,
      variables: variables,
      authorizationMode: guest
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
    } on AuthException catch (e) {
      throw BackendException(e.message, code: e.runtimeType.toString());
    } on ApiException catch (e) {
      throw BackendException(e.message, code: 'ApiException');
    }
  }
}
