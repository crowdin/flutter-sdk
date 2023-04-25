import 'dart:io';
import 'package:yaml/yaml.dart' as yaml;

//possible configuration from l10n.yaml
//https://docs.google.com/document/d/10e0saTfAv32OZLRmONy866vnaw0I2jwL8zukykpgWBc/edit#heading=h.upij01jgi58m

class L10nConfig {
  String arbDir;
  String? outputDir;
  String outputLocalizationFile;
  String templateArbFile;
  String outputClass;
  bool syntheticPackage;

  L10nConfig({
    required this.arbDir,
    required this.templateArbFile,
    required this.outputLocalizationFile,
    required this.outputDir,
    required this.outputClass,
    this.syntheticPackage = true,
  });

  String get finalOutputDir => syntheticPackage
      ? '.dart_tool/flutter_gen/gen_l10n'
      : outputDir ?? arbDir;

  static Future<L10nConfig> getL10nConfig() async {
    if (await File('l10n.yaml').exists()) {
      File l10nFile = File('l10n.yaml');
      String l10nFileString = await l10nFile.readAsString();

      var yamlGenConfig = yaml.loadYaml(l10nFileString);
      String arbDir = yamlGenConfig['arb-dir'] ?? 'lib/l10n';
      String templateArbFile = yamlGenConfig['template-arb-file'];

      String outputLocalizationFile =
          yamlGenConfig['output-localization-file'] ?? 'app_localizations.dart';

      String? outputDir = yamlGenConfig['output-dir'];

      String outputClass = yamlGenConfig['output-class'] ?? 'AppLocalizations';

      bool syntheticPackage = yamlGenConfig['synthetic-package'] ?? true;

      return L10nConfig(
        arbDir: arbDir,
        templateArbFile: templateArbFile,
        outputClass: outputClass,
        outputDir: outputDir,
        syntheticPackage: syntheticPackage,
        outputLocalizationFile: outputLocalizationFile,
      );
    } else {
      throw Exception('No l10n.yaml file');
    }
  }
}
