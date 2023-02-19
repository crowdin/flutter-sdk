import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CrowdinApi {
  HttpClient client = HttpClient();

  static Future<Map<String, dynamic>?> getDistribution({
    required String distributionHash,
    String? path,
  }) async {
    var response = await http.get(
      Uri.parse('https://distributions.crowdin.net/$distributionHash$path'),
    );
    Map<String, dynamic> responseDecoded = jsonDecode(utf8.decode(response.bodyBytes));
    return responseDecoded;
  }

  static Future<Map<String, dynamic>?> getManifest({
    required String distributionHash,
  }) async {
    var response = await http.get(
      Uri.parse('https://distributions.crowdin.net/$distributionHash/manifest.json'),
    );
    Map<String, dynamic> responseDecoded = jsonDecode(utf8.decode(response.bodyBytes));
    return responseDecoded;
  }
}
