# Crowdin Flutter SDK Example Project

Simple project to demonstrate how to use the Crowdin SDK

## Getting Started

Follow the steps below to run the Example project:

1. Clone this repository: `git clone git@github.com:crowdin/flutter-sdk.git`.
2. Navigate to the Example project directory: `cd flutter-sdk/example`.
3. Create a project in [Crowdin](https://crowdin.com/). Upload the [`lib/l10n/texts_en.arb`](https://github.com/crowdin/flutter-sdk/blob/main/example/lib/l10n/text_en.arb) file to the Crowdin project as a source file.
4. Run the `pub get` command to get project dependencies.
5. Run `flutter gen-l10n`.
6. Run `flutter pub run crowdin_sdk:gen` to generate Crowdin localization.
7. Translate your file in Crowdin project and [Set up a Distribution](https://support.crowdin.com/content-delivery/#distribution-setup).
8. Fill in your distribution hash in the `main` function as a `distributionHash` value:

   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Crowdin.init(
       distributionHash: 'distribution_hash', // Fill in with your distribution hash
       connectionType: InternetConnectionType.any,
       updatesInterval: const Duration(minutes: 15),
     );
     runApp(const MyHomePage());
   }
   ```

9. Run the application.