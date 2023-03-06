import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:crowdin_sdk/src/crowdin_storage.dart';
import 'package:crowdin_sdk/src/crowdin_extractor.dart';
import 'package:flutter/cupertino.dart';

import 'exceptions/crowdin_exceptions.dart';
import 'common/gen_l10n_types.dart';

enum InternetConnectionType { wifi, mobileData, ethernet, any }

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

  /// contains certain distribution file paths for locales
  static int? _timestamp;

  static int? _timestampCached = _storage.getTranslationTimestampFromStorage();

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
    if (manifest != null) {
      _distributionsMap = manifest['content'];

      /// fetch manifest file to check if new updates available
      _timestamp = manifest['timestamp'];
    }
  }

  static Future<void> loadTranslations(Locale locale) async {
    Map<String, dynamic>? distribution;

    bool canUseCache = _canUseCachedDistribution(
      distributionTimeToUpdate: _distributionTimeToUpdate,
      translationTimestamp: _timestamp,
      cachedTranslationTimestamp: _timestampCached,
    );

    try {
      if (canUseCache) {
        distribution = _storage.getTranslationFromStorage(locale);
        if (distribution != null) {
          _arb = AppResourceBundle(distribution);
          return;
        }
      }

      ///return from function if connection type is forbidden for downloading translations
      if (!await _isConnectionTypeAllowed(_connectionType)) return;

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

        if (_timestamp != null && _timestamp != _timestampCached) {
          _storage.setTranslationTimeStampStorage(_timestamp!);
          _timestampCached = _timestamp;
        }
      }
    } catch (ex) {
      // return;
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

bool _canUseCachedDistribution({
  DateTime? distributionTimeToUpdate,
  int? translationTimestamp,
  int? cachedTranslationTimestamp,
}) {
  if (distributionTimeToUpdate != null) {
    bool canUseCachedDistribution = distributionTimeToUpdate.isAfter(DateTime.now());
    return canUseCachedDistribution;
  } else {
    return translationTimestamp == 0;
  }
}

Future<bool> _isConnectionTypeAllowed(InternetConnectionType connectionType) async {
  var connectionStatus = await Connectivity().checkConnectivity();
  switch (connectionType) {
    case InternetConnectionType.any:
      return connectionStatus != ConnectivityResult.none;
    case InternetConnectionType.wifi:
      return connectionStatus == ConnectivityResult.wifi;
    case InternetConnectionType.mobileData:
      return connectionStatus == ConnectivityResult.mobile;
    case InternetConnectionType.ethernet:
      return connectionStatus == ConnectivityResult.ethernet;
  }
}
