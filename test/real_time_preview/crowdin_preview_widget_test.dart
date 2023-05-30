import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_arb.dart';

void main() {
  group('CrowdinRealTimePreviewWidget', () {
    Crowdin.setUpRealTimePreviewManager(
        CrowdinAuthConfig(clientId: '', clientSecret: '', redirectUri: ''));
    Crowdin.arb = AppResourceBundle(testArb);
    Crowdin.crowdinPreviewManager
        .setPreviewArb(AppResourceBundle(testPreviewArb));

    testWidgets(
        'CrowdinRealTimePreviewWidget get translation from fallback if withRealTimeUpdates disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CrowdinRealTimePreviewWidget(
            child: Text(Crowdin.getText('en', 'example') ?? ''),
          ),
        ),
      );

      expect(find.text('Example'), findsOneWidget);
    });

    testWidgets(
        'CrowdinRealTimePreviewWidget get updated value after previewArb update',
        (WidgetTester tester) async {
      Crowdin.crowdinPreviewManager
          .setPreviewArb(AppResourceBundle(testPreviewArb));
      Crowdin.withRealTimeUpdates = true;

      await tester.pumpWidget(
        MaterialApp(
          home: CrowdinRealTimePreviewWidget(
            child: Text(Crowdin.getText('en', 'example') ?? ''),
          ),
        ),
      );

      expect(find.text('preview_Example'), findsOneWidget);
      Crowdin.crowdinPreviewManager.finalMapping = {'example': '1'};
      Crowdin.crowdinPreviewManager.updatePreviewArb(
        id: '1',
        text: 'new text',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CrowdinRealTimePreviewWidget(
            child: Text(Crowdin.getText('en', 'example') ?? ''),
          ),
        ),
      );

      expect(find.text('new text'), findsOneWidget);
    });
  });
}
