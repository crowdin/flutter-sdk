import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/crowdin.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_arb.dart';

void main() {
  group('setUpdateInterval', () {
    test(
        'when updatesInterval is greater than 15 minutes, returns updatesInterval',
        () {
      const updatesInterval = Duration(minutes: 30);

      final result = setUpdateInterval(updatesInterval);

      expect(result, equals(updatesInterval));
    });

    test(
        'when updatesInterval is less than 15 minutes, returns a Duration of 15 minutes',
        () {
      const updatesInterval = Duration(minutes: 10);

      final result = setUpdateInterval(updatesInterval);

      expect(result, equals(const Duration(minutes: 15)));
    });

    test('when updatesInterval is exactly 15 minutes, returns updatesInterval',
        () {
      const updatesInterval = Duration(minutes: 15);

      final result = setUpdateInterval(updatesInterval);

      expect(result, equals(updatesInterval));
    });
  });

  group('getText', () {
    setUp(() {
      Crowdin.arb = AppResourceBundle(testArb);
    });
    test('should return null if arb is null', () async {
      Crowdin.arb = null;

      String? result = Crowdin.getText('en', 'example');

      expect(result, isNull);
    });

    test('should return null if wrong key specified', () async {
      String? result = Crowdin.getText('en', 'wrong key');

      expect(result, isNull);
    });

    test('should return value if all arguments specified right', () async {
      String? result = Crowdin.getText('en', 'example');

      expect(result, 'Example');
    });

    test('should return value with a single parameter', () async {
      String? result =
          Crowdin.getText('en', 'hello', {'userName': 'test name'});

      expect(result, 'Hello test name');
    });

    test('should return value with a plurals', () async {
      String? zeroPluralResult =
          Crowdin.getText('en', 'nThings', {'count': 0, 'thing': 'test_thing'});
      String? pluralResult =
          Crowdin.getText('en', 'nThings', {'count': 1, 'thing': 'test_thing'});

      expect(zeroPluralResult, 'no test_things');
      expect(pluralResult, '1 test_things');
    });

    test('should return value with a count format param', () async {
      String? resultValue = Crowdin.getText('en', 'counter', {'value': 10});
      String? resultThousand =
          Crowdin.getText('en', 'counter', {'value': 1000});
      String? resultMillion =
          Crowdin.getText('en', 'counter', {'value': 1000000});
      String? resultBillion =
          Crowdin.getText('en', 'counter', {'value': 1000000000});
      String? resultTrillion =
          Crowdin.getText('en', 'counter', {'value': 1000000000000});

      expect(resultValue, 'Counter: 10');
      expect(resultThousand, 'Counter: 1 thousand');
      expect(resultMillion, 'Counter: 1 million');
      expect(resultBillion, 'Counter: 1 billion');
      expect(resultTrillion, 'Counter: 1 trillion');
    });
  });


}
