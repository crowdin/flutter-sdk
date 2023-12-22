import 'dart:io';

import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/gen/crowdin_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_arb.dart';

void main() {
  group('findPlaceholders test', () {
    test('should return list of translation keys', () {
      var keys = CrowdinGenerator.getKeys(testArb);
      expect(
          keys, ['example', 'hello', 'nThings', 'variable_nThings', 'counter']);
    });

    test('should return list of method parameters', () {
      AppResourceBundle resourceBundle = AppResourceBundle(testArb);
      Message message = Message(resourceBundle, 'nThings', false);
      var result = generateMethodParameters(message);
      var platformVersion = Platform.version;
      String? pluralType = specifyPluralType('int', platformVersion);
      expect(result, ['$pluralType count', 'Object thing']);
    });
  });
}
