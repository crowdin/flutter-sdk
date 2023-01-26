import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

String _kCrowdinTexts = 'crowdin_texts';

class CrowdinStorage {
  CrowdinStorage();

  static late SharedPreferences _sharedPrefs;

  Future<SharedPreferences> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    return _sharedPrefs;
  }

  Future<void> setDistributionToStorage(String distribution) async {
    await _sharedPrefs.setString(_kCrowdinTexts, distribution);
  }

  Map<String, dynamic>? getDistributionFromStorage() {
    String? distributionStr = _sharedPrefs.getString(_kCrowdinTexts);
    if (distributionStr != null) {
      Map<String, dynamic>? distribution = jsonDecode(distributionStr);
      return distribution;
    }
    return null;
  }
}
