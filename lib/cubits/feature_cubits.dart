import '../core/backend/backend_exception.dart';
import '../data/chat_data.dart';
import '../data/dummy_data.dart';
import '../data/my_request.dart';
import '../data/repositories/conversations_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/wallet_repository.dart';
import '../data/request_draft.dart';
import '../data/repositories/my_offers_repository.dart';
import '../data/repositories/notifications_repository.dart';
import '../data/repositories/offers_repository.dart';
import '../data/repositories/requests_repository.dart';
import 'load_cubit.dart';

/// العروض الخاصة (عامة).
class OffersCubit extends LoadCubit<List<Offer>> {
  OffersCubit(this._repo);

  final OffersRepository _repo;

  String? cityCode;
  String? serviceCategory;

  @override
  Future<List<Offer>> fetch() =>
      _repo.listPublicOffers(cityCode: cityCode, serviceCategory: serviceCategory);

  /// null = بدون فلتر؛ بيعيد التحميل.
  Future<void> applyFilters({String? cityCode, String? serviceCategory}) {
    this.cityCode = cityCode;
    this.serviceCategory = serviceCategory;
    return load(force: true);
  }

  Future<OfferDetails> details(String? offerId) =>
      offerId == null ? Future.value(sampleOfferDetails) : _repo.offerDetails(offerId);

  Future<void> trackDetailView(String? id) async => id == null ? null : _repo.trackDetailView(id);

  Future<void> trackWhatsAppClick(String? id) async =>
      id == null ? null : _repo.trackWhatsAppClick(id);

  Future<void> trackRelatedQuoteRequest(String? id) async =>
      id == null ? null : _repo.trackRelatedQuoteRequest(id);
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

  /// قبول/رفض عرض وتحديث القائمة.
  Future<void> respondToOffer(String proposalId, {required bool approve}) async {
    await _repo.respondToOffer(proposalId, approve: approve);
    await load(force: true);
  }

  Future<void> rate(
    String jobId, {
    String? proposalId,
    String? professionalId,
    required int stars,
    String? comment,
  }) => _repo.rate(
    jobId,
    proposalId: proposalId,
    professionalId: professionalId,
    stars: stars,
    comment: comment,
  );

  /// تعديل طلب مفتوح وتحديث القائمة.
  Future<void> updateRequest(
    String jobId, {
    required String description,
    required RequestPriority priority,
    required bool shareWhatsapp,
    String? cityCode,
  }) async {
    await _repo.update(
      jobId,
      description: description,
      priority: priority,
      shareWhatsapp: shareWhatsapp,
      cityCode: cityCode,
    );
    await load(force: true);
  }

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

  Future<RequestOffer?> myProposal(String jobId) => _repo.myProposal(jobId);

  Future<void> sendProposal(Map<String, Object?> input) async {
    await _repo.sendProposal(input);
    await load(force: true);
  }

  /// بيسحب العرض وبيحدّث القائمة.
  Future<void> withdrawProposal(String proposalId) async {
    await _repo.withdrawProposal(proposalId);
    await load(force: true);
  }

  Future<void> ignore(String jobId, {required String reason, String? other}) async {
    await _repo.ignore(jobId, reason: reason, other: other);
    await load(force: true);
  }

