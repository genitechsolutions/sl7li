import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/backend_exception.dart';
import 'package:khaled_flutter/cubits/auth/auth_cubit.dart';
import 'package:khaled_flutter/cubits/feature_cubits.dart';
import 'package:khaled_flutter/cubits/load_cubit.dart';
import 'package:khaled_flutter/data/chat_data.dart';
import 'package:khaled_flutter/data/dummy_data.dart';
import 'package:khaled_flutter/data/my_request.dart';
import 'package:khaled_flutter/data/repositories/auth_repository.dart';
import 'package:khaled_flutter/data/repositories/conversations_repository.dart';
import 'package:khaled_flutter/data/repositories/offers_repository.dart';
import 'package:khaled_flutter/data/repositories/requests_repository.dart';

class _FailingOffers implements OffersRepository {
  _FailingOffers(this.error);

  final Object error;

  @override
  Future<List<Offer>> listPublicOffers({
    String? cityCode,
    String? serviceCategory,
    bool featured = false,
  }) async => throw error;
}

class _CountingRequests implements MyRequestsRepository {
  int lists = 0;
  final cancelled = <String>[];

  @override
  Future<List<MyRequest>> list() async {
    lists++;
    return sampleActiveRequests;
  }

  @override
  Future<void> cancel(String jobId, {String? reason}) async => cancelled.add(jobId);
}

class _RecordingConversations implements ConversationsRepository {
  final modes = <bool>[];

  @override
  Future<List<Conversation>> list({required bool professionalMode}) async {
    modes.add(professionalMode);
    return const [];
  }
}

class _FlakyAuth extends FakeAuthRepository {
  @override
  Future<void> requestCode(String phone) async =>
      throw const BackendException('تعذّر الاتصال بالإنترنت');
}

void main() {
  group('LoadCubit', () {
    test('نجاح: loading ثم success مع البيانات', () async {
      final cubit = OffersCubit(const FakeOffersRepository());
      final states = <LoadStatus>[];
      cubit.stream.listen((s) => states.add(s.status));
      await cubit.load();
      await pumpEventQueue();
      expect(states, [LoadStatus.loading, LoadStatus.success]);
      expect(cubit.state.data, isNotEmpty);
      await cubit.close();
    });

    test('فشل بـ BackendException: رسالة الخطأ بتوصل للحالة', () async {
      final cubit = OffersCubit(_FailingOffers(const BackendException('خطأ تجريبي')));
      await cubit.load();
      expect(cubit.state.status, LoadStatus.failure);
      expect(cubit.state.error, 'خطأ تجريبي');
      expect(cubit.state.data, isNull);
      await cubit.close();
    });

    test('استثناء غير متوقع: رسالة عامة بالعربي', () async {
      final cubit = OffersCubit(_FailingOffers(StateError('boom')));
      await cubit.load();
      expect(cubit.state.status, LoadStatus.failure);
      expect(cubit.state.error, contains('تعذّر'));
      await cubit.close();
    });

    test('load بدون force ما بيعيد الجلب بعد النجاح؛ مع force بيعيد', () async {
      final repo = _CountingRequests();
      final cubit = MyRequestsCubit(repo);
      await cubit.load();
      await cubit.load();
      expect(repo.lists, 1);
      await cubit.load(force: true);
      expect(repo.lists, 2);
      await cubit.close();
    });

    test('reset بيرجّع الحالة الأولية', () async {
      final cubit = MyRequestsCubit(_CountingRequests());
      await cubit.load();
      cubit.reset();
      expect(cubit.state.status, LoadStatus.initial);
      expect(cubit.state.data, isNull);
      await cubit.close();
    });

    test('إلغاء طلب بيحدّث القائمة', () async {
      final repo = _CountingRequests();
      final cubit = MyRequestsCubit(repo);
      await cubit.load();
      await cubit.cancel('j1', reason: 'سبب');
      expect(repo.cancelled, ['j1']);
      expect(repo.lists, 2);
      await cubit.close();
    });

    test('المحادثات: تغيير الوضع (زبون/مهني) بيعيد الجلب', () async {
      final repo = _RecordingConversations();
      final cubit = ConversationsCubit(repo);
      await cubit.loadFor(professionalMode: false);
      await cubit.loadFor(professionalMode: false);
      await cubit.loadFor(professionalMode: true);
      expect(repo.modes, [false, true]);
      await cubit.close();
    });
  });

  group('AuthCubit', () {
    test('رقم ← رمز ← جلسة', () async {
      final cubit = AuthCubit(FakeAuthRepository());
      final statuses = <AuthStatus>[];
      cubit.stream.listen((s) => statuses.add(s.status));

      await cubit.requestCode('+963993930716');
      expect(cubit.state.status, AuthStatus.codeSent);
      expect(cubit.state.phone, '+963993930716');

      await cubit.verifyCode('123456');
      await pumpEventQueue();
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.session?.userId, isNotEmpty);
      expect(statuses, [
        AuthStatus.sendingCode,
        AuthStatus.codeSent,
        AuthStatus.verifying,
        AuthStatus.authenticated,
      ]);
      await cubit.close();
    });

    test('رمز غلط: failure مع رسالة والرقم محفوظ', () async {
      final cubit = AuthCubit(FakeAuthRepository());
      await cubit.requestCode('+963993930716');
      await cubit.verifyCode('123');
      expect(cubit.state.status, AuthStatus.failure);
      expect(cubit.state.error, 'رمز التحقق غير صحيح');
      expect(cubit.state.phone, '+963993930716');
      await cubit.close();
    });

    test('فشل إرسال الرمز', () async {
      final cubit = AuthCubit(_FlakyAuth());
      await cubit.requestCode('+963993930716');
      expect(cubit.state.status, AuthStatus.failure);
      expect(cubit.state.error, contains('الإنترنت'));
      await cubit.close();
    });

    test('restore بدون جلسة ← signedOut، وsignOut بيمسح الجلسة', () async {
      final cubit = AuthCubit(FakeAuthRepository());
      await cubit.restore();
      expect(cubit.state.status, AuthStatus.signedOut);
      await cubit.requestCode('+963993930716');
      await cubit.verifyCode('123456');
      await cubit.signOut();
      expect(cubit.state.status, AuthStatus.signedOut);
      expect(cubit.state.session, isNull);
      await cubit.close();
    });
  });
}
