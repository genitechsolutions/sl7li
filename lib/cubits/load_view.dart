import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'load_cubit.dart';

/// بيعرض حالة cubit تحميل: أول مرة مؤشر، فشل ← رسالة + "إعادة المحاولة"، فاضي ← نص، وإلا [builder].
/// بيطلب التحميل لحاله عند أول بناء ([onInit]؛ الافتراضي `load()`).
class LoadView<C extends LoadCubit<T>, T> extends StatefulWidget {
  const LoadView({
    super.key,
    required this.builder,
    this.isEmpty,
    this.emptyText = 'لا توجد بيانات حالياً',
    this.onInit,
    this.loader,
    this.compact = false,
  });

  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final String emptyText;
  final void Function(C cubit)? onInit;

  /// بديل مؤشر التحميل الافتراضي.
  final Widget? loader;

  /// بدون Center/مساحة كبيرة (للاستعمال جوا صفحة فيها محتوى تاني).
  final bool compact;

  @override
  State<LoadView<C, T>> createState() => _LoadViewState<C, T>();
}

class _LoadViewState<C extends LoadCubit<T>, T> extends State<LoadView<C, T>> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<C>();
    (widget.onInit ?? (c) => c.load())(cubit);
  }

  Widget _wrap(Widget child) => widget.compact
      ? Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: Center(child: child))
      : Center(child: child);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, LoadState<T>>(
      builder: (context, state) {
        final data = state.data;
        if (data != null) {
          if (widget.isEmpty?.call(data) ?? false) {
            return _wrap(_Message(widget.emptyText));
          }
          return widget.builder(context, data);
        }
        if (state.status == LoadStatus.failure) {
          return _wrap(
            _Message(
              state.error ?? 'حدث خطأ',
              onRetry: () => context.read<C>().load(force: true),
            ),
          );
        }
        return _wrap(widget.loader ?? const CircularProgressIndicator());
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.body16Medium.copyWith(
                  color: colors.link,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.link,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
