import 'dart:ui';

///list of the supported locales by GlobalMaterialLocalizations class:
///https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html

class LanguageMapper {
  static Locale mapLocale(Locale locale) {
    String localeTag = locale.toLanguageTag();
    return _localesMap.containsKey(localeTag) ? Locale(_localesMap[localeTag]!) : locale;
  }


 ///_localesMap contains language codes that is different on Crowdin and supported by GlobalMaterialLocalizations class
  static const Map<String, String> _localesMap = {
    'hy': 'hy-AM', //Armenian
    'zh': 'zh-CN', //Chinese Simplified
    'gu': 'gu-IN', //Gujarati
    'ne': 'ne-NP', //Nepali
    'pt': 'pt-PT', //Portuguese
    'pa': 'pa-IN', //Punjabi
    'si': 'si-LK', //Sinhala
    'es': 'es-ES', //Spanish
    'sv': 'sv-SE', //Swedish
    'ur': 'ur-IN', //	Urdu (India)
    // 'fil' : 'Filipino',// suppported
    // 'ach' : 'Acholi',
    // 'frp' : 'Arpitan',
    // 'ast' : 'Asturian',
    // 'tay' : 'Atayal',
    // 'ban' : 'Balinese',
    // 'bal' : 'Balochi',
    // 'ber' : 'Berber',
    // 'bfo' : 'Birifor',
    // 'br-FR' : 'Breton',
    // 'ceb' : 'Cebuano',
    // 'chr' : 'Cherokee',
    // 'fa-AF' : 'Dari',
    // 'vls-BE' : 'Flemish',
    // 'fra-DE' : 'Franconian',
    // 'fy-NL' : 'Frisian',
    // 'fur-IT' : 'Friulian',
    // 'gaa' : 'Ga',
    // 'got' : 'Gothic',
    // 'haw' : 'Hawaiian',
    // 'hil' : 'Hiligaynon',
    // 'hmn' : 'Hmong',
    // 'ido' : 'Ido',
    // 'ilo' : 'Ilokano',
    // 'ga-IE' : 'Irish',
    // 'quc' : "K'iche'",
    // 'kab' : 'Kabyle',
    // 'pam' : 'Kapampangan',
    // 'csb' : 'Kashubian',
    // 'tlh-AA' : 'Klingon',
    // 'kok' : 'Konkani',
    // 'kmr' : 'Kurmanji',
    // 'lol' : 'LOLCAT',
    // 'la-LA' : 'Latin',
    // 'lij' : 'Ligurian',
    // 'jbo' : 'Lojban',
    // 'nds' : 'Low German',
    // 'dsb-DE' : 'Lower Sorbian',
    // 'luy' : 'Luhya',
    // 'mai' : 'Maithili',
    // 'arn' : 'Mapudungun',
    // 'moh' : 'Mohawk',
    // 'sr-Cyrl-ME' : 'Montenegrin',
    // 'mos' : 'Mossi',
    // 'pcm' : 'Nigerian Pidgin',
    // 'nso' : 'Northern Sotho',
    // 'pap' : 'Papiamento',
    // 'qya-AA' : 'Quenya',
    // 'rm-CH' : 'Romansh',
    // 'ry-UA' : 'Rusyn',
    // 'sah' : 'Sakha',
    // 'sat' : 'Santali',
    // 'sco' : 'Santali',
    // 'crs' : 'Seychellois Creole',
    // 'son' : 'Songhay',
    // 'ckb' : 'Sorani (Kurdish)',
    // 'sma' : 'Southern Sami',
    // 'syc' : 'Syriac',
    // 'tzl' : 'Talossan',
    // 'tt-RU' : 'Tatar',
    // 'kdh' : 'Tem (Kotokoli)',
    // 'bo-BT' : 'Tibetan',
    // 'hsb-DE' : 'Upper Sorbian',
    // 'val-ES' : 'Valencian',
    // 'vec' : 'Venetian',
    // 'zea' : 'Zeelandic',
  };
}
