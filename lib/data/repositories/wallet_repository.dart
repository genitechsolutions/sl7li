import '../../core/backend/backend_exception.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import 'auth_repository.dart';

/// رصيد نقاط المهني.
/// أرباح المهني وتقييمه من سجل الإنجازات.
class Earnings {
  const Earnings({
    this.total = const {},
    this.lastWeek = const {},
    this.averageRating,
    this.ratedCount = 0,
  });

  /// المبلغ حسب العملة (SYP/USD).
  final Map<String, num> total;
  final Map<String, num> lastWeek;
  final double? averageRating;
  final int ratedCount;
}

abstract class WalletRepository {
  Future<int> pointsBalance();

  Future<Earnings> earnings();

  Future<List<WalletTx>> transactions();

  Future<WalletTxPage> transactionsPage({String? nextToken});
}

/// صفحة من حركات المحفظة (nextToken لجلب الصفحة التالية).
class WalletTxPage {
  const WalletTxPage(this.items, {this.nextToken});

  final List<WalletTx> items;
  final String? nextToken;
}

/// حركة على رصيد النقاط.
class WalletTx {
  const WalletTx({required this.title, required this.value, required this.income, this.createdAt});

  final String title;
  final String value;
  final bool income;
  final DateTime? createdAt;
}

/// "منذ 3 أيام" من تاريخ الحركة (فاضي إذا ما في تاريخ).
String walletTxAgo(DateTime? at, DateTime now) {
  if (at == null) return '';
  final d = now.difference(at);
  if (d.inMinutes < 1) return 'الآن';
  if (d.inMinutes < 60) return 'منذ ${d.inMinutes} دقيقة';
  if (d.inHours < 24) return 'منذ ${d.inHours} ساعة';
  if (d.inDays < 30) return 'منذ ${d.inDays} يوم';
  if (d.inDays < 365) return 'منذ ${d.inDays ~/ 30} شهر';
  return 'منذ ${d.inDays ~/ 365} سنة';
}

class FakeWalletRepository implements WalletRepository {
  const FakeWalletRepository();

  @override
  Future<int> pointsBalance() async => 0;

  @override
  Future<Earnings> earnings() async => const Earnings();

  @override
  Future<List<WalletTx>> transactions() async {
    final at = DateTime.now().subtract(const Duration(days: 3));
    return [
      WalletTx(title: 'أرباح خدمة - تنظيف مكيفات', value: '+1000', income: true, createdAt: at),
      WalletTx(title: 'سحب رصيد', value: '-1000', income: false, createdAt: at),
    ];
  }

  @override
  Future<WalletTxPage> transactionsPage({String? nextToken}) async => WalletTxPage(await transactions());
}

class RemoteWalletRepository implements WalletRepository {
  const RemoteWalletRepository(this._gateway, this._auth);

  final GraphQlGateway _gateway;
  final AuthRepository _auth;

  @override
  Future<Earnings> earnings() async {
    final id = _auth.currentUserId;
    if (id == null) throw BackendException.unauthenticated;
    final data = await _gateway.run(Gql.getCompletionsByProfessional, variables: {'professionalId': id});
    final res = asMap(data['getJobCompletionsByProfessional']);
    throwIfBackendError(res);
    return earningsFromCompletions(asMapList(res['completions']), DateTime.now());
  }

  @override
  Future<int> pointsBalance() async {
    final data = await _gateway.run(Gql.getMyWallet);
    final res = asMap(data['getMyWalletSecure']);
    throwIfBackendError(res);
    return intOf(asMap(res['wallet']), 'balance') ?? 0;
  }

  @override
  Future<List<WalletTx>> transactions() async {
    final data = await _gateway.run(Gql.getMyWallet);
    final res = asMap(data['getMyWalletSecure']);
    throwIfBackendError(res);
    return asMapList(res['transactions']).map(walletTxFromJson).toList();
  }

  @override
  Future<WalletTxPage> transactionsPage({String? nextToken}) async {
    final data = await _gateway.run(Gql.getMyWallet, variables: {'nextToken': nextToken});
    final res = asMap(data['getMyWalletSecure']);
    throwIfBackendError(res);
    final next = res['nextToken'];
    return WalletTxPage(
      asMapList(res['transactions']).map(walletTxFromJson).toList(),
      nextToken: next is String && next.isNotEmpty ? next : null,
    );
  }
}

WalletTx walletTxFromJson(Map<String, dynamic> j) {
  final debit = str(j, 'transaction_type') == 'debit';
  final amount = intOf(j, 'amount') ?? 0;
  final job = str(j, 'job_title');
  final title = debit
      ? (job == null ? 'خصم نقاط' : 'عرض على: $job')
      : (str(j, 'note') ?? 'إضافة نقاط');
  return WalletTx(
    title: title,
    value: debit ? '-$amount' : '+$amount',
    income: !debit,
    createdAt: DateTime.tryParse(str(j, 'createdAt') ?? str(j, 'created_at') ?? '')?.toLocal(),
  );
}

/// الأسبوع الماضي = من الأحد قبل الماضي لحد الأحد الماضي (متل الموقع).
Earnings earningsFromCompletions(List<Map<String, dynamic>> items, DateTime now) {
  final sunday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday % 7));
  final start = sunday.subtract(const Duration(days: 7));
  final total = <String, num>{};
  final week = <String, num>{};
  var ratingSum = 0.0;
  var rated = 0;
  for (final c in items) {
    final amount = c['actual_earnings'];
    final cur = str(c, 'earnings_currency') ?? 'SYP';
    if (amount is num) {
      total[cur] = (total[cur] ?? 0) + amount;
      final at = DateTime.tryParse(str(c, 'completed_at') ?? '')?.toLocal();
      if (at != null && !at.isBefore(start) && at.isBefore(sunday)) {
        week[cur] = (week[cur] ?? 0) + amount;
      }
    }
    final r = c['user_rating'];
    if (r is num && r > 0) {
      ratingSum += r;
      rated++;
    }
  }
  return Earnings(
    total: total,
    lastWeek: week,
    averageRating: rated == 0 ? null : (ratingSum / rated * 10).round() / 10,
    ratedCount: rated,
  );
}

/// "1,000 ل.س" أو "$50"؛ أكتر من عملة بتنفصل بـ " + ".
String earningsLabel(Map<String, num> byCurrency) {
  final parts = [
    for (final e in byCurrency.entries)
      if (e.value > 0) e.key == 'USD' ? '\$${formatMoney(e.value)}' : '${formatMoney(e.value)} ل.س',
  ];
  return parts.isEmpty ? '0' : parts.join(' + ');
}
