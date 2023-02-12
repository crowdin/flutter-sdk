import 'dart:convert';
import 'dart:ui';

import 'package:crowdin_sdk/src/crowdin_exceptions.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _kCrowdinTexts = 'crowdin_texts';

class CrowdinStorage {
  CrowdinStorage();

  late SharedPreferences _sharedPrefs;

  Future<SharedPreferences> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    return _sharedPrefs;
  }

  Future<void> setDistributionToStorage(String distribution) async {
    try {
      await _sharedPrefs.setString(_kCrowdinTexts, distribution);
    } catch (_) {
      throw CrowdinException(message: "Can't store the distribution");
    }
  }

  Map<String, dynamic>? getDistributionFromStorage(Locale locale) {
    try {
      String? distributionStr = _sharedPrefs.getString(_kCrowdinTexts);
      if (distributionStr != null) {
        Map<String, dynamic>? distribution = jsonDecode(distributionStr);
        var distributionLocale = Locale(distribution?['@@locale']);
        if (Intl.shortLocale(distributionLocale.languageCode) ==
            Intl.shortLocale(locale.languageCode)) {
          return distribution;
        } else {
          return null;
        }
      }
    } catch (ex) {}
    return null;
  }
}