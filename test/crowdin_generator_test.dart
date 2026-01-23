import 'dart:io';

import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/gen/crowdin_generator.dart';
import 'package:crowdin_sdk/src/gen/l10n_config.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_arb.dart';

void main() {
  group('findPlaceholders test', () {
    test('should return list of translation keys', () {
      var keys = CrowdinGenerator.getKeys(testArb);
      expect(keys, [
        'example',
        'hello',
        'nThings',
        'variable_nThings',
        'counter',
        'select_test',
      ]);
    });

    test('should return list of method parameters', () {
      AppResourceBundle resourceBundle = AppResourceBundle(testArb);
      Message message = Message(resourceBundle, 'nThings', false);
      var result = generateMethodParameters(message);
      var platformVersion = Platform.version;
      String? pluralType = specifyPluralType('int', platformVersion);
      expect(result, ['$pluralType count', 'Object thing']);
    });

    test(
        'should generate named parameters when use-named-parameters is enabled',
        () {
      final config = L10nConfig(
        arbDir: 'lib/l10n',
        templateArbFile: 'app_en.arb',
        outputLocalizationFile: 'app_localizations.dart',
        outputDir: null,
        outputClass: 'AppLocalizations',
        syntheticPackage: true,
        useNamedParameters: true,
      );

      final output = generationContent(
        keys: CrowdinGenerator.getKeys(testArb),
        arbResource: testArb,
        l10nConfig: config,
      );

      expect(output, contains('String hello({required'));
      expect(output, contains('_fallbackTexts.hello(userName: userName)'));

      expect(output, contains('String nThings({required'));
      expect(output, contains('_fallbackTexts.nThings('));
      expect(output, contains('count: count'));
      expect(output, contains('thing: thing'));
    });
  });
}
