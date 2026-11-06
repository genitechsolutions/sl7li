import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_dependencies.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/craftsman_signup_cubit.dart';
import 'cubits/feature_cubits.dart';
import 'cubits/professional_profile_cubit.dart';
import 'cubits/job_lifecycle_cubit.dart';
import 'cubits/load_cubit.dart';
import 'cubits/unread_count_cubit.dart';
import 'cubits/ratings_cubit.dart';
import 'data/repositories/reports_ratings_repository.dart';
import 'data/repositories/public_profile_repository.dart';
import 'data/repositories/service_classifier_repository.dart';

/// بيوفّر الـ cubits لكل التطبيق (فوق MaterialApp عشان توصل لكل الصفحات).
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.dependencies, required this.child});

  final AppDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final d = dependencies;
    return RepositoryProvider<ServiceClassifier>.value(
      value: d.classifier,
      child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(d.auth)..restore()),
        BlocProvider(create: (_) => OffersCubit(d.offers)),
        BlocProvider(create: (_) => FeaturedOffersCubit(d.offers)),
        BlocProvider(create: (_) => MyRequestsCubit(d.myRequests)),
        BlocProvider(create: (_) => CraftsmanJobsCubit(d.craftsmanJobs)),
        BlocProvider(create: (_) => ConversationsCubit(d.conversations)),
        BlocProvider(create: (_) => NotificationsCubit(d.notifications)),
        BlocProvider(create: (_) => UnreadCountCubit(d.notifications)),
        BlocProvider(create: (_) => ProfileCubit(d.profile)),
        BlocProvider(create: (_) => WalletCubit(d.wallet)),
        BlocProvider(create: (_) => MyOffersCubit(d.myOffers)),
        BlocProvider(create: (_) => WalletTxCubit(d.wallet)),
        BlocProvider(create: (_) => EarningsCubit(d.wallet)),
        BlocProvider(create: (_) => JobLifecycleCubit(d.jobLifecycle)),
        RepositoryProvider<PublicProfileRepository>.value(value: d.publicProfile),
        BlocProvider(create: (_) => ProfessionalProfileCubit(d.professionalProfile)),
        BlocProvider(create: (_) => CraftsmanSignupCubit(d.craftsmanSignup)),
        RepositoryProvider<ServiceReportsRepository>.value(value: d.reports),
        BlocProvider(create: (_) => RatingsCubit(d.ratings)),
      ],
      child: _ResumeRefresh(child: child),
      ),
    );
  }
}

/// لما التطبيق يرجع من الخلفية بنعيد تحميل القوائم اللي انفتحت قبل (الاتصال المباشر بيقطع بالخلفية).
class _ResumeRefresh extends StatefulWidget {
  const _ResumeRefresh({required this.child});

  final Widget child;

  @override
  State<_ResumeRefresh> createState() => _ResumeRefreshState();
}

class _ResumeRefreshState extends State<_ResumeRefresh> with WidgetsBindingObserver {
  DateTime? _last;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final now = DateTime.now();
    if (_last != null && now.difference(_last!) < const Duration(seconds: 5)) return;
    _last = now;
    final cubits = <LoadCubit<dynamic>>[
      context.read<ConversationsCubit>(),
      context.read<NotificationsCubit>(),
      context.read<UnreadCountCubit>(),
      context.read<MyRequestsCubit>(),
      context.read<CraftsmanJobsCubit>(),
      context.read<WalletCubit>(),
      context.read<EarningsCubit>(),
      context.read<MyOffersCubit>(),
    ];
    for (final c in cubits) {
      if (c.state.data != null) c.load(force: true);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// تسجيل الخروج: بينهي الجلسة وبيفضّي كل البيانات الخاصة بالمستخدم (عشان ما تظهر لحساب تاني).
Future<void> signOutAndReset(BuildContext context) async {
  final auth = context.read<AuthCubit>();
  final cubits = <LoadCubit<dynamic>>[
    context.read<MyRequestsCubit>(),
    context.read<CraftsmanJobsCubit>(),
    context.read<ConversationsCubit>(),
    context.read<NotificationsCubit>(),
    context.read<UnreadCountCubit>(),
    context.read<ProfileCubit>(),
    context.read<WalletCubit>(),
    context.read<MyOffersCubit>(),
    context.read<WalletTxCubit>(),
    context.read<EarningsCubit>(),
    context.read<ProfessionalProfileCubit>(),
    context.read<RatingsCubit>(),
  ];
  await auth.signOut();
  for (final c in cubits) {
    c.reset();
  }
}
