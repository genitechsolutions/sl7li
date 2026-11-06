import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/data/repositories/conversations_repository.dart';
import 'package:khaled_flutter/data/repositories/requests_repository.dart';

void main() {
  test('imageCountError', () {
    expect(imageCountError({'canAttach': true, 'maxAllowed': 30}), isNull);
    expect(
      imageCountError({'canAttach': false, 'maxAllowed': 30}),
      contains('30'),
    );
    expect(imageCountError({'canAttach': true, 'error': 'خطأ'}), 'خطأ');
    expect(imageCountError({'error': 'Error: Invalid image count - must be between 1 and 5'}), contains('1 إلى 5'));
    expect(imageCountError({}), isNull);
  });

  test('ignoredJobIdsFromJson', () {
    expect(
      ignoredJobIdsFromJson({
        'jobIds': ['a', 'b'],
      }),
      {'a', 'b'},
    );
    expect(
      ignoredJobIdsFromJson({
        'jobIds': ['a'],
        'error': 'x',
      }),
      isEmpty,
    );
    expect(ignoredJobIdsFromJson({}), isEmpty);
  });
}
