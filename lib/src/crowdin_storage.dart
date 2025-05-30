import 'dart:convert';
import 'dart:ui';

import 'package:crowdin_sdk/src/crowdin_logger.dart';
import 'package:crowdin_sdk/src/exceptions/crowdin_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _kCrowdinTexts = 'crowdin_texts';
String _kTranslationTimestamp = 'translation_timestamp';
String _kIsPausedPermanently = 'is_paused_permanently';
String _kErrorMap = 'errorMap';

class CrowdinStorage {
  CrowdinStorage();

  late SharedPreferences _sharedPrefs;

  Future<SharedPreferences> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    return _sharedPrefs;
  }

  Future<void> setTranslationTimeStamp(int? timestamp) async {
    try {
      if (_sharedPrefs.containsKey(_kTranslationTimestamp)) {
        await _sharedPrefs.remove(_kTranslationTimestamp);
      }
      await _sharedPrefs.setInt(_kTranslationTimestamp, timestamp ?? 1);
    } catch (_) {
      throw CrowdinException("Can't store translation timestamp");
    }
  }

  int? getTranslationTimestamp() {
    try {
      int? translationTimestamp = _sharedPrefs.getInt(_kTranslationTimestamp);
      return translationTimestamp;
    } catch (ex) {
      throw CrowdinException("Can't get translation timestamp from storage");
    }
  }

  Future<void> setDistribution(String distribution) async {
    try {
      if (_sharedPrefs.containsKey(_kCrowdinTexts)) {
        await _sharedPrefs.remove(_kCrowdinTexts);
      }
      await _sharedPrefs.setString(_kCrowdinTexts, distribution);
    } catch (_) {
      throw CrowdinException("Can't store the distribution");
    }
  }

  Map<String, dynamic>? getTranslation(Locale locale) {
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

  void setIsPausedPermanently(bool shouldPause) {
    try {
      _sharedPrefs.setBool(_kIsPausedPermanently, shouldPause);
    } catch (ex) {
      throw CrowdinException("Can't store the isPausedPermanently value");
    }
  }

  bool? getIsPausedPermanently() {
    try {
      bool? isPausedPermanently = _sharedPrefs.getBool(_kIsPausedPermanently);
      return isPausedPermanently;
    } catch (ex) {
      throw CrowdinException("Can't get isPausedPermanently from storage");
    }
  }

  void setErrorMap(Map<String, int> errorMap) {
    try {
      _sharedPrefs.setString(_kErrorMap, jsonEncode(errorMap));
    } catch (ex) {
      throw CrowdinException("Can't store the errorMap");
    }
  }

  Map<String, int>? getErrorMap() {
    try {
      String? errorMapString = _sharedPrefs.getString(_kErrorMap);
      if (errorMapString != null) {
        Map<String, dynamic> decodedMap = jsonDecode(errorMapString);
        return decodedMap.map((k, v) => MapEntry(k, v as int));
      }
      return errorMapString != null ? jsonDecode(errorMapString) : null;
    } catch (ex) {
      CrowdinLogger.printLog("Can't get errorMap from storage");
      return null;
    }
  }
}
