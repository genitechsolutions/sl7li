import '../data/chat_data.dart';
import '../data/dummy_data.dart';
import '../data/my_request.dart';
import '../data/repositories/conversations_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/request_draft.dart';
import '../data/repositories/notifications_repository.dart';
import '../data/repositories/offers_repository.dart';
import '../data/repositories/requests_repository.dart';
import 'load_cubit.dart';

/// العروض الخاصة (عامة).
class OffersCubit extends LoadCubit<List<Offer>> {
  OffersCubit(this._repo);

  final OffersRepository _repo;

  @override
  Future<List<Offer>> fetch() => _repo.listPublicOffers();
}

/// عروض الرئيسية (عدد قليل).
class FeaturedOffersCubit extends LoadCubit<List<Offer>> {
  FeaturedOffersCubit(this._repo);

  final OffersRepository _repo;

  @override
  Future<List<Offer>> fetch() => _repo.listPublicOffers(featured: true);
}

/// "طلباتي" عند الزبون.
class MyRequestsCubit extends LoadCubit<List<MyRequest>> {
  MyRequestsCubit(this._repo);

  final MyRequestsRepository _repo;

  @override
  Future<List<MyRequest>> fetch() => _repo.list();

  Future<List<RequestOffer>> offers(String jobId) => _repo.offers(jobId);

  /// بيرسل طلب جديد وبيحدّث القائمة.
  Future<void> create(RequestDraft draft) async {
    await _repo.create(draft);
    await load(force: true);
  }

  /// بيلغي الطلب وبيحدّث القائمة.
  Future<void> cancel(String jobId, {String? reason}) async {
    await _repo.cancel(jobId, reason: reason);
    await load(force: true);
  }
}

/// طلبات المهني: المتاحة + مهامه (حالية/مكتملة/ملغاة).
class CraftsmanJobsCubit extends LoadCubit<CraftsmanJobs> {
  CraftsmanJobsCubit(this._repo);

  final CraftsmanJobsRepository _repo;

  @override
  Future<CraftsmanJobs> fetch() => _repo.load();

  Future<void> ignore(String jobId, {required String reason, String? other}) async {
    await _repo.ignore(jobId, reason: reason, other: other);
    await load(force: true);
  }
}

/// قائمة المحادثات؛ الوضع (زبون/مهني) بيتحدد عند الطلب.
class ConversationsCubit extends LoadCubit<List<Conversation>> {
  ConversationsCubit(this._repo);

  final ConversationsRepository _repo;
  bool _professionalMode = false;

  @override
  Future<List<Conversation>> fetch() => _repo.list(professionalMode: _professionalMode);

  Future<List<ChatMessage>> messages(String conversationId) => _repo.messages(conversationId);

  Future<ChatMessage> sendVoice(Conversation c, String path, int seconds) =>
      _repo.sendVoice(c, path, seconds);

  Future<String?> voiceUrl(String key) => _repo.voiceUrl(key);

  Future<ChatMessage> sendText(Conversation c, String text) => _repo.sendText(c, text);

  Future<void> markRead(String conversationId) => _repo.markRead(conversationId);

  Stream<ChatMessage> liveMessages(Conversation c) => _repo.liveMessages(c);

  /// بيحمّل للوضع المطلوب (إذا تغيّر الوضع بنعيد التحميل).
  Future<void> loadFor({required bool professionalMode}) {
    final changed = _professionalMode != professionalMode;
    _professionalMode = professionalMode;
    return load(force: changed);
  }
}

class NotificationsCubit extends LoadCubit<NotificationsData> {
  NotificationsCubit(this._repo);

  final NotificationsRepository _repo;

  @override
  Future<NotificationsData> fetch() => _repo.load();

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await load(force: true);
  }
}

/// بيانات حساب المستخدم (الاسم/الرقم) للإعدادات.
class ProfileCubit extends LoadCubit<UserProfile> {
  ProfileCubit(this._repo);

  final ProfileRepository _repo;

  @override
  Future<UserProfile> fetch() => _repo.load();
}
