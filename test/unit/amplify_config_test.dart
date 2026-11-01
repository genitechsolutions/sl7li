import 'dart:convert';

import 'package:amplify_core/amplify_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/amplify_bootstrap.dart';
import 'package:khaled_flutter/core/backend/app_config.dart';

void main() {
  for (final (name, env) in [
    ('devqa', BackendEnv.devqa),
    ('production', BackendEnv.production),
  ]) {
    test('إعداد $name بيتفك بمحلّل Amplify الرسمي', () {
      final json = buildAmplifyOutputs(env, apiKey: 'test-key');
      final outputs = AmplifyOutputs.fromJson(jsonDecode(json) as Map<String, Object?>);
      expect(outputs.auth?.userPoolId, env.userPoolId);
      expect(outputs.auth?.userPoolClientId, env.userPoolClientId);
      expect(outputs.auth?.identityPoolId, env.identityPoolId);
      expect(outputs.data!.values.first.url, env.graphqlUrl);
    });
  }

  test('بدون مفتاح API ما بينكتب بالإعداد', () {
    final data = (jsonDecode(buildAmplifyOutputs(BackendEnv.devqa)) as Map)['data'] as Map;
    expect(data.containsKey('api_key'), isFalse);
  });

  test('الوضع الافتراضي fake (ما في شبكة بالاختبارات)', () {
    expect(AppConfig.mode, BackendMode.fake);
  });
}
