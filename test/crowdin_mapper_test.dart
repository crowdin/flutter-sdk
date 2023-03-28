import 'package:crowdin_sdk/src/crowdin_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should return same locale when locale is not in map', () {
    expect(CrowdinMapper.mapLocale(const Locale('en')), const Locale('en'));
  });

  test('should map locale correctly when language tag is used', () {
    expect(CrowdinMapper.mapLocale(const Locale('hy')), const Locale('hy-AM'));
  });

  test('should return same locale when language tag is not in map', () {
    expect(CrowdinMapper.mapLocale(const Locale('ja')),const Locale('ja'));
  });
}
