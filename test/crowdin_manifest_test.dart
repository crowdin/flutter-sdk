import 'dart:convert';
import 'dart:ui';

import 'package:crowdin_sdk/src/crowdin.dart';
import 'package:crowdin_sdk/src/exceptions/crowdin_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    var manifest = jsonDecode('''
      {
        "files": [
          "/develop/lib/localization/locales/example_%locale_with_underscore%.arb"
        ],
        "languages": [
          "zh-CN",
          "nl",
          "nl-BE",
          "en",
          "en-GB",
          "fi",
          "fr",
          "de",
          "it",
          "ja",
          "pt",
          "ru",
          "es",
          "sv",
          "tr"
        ],
        "language_mapping": {
          "nl": {
            "locale_with_underscore": "nl"
          },
          "fi": {
            "locale_with_underscore": "fi"
          },
          "fr": {
            "locale_with_underscore": "fr"
          },
          "de": {
            "locale_with_underscore": "de"
          },
          "it": {
            "locale_with_underscore": "it"
          },
          "ja": {
            "locale_with_underscore": "ja"
          },
          "pt": {
            "locale_with_underscore": "pt"
          },
          "ru": {
            "locale_with_underscore": "ru"
          },
          "es": {
            "locale_with_underscore": "es"
          },
          "sv": {
            "locale_with_underscore": "sv"
          },
          "tr": {
            "locale_with_underscore": "tr"
          },
          "zh-CN": {
            "locale_with_underscore": "zh"
          }
        },
        "custom_languages": [],
        "timestamp": 1747301471,
        "content": {
          "zh-CN": [
            "/content/develop/lib/localization/locales/example_zh.arb"
          ],
          "nl": [
            "/content/develop/lib/localization/locales/example_nl.arb"
          ],
          "nl-BE": [
            "/content/develop/lib/localization/locales/example_nl_BE.arb"
          ],
          "en": [
            "/content/develop/lib/localization/locales/example_en_US.arb"
          ],
          "en-GB": [
            "/content/develop/lib/localization/locales/example_en_GB.arb"
          ],
          "en-US": [
            "/content/develop/lib/localization/locales/example_en_US.arb"
          ],
          "fi": [
            "/content/develop/lib/localization/locales/example_fi.arb"
          ],
          "fr": [
            "/content/develop/lib/localization/locales/example_fr.arb"
          ],
          "de": [
            "/content/develop/lib/localization/locales/example_de.arb"
          ],
          "it": [
            "/content/develop/lib/localization/locales/example_it.arb"
          ],
          "ja": [
            "/content/develop/lib/localization/locales/example_ja.arb"
          ],
          "pt": [
            "/content/develop/lib/localization/locales/example_pt.arb"
          ],
          "ru": [
            "/content/develop/lib/localization/locales/example_ru.arb"
          ],
          "es": [
            "/content/develop/lib/localization/locales/example_es.arb"
          ],
          "sv": [
            "/content/develop/lib/localization/locales/example_sv.arb"
          ],
          "tr": [
            "/content/develop/lib/localization/locales/example_tr.arb"
          ]
        },
        "mapping": [
          "/mapping/develop/lib/localization/locales/example_en_US.arb"
        ]
      }
''');
    Crowdin.manifest = manifest;
  });

  group('Crowdin.checkManifestForLocale', () {
    test('should throw if locale is not supported according to manifest', () {
      expect(
        () => Crowdin.checkManifestForLocale(const Locale('xx')),
        throwsA(isA<CrowdinException>()),
      );
    });
    test('should not throw if locale is supported according to manifest', () {
      expect(() => Crowdin.checkManifestForLocale(const Locale('es')),
          isA<void>());
    });
    test(
        'should succeed and fallback on language code only if locale with both language and country code is not found',
        () {
      expect(() => Crowdin.checkManifestForLocale(const Locale('en', 'US')),
          isA<void>());
    });
    test('should throw if manifest not set', () {
      Crowdin.manifest = null;
      expect(() => Crowdin.checkManifestForLocale(const Locale('en')),
          throwsA(isA<CrowdinException>()));
    });
  });

  group('Crowdin.loadTranslations', () {
    test('should not throw if manifest not set', () async {
      Crowdin.manifest = null;
      expect(() async => await Crowdin.loadTranslations(const Locale('en')),
          isA<void>());
    });
  });
}
