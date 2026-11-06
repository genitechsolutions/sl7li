import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/backend/backend_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/wallet_repository.dart';
import 'widgets/craftsman_cards.dart';

/// سجل المحفظة الكامل (صفحات بـ nextToken).
class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({super.key, required this.repository});

  final WalletRepository repository;

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  final _items = <WalletTx>[];
  String? _next;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.repository.transactionsPage(nextToken: _items.isEmpty ? null : _next);
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _next = page.nextToken;
        _loading = false;
      });
    } on BackendException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'تعذّر تحميل السجل';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.pageAlt,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: colors.cardAlt,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/icons/ic_arrow_back.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(colors.primaryContent, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('سجل المحفظة', style: AppTextStyles.title24Medium.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: _loading
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_error ?? 'لا توجد حركات بعد', style: AppTextStyles.body16),
                                if (_error != null) TextButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                              ],
                            ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        for (final t in _items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: CraftsmanTxRow(
                              title: t.title,
                              value: t.value,
                              color: t.income ? colors.success : colors.error,
                              income: t.income,
                              ago: walletTxAgo(t.createdAt, now),
                            ),
                          ),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_error != null)
                          TextButton(onPressed: _load, child: Text(_error!))
                        else if (_next != null)
                          TextButton(onPressed: _load, child: const Text('عرض المزيد')),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
