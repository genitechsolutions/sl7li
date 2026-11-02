import 'dart:convert';
import 'dart:math';

import '../../core/backend/backend_exception.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../craftsman_data.dart';
import '../dummy_data.dart';
import '../my_request.dart';
import '../request_draft.dart';
import 'auth_repository.dart';

/// قوائم طلبات الزبون ("طلباتي").
abstract class MyRequestsRepository {
  Future<List<MyRequest>> list();

  Future<void> cancel(String jobId, {String? reason});

  /// بيرسل طلب خدمة جديد (من خطوات "طلب خدمة").
  Future<void> create(RequestDraft draft);
}

class FakeMyRequestsRepository implements MyRequestsRepository {
  const FakeMyRequestsRepository();

  @override
  Future<List<MyRequest>> list() async => [
    ...sampleActiveRequests,
    ...sampleDoneRequests,
    ...sampleCanceledRequests,
  ];

  @override
  Future<void> cancel(String jobId, {String? reason}) async {}

  @override
  Future<void> create(RequestDraft draft) async {}
}

class RemoteMyRequestsRepository implements MyRequestsRepository {
  const RemoteMyRequestsRepository(this._gateway, this._auth);

  final GraphQlGateway _gateway;
  final AuthRepository _auth;

  @override
  Future<List<MyRequest>> list() async {
    final userId = _auth.currentUserId;
    if (userId == null) throw BackendException.unauthenticated;
    final data = await _gateway.run(
      Gql.getUserDashboard,
      variables: {'userId': userId, 'limit': 100},
    );
    final res = asMap(data['getUserDashboardSecure']);
    throwIfBackendError(res);
    return asMapList(res['jobs']).map(myRequestFromJson).toList();
  }

  @override
  Future<void> cancel(String jobId, {String? reason}) async {
    final data = await _gateway.run(
      Gql.cancelJob,
      variables: {
        'jobId': jobId,
        'cancellationReasonCategory': reason == null ? null : 'other',
        'cancellationReason': reason,
      },
      mutation: true,
    );
    throwIfBackendError(asMap(data['cancelJobSecure']));
  }

  @override
  Future<void> create(RequestDraft draft) async {
    final data = await _gateway.run(
      Gql.createJob,
      variables: {'input': jsonEncode(createJobInput(draft))},
      mutation: true,
    );
    throwIfBackendError(asMap(data['createJobSecure']));
  }
}

/// حقول createJobSecure من مسودة الطلب. (service_id=general لأن التصنيف الدقيق بيصير بالخلفية.)
Map<String, dynamic> createJobInput(RequestDraft d, {String? jobId}) {
  const cityCodes = {
    'دمشق': 'damascus',
    'حلب': 'aleppo',
    'حمص': 'homs',
    'حماة': 'hama',
  };
  const urgency = ['normal', 'urgent', 'emergency'];
  final extra = [
    if (d.serviceType != null) 'نوع الخدمة: ${d.serviceType}',
    if (d.subSpecialty != null) 'التخصص: ${d.subSpecialty}',
  ].join(' - ');
  final title = (d.serviceType ?? 'طلب خدمة');
  return {
    'job_id': jobId ?? _uuid(),
    'service_id': 'general',
    'title': title,
    'description': extra.isEmpty ? d.description : '${d.description}\n$extra',
    'country_code': 'syria',
    'city_code': cityCodes[d.city] ?? 'damascus',
    'urgency': urgency[d.urgency.clamp(0, 2)],
    'specialties_requested': <String>[],
    'images': <String>[],
    'share_whatsapp_with_professionals': d.allowWhatsapp,
    if (d.onBehalf && d.customerName.trim().isNotEmpty)
      'customer_name': d.customerName.trim(),
  };
}

String _uuid() {
  final r = Random.secure();
  String h(int n) =>
      List.generate(n, (_) => r.nextInt(16).toRadixString(16)).join();
  return '${h(8)}-${h(4)}-4${h(3)}-${(8 + r.nextInt(4)).toRadixString(16)}${h(3)}-${h(12)}';
}

/// طلبات واردة/مهام المهني.
class CraftsmanJobs {
  const CraftsmanJobs({
    this.available = const [],
    this.tasks = const [],
    this.done = const [],
    this.cancelled = const [],
  });

  final List<CraftsmanRequest> available;
  final List<CraftsmanRequest> tasks;
  final List<CraftsmanRequest> done;
  final List<CraftsmanRequest> cancelled;
}

abstract class CraftsmanJobsRepository {
  Future<CraftsmanJobs> load();

  Future<void> ignore(String jobId, {required String reason, String? other});
}

class FakeCraftsmanJobsRepository implements CraftsmanJobsRepository {
  const FakeCraftsmanJobsRepository();

  @override
  Future<CraftsmanJobs> load() async => const CraftsmanJobs(
    available: sampleAvailableRequests,
    tasks: sampleCraftsmanTasks,
    done: sampleDoneTasks,
    cancelled: sampleCancelledTasks,
  );

  @override
  Future<void> ignore(
    String jobId, {
    required String reason,
    String? other,
  }) async {}
}

class RemoteCraftsmanJobsRepository implements CraftsmanJobsRepository {
  const RemoteCraftsmanJobsRepository(this._gateway, this._auth);

