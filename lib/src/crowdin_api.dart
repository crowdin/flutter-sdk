import 'dart:convert';

import 'package:http/http.dart' as http;

class CrowdinApi {
  Future<Map<String, dynamic>?> loadTranslations({
    required String distributionHash,
    String? path,
  }) async {
    try {
      var response = await http.get(
        Uri.parse('https://distributions.crowdin.net/$distributionHash$path'),
      );
      Map<String, dynamic> responseDecoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return responseDecoded;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getManifest({
    required String distributionHash,
  }) async {
    try {
      var response = await http.get(
        Uri.parse(
            'https://distributions.crowdin.net/$distributionHash/manifest.json'),
      );
      Map<String, dynamic> responseDecoded =
          jsonDecode(utf8.decode(response.bodyBytes));
      return responseDecoded;
    } catch (_) {
      return null;
    }
  }
}
