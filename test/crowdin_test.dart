import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/crowdin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:crowdin_sdk/src/crowdin_api.dart';
import 'package:crowdin_sdk/src/crowdin_storage.dart';

class MockCrowdinApi extends Mock implements CrowdinApi {}

class MockCrowdinStorage extends Mock implements CrowdinStorage {}

void main() {
  group('Crowdin', () {
    late MockCrowdinApi mockApi;
    late MockCrowdinStorage mockStorage;

    setUp(() {
      mockApi = MockCrowdinApi();
      // CrowdinApi.setInstance(mockApi);

      mockStorage = MockCrowdinStorage();
      // Crowdin._storage.setInstance(mockStorage);
    });

    test('init() initializes Crowdin with the given parameters', () async {
      const distributionHash = 'test_distribution_hash';
      const updatesInterval = Duration(minutes: 30);
      const connectionType = InternetConnectionType.mobileData;

      when(mockApi.getManifest(distributionHash: distributionHash)).thenAnswer((_) async =>
      {
        'timestamp': 1234567890,
        'content': {'en': ['en.arb']}
      });

      await Crowdin.init(
        distributionHash: distributionHash,
        updatesInterval: updatesInterval,
        connectionType: connectionType,
      );

      verify(mockApi.getManifest(distributionHash: distributionHash)).called(1);
      // expect(Crowdin._distributionHash, distributionHash);
      // expect(Crowdin._updatesInterval, updatesInterval);
      // expect(Crowdin._connectionType, connectionType);
      // expect(Crowdin._distributionsMap, {'en': ['en.arb']});
      // expect(Crowdin._timestamp, 1234567890);
    });

    test('loadTranslations() downloads and saves translations', () async {
      const distributionHash = 'test_distribution_hash';
      const locale = Locale('en');
      const distribution = {'key1': 'value1', 'key2': 'value2'};

      when(mockApi.loadTranslations(path: 'en.arb', distributionHash: distributionHash))
          .thenAnswer((_) async => distribution);

      await Crowdin.init(distributionHash: distributionHash);
      await Crowdin.loadTranslations(locale);

      verify(mockApi.loadTranslations(path: 'en.arb', distributionHash: distributionHash)).called(
          1);
      verify(mockStorage.setDistributionToStorage('{"key1":"value1","key2":"value2"}')).called(1);
      verify(mockStorage.setTranslationTimeStampStorage(any)).called(1);
      // expect(Crowdin._arb, isNotNull);
    });

    test('getText() returns the value for the given key', () {
      const locale = 'en';
      const key = 'key1';
      const value = 'value1';
      const args = {'arg1': 'value1', 'arg2': 'value2'};
      const distribution = {'key1': 'value1', 'key2': 'value2'};

      // Crowdin._arb = AppResourceBundle(distribution);

      expect(Crowdin.getText(locale, key), value);
      expect(Crowdin.getText(locale, 'unknown_key'), isNull);
      expect(Crowdin.getText(locale, key, args), 'value1');
    });
  });}