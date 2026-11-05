import '../../core/backend/backend_exception.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/media_upload.dart';
import '../../core/backend/json_utils.dart';

/// بيانات حساب الزبون المعروضة بالإعدادات والملف الشخصي.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    this.cityCode,
    this.neighborhoodCode,
    this.isProfessional = false,
    this.idStatus,
    this.userId = '',
  });

  final String userId;

  /// حالة توثيق الهوية بالخلفية (approved/pending/rejected)، null = ما في طلب.
  final String? idStatus;

  /// عنده ملف مهني بالخلفية (مو بس الدور بالحساب).
  final bool isProfessional;

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

  Future<void> saveName(UserProfile current, String name);

  Future<void> deleteAccount();

  Future<void> submitIdPhoto(String path);
}

class FakeProfileRepository implements ProfileRepository {
  const FakeProfileRepository();

  @override
  Future<UserProfile> load() async =>
      const UserProfile(name: 'رضا الكويفاتي', phone: '+963939316463');

  @override
  Future<void> saveName(UserProfile current, String name) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> submitIdPhoto(String path) async {}
}

class RemoteProfileRepository implements ProfileRepository {
  const RemoteProfileRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<UserProfile> load() async {
    final data = await _gateway.run(Gql.getCurrentUser);
    final res = asMap(data['getCurrentUserSecure']);
    throwIfBackendError(res);
    var professional = false;
    try {
      final pro = await _gateway.run(Gql.getCurrentProfessional);
      professional = asMap(asMap(pro['getCurrentProfessionalSecure'])['professional']).isNotEmpty;
    } on BackendException {
      professional = false;
    }
    String? idStatus;
    if (professional) {
      try {
        final v = await _gateway.run(Gql.getIdVerificationStatus);
        final r = asMap(v['getGovernmentIdVerificationStatusSecure']);
        idStatus = str(r, 'status');
      } on BackendException {
        idStatus = null;
      }
    }
    final base = userProfileFromJson(asMap(res['user']), professional: professional);
    return UserProfile(
      name: base.name,
      phone: base.phone,
      cityCode: base.cityCode,
      neighborhoodCode: base.neighborhoodCode,
      isProfessional: professional,
      idStatus: idStatus,
      userId: base.userId,
    );
  }

  @override
  Future<void> saveName(UserProfile current, String name) async {
    await _gateway.run(
      Gql.updateUser,
      variables: {
        'input': {'user_id': current.userId, 'name': name},
      },
      mutation: true,
    );
  }

  @override
  Future<void> deleteAccount() async {
    final data = await _gateway.run(Gql.deleteAccount, mutation: true);
    throwIfBackendError(asMap(data['deleteAccountSecure']));
  }

  @override
  Future<void> submitIdPhoto(String path) async {
    final key = await uploadMedia(_gateway, path, type: 'government-id');
    final data = await _gateway.run(
      Gql.submitIdVerification,
      variables: {'s3Key': key},
      mutation: true,
    );
    throwIfBackendError(asMap(data['submitGovernmentIdVerificationSecure']));
  }
}

UserProfile userProfileFromJson(Map<String, dynamic> j, {bool professional = false}) => UserProfile(
  name: str(j, 'name') ?? '',
  phone: str(j, 'phone_number') ?? '',
  cityCode: str(j, 'city_code'),
  neighborhoodCode: str(j, 'neighborhood_code'),
  isProfessional: professional,
  userId: str(j, 'user_id') ?? '',
);
