import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/backend/backend_exception.dart';

enum LoadStatus { initial, loading, success, failure }

/// حالة تحميل عامة: بيانات + حالة + رسالة خطأ (بتنعرض بالعربي).
class LoadState<T> extends Equatable {
  const LoadState({this.status = LoadStatus.initial, this.data, this.error});

  final LoadStatus status;
  final T? data;
  final String? error;

  bool get isLoading => status == LoadStatus.loading;
  bool get hasData => data != null;

  @override
  List<Object?> get props => [status, data, error];
}

/// قاعدة cubits القراءة: `load()` مرة، `load(force: true)` للتحديث. الأخطاء بتتحوّل لحالة failure.
abstract class LoadCubit<T> extends Cubit<LoadState<T>> {
  LoadCubit() : super(const LoadState());

  Future<T> fetch();

  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && state.status == LoadStatus.success) return;
    emit(LoadState(status: LoadStatus.loading, data: state.data));
    try {
      emit(LoadState(status: LoadStatus.success, data: await fetch()));
    } on BackendException catch (e) {
      emit(LoadState(status: LoadStatus.failure, data: state.data, error: e.message));
    } on Object {
      emit(
        LoadState(
          status: LoadStatus.failure,
          data: state.data,
          error: 'تعذّر تحميل البيانات، حاول مرة ثانية',
        ),
      );
    }
  }

  /// بيرجّع الحالة لأولية (مثلاً بعد تسجيل الخروج).
  void reset() => emit(const LoadState());
}
