import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import 'common/gen_l10n_types.dart';

class CrowdinGenerator1 {
  static Future<void> generate() async {
    final String projectDirectory = Directory.current.path;
    File genFile = File(path.join(
        projectDirectory, '.dart_tool', 'flutter_gen', 'gen_l10n', 'crowdin_localizations.dart'));
    await genFile.create(recursive: true);

    final arbPath = await getTemplateDirPath();
    final arbFile = File(arbPath);
    final arbStr = await arbFile.readAsString();

    List<String> keys = getKeys(jsonDecode(arbStr));
    var content = generationContent(keys: keys, arbResource: jsonDecode(arbStr));
    await genFile.writeAsString(content, mode: FileMode.writeOnly, flush: true);
  }

  static List<String> getKeys(Map<String, Object?> arb) {
    List<String> keys = arb.keys.where((element) => !element.startsWith('@')).toList();
    return keys;
  }
}

///todo implement configurations accordingly to https://docs.google.com/document/d/10e0saTfAv32OZLRmONy866vnaw0I2jwL8zukykpgWBc/edit#heading=h.upij01jgi58m
class L10nConfig {
  String arbDir;

  L10nConfig({
    required this.arbDir,
  });
}

Future<String> getTemplateDirPath() async {
  if (await File('l10n.yaml').exists()) {
    File l10nFile = File('l10n.yaml');
    String l10nFileString = await l10nFile.readAsString();

    var yamlGenConfig = yaml.loadYaml(l10nFileString);
    String arbDir = yamlGenConfig['arb-dir'];
    String templateArbFile = yamlGenConfig['template-arb-file'];
    String templateDirPat = path.join(arbDir, templateArbFile);
    return templateDirPat;
  } else {
    throw Exception('No l10n.yaml file');
  }
}

String generationContent({required List<String> keys, required Map<String, Object?> arbResource}) {
  StringBuffer buffer = StringBuffer();
  buffer.writeln('''import 'dart:convert';

import 'app_localizations.dart';

import 'package:crowdin_sdk/crowdin_sdk.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CrowdinLocalization extends AppLocalizations {
  final AppLocalizations _fallbackTexts;
  
  CrowdinLocalization(String locale, AppLocalizations fallbackTexts) : _fallbackTexts = fallbackTexts, super(locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _CrowdinLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <
      LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;
 ''');

  ///+++

  var arb = AppResourceBundle(arbResource);
  var messages = arb.resourceIds.map((id) => Message(arb, id, false)).toList(growable: false);
  for (var message in messages) {
    var key = message.resourceId;
    var placeholders = message.placeholders.values;

    buffer.writeln('\t@override');
    if (message.placeholders.isEmpty) {
      buffer.writeln(
          "  String get $key => Crowdin.getText(localeName, '$key') ?? _fallbackTexts.$key;");
    } else {
      var params = _generateMethodParameters(message).join(', ');
      var values = placeholders.map((placeholder) => placeholder.name).join(', ');
      var args = placeholders
          .map((placeholder) => '\'${placeholder.name}\':${placeholder.name}')
          .join(', ');
      buffer.writeln(
          "\tString $key($params) => Crowdin.getText(localeName, '$key', {$args}) ?? _fallbackTexts.$key($values);");
    }
    buffer.writeln('');
  }

  // for (String key in keys) {
  //   buffer.writeln('  @override');
  //   buffer.writeln("  String get $key => Crowdin.getText('$key') ?? _fallbackTexts.$key;");
  //   buffer.writeln('');
  // }

  buffer.writeln(''' 
}

class _CrowdinLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _CrowdinLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.delegate.load(locale)
          .then((fallback) => CrowdinLocalization(locale.toString(), fallback));

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.contains(locale);

  @override
  bool shouldReload(_CrowdinLocalizationsDelegate old) => false;
}''');

  return buffer.toString();
}

List<String> _generateMethodParameters(Message message) {
  assert(message.placeholders.isNotEmpty);
  final countPlaceholder = message.isPlural ? message.getCountPlaceholder() : Object;
  return message.placeholders.values.map((Placeholder placeholder) {
    final type = placeholder == countPlaceholder ? 'num' : placeholder.type;
    return '${type ?? Object} ${placeholder.name}';
  }).toList();
}
