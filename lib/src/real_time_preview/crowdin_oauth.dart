import 'dart:async';

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'crowdin_auth_config.dart';

const String _kAuthorizationEndpoint =
    'https://accounts.crowdin.com/oauth/authorize';
const String _kTokenEndpoint = 'https://accounts.crowdin.com/oauth/token';

class CrowdinOauth {
  final CrowdinAuthConfig config;
  final Future<void> Function(oauth2.Credentials) onAuthenticated;

  CrowdinOauth(this.config, this.onAuthenticated);

  late oauth2.Client _client;
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

    var authorizationUrl = grant.getAuthorizationUrl(
        Uri.parse(config.redirectUri),
        scopes: ['project.translation']);

    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.toString().startsWith(config.redirectUri)) {
        var client =
            await grant.handleAuthorizationResponse(uri.queryParameters);

        _client = client;
        dispose();
        onAuthenticated(_client.credentials);
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
