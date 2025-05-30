import 'package:crowdin_sdk/src/crowdin_request_limiter.dart';
import 'package:crowdin_sdk/src/crowdin_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crowdin_sdk/src/crowdin_api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'crowdin_request_limiter_test.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late CrowdinApi crowdinApi;
  late MockHttpClient mockHttpClient;
  late CrowdinRequestLimiter requestLimiter;
  late SharedPreferences sharedPrefs;
  late CrowdinStorage storage;

  setUp(() async {
    mockHttpClient = MockHttpClient();
    crowdinApi = CrowdinApi();
    requestLimiter = CrowdinRequestLimiter();
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(Uri());
    crowdinApi.requestLimiter = requestLimiter;
    crowdinApi.client = mockHttpClient;
    sharedPrefs = await SharedPreferences.getInstance();
    storage = CrowdinStorage();
    await storage.init();
  });

  tearDown(() async {
    await sharedPrefs.clear();
  });

  group('CrowdinApi', () {
    test('loadTranslations returns decoded response on success', () async {
      final uri = Uri.https(
          'distributions.crowdin.net', '/hash/path', {'timestamp': '12345'});
      when(() => mockHttpClient.get(uri)).thenAnswer(
        (_) async => http.Response('{"key": "value"}', 200),
      );

      final result = await crowdinApi.loadTranslations(
        distributionHash: 'hash',
        timeStamp: '12345',
        path: '/path',
      );

      expect(result, {'key': 'value'});
    });

    test('getMapping returns decoded response on success', () async {
      final uri = Uri.parse('https://distributions.crowdin.net/hash/path');
      when(() => mockHttpClient.get(uri)).thenAnswer(
        (_) async => http.Response('{"key": "value"}', 200),
      );

      final result = await crowdinApi.getMapping(
        distributionHash: 'hash',
        mappingFilePath: '/path',
      );

      expect(result, {'key': 'value'});
    });

    test('getMetadata returns decoded response on success', () async {
      final uri = Uri.parse(
          'https://api.crowdin.com/api/v2/distributions/metadata?hash=hash');
      when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response('{"data": {"key": "value"}}', 200),
      );

      final result = await crowdinApi.getMetadata(
        accessToken: 'token',
        distributionHash: 'hash',
      );

      expect(result, {
        'data': {'key': 'value'}
      });
    });

    test('getWebsocketTicket returns ticket on success', () async {
      final uri =
          Uri.parse('https://api.crowdin.com/api/v2/user/websocket-ticket');
      when(() => mockHttpClient.post(uri,
          headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response('{"data": {"ticket": "ticket_value"}}', 200),
      );

      final result = await crowdinApi.getWebsocketTicket(
        accessToken: 'token',
        event: 'event_name',
      );

      expect(result, 'ticket_value');
    });

    test('getManifest returns null and increment error count on 400 status',
        () async {
      await requestLimiter.init(storage);

      final uri =
          Uri.parse('https://distributions.crowdin.net/hash/manifest.json');
      when(() => mockHttpClient.get(uri)).thenAnswer(
        (_) async => http.Response('', 400),
      );

      final result = await crowdinApi.getManifest(distributionHash: 'hash');

      expect(result, isNull);
      expect(storage.getErrorMap(), {getTodayDateString(): 1});
    });

    test(
        'getManifest returns null and do not call request when requests paused',
        () async {
      storage.setIsPausedPermanently(true);
      await requestLimiter.init(storage);

      final uri =
          Uri.parse('https://distributions.crowdin.net/hash/manifest.json');
      when(() => mockHttpClient.get(uri)).thenAnswer(
        (_) async => http.Response('', 200),
      );

      final result = await crowdinApi.getManifest(distributionHash: 'hash');

      verifyNever(() => mockHttpClient.get(any()));
      expect(result, isNull);
    });
  });
}
