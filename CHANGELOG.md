# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 1.1.0

feat: support named parameters

## 1.0.0

- First stable release

### Breaking Changes

- **Minimum requirements updated**: Dart SDK `>=3.4.0 <4.0.0`, Flutter `>=3.22.0`
- Default `synthetic-package` changed from `true` to `false` to align with Flutter 3.32+ deprecation
- Import paths changed from `package:flutter_gen/gen_l10n/...` to direct source imports

### Migration

1. Add `synthetic-package: false` to your `l10n.yaml` (or rely on new default)
2. Update imports:
   ```dart
   // Before
   import 'package:flutter_gen/gen_l10n/crowdin_localizations.dart';

   // After
   import 'package:your_app/l10n/crowdin_localizations.dart';
   ```
3. Run `flutter pub run crowdin_sdk:gen` to regenerate

## 0.8.1

- fix: add undeclared placeholders to the placeholders list

## 0.8.0

- feat: expose downloaded manifest statically + check if locale is supported according to manifest
- feat: stop requests when distribution deleted
- docs: flutter_gen synthetic package migration

## 0.7.0

* feat: websocket security improvement
* fix: intl update to 0.20.2 max

## 0.6.4

* fix: Spanish Language not handling properly within the SDK (es-ES)

## 0.6.3

* fix: timestamp query for translation request

## 0.6.2

* fix: deprecated uni_links package changed by app_links

## 0.6.1

* fix: Pass static analysis. crowdin_generator.dart format

## 0.6.0

* fix: Select options in Flutter ARB translation languages not working when using CDN

## 0.5.1

* fix: pass organizationName to the getMetadata method

## 0.5.0

* Set more precise scopes required for the OAuth application

## 0.4.0

* Fix plural strings handling
* Add exceptions logging
* Dependencies update

## 0.3.1

* Update dependencies and add code comments

## 0.3.0

* Real-Time Preview feature

## 0.2.0

* Support more l10n.yaml options

## 0.1.2

* removed unnecessary io dependencies

## 0.1.1

* Internal updates (dependencies, ci/cd, code style, docs)

## 0.1.0

* Initial Release
