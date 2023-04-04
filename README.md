[<p align='center'><img src='https://support.crowdin.com/assets/logos/crowdin-dark-symbol.png' data-canonical-src='https://support.crowdin.com/assets/logos/crowdin-dark-symbol.png' width='150' height='150' align='center'/></p>](https://crowdin.com)

# Crowdin Flutter SDK [<img src="https://img.shields.io/badge/beta-yellow"/>](https://github.com/crowdin/flutter-sdk)

The Crowdin Flutter SDK delivers all new translations from Crowdin project to the application immediately. So there is no need to update the application via Store to get the new version with the localization.

<div align="center">

[**`Example project`**](https://github.com/crowdin/flutter-sdk/tree/main/example) &nbsp;|&nbsp;
[**`Crowdin Docs`**](https://support.crowdin.com/content-delivery)  &nbsp;|&nbsp;
[**`Crowdin Enterprise Docs`**](https://support.crowdin.com/enterprise/content-delivery/)

[![Pub Version](https://img.shields.io/pub/v/crowdin_sdk?cacheSeconds=9000)](https://pub.dev/packages/crowdin_sdk)
[![Pub Points](https://img.shields.io/pub/points/crowdin_sdk?cacheSeconds=1000)](https://pub.dev/packages/crowdin_sdk)
[![GitHub issues](https://img.shields.io/github/issues/crowdin/flutter-sdk?cacheSeconds=9000)](https://github.com/crowdin/flutter-sdk/issues)
[![GitHub contributors](https://img.shields.io/github/contributors/crowdin/flutter-sdk?cacheSeconds=9000)](https://github.com/crowdin/flutter-sdk/graphs/contributors)
[![GitHub](https://img.shields.io/github/license/crowdin/flutter-sdk?cacheSeconds=20000)](https://github.com/crowdin/flutter-sdk/blob/master/LICENSE)

</div>

## Features

- Load remote strings from Crowdin Over-The-Air Content Delivery Network
- Built-in translations caching mechanism (enabled by default, can be disabled)
- Network usage configuration (All, only Wi-Fi or Cellular)
- Load static strings from the bundled ARB files (usable as a fallback for the CDN strings)

## Requirements

* Dart >=2.12.0

## Setup

To configure Flutter SDK integration you need to:

- Upload your *.arb* localization files to Crowdin. If you have ready translations, you can also upload them. Alternatively, you can use the [Flutter .ARB String Exporter](https://store.crowdin.com/arb-export) to export Flutter `.arb` from your Crowdin project strings.
- Set up Distribution in Crowdin.
- Set up SDK and enable Over-The-Air Content Delivery feature in your project.

**Distribution** is a CDN vault that mirrors the translated content of your project and is required for integration with the Flutter app.

To manage distributions open the needed project and go to *Over-The-Air Content Delivery*. You can create as many distributions as you need and choose different files for each. You’ll need to click the *Release* button next to the necessary distribution every time you want to send new translations to the app.

**Notes:**

- The CDN feature does not update the localization files. if you want to add new translations to the localization files you need to do it yourself.
- Once SDK receives the translations, it's stored on the device as application files for further sessions to minimize requests the next time the app starts. Storage time can be configured.
- CDN caches all the translations in release and even when new translations are released in Crowdin, CDN may return them with a delay.

**To integrate SDK with your application you need to follow the step-by-step instructions:**

- First of all, your Flutter project should be internationalized using the `flutter_localizations` package. For more detail, see [Setting up an internationalized app](https://docs.flutter.dev/development/accessibility-and-localization/internationalization#setting-up).
- Create a project in [Crowdin](https://crowdin.com/).
- Upload your `app_en.arb` file to the created Crowdin project. Optionally, you can also [Upload Existing Translations](https://support.crowdin.com/uploading-translations/).
- [Set up a Distribution](https://support.crowdin.com/content-delivery/#distribution-setup).
- Add the `crowdin_sdk` dependency to your project:

  ```yml
  dependencies:
    crowdin_sdk: ^0.1.0

    flutter_localizations:
      sdk: flutter
    intl: any

  flutter:
    generate: true
  ```

- Run the following command to generate Crowdin localization:

  ```consloe
  flutter pub run crowdin_sdk:gen
  ```

  As a result, the `Crowdin_localizations.dart` will be created in the `{FLUTTER_PROJECT}/.dart_tool/flutter_gen/gen_l10n` directory.

- Update localizationsDelegates in your project:

  ```dart
  import 'package:flutter_gen/gen_l10n/app_localizations.dart';
  import 'package:crowdin_sdk/crowdin_sdk.dart';
  import 'package:flutter_gen/gen_l10n/crowdin_localizations.dart';
  ```

  ```dart
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...

      localizationsDelegates: CrowdinLocalization.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      ),

      // ...
    );
  }
  ```

- Initialize Crowdin SDK in the `main` function of your application:

   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     await Crowdin.init(
       distributionHash: 'distribution_hash', // Fill in with your distribution hash
       connectionType: InternetConnectionType.any,
       updatesInterval: const Duration(minutes: 15),
     );

     // ...
   }
   ```

- Use the `Crowdin.loadTranslations` function to load translations from Crowdin for the specified locale:

  ```dart
  await Crowdin.loadTranslations(Locale('en'));
  ```

After receiving translations change the app locale as usual and translations from Crowdin will be applied.

## Configuration

| Config option      | Description                                                                                                                                                                                           |
|--------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `distributionHash` | Crowdin Distribution Hash                                                                                                                                                                             |
| `connectionType`   | Network type to be used for translations download. Supported values are `any`, `wifi`, `mobileData`, `ethernet`                                                                                       |
| `updatesInterval`  | Translations update interval. Translations will not be updated more frequently than the designated time interval (default minimum is 15 minutes). Instead, it will use previously cached translations |

## Notes

Since some languages have different language codes maintained by the intl package and by Crowdin (for example, intl uses "es" for the Spanish language, and Crowdin uses "es-ES"). For the following intl language codes Crowdin SDK uses equivalent language codes:

- Armenian - 'hy': 'hy-AM'
- Chinese Simplified -'zh': 'zh-CN'
- Gujarati - 'gu': 'gu-IN'
- Nepali - 'ne': 'ne-NP'
- Portuguese -'pt': 'pt-PT'
- Punjabi - 'pa': 'pa-IN'
- Sinhala - 'si': 'si-LK'
- Spanish -'es': 'es-ES'
- Swedish - 'sv': 'sv-SE'
- Urdu (India) -'ur': 'ur-IN'

## Contributing

If you want to contribute please read the [Contributing](/CONTRIBUTING.md) guidelines.

## Seeking Assistance

If you find any problems or would like to suggest a feature, please feel free to file an issue on GitHub at [Issues Page](https://github.com/crowdin/flutter-sdk/issues).

## Security

Crowdin Flutter SDK CDN feature is built with security in mind, which means minimal access possible from the end-user is required.
When you decide to use Crowdin Flutter SDK, please make sure you’ve made the following information accessible to your end-users.

- We use the advantages of Amazon Web Services (AWS) for our computing infrastructure. AWS has ISO 27001 certification and has completed multiple SSAE 16 audits. All the translations are stored at AWS servers.
- When you use Crowdin Flutter SDK CDN – translations are uploaded to Amazon CloudFront to be delivered to the app and speed up the download. Keep in mind that your users download translations without any additional authentication.
- We use encryption to keep your data private while in transit.
- We do not store any Personally Identifiable Information (PII) about the end-user, but you can decide to develop the opt-out option inside your application to make sure your users have full control.

## License
<pre>
The Crowdin Flutter SDK is licensed under the MIT License.
See the LICENSE file distributed with this work for additional 
information regarding copyright ownership.

Except as contained in the LICENSE file, the name(s) of the above copyright 
holders shall not be used in advertising or otherwise to promote the sale, 
use or other dealings in this Software without prior written authorization.
</pre>
