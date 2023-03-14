import 'dart:convert';
import 'dart:ui';

import 'package:crowdin_sdk/src/exceptions/crowdin_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _kCrowdinTexts = 'crowdin_texts';
String _kTranslationTimestamp = 'translation_timestamp';

class CrowdinStorage {
  CrowdinStorage();

  late SharedPreferences _sharedPrefs;

  Future<SharedPreferences> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    return _sharedPrefs;
  }

  Future<void> setTranslationTimeStampStorage(int timestamp) async {
    try {
      if (_sharedPrefs.containsKey(_kTranslationTimestamp)) {
        await _sharedPrefs.remove(_kTranslationTimestamp);
      }
      await _sharedPrefs.setInt(_kTranslationTimestamp, timestamp);
    } catch (_) {
      throw CrowdinException("Can't store translation timestamp");
    }
  }

  int? getTranslationTimestampFromStorage() {
    try {
      int? translationTimestamp = _sharedPrefs.getInt(_kTranslationTimestamp);
      return translationTimestamp;
    } catch (ex) {
      throw CrowdinException("Can't get translation timestamp from storage");
    }
  }

  Future<void> setDistributionToStorage(String distribution) async {
    try {
      if (_sharedPrefs.containsKey(_kCrowdinTexts)) {
        await _sharedPrefs.remove(_kCrowdinTexts);
      }
      await _sharedPrefs.setString(_kCrowdinTexts, distribution);
    } catch (_) {
      throw CrowdinException("Can't store the distribution");
    }
  }

  Map<String, dynamic>? getTranslationFromStorage(Locale locale) {
    try {
      String? distributionStr = _sharedPrefs.getString(_kCrowdinTexts);
      if (distributionStr != null) {
        Map<String, dynamic>? distribution = jsonDecode(distributionStr);
        var distributionLocale = Locale(distribution?['@@locale']);
        if (distributionLocale.toString() == locale.toString()) {
          return distribution;
        } else {
          return null;
        }
      }
    } catch (ex) {
      throw CrowdinException("Can't get distribution from storage");
    }
    return null;
  }
}