  Future<void> unignore(String jobId) async {
    await _repo.unignore(jobId);
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

  Future<ChatMessage> sendImage(Conversation c, String path) => _repo.sendImage(c, path);

  Future<void> markRead(String conversationId) => _repo.markRead(conversationId);

  Future<void> validateImage(Conversation c) => _repo.validateImage(c);

  Future<void> deleteMessage(String id) => _repo.deleteMessage(id);

  Future<String?> assignedWhatsApp(String jobId) => _repo.assignedWhatsApp(jobId);

  /// محادثة الزبون مع مهني معيّن على طلب (بتنعمل إذا ما كانت موجودة).
  Future<Conversation?> openWithProfessional(String jobId, String professionalId) async {
    Conversation? find() {
      for (final c in state.data ?? const <Conversation>[]) {
        if (c.jobId == jobId && c.participant2Id == professionalId) return c;
      }
      return null;
    }

    await loadFor(professionalMode: false);
    var found = find();
    if (found == null) {
      await _repo.ensureJobConversation(jobId, professionalId, asCustomer: true);
      await load(force: true);
      found = find();
    }
    return found;
  }

  /// محادثة طلب (بتنعمل إذا ما كانت موجودة) بوضع المهني.
  Future<Conversation?> openForJob(String jobId, String? customerId) async {
    Conversation? find() {
      for (final c in state.data ?? const <Conversation>[]) {
        if (c.jobId == jobId) return c;
      }
      return null;
    }

    await loadFor(professionalMode: true);
    var found = find();
    if (found == null && customerId != null) {
      await _repo.ensureJobConversation(jobId, customerId);
      await load(force: true);
      found = find();
    }
    return found;
  }

  Stream<ChatMessage> liveMessages(Conversation c) => _repo.liveMessages(c);

  Stream<MessageEvent> liveUpdates(Conversation c) => _repo.liveUpdates(c);

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

  /// تحديث متفائل؛ إذا فشل الطلب بنرجّع القائمة من الخلفية.
  Future<void> markRead(NotificationItem item) async {
    final data = state.data;
    final id = item.id;
    if (!item.unread || data == null) return;
    emit(LoadState(status: state.status, data: data.withRead(item)));
    if (id == null) return;
    try {
      await _repo.markRead(id);
    } on Object {
      await load(force: true);
    }
  }
}

/// بيانات حساب المستخدم (الاسم/الرقم) للإعدادات.
class ProfileCubit extends LoadCubit<UserProfile> {
  ProfileCubit(this._repo);

  final ProfileRepository _repo;

  @override
  Future<UserProfile> fetch() => _repo.load();

  Future<void> saveName(String name) async {
    final current = state.data;
    if (current == null || name.trim() == current.name) return;
    await _repo.saveName(current, name.trim());
    await load(force: true);
  }

  /// تسجيل الزبون الجديد: بنحفظ الاسم/المدينة/الحي إذا اسم الحساب فاضي.
  Future<void> saveRegistration({required String name, String? city, String? neighborhood}) async {
    var current = state.data;
    if (current == null) {
      await load(force: true);
      current = state.data;
    }
    if (current == null) throw const BackendException('تعذّر تحميل حسابك، حاول مرة ثانية');
    if (current.name.isNotEmpty) return;
    await _repo.saveDetails(current, name: name.trim(), city: city, neighborhood: neighborhood);
    await load(force: true);
  }

  Future<void> saveDetails({required String name, String? city, String? neighborhood}) async {
    final current = state.data;
    if (current == null) return;
    await _repo.saveDetails(current, name: name.trim(), city: city, neighborhood: neighborhood);
    await load(force: true);
  }

  Future<void> saveNotificationPrefs(NotificationPrefs prefs) async {
    final current = state.data;
    if (current == null) return;
    await _repo.saveNotificationPrefs(current, prefs);
    await load(force: true);
  }

  Future<void> saveAvatar(String path) async {
    final current = state.data;
    if (current == null) return;
    await _repo.saveAvatar(current, path);
    await load(force: true);
  }

  Future<void> deleteAccount() => _repo.deleteAccount();

  Future<void> submitIdPhoto(String path) => _repo.submitIdPhoto(path);
}

/// رصيد نقاط المهني.
class WalletCubit extends LoadCubit<int> {
  WalletCubit(this._repo);

  final WalletRepository _repo;

  @override
  Future<int> fetch() => _repo.pointsBalance();
}

/// عروض المهني الترويجية.
class MyOffersCubit extends LoadCubit<List<MyOffer>> {
  MyOffersCubit(this._repo);

  final MyOffersRepository _repo;

  @override
  Future<List<MyOffer>> fetch() => _repo.list();

  Future<void> create(NewOffer offer) async {
    await _repo.create(offer);
    await load(force: true);
  }

  Future<void> update(String id, NewOffer offer) async {
    await _repo.update(id, offer);
    await load(force: true);
  }

  Future<void> toggle(String id) async {
    await _repo.toggle(id);
    await load(force: true);
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load(force: true);
  }
}

/// آخر حركات المحفظة.
class WalletTxCubit extends LoadCubit<List<WalletTx>> {
  WalletTxCubit(this._repo);

  final WalletRepository _repo;

  @override
  Future<List<WalletTx>> fetch() => _repo.transactions();
}

/// أرباح وتقييم المهني.
class EarningsCubit extends LoadCubit<Earnings> {
  EarningsCubit(this._repo);

  final WalletRepository _repo;

  @override
  Future<Earnings> fetch() => _repo.earnings();
}
