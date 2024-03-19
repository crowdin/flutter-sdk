import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:crowdin_sdk/src/common/message_parser.dart';

import 'common/gen_l10n_types.dart';
import 'common/localizations_utils.dart';

///finds message parameters
class Extractor {
  String? getText(
    String locale,
    AppResourceBundle arb,
    String key, [
    Map<String, dynamic> args = const {},
  ]) {
    final message = Message(arb, key, false);
    if (message.isPlural) {
      return _getPlural(locale, message, args);
    } else if (message.placeholders.isNotEmpty) {
      return findPlaceholders(locale, message, message.value, args);
    } else {
      return message.value;
    }
  }

  @visibleForTesting
  String? findPlaceholders(
    String locale,
    Message message,
    String? buffer, [
    Map<String, dynamic> args = const {},
  ]) {
    if (buffer == null) return null;
    final countPlaceholder =
        message.isPlural ? message.getCountPlaceholder() : null;
    var placeholders = message.placeholders;
    for (var i = 0; i < placeholders.length; i++) {
      final placeholder = placeholders.values.toList()[i];
      final value = args[placeholder.name];
      final optionals = {
        for (final op in placeholder.optionalParameters) op.name: op.value
      };
      String result;
      if (placeholder.isDate) {
        result = intl.DateFormat(placeholder.format, locale)
            .format(value as DateTime);
      } else if (placeholder.isNumber || placeholder == countPlaceholder) {
        result = _findNumberPlaceholder(
          optionals: optionals,
          locale: locale,
          placeholder: placeholder,
          placeholderValue: value,
        );
      } else if (placeholder.isSelect) {
        result = _findSelection(message, locale, value);
        return result;
      } else {
        result = value.toString();
      }
      buffer = buffer?.replaceAll('{${placeholder.name}}', result);
    }
    return buffer;
  }

  String _findSelection(Message message, String locale, String select) {
    final node =
        message.parsedMessages[LocaleInfo.fromString(locale)]?.children[0];

    final Node selectParts = node!.children[5];
    final Node selectedPart = selectParts.children.firstWhere(
        (element) => element.children[0].value == select,
        orElse: () => selectParts.children
            .firstWhere((element) => element.children[0].value == 'other'));
    final String selectedValue =
        selectedPart.children[2].children[0].value ?? 'other';
    return selectedValue;
  }

  String _findNumberPlaceholder({
    required Map<String, dynamic> optionals,
    required Placeholder placeholder,
    required dynamic placeholderValue,
    required String locale,
  }) {
    final name = optionals['name'] as String?;
    final symbol = optionals['symbol'] as String?;
    final decimalDigits = optionals['decimalDigits'] as int?;
    final customPattern = optionals['customPattern'] as String?;
    switch (placeholder.format) {
      case 'compact':
        return intl.NumberFormat.compact(locale: locale)
            .format(placeholderValue);
      case 'compactCurrency':
        return intl.NumberFormat.compactCurrency(
          locale: locale,
          name: name,
          symbol: symbol,
          decimalDigits: decimalDigits,
        ).format(placeholderValue);
      case 'compactSimpleCurrency':
        return intl.NumberFormat.compactSimpleCurrency(
          locale: locale,
          name: name,
          decimalDigits: decimalDigits,
        ).format(placeholderValue);
      case 'compactLong':
        return intl.NumberFormat.compactLong(locale: locale)
            .format(placeholderValue);
      case 'currency':
        return intl.NumberFormat.currency(
          locale: locale,
          name: name,
          symbol: symbol,
          decimalDigits: decimalDigits,
          customPattern: customPattern,
        ).format(placeholderValue);
      case 'decimalPattern':
        return intl.NumberFormat.decimalPattern().format(placeholderValue);
      case 'decimalPercentPattern':
        return intl.NumberFormat.decimalPercentPattern(
          locale: locale,
          decimalDigits: decimalDigits,
        ).format(placeholderValue);
      case 'percentPattern':
        return intl.NumberFormat.percentPattern().format(placeholderValue);
      case 'scientificPattern':
        return intl.NumberFormat.scientificPattern().format(placeholderValue);
      case 'simpleCurrency':
        return intl.NumberFormat.simpleCurrency(
          locale: locale,
          name: name,
          decimalDigits: decimalDigits,
        ).format(placeholderValue);
      default:
        return placeholderValue.toString();
    }
  }

//https://docs.google.com/document/d/10e0saTfAv32OZLRmONy866vnaw0I2jwL8zukykpgWBc/edit#heading=h.yfh1gyd78g7g
  String? _getPlural(
    String locale,
    Message message, [
    Map<String, dynamic> args = const {},
  ]) {
    const pluralIds = [
      '=0',
      '=1',
      '=2',
      'few',
      'many',
      'other',
    ];

    var messageValue = message.value;
    for (final placeholder in message.placeholders.values) {
      messageValue = messageValue.replaceAll(
          '{${placeholder.name}}', '#${placeholder.name}#');
    }

    final extractedPlurals = List.generate(pluralIds.length, (i) {
      final extracted = findPlural(messageValue, pluralIds[i]);
      var formattedPlural = message.placeholders.values.fold<String?>(
        extracted,
        (extracted, placeholder) => extracted?.replaceAll(
            '#${placeholder.name}#', '{${placeholder.name}}'),
      );
      String? formattedMessage = formattedPlural != null
          ? messageValue.replaceRange(messageValue.indexOf('{'),
              messageValue.lastIndexOf('}') + 1, formattedPlural)
          : formattedPlural;

      for (final placeholder in message.placeholders.values) {
        formattedMessage = formattedMessage?.replaceAll(
            '#${placeholder.name}#', '{${placeholder.name}}');
      }
      return findPlaceholders(locale, message, formattedMessage, args);
    });

    int howMany = args[message.getCountPlaceholder().name];
    return intl.Intl.pluralLogic(
      howMany,
      locale: locale,
      zero: extractedPlurals[0],
      one: extractedPlurals[1],
      two: extractedPlurals[2],
      few: extractedPlurals[3],
      many: extractedPlurals[4],
      other: extractedPlurals[5],
    );
  }
}

@visibleForTesting
String? findPlural(String messageValue, String pluralKey) {
  final startIndex = messageValue.indexOf(pluralKey);

  /// Returns -1 if no match is found
  if (startIndex == -1) {
    return null;
  }
  final openingBraceIndex = messageValue.indexOf('{', startIndex);
  if (openingBraceIndex == -1) {
    return null;
  }
  final closingBraceIndex = messageValue.indexOf('}', openingBraceIndex);
  if (closingBraceIndex == -1) {
    return null;
  }
  return messageValue.substring(openingBraceIndex + 1, closingBraceIndex);
}
