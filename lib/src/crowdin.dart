import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/crowdin_storage.dart';
import 'package:crowdin_sdk/src/crowdin_extractor.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'exceptions/crowdin_exceptions.dart';
import 'common/gen_l10n_types.dart';

enum InternetConnectionType { wifi, mobileData, any }

class Crowdin {
  static String _distributionHash = '';
  static Duration _distributionTtl = const Duration(minutes: 15);
  /// connection type logic will be implemented soon
  static InternetConnectionType _connectionType = InternetConnectionType.any;

  static Map<String, dynamic> _otaTranslation = {};

  static DateTime _distributionTimeToUpdate = DateTime.now();

  static final CrowdinStorage _storage = CrowdinStorage();

  static Future<String> getArb() async {
    String arb = await rootBundle.loadString('lib/l10n/en.arb');
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

    _distributionTimeToUpdate = DateTime.now().add(_distributionTtl);

    await Crowdin.getDistribution(const Locale('en'));
  }

  static Future<void> getDistribution(Locale locale) async {
    Map<String, dynamic>? distribution;

    try {
      if (_canUseCachedDistribution(_distributionTimeToUpdate)) {
        distribution = _storage.getDistributionFromStorage(locale);
        if (distribution != null) {
          _otaTranslation = distribution;
          return;
        }
      }
      distribution = await CrowdinApi.getDistribution(
          locale: locale.toLanguageTag(), distributionHash: _distributionHash);
      if (distribution != null) {
        _storage.setDistributionToStorage(
          jsonEncode(distribution),
        );
      }
    } catch (ex) {
      // throw CrowdinException(message: 'No translations on Crowdin');
      throw CrowdinException('$ex');
    }
    _otaTranslation = distribution ?? {};
  }

  // static String? getText(String key) {
  //   if (_otaTranslation[key] is String) {}
  //   String? translation = _otaTranslation[key] is String ? _otaTranslation[key] : null;
  //   return translation;
  // }

  static final Extractor _extractor = Extractor();

  static String? getText(
    String locale,
    String key, [
    Map<String, dynamic> args = const {},
  ]) {
    try {
      var arb = AppResourceBundle(_otaTranslation);
        return _extractor.getText(locale, arb, key, args);
    } catch (e) {
      return null;
    }
  }
}

bool _canUseCachedDistribution(DateTime distributionTimeToUpdate) {
  bool canUseCachedDistribution = distributionTimeToUpdate.isAfter(DateTime.now());
  return canUseCachedDistribution;
}
