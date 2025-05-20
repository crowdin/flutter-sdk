import 'dart:convert';

import 'package:crowdin_sdk/src/crowdin_request_limiter.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'crowdin_logger.dart';

class CrowdinApi {
  @visibleForTesting
  http.Client client = http.Client();
  @visibleForTesting
  CrowdinRequestLimiter requestLimiter = CrowdinRequestLimiter();

  Future<Map<String, dynamic>?> loadTranslations({
    required String distributionHash,
    required String timeStamp,
    String? path,
  }) async {
    try {
      var response = await client.crowdinGet(
        Uri.https('distributions.crowdin.net', '/$distributionHash$path',
            {'timestamp': timeStamp}),
      );
      if (response == null) return null;
      Map<String, dynamic>? responseDecoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return responseDecoded;
    } catch (ex) {
      CrowdinLogger.printLog(
          "something went wrong. Crowdin couldn't download mapping file. Next exception occurred: $ex");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getManifest({
    required String distributionHash,
  }) async {
    try {
      var response = await client.crowdinGet(
        Uri.parse(
            'https://distributions.crowdin.net/$distributionHash/manifest.json'),
      );
      if (response == null) {
        return null;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        requestLimiter.incrementErrorCounter();
        return null;
      } else {
        Map<String, dynamic> responseDecoded =
            jsonDecode(utf8.decode(response.bodyBytes));
        requestLimiter.reset();
        return responseDecoded;
      }
    } catch (ex) {
      CrowdinLogger.printLog(
          "something went wrong. Crowdin couldn't download manifest file. Next exception occurred: $ex");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMapping({
    required String distributionHash,
    required String mappingFilePath,
  }) async {
    try {
      var response = await client.crowdinGet(Uri.parse(
          'https://distributions.crowdin.net/$distributionHash$mappingFilePath'));
      if (response == null) return null;
      Map<String, dynamic> responseDecoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return responseDecoded;
    } catch (ex) {
      CrowdinLogger.printLog(
          "something went wrong. Crowdin couldn't download mapping file. Next exception occurred: $ex");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getMetadata({
    required String accessToken,
    required String distributionHash,
    String? organizationName,
  }) async {
    try {
      String organizationDomain =
          organizationName != null ? '$organizationName.' : '';
      var response = await client.crowdinGet(
          Uri.parse(
              'https://${organizationDomain}api.crowdin.com/api/v2/distributions/metadata?hash=$distributionHash'),
          headers: {'Authorization': 'Bearer $accessToken'});
      if (response == null) return null;
      Map<String, dynamic> responseDecoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return responseDecoded;
    } catch (ex) {
      CrowdinLogger.printLog(
          "something went wrong. Crowdin couldn't download metadata file. Next exception occurred: $ex");
      return null;
    }
  }

  Future<String?> getWebsocketTicket({
    required String accessToken,
    required String event,
    String? organizationName,
  }) async {
    try {
      String organizationDomain =
          organizationName != null ? '$organizationName.' : '';
      var response = await client.crowdinPost(
          Uri.parse(
              'https://${organizationDomain}api.crowdin.com/api/v2/user/websocket-ticket'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "event": event,
            "context": {"mode": "translate"}
          }));
      if (response == null) return null;
      Map<String, dynamic> responseDecoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return responseDecoded['data']['ticket'];
    } catch (e) {
      CrowdinLogger.printLog(
          "Something went wrong. Crowdin couldn't get the WebSocket ticket. The following exception was thrown:: $e");
      return null;
    }
  }
}

extension _CrowdinHttpInterceptorExtension on http.Client {
  Future<http.Response?> crowdinGet(Uri url,
      {Map<String, String>? headers}) async {
    return CrowdinRequestLimiter().pauseRequests
        ? null
        : get(url, headers: headers);
  }

  Future<http.Response?> crowdinPost(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return CrowdinRequestLimiter().pauseRequests
        ? null
        : post(url, headers: headers, body: body, encoding: encoding);
  }
}
