import 'dart:async';
import 'dart:convert';

import 'package:crowdin_sdk/src/crowdin_api.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'crowdin_oauth.dart';

const String _kAuthorizationEndpoint = 'https://accounts.crowdin.com/oauth/authorize';
const String _kTokenEndpoint = 'https://accounts.crowdin.com/oauth/token';

class CrowdinPreviewConfig {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String? organizationName;

  CrowdinPreviewConfig({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.organizationName,
  });
}

class CrowdinPreviewManager {
  final authorizationEndpoint = Uri.parse(_kAuthorizationEndpoint);

  final CrowdinPreviewConfig config;
  final String distributionHash;

  CrowdinPreviewManager({
    required this.config,
    required this.distributionHash,
  });

  final tokenEndpoint = Uri.parse(_kTokenEndpoint);
  late CrowdinOauth auth;


  Future<void> init () async {

  }

  Future<void> authenticate() async {

    auth =  CrowdinOauth(config, (onAuthenticated));
    auth.authenticate();
  }

  Future<void> onAuthenticated (oauth2.Credentials credentials) async {

    _connectWebSocket(credentials: credentials);

  }

  Future<void> _connectWebSocket({required oauth2.Credentials credentials}) async {
    var wsUrl = await CrowdinApi().getWebSocket(
      accessToken: credentials.accessToken,
      distributionHash: distributionHash,
    );
    if (wsUrl != null) {
      print('-----webSocket creation');
      var channel = WebSocketChannel.connect(Uri.parse('wss://ws-lb.crowdin.com'));
      var data = jsonEncode(
          {'action': 'subscribe', 'event': 'update-draft:973b40b8:568227:15615549:en:7'});
      print('-----data $data');
      channel.sink.add(data);
      channel.stream.listen((message) {
        print('-----message $message');
        channel.sink.add('received!');
      }, onError: (er) {
        print('------er $er');
      }, onDone: () {
        print('------onDone');
      });
    }
  }
}
