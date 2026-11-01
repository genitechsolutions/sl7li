/// وضع الخلفية: `fake` (بيانات وهمية، بدون شبكة — الافتراضي للاختبارات) أو `amplify` (AWS الحقيقي).
enum BackendMode { fake, amplify }

/// إعدادات البيئة. التشغيل مع الخلفية الحقيقية:
/// `flutter run --dart-define=BACKEND=amplify --dart-define=APP_ENV=devqa --dart-define=APPSYNC_API_KEY=...`
/// مفتاح AppSync (API key) ما بينحط بالكود — بيجي من `--dart-define` بس.
class AppConfig {
  const AppConfig._();

  static const _backend = String.fromEnvironment('BACKEND', defaultValue: 'fake');
  static const envName = String.fromEnvironment('APP_ENV', defaultValue: 'devqa');
  static const apiKey = String.fromEnvironment('APPSYNC_API_KEY');

  static BackendMode get mode =>
      _backend == 'amplify' ? BackendMode.amplify : BackendMode.fake;

  static bool get isProduction => envName == 'production';

  static BackendEnv get env => isProduction ? BackendEnv.production : BackendEnv.devqa;
}

/// معرّفات البيئة (مأخوذة من إعدادات موقع الويب العام؛ مش أسرار).
class BackendEnv {
  const BackendEnv({
    required this.region,
    required this.userPoolId,
    required this.userPoolClientId,
    required this.identityPoolId,
    required this.graphqlUrl,
    required this.resourcesHost,
  });

  final String region;
  final String userPoolId;
  final String userPoolClientId;
  final String identityPoolId;
  final String graphqlUrl;

  /// مضيف الصور/الملفات (CloudFront).
  final String resourcesHost;

  static const devqa = BackendEnv(
    region: 'us-east-2',
    userPoolId: 'us-east-2_GzDE0xy0O',
    userPoolClientId: '3237ebmib6230h1fcnc6edadtg',
    identityPoolId: 'us-east-2:37d044db-0e7b-4c85-b653-d6a645e2a49b',
    graphqlUrl:
        'https://khlnguhv6jfa3l476zlirvz7ay.appsync-api.us-east-2.amazonaws.com/graphql',
    resourcesHost: 'devqa-resources.salehli.com',
  );

  static const production = BackendEnv(
    region: 'us-east-2',
    userPoolId: 'us-east-2_OEcZGOijK',
    userPoolClientId: '2lbb91hdhssguk5t0o1ggb4ke4',
    identityPoolId: 'us-east-2:a030aaba-6005-4bd8-813f-823450f20167',
    graphqlUrl: 'https://api.salehli.com/graphql',
    resourcesHost: 'resources.salehli.com',
  );
}
