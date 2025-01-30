import 'dart:async';
import 'dart:convert';

import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/crowdin_api.dart';
import 'package:crowdin_sdk/src/crowdin_logger.dart';
import 'package:crowdin_sdk/src/exceptions/crowdin_exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'crowdin_oauth.dart';

const String _kAuthorizationEndpoint =
    'https://accounts.crowdin.com/oauth/authorize';

class CrowdinPreviewManager {
  final authorizationEndpoint = Uri.parse(_kAuthorizationEndpoint);

  final CrowdinAuthConfig config;
  final String distributionHash;
  final List<String> mappingFilePaths;
  Function(String key)? _onTranslationUpdate;

  late CrowdinOauth _auth;
  late CrowdinApi _api;
  late oauth2.Credentials _credentials;

  late final WebSocketChannel _channel;

  Map<String, String> finalMapping = {};

  _CrowdinMetadata? _metadata;

  CrowdinPreviewManager({
    required this.config,
    required this.distributionHash,
    required this.mappingFilePaths,
  });

  late AppResourceBundle previewArb;

  // set preview arb when locale changes
  void setPreviewArb(AppResourceBundle distributionArb) {
    previewArb = distributionArb;

    if (_metadata != null) {
      _subscribeToAllTranslations();
    }
  }

  Future<void> init(Function(String key) onTranslationUpdate) async {
    _onTranslationUpdate = onTranslationUpdate;
    _api = CrowdinApi();
    _auth = CrowdinOauth(config, (_onAuthenticated))..authenticate();

    for (String path in mappingFilePaths) {
      var mappingData = await _api.getMapping(
        distributionHash: distributionHash,
        mappingFilePath: path,
      );
      if (mappingData != null) {
        finalMapping = getFinalMappingData(mappingData, finalMapping);
      }
    }
  }

  // sort only needed key-value pairs
  Map<String, String> getFinalMappingData(
      Map<String, dynamic> mappingData, Map<String, String> currentMap) {
    var data = mappingData;
    Map<String, String> finalMappingData = currentMap;
    data.removeWhere((key, value) => key.startsWith('@'));
    data.forEach((key, value) {
      finalMappingData[key] = value.toString();
    });
    return finalMappingData;
  }

  Future<void> authenticate() async {
    _auth.authenticate();
  }

  Future<void> _onAuthenticated(oauth2.Credentials credentials) async {
    _credentials = credentials;
    await _getMetadata(credentials: credentials);
    _connectWebSocket(credentials: credentials);
  }

  Future<void> _getMetadata({required oauth2.Credentials credentials}) async {
    var metadataResp = await _api.getMetadata(
      accessToken: credentials.accessToken,
      distributionHash: distributionHash,
      organizationName: config.organizationName,
    );
    if (metadataResp != null) {
      var metadata = _CrowdinMetadata.fromJson(metadataResp);
      _metadata = metadata;
    } else {
      throw CrowdinException(
          "Can't receive metadata. Real-time preview will be unavailable");
    }
  }

  Future<void> _connectWebSocket(
      {required oauth2.Credentials credentials}) async {
    _channel = WebSocketChannel.connect(Uri.parse(_metadata!.wsUrl));
    Stream crowdinStream = _channel.stream;
    crowdinStream.listen(
      (message) {
        Map<String, dynamic> messageDecoded = jsonDecode(message);
        Map<String, dynamic> data = messageDecoded['data'];
        String event = messageDecoded['event'];
        String textId = event.split(':').last;
        updatePreviewArb(
          id: textId,
          text: data['text'] ?? '',
        );
      },
      onError: (e) {
        CrowdinException(
            'Something went wrong during receiving translation for real time preview');
      },
    );

    await _subscribeToAllTranslations();
  }

  Future<String?> _getWebsocketTicket({
    required oauth2.Credentials credentials,
    required String event,
  }) async {
    return _api.getWebsocketTicket(
      accessToken: credentials.accessToken,
      event: event,
      organizationName: config.organizationName,
    );
  }

  Future<void> _subscribeToAllTranslations() async {
    String langCode = previewArb.locale.languageCode;
    if (_metadata == null) {
      CrowdinLogger.printLog(
          'Something went wrong during subscribing to translations for real time preview. Metadata is not provided');
    } else {
      _CrowdinMetadata metadata = _metadata!;
      for (var id in finalMapping.values) {
        final String event =
            'update-draft:${metadata.wsHash}:${metadata.projectId}:${metadata.userId}:$langCode:$id';
        final ticket =
            await _getWebsocketTicket(credentials: _credentials, event: event);
        if (ticket != null) {
          var data = jsonEncode({
            'action': 'subscribe',
            'ticket': ticket,
            'event': event,
          });
          _channel.sink.add(data);
        } else {
          CrowdinLogger.printLog(
              'Something went wrong during subscribing to translations for real time preview. Websocket ticket is not provided');
        }
      }
    }
  }

  // update preview arb when translation change received
  @visibleForTesting
  void updatePreviewArb({
    required String id,
    required String text,
  }) {
    String textKey =
        finalMapping.keys.firstWhere((key) => finalMapping[key] == id);
    previewArb.resources[textKey] = text;
    if (_onTranslationUpdate != null) {
      _onTranslationUpdate!('');
    }
  }
}

class _CrowdinMetadata {
  late String projectId;
  late String wsHash;
  late String userId;
  late String wsUrl;

  _CrowdinMetadata(
    this.projectId,
    this.wsHash,
    this.userId,
    this.wsUrl,
  );

  _CrowdinMetadata.fromJson(Map<String, dynamic> json) {
    projectId = json['data']['project']['id'] ?? '';
    wsHash = json['data']['project']['wsHash'] ?? '';
    userId = json['data']['user']['id'] ?? '';
    wsUrl = json['data']['wsUrl'] ?? '';
  }
}
