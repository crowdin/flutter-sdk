import 'package:crowdin_sdk/src/crowdin_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrowdinFormatter findPlural methods tests', () {
    test('returns null if plural key not found', () {
      const message = 'message with no plural key';
      const pluralKey = 'other';

      final result = findPlural(message, pluralKey);

      expect(result, isNull);
    });

    test('returns null if opening brace not found', () {
      const message = 'message with {no closing brace';
      const pluralKey = 'other';

      final result = findPlural(message, pluralKey);

      expect(result, isNull);
    });

    test('returns null if closing brace not found', () {
      const message = 'message with no opening brace}';
      const pluralKey = 'other';

      final result = findPlural(message, pluralKey);

      expect(result, isNull);
    });

    test('returns the correct plural string', () {
      const message = ' {count,plural,=0{no items} =1{one item} other{items}}';
      const pluralKey = '=0';

      final result = findPlural(message, pluralKey);

      expect(result, equals('no items'));
    });
  });
}

