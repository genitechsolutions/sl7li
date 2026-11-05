import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';

/// رصيد نقاط المهني.
abstract class WalletRepository {
  Future<int> pointsBalance();

  Future<List<WalletTx>> transactions();
}

/// حركة على رصيد النقاط.
class WalletTx {
  const WalletTx({required this.title, required this.value, required this.income});

  final String title;
  final String value;
  final bool income;
}

class FakeWalletRepository implements WalletRepository {
  const FakeWalletRepository();

  @override
  Future<int> pointsBalance() async => 0;

  @override
  Future<List<WalletTx>> transactions() async => const [
    WalletTx(title: 'أرباح خدمة - تنظيف مكيفات', value: '+1000', income: true),
    WalletTx(title: 'سحب رصيد', value: '-1000', income: false),
  ];
}

class RemoteWalletRepository implements WalletRepository {
  const RemoteWalletRepository(this._gateway);

  final GraphQlGateway _gateway;

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
}

WalletTx walletTxFromJson(Map<String, dynamic> j) {
  final debit = str(j, 'transaction_type') == 'debit';
  final amount = intOf(j, 'amount') ?? 0;
  final job = str(j, 'job_title');
  final title = debit
      ? (job == null ? 'خصم نقاط' : 'عرض على: $job')
      : (str(j, 'note') ?? 'إضافة نقاط');
  return WalletTx(title: title, value: debit ? '-$amount' : '+$amount', income: !debit);
}
