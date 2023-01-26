import 'dart:io';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class CrowdinApi {
  HttpClient client = HttpClient();

  static Future<Map<String, dynamic>?> getDistribution({
    required String distributionHash,
    String locale = 'en',
  }) async {
    var response = await http.get(
      Uri.parse('https://distributions.crowdin.net/$distributionHash/content/$locale'),
    );
    Map<String, dynamic> responseDecoded = jsonDecode(utf8.decode(response.bodyBytes));
    log('-=Crowdin=- getDistribution responseDecoded: $responseDecoded');
    return responseDecoded;
  }
}
