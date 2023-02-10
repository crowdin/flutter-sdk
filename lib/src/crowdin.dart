import 'dart:convert';
import 'dart:developer';

import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/crowdin_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'crowdin_exceptions.dart';

enum InternetConnectionType { wifi, mobileData, any }

class Crowdin {
  static String _distributionHash = '';
  static Duration _distributionTtl = const Duration(minutes: 15);
  static InternetConnectionType _connectionType = InternetConnectionType.any;


  static Map<String, dynamic> _otaTranslation = {};

  static final CrowdinStorage _storage = CrowdinStorage();

  static Future<String> getArb () async{
    String arb  = await rootBundle.loadString('lib/l10n/en.arb');
    return arb;
  }

  static void init({
    required String distributionHash,
    Duration? distributionTtl,
    InternetConnectionType? connectionType,
  }) async {

    await _storage.init();

    if (distributionTtl != null) _distributionHash = distributionHash;
    log('-=Crowdin=- distributionHash $_distributionHash');

    if (distributionTtl != null) _distributionTtl = distributionTtl;
    log('-=Crowdin=- distributionTtl $_distributionTtl');

    if (connectionType != null) _connectionType = connectionType;
    log('-=Crowdin=- connectionType $_connectionType');
  }

  static Future<void> getDistribution(String locale) async {

    try {
      var result =
      await CrowdinApi.getDistribution(locale: locale, distributionHash: _distributionHash);
      if(result != null) {
        _otaTranslation = result;
        _storage.setDistributionToStorage(jsonEncode(result));
      } else {
        result = _storage.getDistributionFromStorage();
      }
      log('-=Crowdin=- translation $_otaTranslation');
    } catch (ex) {
      // throw CrowdinException(message: 'No translations on Crowdin');
      throw CrowdinException(message: '$ex');
    }


  }

  static String? getText(String key) {
    if(_otaTranslation[key] is String) {}
    String? translation = _otaTranslation[key] is String ? _otaTranslation[key] : null;
    return translation;
  }

  // Future<void> setDistributionToStorage(String distribution) async {
  //   CrowdinStorage storage = CrowdinStorage()..init();
  //   storage.setDistributionToStorage(distribution);
  // }


  Future<Map<String, dynamic>?> getDistributionFromStorage() async {
    Map<String, dynamic>? distributionFromStorage = _storage.getDistributionFromStorage();
   return distributionFromStorage;
  }

}
