import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as path;

class CrowdinGenerator1 {
  static Future<void> generate() async {
    final String _projectFolder = Directory.current.path;
    File genFile = File(path.join(
        _projectFolder, '.dart_tool', 'flutter_gen', 'gen_l10n', 'crowdin_localizations.dart'));
    await genFile.create(recursive: true);

    final arbPath = path.join('lib', 'l10n', 'en.arb');
    final arbFile = File(arbPath);
    final arbStr = await arbFile.readAsString();

    List<String> keys = getKeys(jsonDecode(arbStr));

    var content = generationContent(keys: keys);

    await genFile.writeAsString(content, mode: FileMode.writeOnly, flush: true);
  }

  static List<String> getKeys(Map<String, dynamic> arb) {
    List<String> keys = arb.keys.where((element) => !element.startsWith('@')).toList();
    return keys;
  }
}

String generationContent({required List<String> keys}) {
  StringBuffer buffer = StringBuffer();
  buffer.writeln('''import 'dart:convert';

import 'app_localizations.dart';

import 'package:crowdin_sdk/crowdin_sdk.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CrowdinLocalization extends AppLocalizations {
  CrowdinLocalization(String locale) : super(locale);

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
  for (String key in keys) {
    buffer.writeln('  @override');
    buffer.writeln("  String get $key => Crowdin.getText('$key') ?? 'no value';");
    buffer.writeln('');
  }

  buffer.writeln(''' 
}

class _CrowdinLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _CrowdinLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.delegate.load(locale)
          .then((value) => CrowdinLocalization(locale.toString()))
          .whenComplete(() => print);

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_CrowdinLocalizationsDelegate old) => false;
}''');

  return buffer.toString();
}
