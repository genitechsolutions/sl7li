import './core/widgets/coming_soon.dart';
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
  runApp(const _Boot());
}

/// بيعرض مؤشر تحميل فوراً وبيهيّئ Amplify بالخلفية (بدل شاشة سودا لحد ما يخلص).
class _Boot extends StatefulWidget {
  const _Boot();

  @override
  State<_Boot> createState() => _BootState();
}

class _BootState extends State<_Boot> {
  late final Future<AppDependencies> _deps = _init();

  Future<AppDependencies> _init() async {
    if (AppConfig.mode != BackendMode.amplify) return AppDependencies.fake();
    try {
      await configureAmplify().timeout(const Duration(seconds: 25));
      return AppDependencies.amplify();
    } on Object catch (e, st) {
      debugPrint('Amplify configuration failed, using fake data: $e\n$st');
      return AppDependencies.fake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _deps,
      builder: (context, snap) {
        final deps = snap.data;
        if (deps != null) return App(dependencies: deps);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
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
      scaffoldMessengerKey: appMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
