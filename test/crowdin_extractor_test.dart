import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/crowdin_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_arb.dart';

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

  group('findPlaceholders test', () {
    Extractor extractor = Extractor();

    test('should return correct placeholders for plurals', () {
      Message message = Message(AppResourceBundle(testArb), 'nThings', false);
      var result = extractor.findPlaceholders('en', message, message.value);
      expect(result, "{count,plural, =0{no nulls} other{null nulls}}");
    });

    test('should return message.value for message without placeholders', () {
      Message message = Message(AppResourceBundle(testArb), 'example', false);
      var result = extractor.findPlaceholders('en', message, message.value);
      expect(result, message.value);
    });
  });

  group('findNumberPlaceholder test', () {
    Extractor extractor = Extractor();

    test('should return correct placeholders for plurals', () {
      Message message = Message(AppResourceBundle(testArb), 'nThings', false);
      var result = extractor.findPlaceholders('en', message, message.value);
      expect(result, "{count,plural, =0{no nulls} other{null nulls}}");
    });

    test('should return message.value for message without placeholders', () {
      Message message = Message(AppResourceBundle(testArb), 'example', false);
      var result = extractor.findPlaceholders('en', message, message.value);
      expect(result, message.value);
    });

    test('should return correct placeholders for number param', () {
      Message message = Message(AppResourceBundle(testArb), 'counter', true);
      var counterValue = 10;
      var result = extractor.findPlaceholders(
          'en', message, message.value, {'value': counterValue});
      expect(result, "Counter: $counterValue");
    });
  });
}
