import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/backend/backend_exception.dart';
import '../../../cubits/feature_cubits.dart';
import 'task_dialogs.dart';

void _toast(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// سحب عرض المهني على طلب بعد التأكيد؛ بترجع true إذا انسحب.
Future<bool> withdrawMyOffer(
  BuildContext context, {
  required String jobId,
  String? proposalId,
}) async {
  final cubit = context.read<CraftsmanJobsCubit>();
  var id = proposalId;
  try {
    id ??= (await cubit.myProposal(jobId))?.proposalId;
  } on Object {
    id = null;
  }
  if (!context.mounted) return false;
  if (id == null) {
    _toast(context, 'ما لقينا عرض لسحبه');
    return false;
  }
  if (await showCancelOfferDialog(context) != true || !context.mounted) {
    return false;
  }
  try {
    await cubit.withdrawProposal(id);
  } on BackendException catch (e) {
    if (context.mounted) _toast(context, e.message);
    return false;
  } on Object {
    if (context.mounted) _toast(context, 'تعذّر سحب العرض، حاول مرة ثانية');
    return false;
  }
  if (context.mounted) _toast(context, 'تم سحب العرض');
  return true;
}
