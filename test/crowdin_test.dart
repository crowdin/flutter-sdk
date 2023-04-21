import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/crowdin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('setUpdateInterval', () {
    test('when updatesInterval is greater than 15 minutes, returns updatesInterval', () {
      const updatesInterval = Duration(minutes: 30);

      final result = setUpdateInterval(updatesInterval);

      expect(result, equals(updatesInterval));
    });

    test('when updatesInterval is less than 15 minutes, returns a Duration of 15 minutes', () {
      const updatesInterval = Duration(minutes: 10);

      final result = setUpdateInterval(updatesInterval);

      expect(result, equals(const Duration(minutes: 15)));
    });

    test('when updatesInterval is exactly 15 minutes, returns updatesInterval', () {
      const updatesInterval = Duration(minutes: 15);

      final result = setUpdateInterval(updatesInterval);

      expect(result, equals(updatesInterval));
    });
  });

  group('getText', () {
    Crowdin sdk = Crowdin();
    setUp(() {});
    test('should return null if arb is null', () async {
      sdk.arb = null;

      String? result = Crowdin.getText('en', 'example');

      expect(result, isNull);
    });

    test('should return null if wrong key specified', () async {
      sdk.arb = AppResourceBundle(testArb);

      String? result = Crowdin.getText('en', 'wrong key');

      expect(result, isNull);
    });

    test('should return value if all arguments specified right', () async {
      sdk.arb = AppResourceBundle(testArb);

      String? result = Crowdin.getText('en', 'example');

      expect(result, 'Example');
    });
  });

}

var testArb = {
  "@@locale": "en",
  "example": "Example",
  "hello": "_Hello {userName}",
  "@hello": {
    "description": "A message with a single parameter",
    "placeholders": {
      "userName": {"type": "String", "example": "Bob"}
    }
  },
  "nThings": "{count,plural, =0{no {thing}s} other{{count} {thing}s}}",
  "@nThings": {
    "description": "A plural message with an additional parameter",
    "placeholders": {
      "count": {"type": "int"},
      "thing": {"example": "wombat"}
    }
  },
  "settings": "Settings",
  "language": "Language",
  "main": "Main",
  "counter": "Counter: {value}",
  "@counter": {
    "description": "A message with a formatted int parameter",
    "placeholders": {
      "value": {"type": "int", "format": "compactLong"}
    }
  }
};
