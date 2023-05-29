import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/real_time_preview/crowdin_preview_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_arb.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CrowdinPreviewManager updatePreviewArb tests', () {
    late CrowdinPreviewManager crowdinPreviewManager;
    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      crowdinPreviewManager = CrowdinPreviewManager(
        config:
            CrowdinAuthConfig(clientId: '', clientSecret: '', redirectUri: ''),
        distributionHash: 'distributionHash',
        mappingFilePaths: ['mappingFilePath1', 'mappingFilePath2'],
      );
      crowdinPreviewManager.setPreviewArb(AppResourceBundle(testArb));
    });

    test('updatePreviewArb should update value in the previewArb', () {
      crowdinPreviewManager.finalMapping = {
        'example': 'id1',
        'hello': 'id2',
      };

      crowdinPreviewManager.updatePreviewArb(
          id: 'id1',
          text: 'New Text 1',
          onPreviewArbUpdated: (String textKey) {});
      crowdinPreviewManager.updatePreviewArb(
          id: 'id2',
          text: 'New Text 2',
          onPreviewArbUpdated: (String textKey) {});

      expect(crowdinPreviewManager.previewArb.resources['example'],
          equals('New Text 1'));
      expect(crowdinPreviewManager.previewArb.resources['hello'],
          equals('New Text 2'));
    });

    test('getFinalMappingData returns updated map if value exist', () {
      Map<String, String> currentMap = {
        'example': 'test_example',
      };
      var mappingData = testArb;

      var resultMap =
          crowdinPreviewManager.getFinalMappingData(mappingData, currentMap);
      expect(resultMap['example'], mappingData['example']);
    });
  });

  group('CrowdinPreviewManager getFinalMappingData tests', () {
    late CrowdinPreviewManager crowdinPreviewManager;
    var mappingData = testArb;
    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      crowdinPreviewManager = CrowdinPreviewManager(
        config:
            CrowdinAuthConfig(clientId: '', clientSecret: '', redirectUri: ''),
        distributionHash: 'distributionHash',
        mappingFilePaths: ['mappingFilePath1', 'mappingFilePath2'],
      );
    });
    test('getFinalMappingData returns updated map if value exist', () {
      Map<String, String> currentMap = {
        'example': 'test_example',
      };
      var resultMap =
          crowdinPreviewManager.getFinalMappingData(mappingData, currentMap);
      expect(resultMap['example'], mappingData['example']);
    });

    test('getFinalMappingData returns updated map with new values', () {
      Map<String, String> currentMap = {
        'example': 'test_example',
      };
      var resultMap =
          crowdinPreviewManager.getFinalMappingData(mappingData, currentMap);
      expect(resultMap['example'], mappingData['example']);
    });

    test('getFinalMappingData returns current map if mappingData is empty', () {
      Map<String, String> currentMap = {
        'example': 'test_example',
        'test_key': 'test_text'
      };
      Map<String, dynamic> mappingData = {};

      var resultMap =
          crowdinPreviewManager.getFinalMappingData(mappingData, currentMap);
      expect(resultMap, currentMap);
    });

    test('getFinalMappingData returns current map if mappingData is empty', () {
      Map<String, String> currentMap = {
        'example': 'test_example',
        'test_key': 'test_text'
      };
      Map<String, dynamic> mappingData = {'new_key': 'test_text'};

      var resultMap =
          crowdinPreviewManager.getFinalMappingData(mappingData, currentMap);
      expect(resultMap['new_key'], mappingData['new_key']);
    });
  });

  group('getText test with realTimePreview enabled', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Crowdin.init(
          distributionHash: '',
          withRealTimeUpdates: true,
          authConfigurations: CrowdinAuthConfig(
            clientId: 'clientId',
            clientSecret: 'clientSecret',
            redirectUri: 'redirectUri',
          ));
      Crowdin.arb = AppResourceBundle(testPreviewArb);
      Crowdin.crowdinPreviewManager
          .setPreviewArb(AppResourceBundle(testPreviewArb));
    });
    test('should return values from previewArb', () async {
      String? simpleText = Crowdin.getText('en', 'example');

      String? zeroPluralResult =
          Crowdin.getText('en', 'nThings', {'count': 0, 'thing': 'test_thing'});

      String? pluralResult =
          Crowdin.getText('en', 'nThings', {'count': 1, 'thing': 'test_thing'});

      expect(simpleText, 'preview_Example');
      expect(zeroPluralResult, 'no preview_test_things');
      expect(pluralResult, '1 preview_test_things');
    });

    test('should return null if arb is null', () async {
      Crowdin.arb = null;

      String? result = Crowdin.getText('en', 'example');

      expect(result, isNull);
    });

    test('should return null if wrong key specified', () async {
      String? result = Crowdin.getText('en', 'wrong key');

      expect(result, isNull);
    });

    test('should return value if all arguments specified right', () async {
      String? result = Crowdin.getText('en', 'example');

      expect(result, 'preview_Example');
    });

    test('should return value with a single parameter', () async {
      String? result =
          Crowdin.getText('en', 'hello', {'userName': 'test name'});

      expect(result, 'preview_Hello test name');
    });

    test('should return value with a plurals', () async {
      String? zeroPluralResult =
          Crowdin.getText('en', 'nThings', {'count': 0, 'thing': 'test_thing'});
      String? pluralResult =
          Crowdin.getText('en', 'nThings', {'count': 1, 'thing': 'test_thing'});

      expect(zeroPluralResult, 'no preview_test_things');
      expect(pluralResult, '1 preview_test_things');
    });

    test('should return value with a count format param', () async {
      String? resultValue = Crowdin.getText('en', 'counter', {'value': 10});
      String? resultThousand =
          Crowdin.getText('en', 'counter', {'value': 1000});
      String? resultMillion =
          Crowdin.getText('en', 'counter', {'value': 1000000});
      String? resultBillion =
          Crowdin.getText('en', 'counter', {'value': 1000000000});
      String? resultTrillion =
          Crowdin.getText('en', 'counter', {'value': 1000000000000});

      expect(resultValue, 'preview_Counter: 10');
      expect(resultThousand, 'preview_Counter: 1 thousand');
      expect(resultMillion, 'preview_Counter: 1 million');
      expect(resultBillion, 'preview_Counter: 1 billion');
      expect(resultTrillion, 'preview_Counter: 1 trillion');
    });
  });
}
