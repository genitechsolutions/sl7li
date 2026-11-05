import 'dart:convert';

import '../../core/backend/backend_exception.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/media_upload.dart';
import '../../core/backend/json_utils.dart';

/// تفضيلات الإشعارات بالخلفية (`notification_preferences`)؛ المفاتيح غير المعروفة بتنحفظ.
class NotificationPrefs {
  const NotificationPrefs({
    this.sms = true,
    this.whatsapp = true,
    this.push = true,
    this.extra = const {},
  });

  final bool sms;
  final bool whatsapp;
  final bool push;
  final Map<String, dynamic> extra;

  NotificationPrefs copyWith({bool? sms, bool? whatsapp, bool? push}) => NotificationPrefs(
    sms: sms ?? this.sms,
    whatsapp: whatsapp ?? this.whatsapp,
    push: push ?? this.push,
    extra: extra,
  );

  Map<String, dynamic> toJson() => {...extra, 'sms': sms, 'whatsapp': whatsapp, 'push': push};

  /// AWSJSON نص، لكن ممكن يوصل كائن جاهز.
  factory NotificationPrefs.fromJson(Object? raw) {
    var v = raw;
    if (v is String) {
      try {
        v = jsonDecode(v);
      } on FormatException {
        v = null;
      }
    }
    if (v is! Map) return const NotificationPrefs();
    final m = Map<String, dynamic>.from(v);
    bool flag(String k) => m[k] is bool ? m[k] as bool : true;
    return NotificationPrefs(
      sms: flag('sms'),
      whatsapp: flag('whatsapp'),
      push: flag('push'),
      extra: {
        for (final e in m.entries)
          if (!const {'sms', 'whatsapp', 'push'}.contains(e.key)) e.key: e.value,
      },
    );
  }
}

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
    this.imageUrl,
    this.notificationPrefs = const NotificationPrefs(),
  });

  final NotificationPrefs notificationPrefs;

  /// رابط صورة الحساب (null = ما في).
  final String? imageUrl;

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

  /// الاسم + المدينة/الحي (أسماء عربية؛ null = ما تتغير).
  Future<void> saveDetails(UserProfile current, {required String name, String? city, String? neighborhood});

  Future<void> saveNotificationPrefs(UserProfile current, NotificationPrefs prefs);

  Future<void> saveAvatar(UserProfile current, String path);

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
  Future<void> saveDetails(UserProfile current, {required String name, String? city, String? neighborhood}) async {}

  @override
  Future<void> saveNotificationPrefs(UserProfile current, NotificationPrefs prefs) async {}

  @override
  Future<void> saveAvatar(UserProfile current, String path) async {}

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
      imageUrl: base.imageUrl,
      notificationPrefs: base.notificationPrefs,
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
  Future<void> saveDetails(UserProfile current, {required String name, String? city, String? neighborhood}) async {
    await _gateway.run(
      Gql.updateUser,
      variables: {'input': profileDetailsInput(current.userId, name: name, city: city, neighborhood: neighborhood)},
      mutation: true,
    );
  }

  @override
  Future<void> saveNotificationPrefs(UserProfile current, NotificationPrefs prefs) async {
    await _gateway.run(
      Gql.updateUser,
      variables: {'input': notificationPrefsInput(current.userId, prefs)},
      mutation: true,
    );
  }

  @override
  Future<void> saveAvatar(UserProfile current, String path) async {
    final key = await uploadMedia(_gateway, path, type: 'profile');
    await _gateway.run(
      Gql.updateUser,
      variables: {
        'input': {'user_id': current.userId, 'profile_image_url': key},
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

/// مدخل `updateUser` لبيانات الحساب؛ المدينة/الحي بتنرسل أكوادها وبس إذا موجودة.
Map<String, dynamic> profileDetailsInput(String userId, {required String name, String? city, String? neighborhood}) => {
  'user_id': userId,
  'name': name,
  if (city != null && city.isNotEmpty) 'city_code': placeCode(city),
  if (neighborhood != null && neighborhood.isNotEmpty) 'neighborhood_code': placeCode(neighborhood),
};

/// `notification_preferences` نوعه AWSJSON فبنرسله نص JSON.
Map<String, dynamic> notificationPrefsInput(String userId, NotificationPrefs prefs) => {
  'user_id': userId,
  'notification_preferences': jsonEncode(prefs.toJson()),
};

UserProfile userProfileFromJson(Map<String, dynamic> j, {bool professional = false}) => UserProfile(
  name: str(j, 'name') ?? '',
  phone: str(j, 'phone_number') ?? '',
  cityCode: str(j, 'city_code'),
  neighborhoodCode: str(j, 'neighborhood_code'),
  isProfessional: professional,
  userId: str(j, 'user_id') ?? '',
  imageUrl: str(j, 'profile_image_url') == null
      ? null
      : resourceUrl(str(j, 'profile_image_url')!),
  notificationPrefs: NotificationPrefs.fromJson(j['notification_preferences']),
);
