import 'dart:ui';

// list of the supported locales by GlobalMaterialLocalizations class:
// https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html

class CrowdinMapper {
  static Locale mapLocale(Locale locale) {
    String localeTag = locale.toLanguageTag();
    return _localesMap.containsKey(localeTag)
        ? Locale(_localesMap[localeTag]!)
        : locale;
  }

  /// Maps a lanugage code to a [Locale] object.
  /// Reference https://support.crowdin.com/developer/language-codes/
  static Locale localeFromLanguageCode(String languageCode) {
    final parts = languageCode.split('-');
    final lang = parts.first;
    final country = parts.length > 1 ? parts.last : null;
    return mapLocale(
        Locale.fromSubtags(languageCode: lang, countryCode: country));
  }

  // _localesMap contains language codes that is different on Crowdin and supported by GlobalMaterialLocalizations class
  static const Map<String, String> _localesMap = {
    'hy': 'hy-AM', // Armenian
    'zh': 'zh-CN', // Chinese Simplified
    'gu': 'gu-IN', // Gujarati
    'ne': 'ne-NP', // Nepali
    'pt': 'pt-PT', // Portuguese
    'pa': 'pa-IN', // Punjabi
    'si': 'si-LK', // Sinhala
    'es': 'es-ES', // Spanish
    'sv': 'sv-SE', // Swedish
    'ur': 'ur-IN', // Urdu (India)
  };
}
