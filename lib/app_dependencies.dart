import 'core/backend/app_config.dart';
import 'core/backend/graphql_gateway.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/conversations_repository.dart';
import 'data/repositories/professional_profile_repository.dart';
import 'data/repositories/craftsman_signup_repository.dart';
import 'data/repositories/profile_repository.dart';
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
    required this.publicProfile,
    required this.professionalProfile,
    required this.craftsmanSignup,
    this.classifier = const FakeServiceClassifier(),
    this.reports = const FakeServiceReportsRepository(),
    this.ratings = const FakeProfessionalRatingsRepository(),
  });

  final ServiceReportsRepository reports;
  final ProfessionalRatingsRepository ratings;

  final ServiceClassifier classifier;

  final AuthRepository auth;
  final OffersRepository offers;
  final MyRequestsRepository myRequests;
  final CraftsmanJobsRepository craftsmanJobs;
  final ConversationsRepository conversations;
  final ProfileRepository profile;
  final WalletRepository wallet;
  final NotificationsRepository notifications;
  final MyOffersRepository myOffers;
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
      publicProfile: const RemotePublicProfileRepository(gateway),
      professionalProfile: const RemoteProfessionalProfileRepository(gateway),
      craftsmanSignup: const RemoteCraftsmanSignupRepository(gateway),
      classifier: const RemoteServiceClassifier(gateway),
      reports: const RemoteServiceReportsRepository(gateway),
      ratings: const RemoteProfessionalRatingsRepository(gateway),
    );
  }

  factory AppDependencies.forMode(BackendMode mode) =>
      mode == BackendMode.amplify ? AppDependencies.amplify() : AppDependencies.fake();
}
