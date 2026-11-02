import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';

/// بيانات حساب الزبون المعروضة بالإعدادات والملف الشخصي.
class UserProfile {
  const UserProfile({required this.name, required this.phone, this.cityCode, this.neighborhoodCode});

  final String name;

  /// بصيغة دولية (+963...).
  final String phone;
  final String? cityCode;
  final String? neighborhoodCode;

  /// الرقم بدون رمز الدولة (للحقل): `939316463`.
  String get localPhone => phone.replaceFirst(RegExp(r'^\+?963'), '');

  /// الرقم للعرض: `+963 939 316 463`.
  String get displayPhone {
    final l = localPhone;
    if (l.length != 9) return phone;
    return '+963 ${l.substring(0, 3)} ${l.substring(3, 6)} ${l.substring(6)}';
  }
}

abstract class ProfileRepository {
  Future<UserProfile> load();
}

class FakeProfileRepository implements ProfileRepository {
  const FakeProfileRepository();

  @override
  Future<UserProfile> load() async =>
      const UserProfile(name: 'رضا الكويفاتي', phone: '+963939316463');
}

class RemoteProfileRepository implements ProfileRepository {
  const RemoteProfileRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<UserProfile> load() async {
    final data = await _gateway.run(Gql.getCurrentUser);
    final res = asMap(data['getCurrentUserSecure']);
    throwIfBackendError(res);
    return userProfileFromJson(asMap(res['user']));
  }
}

UserProfile userProfileFromJson(Map<String, dynamic> j) => UserProfile(
  name: str(j, 'name') ?? '',
  phone: str(j, 'phone_number') ?? '',
  cityCode: str(j, 'city_code'),
  neighborhoodCode: str(j, 'neighborhood_code'),
);
