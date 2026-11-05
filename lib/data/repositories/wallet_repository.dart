import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';

/// رصيد نقاط المهني.
abstract class WalletRepository {
  Future<int> pointsBalance();
}

class FakeWalletRepository implements WalletRepository {
  const FakeWalletRepository();

  @override
  Future<int> pointsBalance() async => 0;
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
}
