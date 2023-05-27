import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/real_time_preview/crowdin_preview_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_arb.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CrowdinPreviewManager', () {
    late CrowdinPreviewManager crowdinPreviewManager;
    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      crowdinPreviewManager = CrowdinPreviewManager(
        config: CrowdinAuthConfig(clientId: '', clientSecret: '', redirectUri: ''),
        distributionHash: 'distributionHash',
        mappingFilePaths: ['mappingFilePath1', 'mappingFilePath2'],
      );
      crowdinPreviewManager.setPreviewArb(AppResourceBundle(testArb));
    });

    test('updatePreviewArb updates the previewArb resources correctly', () {
      crowdinPreviewManager.finalMapping = {
        'example': 'id1',
        'hello': 'id2',
      };

      crowdinPreviewManager.updatePreviewArb(
          id: 'id1', text: 'New Text 1', onPreviewArbUpdated: (String textKey) {});
      crowdinPreviewManager.updatePreviewArb(
          id: 'id2', text: 'New Text 2', onPreviewArbUpdated: (String textKey) {});

      expect(crowdinPreviewManager.previewArb.resources['example'], equals('New Text 1'));
      expect(crowdinPreviewManager.previewArb.resources['hello'], equals('New Text 2'));
    });

    test('getFinalMappingData returns map ', () {
      Map<String, String> currentMap = {
        'example': 'test_example',
        'test_key': 'test_text'
      };
      var mappingData = testArb;

      var resultMap = crowdinPreviewManager.getFinalMappingData(mappingData, currentMap);
      expect(resultMap['example'], mappingData['example']);
      expect(resultMap['test_text'], currentMap['test_text']);
    });
  });

  group('getText test with for realTimePreview', () {
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
      Crowdin.arb = AppResourceBundle(testArb);
      Crowdin.crowdinPreviewManager.setPreviewArb(AppResourceBundle(testPreviewArb));
    });
    test('should return values from previewArb', () async {
      String? simpleText = Crowdin.getText('en', 'example');

      String? zeroPluralResult =
          Crowdin.getText('en', 'nThings', {'count': 0, 'thing': 'test_thing'});

      String? pluralResult = Crowdin.getText('en', 'nThings', {'count': 1, 'thing': 'test_thing'});

      expect(simpleText, 'preview_Example');
      expect(zeroPluralResult, 'no preview_test_things');
      expect(pluralResult, '1 preview_test_things');
    });
  });
}
