// Copyright 2014 The Flutter Authors. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following
// disclaimer in the documentation and/or other materials provided
// with the distribution.
// * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived
// from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'package:crowdin_sdk/src/exceptions/crowdin_exceptions.dart';

import 'localizations_utils.dart';
import 'message_parser.dart';

// The set of date formats that can be automatically localized.
//
// The localizations generation tool makes use of the intl library's
// DateFormat class to properly format dates based on the locale, the
// desired format, as well as the passed in [DateTime]. For example, using
// DateFormat.yMMMMd("en_US").format(DateTime.utc(1996, 7, 10)) results
// in the string "July 10, 1996".
//
// Since the tool generates code that uses DateFormat's constructor, it is
// necessary to verify that the constructor exists, or the
// tool will generate code that may cause a compile-time error.
//
// See also:
//
// * <https://pub.dev/packages/intl>
// * <https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html>
// * <https://api.dartlang.org/stable/2.7.0/dart-core/DateTime-class.html>
const Set<String> _validDateFormats = <String>{
  'd',
  'E',
  'EEEE',
  'LLL',
  'LLLL',
  'M',
  'Md',
  'MEd',
  'MMM',
  'MMMd',
  'MMMEd',
  'MMMM',
  'MMMMd',
  'MMMMEEEEd',
  'QQQ',
  'QQQQ',
  'y',
  'yM',
  'yMd',
  'yMEd',
  'yMMM',
  'yMMMd',
  'yMMMEd',
  'yMMMM',
  'yMMMMd',
  'yMMMMEEEEd',
  'yQQQ',
  'yQQQQ',
  'H',
  'Hm',
  'Hms',
  'j',
  'jm',
  'jms',
  'jmv',
  'jmz',
  'jv',
  'jz',
  'm',
  'ms',
  's',
};

// The set of number formats that can be automatically localized.
//
// The localizations generation tool makes use of the intl library's
// NumberFormat class to properly format numbers based on the locale and
// the desired format. For example, using
// NumberFormat.compactLong("en_US").format(1200000) results
// in the string "1.2 million".
//
// Since the tool generates code that uses NumberFormat's constructor, it is
// necessary to verify that the constructor exists, or the
// tool will generate code that may cause a compile-time error.
//
// See also:
//
// * <https://pub.dev/packages/intl>
// * <https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html>
const Set<String> _validNumberFormats = <String>{
  'compact',
  'compactCurrency',
  'compactSimpleCurrency',
  'compactLong',
  'currency',
  'decimalPattern',
  'decimalPercentPattern',
  'percentPattern',
  'scientificPattern',
  'simpleCurrency',
};

// The names of the NumberFormat factory constructors which have named
// parameters rather than positional parameters.
//
// This helps the tool correctly generate number formatting code correctly.
//
// Example of code that uses named parameters:
// final NumberFormat format = NumberFormat.compact(
//   locale: localeName,
// );
//
// Example of code that uses positional parameters:
// final NumberFormat format = NumberFormat.scientificPattern(localeName);
const Set<String> _numberFormatsWithNamedParameters = <String>{
  'compact',
  'compactCurrency',
  'compactSimpleCurrency',
  'compactLong',
  'currency',
  'decimalPercentPattern',
  'simpleCurrency',
};

class L10nException implements Exception {
  L10nException(this.message);

  final String message;

  @override
  String toString() => message;
}

class L10nParserException extends L10nException {
  L10nParserException(this.error, this.fileName, this.messageId,
      this.messageString, this.charNumber)
      : super('''
[$fileName:$messageId] $error
    $messageString
    ${List<String>.filled(charNumber, ' ').join()}^''');

  final String error;
  final String fileName;
  final String messageId;
  final String messageString;

  // Position of character within the "messageString" where the error is.
  final int charNumber;
}

// class L10nMissingPlaceholderException extends L10nParserException {
//   L10nMissingPlaceholderException(
//       super.error,
//       super.fileName,
//       super.messageId,
//       super.messageString,
//       super.charNumber,
//       this.placeholderName,
//       );
//
//   final String placeholderName;
// }

