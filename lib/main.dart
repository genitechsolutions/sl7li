import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import 'app_providers.dart';
import 'core/backend/amplify_bootstrap.dart';
import 'core/backend/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_notifier.dart';
import 'screens/onboarding/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dependencies = AppDependencies.fake();
  if (AppConfig.mode == BackendMode.amplify) {
    try {
      await configureAmplify();
      dependencies = AppDependencies.amplify();
    } on Object catch (e, st) {
      // فشل التهيئة ما لازم يطيّح التطبيق: منكمل ببيانات وهمية ومنسجّل السبب.
      debugPrint('Amplify configuration failed, using fake data: $e\n$st');
    }
  }
  runApp(App(dependencies: dependencies));
}

class App extends StatelessWidget {
  /// بدون [dependencies] بنستعمل البيانات الوهمية (اختبارات/تصميم).
  App({super.key, AppDependencies? dependencies})
    : dependencies = dependencies ?? AppDependencies.fake();

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      dependencies: dependencies,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, themeMode, _) => _buildApp(themeMode),
      ),
    );
  }

  Widget _buildApp(ThemeMode themeMode) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // الداكن بيمشي حسب إعداد الجهاز.
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
