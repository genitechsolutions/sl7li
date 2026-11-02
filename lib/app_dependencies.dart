import 'core/backend/app_config.dart';
import 'core/backend/graphql_gateway.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/conversations_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/notifications_repository.dart';
import 'data/repositories/offers_repository.dart';
import 'data/repositories/requests_repository.dart';

/// كل الـ repositories بمكان واحد. `fake` للتصميم/الاختبارات، `amplify` للخلفية الحقيقية.
class AppDependencies {
  const AppDependencies({
    required this.auth,
    required this.offers,
    required this.myRequests,
    required this.craftsmanJobs,
    required this.conversations,
    required this.profile,
    required this.notifications,
  });

  final AuthRepository auth;
  final OffersRepository offers;
  final MyRequestsRepository myRequests;
  final CraftsmanJobsRepository craftsmanJobs;
  final ConversationsRepository conversations;
  final ProfileRepository profile;
  final NotificationsRepository notifications;

  factory AppDependencies.fake() => AppDependencies(
    auth: FakeAuthRepository(),
    offers: const FakeOffersRepository(),
    myRequests: const FakeMyRequestsRepository(),
    craftsmanJobs: const FakeCraftsmanJobsRepository(),
    conversations: const FakeConversationsRepository(),
    profile: const FakeProfileRepository(),
    notifications: const FakeNotificationsRepository(),
  );

  factory AppDependencies.amplify() {
    const gateway = AmplifyGraphQlGateway();
    final auth = AmplifyAuthRepository(gateway);
    return AppDependencies(
      auth: auth,
      offers: const RemoteOffersRepository(gateway),
      myRequests: RemoteMyRequestsRepository(gateway, auth),
      craftsmanJobs: RemoteCraftsmanJobsRepository(gateway, auth),
      conversations: RemoteConversationsRepository(gateway, auth),
      profile: const RemoteProfileRepository(gateway),
      notifications: RemoteNotificationsRepository(gateway, auth),
    );
  }

  factory AppDependencies.forMode(BackendMode mode) =>
      mode == BackendMode.amplify ? AppDependencies.amplify() : AppDependencies.fake();
}
