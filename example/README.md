# example

Simple project to demonstrate how to use Crowdin SDK

## Getting Started

To run example project follow next steps:

1. Clone repository from GitHub
2. Create project on [Crowdin](https://crowdin.com/). Use texts_en.arb file from this project (flutter-sdk/example/lib/l10n/texts_en.arb) as source file.
3. Run 'pup get' command to get project dependencies
4. Run 'flutter gen-l10n'
5. Run 'flutter pub run crowdin_sdk:gen' to generate Crowdin localization
6. Provide your distribution hash to Crowdin initialization in 'main' function
   ```
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     Crowdin.init(
       distributionHash: 'your distribution hash',
       ...
     );
   ...
   }
   ```
8. Run the application