// One optional named parameter to be used by a NumberFormat.
//
// Some of the NumberFormat factory constructors have optional named parameters.
// For example NumberFormat.compactCurrency has a decimalDigits parameter that
// specifies the number of decimal places to use when formatting.
//
// Optional parameters for NumberFormat placeholders are specified as a
// JSON map value for optionalParameters in a resource's "@" ARB file entry:
//
// "@myResourceId": {
//   "placeholders": {
//     "myNumberPlaceholder": {
//       "type": "double",
//       "format": "compactCurrency",
//       "optionalParameters": {
//         "decimalDigits": 2
//       }
//     }
//   }
// }
class OptionalParameter {
  const OptionalParameter(this.name, this.value);

  final String name;
  final Object value;
}

// One message parameter: one placeholder from an @foo entry in the template ARB file.
//
// Placeholders are specified as a JSON map with one entry for each placeholder.
// One placeholder must be specified for each message "{parameter}".
// Each placeholder entry is also a JSON map. If the map is empty, the placeholder
// is assumed to be an Object value whose toString() value will be displayed.
// For example:
//
// "greeting": "{hello} {world}",
// "@greeting": {
//   "description": "A message with a two parameters",
//   "placeholders": {
//     "hello": {},
//     "world": {}
//   }
// }
//
// Each placeholder can optionally specify a valid Dart type. If the type
// is NumberFormat or DateFormat then a format which matches one of the
// type's factory constructors can also be specified. In this example the
// date placeholder is to be formatted with DateFormat.yMMMMd:
//
// "helloWorldOn": "Hello World on {date}",
// "@helloWorldOn": {
//   "description": "A message with a date parameter",
//   "placeholders": {
//     "date": {
//       "type": "DateTime",
//       "format": "yMMMMd"
//     }
//   }
// }
//
class Placeholder {
  Placeholder(this.resourceId, this.name, Map<String, Object?> attributes)
      : example = _stringAttribute(resourceId, name, attributes, 'example'),
        type = _stringAttribute(resourceId, name, attributes, 'type'),
        format = _stringAttribute(resourceId, name, attributes, 'format'),
        optionalParameters = _optionalParameters(resourceId, name, attributes),
        isCustomDateFormat =
            _boolAttribute(resourceId, name, attributes, 'isCustomDateFormat');

  final String resourceId;
  final String name;
  final String? example;
  final String? format;
  final List<OptionalParameter> optionalParameters;
  final bool? isCustomDateFormat;

  // The following will be initialized after all messages are parsed in the Message constructor.
  String? type;
  bool isPlural = false;
  bool isSelect = false;

  bool get requiresFormatting =>
      requiresDateFormatting || requiresNumFormatting;

  bool get requiresDateFormatting => type == 'DateTime';

  bool get requiresNumFormatting =>
      <String>['int', 'num', 'double'].contains(type) && format != null;

  bool get hasValidNumberFormat => _validNumberFormats.contains(format);

  bool get hasNumberFormatWithParameters =>
      _numberFormatsWithNamedParameters.contains(format);

  bool get hasValidDateFormat => _validDateFormats.contains(format);

  bool get isNumber => <String>['double', 'int', 'num'].contains(type);

  bool get isDate => 'DateTime' == type;

  static String? _stringAttribute(
    String resourceId,
    String name,
    Map<String, Object?> attributes,
    String attributeName,
  ) {
    final Object? value = attributes[attributeName];
    if (value == null) {
      return null;
    }
    if (value is! String || value.isEmpty) {
      throw L10nException(
        'The "$attributeName" value of the "$name" placeholder in message $resourceId '
        'must be a non-empty string.',
      );
    }
    return value;
  }

  static bool? _boolAttribute(
    String resourceId,
    String name,
    Map<String, Object?> attributes,
    String attributeName,
  ) {
    final Object? value = attributes[attributeName];
    if (value == null) {
      return null;
    }
    if (value != 'true' && value != 'false') {
      throw CrowdinException(
        'The "$attributeName" value of the "$name" placeholder in message $resourceId '
        'must be a boolean value.',
      );
    }
    return value == 'true';
  }

  static List<OptionalParameter> _optionalParameters(
      String resourceId, String name, Map<String, Object?> attributes) {
    final Object? value = attributes['optionalParameters'];
    if (value == null) {
      return <OptionalParameter>[];
    }
    if (value is! Map<String, Object?>) {
      throw CrowdinException(
          'The "optionalParameters" value of the "$name" placeholder in message '
          '$resourceId is not a properly formatted Map. Ensure that it is a map '
          'with keys that are strings.');
    }
    final Map<String, Object?> optionalParameterMap = value;
    return optionalParameterMap.keys
        .map<OptionalParameter>((String parameterName) {
      return OptionalParameter(
          parameterName, optionalParameterMap[parameterName]!);
    }).toList();
  }
}

