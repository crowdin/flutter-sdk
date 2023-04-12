import 'dart:io';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'common/gen_l10n_types.dart';
import 'gen/l10n_config.dart';

class CrowdinGenerator {
  static Future<void> generate() async {
    final String projectDirectory = Directory.current.path;

    L10nConfig l10nConfig = await L10nConfig.getL10nConfig();
    File genFile =
        File(path.join(projectDirectory, l10nConfig.finalOutputDir, 'crowdin_localizations.dart'));
    await genFile.create(recursive: true);

    final arbPath = path.join(l10nConfig.arbDir, l10nConfig.templateArbFile);
    final arbFile = File(arbPath);
    final arbStr = await arbFile.readAsString();

    List<String> keys = getKeys(jsonDecode(arbStr));
    var content = generationContent(
      keys: keys,
      arbResource: jsonDecode(arbStr),
      l10nConfig: l10nConfig,
    );
    await genFile.writeAsString(content, mode: FileMode.writeOnly, flush: true);
  }

  static List<String> getKeys(Map<String, Object?> arb) {
    List<String> keys = arb.keys.where((element) => !element.startsWith('@')).toList();
    return keys;
  }
}

String generationContent(
    {required List<String> keys,
    required Map<String, Object?> arbResource,
    required L10nConfig l10nConfig}) {
  StringBuffer buffer = StringBuffer();
  buffer.writeln('''import 'dart:convert';

import '${l10nConfig.outputLocalizationFile}';

import 'package:crowdin_sdk/crowdin_sdk.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CrowdinLocalization extends ${l10nConfig.outputClass} {
  final ${l10nConfig.outputClass} _fallbackTexts;
  
  CrowdinLocalization(String locale, ${l10nConfig.outputClass} fallbackTexts) : _fallbackTexts = fallbackTexts, super(locale);

  static const LocalizationsDelegate<${l10nConfig.outputClass}> delegate = _CrowdinLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <
      LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = ${l10nConfig.outputClass}.supportedLocales;
 ''');

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

  buffer.writeln(''' 
}

class _CrowdinLocalizationsDelegate extends LocalizationsDelegate<${l10nConfig.outputClass}> {
  const _CrowdinLocalizationsDelegate();

  @override
  Future<${l10nConfig.outputClass}> load(Locale locale) =>
      ${l10nConfig.outputClass}.delegate.load(locale)
          .then((fallback) => CrowdinLocalization(locale.toString(), fallback));

  @override
  bool isSupported(Locale locale) => ${l10nConfig.outputClass}.supportedLocales.contains(locale);

  @override
  bool shouldReload(_CrowdinLocalizationsDelegate old) => false;
}''');

  return buffer.toString();
}

List<String> _generateMethodParameters(Message message) {
  assert(message.placeholders.isNotEmpty);
  final pluralPlaceholder = message.isPlural ? message.getCountPlaceholder() : null;
  return message.placeholders.values.map((Placeholder placeholder) {
    final type = placeholder.type == pluralPlaceholder?.type
        ? specifyPluralType(pluralPlaceholder?.type, Platform.version)
        : placeholder.type;
    return '${type ?? Object} ${placeholder.name}';
  }).toList();
}

//need specifying plural types since changes in gen_l10n from Flutter 3.7.0
//https://docs.flutter.dev/development/tools/sdk/release-notes/release-notes-3.7.0
@visibleForTesting
String? specifyPluralType(String? type, String dartVersion) {
  List<String> dartVersionNumbers = dartVersion.split('.');
  var major = int.tryParse(dartVersionNumbers[0]);
  var minor = int.tryParse(dartVersionNumbers[1]);

  if (major == null || minor == null) {
    return type;
  }

  if (major > 2 || (major == 2 && minor >= 19)) {
    return type;
  } else {
    return 'num';
  }
}
