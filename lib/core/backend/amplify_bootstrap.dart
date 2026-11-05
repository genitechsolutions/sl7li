import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

import 'app_config.dart';

/// إعداد Amplify بصيغة amplify_outputs (Gen2) من معرّفات البيئة. دالة نقية للاختبار.
String buildAmplifyOutputs(BackendEnv env, {String apiKey = ''}) {
  return jsonEncode({
    'version': '1.4',
    'auth': {
      'user_pool_id': env.userPoolId,
      'aws_region': env.region,
      'user_pool_client_id': env.userPoolClientId,
      'identity_pool_id': env.identityPoolId,
      'username_attributes': ['phone_number'],
      'standard_required_attributes': ['phone_number'],
      'user_verification_types': ['phone_number'],
      'unauthenticated_identities_enabled': true,
      'mfa_configuration': 'NONE',
      'mfa_methods': <String>[],
    },
    'data': {
      'url': env.graphqlUrl,
      'aws_region': env.region,
      'default_authorization_type': 'AMAZON_COGNITO_USER_POOLS',
      'authorization_types': ['API_KEY', 'AWS_IAM'],
      if (apiKey.isNotEmpty) 'api_key': apiKey,
    },
    if (env.storageBucket != null)
      'storage': {
        'aws_region': env.region,
        'bucket_name': env.storageBucket,
      },
  });
}

/// بيهيّئ Amplify (Auth + API) مرة وحدة عند الإقلاع بوضع `amplify`.
Future<void> configureAmplify() async {
  if (Amplify.isConfigured) return;
  await Amplify.addPlugins([
    AmplifyAuthCognito(),
    AmplifyAPI(),
    if (AppConfig.env.storageBucket != null) AmplifyStorageS3(),
  ]);
  await Amplify.configure(
    buildAmplifyOutputs(AppConfig.env, apiKey: AppConfig.apiKey),
  );
}
