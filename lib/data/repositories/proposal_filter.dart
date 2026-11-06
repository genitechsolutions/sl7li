/// حالات العرض اللي ما لازم تظهر للزبون (مسحوب/مرفوض...).
const _deadProposalStatuses = {
  'withdrawn',
  'rejected',
  'cancelled',
  'canceled',
  'declined',
  'expired',
};

bool isLiveProposal(Map<String, dynamic> p) => !_deadProposalStatuses.contains(p['status']);

/// العروض الفعّالة بس، وبتبقى آخر نسخة لكل مهني (الخلفية بترجع المسحوب والمكرر).
List<Map<String, dynamic>> liveProposals(List<Map<String, dynamic>> all) {
  final byPro = <String, Map<String, dynamic>>{};
  final order = <String>[];
  for (final p in all.where(isLiveProposal)) {
    final key = (p['professional_id'] ?? p['proposal_id'] ?? '${order.length}').toString();
    final prev = byPro[key];
    if (prev == null) order.add(key);
    if (prev == null || _stamp(p).compareTo(_stamp(prev)) >= 0) byPro[key] = p;
  }
  return [for (final k in order) byPro[k]!];
}

String _stamp(Map<String, dynamic> p) => (p['updatedAt'] ?? p['createdAt'] ?? '').toString();

/// فهرس العرض المختار بالقائمة: عرض وحيد بيتختار تلقائياً، وغير هيك لازم المستخدم يختار.
String? effectiveSelection(List<String?> ids, String? picked) {
  if (picked != null && ids.contains(picked)) return picked;
  final real = ids.whereType<String>().toList();
  return ids.length == 1 && real.length == 1 ? real.first : null;
}
