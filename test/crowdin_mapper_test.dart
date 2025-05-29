import 'package:crowdin_sdk/src/crowdin_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrowdinMapper.mapLocale', () {
    test('should return same locale when locale is not in map', () {
      expect(CrowdinMapper.mapLocale(const Locale('en')), const Locale('en'));
    });

    test('should map locale correctly when language tag is used', () {
      expect(
          CrowdinMapper.mapLocale(const Locale('hy')), const Locale('hy-AM'));
    });

    test('should return same locale when language tag is not in map', () {
      expect(CrowdinMapper.mapLocale(const Locale('ja')), const Locale('ja'));
    });
  });

  group('CrowdinMapper.localeFromLanguageCode', () {
    test('should return correct Locale for language code with country', () {
      expect(CrowdinMapper.localeFromLanguageCode('nl-BE'),
          const Locale('nl', 'BE'));
    });

    test(
        'should return Crowdin side locale correctly when language tag is used',
        () {
      expect(CrowdinMapper.localeFromLanguageCode('zh'), const Locale('zh-CN'));
    });

    test('should return correct Locale for language code without country', () {
      expect(CrowdinMapper.localeFromLanguageCode('en'), const Locale('en'));
    });

    test('should return same locale when language code is not in map', () {
      expect(CrowdinMapper.localeFromLanguageCode('xx-YY'),
          const Locale('xx', 'YY'));
    });
  });
}