  final GraphQlGateway _gateway;
  final AuthRepository _auth;

  @override
  Future<CraftsmanJobs> load() async {
    final userId = _auth.currentUserId;
    if (userId == null) throw BackendException.unauthenticated;
    final results = await Future.wait([
      _gateway.run(
        Gql.getAvailableJobsForProfessional,
        variables: {'professionalId': userId},
      ),
      _gateway.run(
        Gql.getCurrentTasksForProfessional,
        variables: {'professionalId': userId},
      ),
    ]);
    final availableRes = asMap(
      results[0]['getAvailableJobsForProfessionalSecure'],
    );
    final tasksRes = asMap(results[1]['getCurrentTasksForProfessionalSecure']);
    throwIfBackendError(availableRes);
    throwIfBackendError(tasksRes);

    final available = asMapList(availableRes['jobs'])
        .map((j) => craftsmanRequestFromJson(j, open: true))
        .toList();
    final all = asMapList(tasksRes['jobs'])
        .map(craftsmanRequestFromJson)
        .toList();
    return CraftsmanJobs(
      available: available,
      tasks: all.where((r) => r.state == CraftsmanRequestState.task).toList(),
      done: all.where((r) => r.state == CraftsmanRequestState.done).toList(),
      cancelled: all
          .where(
            (r) =>
                r.state == CraftsmanRequestState.cancelled ||
                r.state == CraftsmanRequestState.withdrawn,
          )
          .toList(),
    );
  }

  @override
  Future<void> ignore(
    String jobId, {
    required String reason,
    String? other,
  }) async {
    final data = await _gateway.run(
      Gql.ignoreJob,
      variables: {'jobId': jobId, 'ignoreReason': reason, 'otherReason': other},
      mutation: true,
    );
    throwIfBackendError(asMap(data['ignoreJobForProfessionalSecure']));
  }
}

// ───────────────────────── تحويل JSON ← نماذج الواجهة ─────────────────────────

RequestPriority _priority(String? urgency) => switch (urgency) {
  'emergency' => RequestPriority.emergency,
  'urgent' => RequestPriority.urgent,
  _ => RequestPriority.normal,
};

String _urgencyLabel(String? urgency) => switch (urgency) {
  'emergency' => 'طارئ',
  'urgent' => 'عاجل',
  _ => 'عادي',
};

String _locationOf(Map<String, dynamic> j) {
  final parts = [
    str(j, 'city_code'),
    str(j, 'neighborhood_code'),
  ].whereType<String>().toList();
  return parts.join(', ');
}

/// حالة الطلب بالخلفية ← مرحلة الواجهة: 0 مفتوح، 1 تم الاتفاق، 2 قيد التنفيذ، 3/4 مكتمل.
MyRequest myRequestFromJson(Map<String, dynamic> j) {
  final status = str(j, 'status') ?? 'open';
  final done = status == 'completed';
  final canceled = const {
    'cancelled',
    'canceled',
    'expired',
    'closed',
  }.contains(status);
  final stage = switch (status) {
    'professional_selected' || 'selected' => 1,
    'in_progress' => 2,
    'completed' => 4,
    _ => 0,
  };
  return MyRequest(
    id: str(j, 'job_id'),
    date: arabicDate(str(j, 'createdAt')),
    priority: _priority(str(j, 'urgency')),
    title: str(j, 'title') ?? '',
    description: str(j, 'description') ?? '',
    stage: stage,
    status: done
        ? RequestStatus.done
        : canceled
        ? RequestStatus.canceled
        : RequestStatus.active,
    cancelNote: canceled
        ? (status == 'expired' ? 'لقد انتهت مدة طلبك' : 'تم إلغاء الطلب')
        : null,
    offersCount: stage == 0 && !canceled
        ? (intOf(j, 'response_count') ?? 0)
        : null,
    craftsmanName: str(j, 'accepted_pro_name'),
  );
}

CraftsmanRequest craftsmanRequestFromJson(
  Map<String, dynamic> j, {
  bool open = false,
}) {
  final status = str(j, 'statusByProfessional') ?? str(j, 'status') ?? 'open';
  final cancelled = const {
    'cancelled',
    'canceled',
    'expired',
    'closed',
  }.contains(status);
  final done = status == 'completed';
  final state = open
      ? CraftsmanRequestState.open
      : cancelled
      ? CraftsmanRequestState.cancelled
      : done
      ? CraftsmanRequestState.done
      : CraftsmanRequestState.task;
  final stage = open
      ? null
      : switch (status) {
          'professional_selected' || 'selected' => 1,
          'in_progress' => 2,
          'completed' => 3,
          _ => 0,
        };
  return CraftsmanRequest(
    id: str(j, 'job_id'),
    date: arabicDate(str(j, 'createdAt')),
    urgency: _urgencyLabel(str(j, 'urgency')),
    title: str(j, 'title') ?? '',
    description: str(j, 'description') ?? '',
    location: _locationOf(j),
    contacts: open ? intOf(j, 'interactions_count') : null,
    stage: stage,
    photos: strList(j, 'images').length,
    state: state,
    note: str(j, 'cancellation_reason'),
  );
}
