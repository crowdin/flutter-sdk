import 'dart:async';
import 'dart:convert';

import 'package:crowdin_sdk/src/common/gen_l10n_types.dart';
import 'package:crowdin_sdk/src/crowdin_api.dart';
import 'package:crowdin_sdk/src/exceptions/crowdin_exceptions.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'crowdin_auth_config.dart';
import 'crowdin_oauth.dart';

const String _kAuthorizationEndpoint = 'https://accounts.crowdin.com/oauth/authorize';
const String _kTokenEndpoint = 'https://accounts.crowdin.com/oauth/token';


class CrowdinPreviewManager {
  final authorizationEndpoint = Uri.parse(_kAuthorizationEndpoint);

  final CrowdinAuthConfig config;
  final String distributionHash;
  final List<String> mappingFilePaths;
  late Function(String key) _onTranslationUpdate;

  late final WebSocketChannel _channel;
  late final CrowdinMetadata _metadata;

  CrowdinPreviewManager({
    required this.config,
    required this.distributionHash,
    required this.mappingFilePaths,
  });

  late AppResourceBundle previewArb;

  void setPreviewArb(AppResourceBundle distributionArb) {
    previewArb = distributionArb;

    subscribeToAllTranslations();
  }

  final tokenEndpoint = Uri.parse(_kTokenEndpoint);

  late CrowdinOauth auth;
  late CrowdinApi api;
  Map<String, String> finalMappingMap = {};
  late Stream crowdinStream;

  Future<void> init(Function(String key) onTranslationUpdate) async {
    _onTranslationUpdate = onTranslationUpdate;
    api = CrowdinApi();
    auth = CrowdinOauth(config, (onAuthenticated))..authenticate();

    for (String path in mappingFilePaths) {
      var mappingData = await api.getMapping(
        distributionHash: distributionHash,
        mappingFilePath: path,
      );
      if (mappingData != null) {
        mappingData.removeWhere((key, value) => key.startsWith('@'));
        mappingData.forEach((key, value) {
          finalMappingMap[key] = value.toString();
        });
      }
      print('-----finalMappingMap $finalMappingMap');
    }
  }

  Future<void> authenticate() async {
    auth.authenticate();
  }

  Future<void> onAuthenticated(oauth2.Credentials credentials) async {
    _connectWebSocket(credentials: credentials);
  }

  Future<void> _connectWebSocket({required oauth2.Credentials credentials}) async {
    var metadataResp = await api.getMetadata(
      accessToken: credentials.accessToken,
      distributionHash: distributionHash,
    );
    if (metadataResp != null) {
      _metadata = CrowdinMetadata.fromJson(metadataResp);
      print('-----metadata $_metadata');
    } else {
      throw CrowdinException("Can't receive metadata. Real-time preview will be unavailable");
    }

    print('-----webSocket creation');
    _channel = WebSocketChannel.connect(Uri.parse(_metadata.wsUrl));
    crowdinStream = _channel.stream;
    crowdinStream.listen(
      (message) {
        Map<String, dynamic> messageDecoded = jsonDecode(message);
        Map<String, dynamic> data = messageDecoded['data'];
        String event = messageDecoded['event'];
        String textId = event.split(':').last;
        addToUpdated(id: textId, text: data['text'] ?? '');
      },
      onError: (e) {
        CrowdinException(
            'Something went wrong during receiving translation ( for real time preview');
      },
    );

    subscribeToAllTranslations();
  }

  void subscribeToAllTranslations() {
    String langCode = previewArb.locale.languageCode;
    for (var id in finalMappingMap.values) {
      var data = jsonEncode({
        'action': 'subscribe',
        'event':
            'update-draft:${_metadata.wsHash}:${_metadata.projectId}:${_metadata.userId}:$langCode:$id',
      });
      print('-----data $data');
      _channel.sink.add(data);
    }
  }

  void addToUpdated({required String id, required String text}) {
    String textKey = finalMappingMap.keys.firstWhere((key) => finalMappingMap[key] == id);
    previewArb.resources[textKey] = text;
    _onTranslationUpdate(textKey);
  }
}

class UpdatedTranslation {
  final String key;
  final String text;
  final int id;
  final String pluralForm;

  UpdatedTranslation({
    required this.key,
    required this.text,
    required this.id,
    required this.pluralForm,
  });
}

class CrowdinMetadata {
  late String projectId;
  late String wsHash;
  late String userId;
  late String wsUrl;

  CrowdinMetadata(this.projectId, this.wsHash, this.userId, this.wsUrl);

  CrowdinMetadata.fromJson(Map<String, dynamic> json) {
    projectId = json['data']['project']['id'] ?? '';
    wsHash = json['data']['project']['wsHash'] ?? '';
    userId = json['data']['user']['id'] ?? '';
    wsUrl = json['data']['wsUrl'] ?? '';
  }
}
