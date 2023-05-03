import 'dart:async';

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../crowdin_sdk.dart';

const String _kAuthorizationEndpoint = 'https://accounts.crowdin.com/oauth/authorize';
const String _kTokenEndpoint = 'https://accounts.crowdin.com/oauth/token';

class CrowdinOauth {

  final CrowdinPreviewConfig config;
  final Future<void> Function(oauth2.Credentials) onAuthenticated;

  CrowdinOauth(this.config, this.onAuthenticated);

  late oauth2.Client _client;
  bool _isAuthenticated = false;
  StreamSubscription? _sub;

  Future<void> authenticate() async {

    final authorizationEndpoint = Uri.parse(_kAuthorizationEndpoint);
    final tokenEndpoint = Uri.parse(_kTokenEndpoint);

    var grant = oauth2.AuthorizationCodeGrant(

      config.clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: config.clientSecret,
      basicAuth: false,
    );

    var authorizationUrl =
    grant.getAuthorizationUrl(Uri.parse(config.redirectUri), scopes: ['project', 'tm']);

    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri.toString().startsWith(config.redirectUri)) {
        print('-----2 $uri');

        print('-----uri!.queryParameters ${uri!.queryParameters}');

        var client = await grant.handleAuthorizationResponse(uri.queryParameters);

        _client = client;
        _isAuthenticated = true;
        print('------client.credentials ${client.credentials.accessToken}');
        dispose();
        onAuthenticated(_client.credentials);
        // _connectWebSocket();
      }
    });

    await launchUrl(
      authorizationUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  void dispose() {
    _sub?.cancel();
  }
}