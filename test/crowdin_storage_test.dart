import 'dart:convert';

import 'package:crowdin_sdk/src/crowdin_storage.dart';
import 'package:crowdin_sdk/src/exceptions/crowdin_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CrowdinStorage', () {
    late CrowdinStorage crowdinStorage;
    late SharedPreferences sharedPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPrefs = await SharedPreferences.getInstance();
      crowdinStorage = CrowdinStorage();
      await crowdinStorage.init();
    });

    tearDown(() async {
      await sharedPrefs.clear();
    });

    test('set and get translation timestamp', () async {
      const int timestamp = 123456;
      await crowdinStorage.setTranslationTimeStampStorage(timestamp);
      final int? retrievedTimestamp =
          crowdinStorage.getTranslationTimestampFromStorage();
      expect(retrievedTimestamp, equals(timestamp));
    });

    test('set and get distribution', () async {
      const String distributionJson =
          '{"@@locale": "en_US", "hello_world": "Hello, world!"}';
      final Map<String, dynamic> expectedDistribution =
          jsonDecode(distributionJson);

      await crowdinStorage.setDistributionToStorage(distributionJson);

      final Map<String, dynamic>? retrievedDistribution =
          crowdinStorage.getTranslationFromStorage(const Locale('en', 'US'));

      expect(retrievedDistribution, equals(expectedDistribution));
    });

    test('get exception in case of empty distribution ', () async {
      await crowdinStorage.setDistributionToStorage('');

      expect(
          () => crowdinStorage
              .getTranslationFromStorage(const Locale('en', 'US')),
          throwsA(const TypeMatcher<CrowdinException>()));
    });

    test('get null if timestamp is missed', () async {
      final int? retrievedTimestamp =
          crowdinStorage.getTranslationTimestampFromStorage();

      expect(retrievedTimestamp, isNull);
    });

    test('get null if distribution is missed', () async {
      final Map<String, dynamic>? retrievedDistribution =
          crowdinStorage.getTranslationFromStorage(const Locale('en', 'US'));

      expect(retrievedDistribution, isNull);
    });

    test('get null if distribution locale mismatched', () async {
      const String distributionJson =
          '{"@@locale": "en_US", "hello_world": "Hello, world!"}';
      await crowdinStorage.setDistributionToStorage(distributionJson);

      final Map<String, dynamic>? retrievedDistribution =
          crowdinStorage.getTranslationFromStorage(const Locale('es', 'ES'));

      expect(retrievedDistribution, isNull);
    });
  });
}
