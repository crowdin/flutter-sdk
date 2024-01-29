import 'dart:async';
import 'dart:convert';

import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/crowdin_api.dart';
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
      _subscribeToAllTranslations(_metadata!);
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
    _metadata = await _getMetadata(credentials: credentials);
    _connectWebSocket(credentials: credentials);
  }

  Future<_CrowdinMetadata> _getMetadata(
      {required oauth2.Credentials credentials}) async {
    var metadataResp = await _api.getMetadata(
      accessToken: credentials.accessToken,
      distributionHash: distributionHash,
      organizationName: config.organizationName,
    );
    if (metadataResp != null) {
      var metadata = _CrowdinMetadata.fromJson(metadataResp);
      return metadata;
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
            'Something went wrong during receiving translation ( for real time preview');
      },
    );

    if (_metadata != null) {
      _subscribeToAllTranslations(_metadata!);
    }
  }

  void _subscribeToAllTranslations(_CrowdinMetadata metadata) {
    String langCode = previewArb.locale.languageCode;
    for (var id in finalMapping.values) {
      var data = jsonEncode({
        'action': 'subscribe',
        'event':
            'update-draft:${metadata.wsHash}:${metadata.projectId}:${metadata.userId}:$langCode:$id',
      });
      _channel.sink.add(data);
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
