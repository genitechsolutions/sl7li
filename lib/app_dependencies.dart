import 'core/backend/app_config.dart';
import 'core/backend/graphql_gateway.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/conversations_repository.dart';
import 'data/repositories/job_lifecycle_repository.dart';
import 'data/repositories/professional_profile_repository.dart';
import 'data/repositories/craftsman_signup_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/push_token_repository.dart';
import 'data/repositories/wallet_repository.dart';
import 'data/repositories/notifications_repository.dart';
import 'data/repositories/my_offers_repository.dart';
import 'data/repositories/offers_repository.dart';
import 'data/repositories/public_profile_repository.dart';
import 'data/repositories/reports_ratings_repository.dart';
import 'data/repositories/requests_repository.dart';
import 'data/repositories/service_classifier_repository.dart';

/// كل الـ repositories بمكان واحد. `fake` للتصميم/الاختبارات، `amplify` للخلفية الحقيقية.
class AppDependencies {
  const AppDependencies({
    required this.auth,
    required this.offers,
    required this.myRequests,
    required this.craftsmanJobs,
    required this.conversations,
    required this.profile,
    required this.wallet,
    required this.notifications,
    required this.myOffers,
    required this.pushTokens,
    required this.publicProfile,
    required this.professionalProfile,
    required this.craftsmanSignup,
    this.classifier = const FakeServiceClassifier(),
    this.jobLifecycle = const FakeJobLifecycleRepository(),
    this.reports = const FakeServiceReportsRepository(),
    this.ratings = const FakeProfessionalRatingsRepository(),
  });

  final ServiceReportsRepository reports;
  final ProfessionalRatingsRepository ratings;

  final ServiceClassifier classifier;
  final JobLifecycleRepository jobLifecycle;

  final AuthRepository auth;
  final OffersRepository offers;
  final MyRequestsRepository myRequests;
  final CraftsmanJobsRepository craftsmanJobs;
  final ConversationsRepository conversations;
  final ProfileRepository profile;
  final WalletRepository wallet;
  final NotificationsRepository notifications;
  final MyOffersRepository myOffers;
  final PushTokenRepository pushTokens;
  final PublicProfileRepository publicProfile;
  final ProfessionalProfileRepository professionalProfile;
  final CraftsmanSignupRepository craftsmanSignup;

  factory AppDependencies.fake() => AppDependencies(
    auth: FakeAuthRepository(),
    offers: const FakeOffersRepository(),
    myRequests: const FakeMyRequestsRepository(),
    craftsmanJobs: const FakeCraftsmanJobsRepository(),
    conversations: const FakeConversationsRepository(),
    profile: const FakeProfileRepository(),
    wallet: const FakeWalletRepository(),
    notifications: const FakeNotificationsRepository(),
    myOffers: const FakeMyOffersRepository(),
    pushTokens: const FakePushTokenRepository(),
    publicProfile: const FakePublicProfileRepository(),
    professionalProfile: const FakeProfessionalProfileRepository(),
    craftsmanSignup: const FakeCraftsmanSignupRepository(),
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
      wallet: RemoteWalletRepository(gateway, auth),
      notifications: RemoteNotificationsRepository(gateway, auth),
      myOffers: const RemoteMyOffersRepository(gateway),
      pushTokens: RemotePushTokenRepository(gateway, auth),
      publicProfile: const RemotePublicProfileRepository(gateway),
      professionalProfile: const RemoteProfessionalProfileRepository(gateway),
      craftsmanSignup: const RemoteCraftsmanSignupRepository(gateway),
      classifier: const RemoteServiceClassifier(gateway),
      jobLifecycle: const RemoteJobLifecycleRepository(gateway),
      reports: const RemoteServiceReportsRepository(gateway),
      ratings: const RemoteProfessionalRatingsRepository(gateway),
    );
  }

  factory AppDependencies.forMode(BackendMode mode) =>
      mode == BackendMode.amplify ? AppDependencies.amplify() : AppDependencies.fake();
}
