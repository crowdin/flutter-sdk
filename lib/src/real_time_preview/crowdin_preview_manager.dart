import 'dart:async';
import 'dart:convert';

import 'package:crowdin_sdk/src/crowdin_api.dart';
import 'package:crowdin_sdk/src/exceptions/crowdin_exceptions.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'crowdin_oauth.dart';

const String _kAuthorizationEndpoint = 'https://accounts.crowdin.com/oauth/authorize';
const String _kTokenEndpoint = 'https://accounts.crowdin.com/oauth/token';

class CrowdinAuthConfig {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String? organizationName;

  CrowdinAuthConfig({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.organizationName,
  });
}

class CrowdinPreviewManager {
  final authorizationEndpoint = Uri.parse(_kAuthorizationEndpoint);

  final CrowdinAuthConfig config;
  final String distributionHash;
  final List<String> mappingFilePaths;
  late Function(String key) _onTranslationUpdate;

  CrowdinPreviewManager({
    required this.config,
    required this.distributionHash,
    required this.mappingFilePaths,
  });

  final tokenEndpoint = Uri.parse(_kTokenEndpoint);

  late CrowdinOauth auth;
  late CrowdinApi api;
  Map<String, String> finalMappingMap = {};
  Map<String, String> updatedTranslations = {};
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
    var metadataResp = await CrowdinApi().getMetadata(
      accessToken: credentials.accessToken,
      distributionHash: distributionHash,
    );
    late CrowdinMetadata metadata;

    if (metadataResp != null) {
      metadata = CrowdinMetadata.fromJson(metadataResp);
      print('-----metadata $metadata');
    } else {
      throw CrowdinException("Can't receive metadata. Real-time preview will be unavailable");
    }

    // if (metadata != null) {
    print('-----webSocket creation');
    var channel = WebSocketChannel.connect(Uri.parse(metadata.wsUrl));
    crowdinStream = channel.stream;
    crowdinStream.listen(
      (message) {
        Map<String, dynamic> messageDecoded = jsonDecode(message);
        Map<String, dynamic> data = messageDecoded['data'];
        String event = messageDecoded['event'];
        String textId = event.split(':').last;
        addToUpdated(id: textId, text: data['text'] ?? '');
        // _onTranslationUpdate();
        print('-----message $message');
      },
      // onError: (er) {},
      // onDone: () {},
    );

    subscribeToAllTranslations(
      channel: channel,
      finalMappingMap: finalMappingMap,
      metadata: metadata,
    );
    // }
  }

  void subscribeToAllTranslations({
    required CrowdinMetadata metadata,
    required Map<String, String> finalMappingMap,
    required WebSocketChannel channel,
  }) {
    // for (var mappingData in mappingDataList) {
    for (var id in finalMappingMap.values) {
      var data = jsonEncode({
        'action': 'subscribe',
        'event': 'update-draft:${metadata.wsHash}:${metadata.projectId}:${metadata.userId}:en:$id'
      });
      print('-----data $data');
      channel.sink.add(data);
    }
    // }
  }

  void addToUpdated({required String id, required String text}) {
    // updatedTranslations.update(id.toString(), (value) => text, ifAbsent: () => text);
    String textKey = finalMappingMap.keys.firstWhere((key) => finalMappingMap[key] == id);
    updatedTranslations.update(textKey, (value) => text, ifAbsent: () => text);
    print('------updatedTranslations $updatedTranslations');
    _onTranslationUpdate(textKey);
  }

  void getTextIdFromEvent() {}
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
