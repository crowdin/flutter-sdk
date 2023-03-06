import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/crowdin_storage.dart';
import 'package:crowdin_sdk/src/crowdin_extractor.dart';

import 'exceptions/crowdin_exceptions.dart';
import 'common/gen_l10n_types.dart';

enum InternetConnectionType { wifi, mobileData, any }

class Crowdin {
  static String _distributionHash = '';
  static Duration _updatesInterval = const Duration(minutes: 15);

  /// connection type logic will be implemented soon
  static InternetConnectionType _connectionType = InternetConnectionType.any;

  /// keeps app resource bundle for the last received distribution
  static late AppResourceBundle _arb;

  static DateTime _distributionTimeToUpdate = DateTime.now();

  /// contains certain distribution file paths for locales
  static Map<String, dynamic> _distributionsMap = {};

  static final CrowdinStorage _storage = CrowdinStorage();

  static Future<void> init({
    required String distributionHash,
    Duration? updatesInterval,
    InternetConnectionType? connectionType,
  }) async {
    await _storage.init();

    if (updatesInterval != null) _distributionHash = distributionHash;
    log('-=Crowdin=- distributionHash $_distributionHash');

    if (updatesInterval != null) _updatesInterval = updatesInterval;
    log('-=Crowdin=- updatesInterval $_updatesInterval');

    if (connectionType != null) _connectionType = connectionType;
    log('-=Crowdin=- connectionType $_connectionType');

    _distributionTimeToUpdate = DateTime.now().add(_updatesInterval);

    /// fetch manifest file to get certain paths for each locale distribution
    var manifest = await CrowdinApi.getManifest(distributionHash: _distributionHash);
    _distributionsMap = manifest?['content'];
  }

  static Future<void> loadTranslations(Locale locale) async {
    Map<String, dynamic>? distribution;

    try {
      if (_canUseCachedDistribution(_distributionTimeToUpdate)) {
        distribution = _storage.getTranslationFromStorage(locale);
        if (distribution != null) {
          _arb = AppResourceBundle(distribution);
          return;
        }
      }

      distribution = await CrowdinApi.loadTranslations(
          path: _distributionsMap[locale.toLanguageTag()][0] as String,
          distributionHash: _distributionHash);
      if (distribution != null) {
        /// todo remove when distribution file locale will be fixed
        distribution['@@locale'] = locale.languageCode;

        _storage.setDistributionToStorage(
          jsonEncode(distribution),
        );
        _arb = AppResourceBundle(distribution);
      }
    } catch (ex) {
      throw CrowdinException('No translations on Crowdin');
    }
  }

  static final Extractor _extractor = Extractor();

  static String? getText(
    String locale,
    String key, [
    Map<String, dynamic> args = const {},
  ]) {
    try {
      return _extractor.getText(
        locale,
        _arb,
        key,
        args,
      );
    } catch (e) {
      return null;
    }
  }
}

bool _canUseCachedDistribution(DateTime distributionTimeToUpdate) {
  bool canUseCachedDistribution = distributionTimeToUpdate.isAfter(DateTime.now());
  return canUseCachedDistribution;
}
