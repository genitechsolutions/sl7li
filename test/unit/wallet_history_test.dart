import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/data/repositories/wallet_repository.dart';

void main() {
  test('walletTxFromJson بيقرأ createdAt والنوع', () {
    final tx = walletTxFromJson({
      'transaction_type': 'debit',
      'amount': 1,
      'job_title': 'سباكة',
      'createdAt': '2026-11-06T13:20:38.019Z',
    });
    expect(tx.income, isFalse);
    expect(tx.value, '-1');
    expect(tx.title, 'عرض على: سباكة');
    expect(tx.createdAt, isNotNull);
  });

  test('walletTxAgo', () {
    final now = DateTime(2026, 11, 6, 12);
    expect(walletTxAgo(null, now), '');
    expect(walletTxAgo(now.subtract(const Duration(days: 3)), now), 'منذ 3 يوم');
    expect(walletTxAgo(now.subtract(const Duration(hours: 5)), now), 'منذ 5 ساعة');
  });

  test('الفيك بيرجع صفحة بدون nextToken', () async {
    final page = await const FakeWalletRepository().transactionsPage();
    expect(page.items, isNotEmpty);
    expect(page.nextToken, isNull);
  });
}