// All translations for a given message specified by a resource id.
//
// The template ARB file must contain an entry called @myResourceId for each
// message named myResourceId. The @ entry describes message parameters
// called "placeholders" and can include an optional description.
// Here's a simple example message with no parameters:
//
// "helloWorld": "Hello World",
// "@helloWorld": {
//   "description": "The conventional newborn programmer greeting"
// }
//
// The value of this Message is "Hello World". The Message's value is the
// localized string to be shown for the template ARB file's locale.
// The docs for the Placeholder explain how placeholder entries are defined.
class Message {
  Message(
    AppResourceBundle templateBundle,
    this.resourceId,
    bool isResourceAttributeRequired, {
    this.useEscaping = false,
  })  : assert(resourceId.isNotEmpty),
        value = _value(templateBundle.resources, resourceId),
        description = _description(
            templateBundle.resources, resourceId, isResourceAttributeRequired),
        placeholders = _placeholders(
            templateBundle.resources, resourceId, isResourceAttributeRequired),
        messages = <LocaleInfo, String?>{},
        _pluralMatch =
            _pluralRE.firstMatch(_value(templateBundle.resources, resourceId)),
        parsedMessages = <LocaleInfo, Node?>{} {
    // Filenames for error handling.
    final Map<LocaleInfo, String> filenames = <LocaleInfo, String>{};
    // Collect all translations from allBundles and parse them.
    // for (final AppResourceBundle bundle in allBundles.bundles) {
    // filenames[bundle.locale] = bundle.file.basename;
    final String? translation = templateBundle.translationFor(resourceId);
    messages[templateBundle.locale] = translation;
    parsedMessages[templateBundle.locale] = translation == null
        ? null
        : Parser(
            resourceId,
            'OTA data',
            translation,
            useEscaping: useEscaping,
          ).parse();
    // Infer the placeholders
    _inferPlaceholders(filenames);
  }

  final String resourceId;
  final String value;
  final String? description;
  late final Map<LocaleInfo, String?> messages;
  final Map<LocaleInfo, Node?> parsedMessages;
  final Map<String, Placeholder> placeholders;
  final bool useEscaping;
  final RegExpMatch? _pluralMatch;

  bool get placeholdersRequireFormatting =>
      placeholders.values.any((Placeholder p) => p.requiresFormatting);

  static String _value(Map<String, Object?> bundle, String resourceId) {
    final Object? value = bundle[resourceId];
    if (value == null) {
      throw L10nException('A value for resource "$resourceId" was not found.');
    }
    if (value is! String) {
      throw L10nException('The value of "$resourceId" is not a string.');
    }
    return value;
  }

  static Map<String, Object?>? _attributes(
    Map<String, Object?> bundle,
    String resourceId,
    bool isResourceAttributeRequired,
  ) {
    final Object? attributes = bundle['@$resourceId'];
    if (isResourceAttributeRequired) {
      if (attributes == null) {
        throw L10nException(
            'Resource attribute "@$resourceId" was not found. Please '
            'ensure that each resource has a corresponding @resource.');
      }
    }

    if (attributes != null && attributes is! Map<String, Object?>) {
      throw L10nException(
          'The resource attribute "@$resourceId" is not a properly formatted Map. '
          'Ensure that it is a map with keys that are strings.');
    }

    return attributes as Map<String, Object?>?;
  }

