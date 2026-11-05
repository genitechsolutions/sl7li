import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_dependencies.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/feature_cubits.dart';
import 'cubits/load_cubit.dart';

/// بيوفّر الـ cubits لكل التطبيق (فوق MaterialApp عشان توصل لكل الصفحات).
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.dependencies, required this.child});

  final AppDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final d = dependencies;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(d.auth)..restore()),
        BlocProvider(create: (_) => OffersCubit(d.offers)),
        BlocProvider(create: (_) => FeaturedOffersCubit(d.offers)),
        BlocProvider(create: (_) => MyRequestsCubit(d.myRequests)),
        BlocProvider(create: (_) => CraftsmanJobsCubit(d.craftsmanJobs)),
        BlocProvider(create: (_) => ConversationsCubit(d.conversations)),
        BlocProvider(create: (_) => NotificationsCubit(d.notifications)),
        BlocProvider(create: (_) => ProfileCubit(d.profile)),
        BlocProvider(create: (_) => WalletCubit(d.wallet)),
        BlocProvider(create: (_) => MyOffersCubit(d.myOffers)),
        BlocProvider(create: (_) => WalletTxCubit(d.wallet)),
      ],
      child: child,
    );
  }
}

/// تسجيل الخروج: بينهي الجلسة وبيفضّي كل البيانات الخاصة بالمستخدم (عشان ما تظهر لحساب تاني).
Future<void> signOutAndReset(BuildContext context) async {
  final auth = context.read<AuthCubit>();
  final cubits = <LoadCubit<dynamic>>[
    context.read<MyRequestsCubit>(),
    context.read<CraftsmanJobsCubit>(),
    context.read<ConversationsCubit>(),
    context.read<NotificationsCubit>(),
    context.read<ProfileCubit>(),
    context.read<WalletCubit>(),
    context.read<MyOffersCubit>(),
    context.read<WalletTxCubit>(),
  ];
  await auth.signOut();
  for (final c in cubits) {
    c.reset();
  }
}
