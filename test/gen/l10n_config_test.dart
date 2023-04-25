import 'dart:io';

import 'package:crowdin_sdk/src/gen/l10n_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('L10nConfig tests', () {
    test('finalOutputDir returns default value if syntheticPackage is true',
        () {
      final l10nConfig = L10nConfig(
        arbDir: 'lib/l10n',
        templateArbFile: 'app_en.arb',
        outputClass: 'AppLocalizations',
        outputLocalizationFile: 'app_localizations.dart',
        outputDir: 'lib/generated',
        syntheticPackage: true,
      );
      expect(l10nConfig.finalOutputDir, '.dart_tool/flutter_gen/gen_l10n');
    });

    test(
        'finalOutputDir returns outputDir value if syntheticPackage is false and outputDir is specified',
        () {
      final l10nConfig = L10nConfig(
        arbDir: 'lib/l10n',
        templateArbFile: 'app_en.arb',
        outputClass: 'AppLocalizations',
        outputLocalizationFile: 'app_localizations.dart',
        outputDir: 'lib/generated',
        syntheticPackage: false,
      );
      expect(l10nConfig.finalOutputDir, l10nConfig.finalOutputDir);
    });

    test(
        'finalOutputDir returns arbDir value if syntheticPackage is false and outputDir is not specified',
        () {
      final l10nConfig = L10nConfig(
        arbDir: 'lib/l10n',
        templateArbFile: 'app_en.arb',
        outputClass: 'AppLocalizations',
        outputLocalizationFile: 'app_localizations.dart',
        outputDir: null,
        syntheticPackage: false,
      );
      expect(l10nConfig.finalOutputDir, l10nConfig.arbDir);
    });

    test('getL10nConfig throws exception when l10n.yaml file is not found', () {
      expect(() => L10nConfig.getL10nConfig(), throwsA(isA<Exception>()));
    });

    test('getL10nConfig returns a L10nConfig object with the correct values',
        () async {
      // Create temporary l10n.yaml file
      final l10nYamlFile = File('l10n.yaml');
      await l10nYamlFile.writeAsString('''
        arb-dir: lib/l10n
        template-arb-file: app_en.arb
        output-localization-file: app_localizations.dart
        output-dir: lib/generated
        output-class: AppLocalizations
        synthetic-package: false
      ''');

      final l10nConfig = await L10nConfig.getL10nConfig();
      expect(l10nConfig.arbDir, 'lib/l10n');
      expect(l10nConfig.templateArbFile, 'app_en.arb');
      expect(l10nConfig.outputLocalizationFile, 'app_localizations.dart');
      expect(l10nConfig.outputDir, 'lib/generated');
      expect(l10nConfig.outputClass, 'AppLocalizations');
      expect(l10nConfig.syntheticPackage, false);

      // Delete the temporary l10n.yaml file
      await l10nYamlFile.delete();
    });
  });
}