  static String? _description(
    Map<String, Object?> bundle,
    String resourceId,
    bool isResourceAttributeRequired,
  ) {
    final Map<String, Object?>? resourceAttributes =
        _attributes(bundle, resourceId, isResourceAttributeRequired);
    if (resourceAttributes == null) {
      return null;
    }

    final Object? value = resourceAttributes['description'];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw L10nException(
          'The description for "@$resourceId" is not a properly formatted String.');
    }
    return value;
  }

  static final RegExp _pluralRE = RegExp(r'\s*\{([\w\s,]*),\s*plural\s*,');

  bool get isPlural => _pluralMatch != null && _pluralMatch!.groupCount == 1;

  Placeholder getCountPlaceholder() {
    assert(isPlural);
    final String countPlaceholderName = _pluralMatch![1]!;
    return placeholders.values.firstWhere(
        (Placeholder p) => p.name == countPlaceholderName, orElse: () {
      throw L10nException(
          'Cannot find the $countPlaceholderName placeholder in plural message "$resourceId".');
    });
  }

  static Map<String, Placeholder> _placeholders(
    Map<String, Object?> bundle,
    String resourceId,
    bool isResourceAttributeRequired,
  ) {
    final Map<String, Object?>? resourceAttributes =
        _attributes(bundle, resourceId, isResourceAttributeRequired);
    if (resourceAttributes == null) {
      return <String, Placeholder>{};
    }
    final Object? allPlaceholdersMap = resourceAttributes['placeholders'];
    if (allPlaceholdersMap == null) {
      return <String, Placeholder>{};
    }
    if (allPlaceholdersMap is! Map<String, Object?>) {
      throw L10nException(
          'The "placeholders" attribute for message $resourceId, is not '
          'properly formatted. Ensure that it is a map with string valued keys.');
    }
    return Map<String, Placeholder>.fromEntries(
      allPlaceholdersMap.keys.map((String placeholderName) {
        final Object? value = allPlaceholdersMap[placeholderName];
        if (value is! Map<String, Object?>) {
          throw L10nException(
              'The value of the "$placeholderName" placeholder attribute for message '
              '"$resourceId", is not properly formatted. Ensure that it is a map '
              'with string valued keys.');
        }
        return MapEntry<String, Placeholder>(
            placeholderName, Placeholder(resourceId, placeholderName, value));
      }),
    );
  }

// Using parsed translations, attempt to infer types of placeholders used by plurals and selects.
// For undeclared placeholders, create a new placeholder.
  void _inferPlaceholders(Map<LocaleInfo, String> filenames) {
    // We keep the undeclared placeholders separate so that we can sort them alphabetically afterwards.
    final Map<String, Placeholder> undeclaredPlaceholders =
        <String, Placeholder>{};
    // Helper for getting placeholder by name.
    Placeholder? getPlaceholder(String name) =>
        placeholders[name] ?? undeclaredPlaceholders[name];
    for (final LocaleInfo locale in parsedMessages.keys) {
      if (parsedMessages[locale] == null) {
        continue;
      }
      final List<Node> traversalStack = <Node>[parsedMessages[locale]!];
      while (traversalStack.isNotEmpty) {
        final Node node = traversalStack.removeLast();
        if (<ST>[
          ST.placeholderExpr,
          ST.pluralExpr,
          ST.selectExpr,
        ].contains(node.type)) {
          final String identifier = node.children[1].value!;
          Placeholder? placeholder = getPlaceholder(identifier);
          if (placeholder == null) {
            placeholder =
                Placeholder(resourceId, identifier, <String, Object?>{});
            undeclaredPlaceholders[identifier] = placeholder;
          }
          if (node.type == ST.pluralExpr) {
            placeholder.isPlural = true;
          } else if (node.type == ST.selectExpr) {
            placeholder.isSelect = true;
          }
        }
        traversalStack.addAll(node.children);
      }
    }
    placeholders.addAll(undeclaredPlaceholders);
  }
}

// Represents the contents of one ARB file.
class AppResourceBundle {
  factory AppResourceBundle(Map<String, Object?> resources) {
    String? localeString = resources['@@locale'] as String?;

    if (localeString == null) {
      throw L10nException(
          "The following .arb file's locale could not be determined: \n"
          '{file.path} \n'
          "Make sure that the locale is specified in the file's '@@locale' "
          'property or as part of the filename (e.g. file_en.arb)');
    }

    final Iterable<String> ids =
        resources.keys.where((String key) => !key.startsWith('@'));
    return AppResourceBundle._(
        LocaleInfo.fromString(localeString), resources, ids);
  }

  const AppResourceBundle._(this.locale, this.resources, this.resourceIds);

  // final File file;
  final LocaleInfo locale;

  /// JSON representation of the contents of the ARB file.
  final Map<String, Object?> resources;
  final Iterable<String> resourceIds;

  String? translationFor(String resourceId) => resources[resourceId] as String?;

  @override
  String toString() {
    return 'AppResourceBundle($locale, {file.path})';
  }
}
