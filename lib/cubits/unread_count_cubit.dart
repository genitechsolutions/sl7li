import '../data/repositories/notifications_repository.dart';
import 'load_cubit.dart';

/// عدّاد الإشعارات غير المقروءة (شارة الجرس).
class UnreadCountCubit extends LoadCubit<int> {
  UnreadCountCubit(this._repo);

  final NotificationsRepository _repo;

  @override
  Future<int> fetch() => _repo.unreadCount();

  void set(int count) => emit(LoadState(status: LoadStatus.success, data: count < 0 ? 0 : count));

  void decrement() => set((state.data ?? 0) - 1);

  /// فتح محادثة: بنعلّم إشعاراتها مقروءة وبنحدّث العدّاد.
  Future<void> markConversation(String conversationId) async {
    try {
      await _repo.markConversationRead(conversationId);
      await load(force: true);
    } on Object {
      // الشارة مش حرجة.
    }
  }
}
