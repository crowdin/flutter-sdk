import 'package:intl/intl.dart' as intl;

import 'common/gen_l10n_types.dart';

///finds message parameters
class Extractor {
  //throws exceptions
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
      return _findPlaceholders(locale, message, message.value, args);
    } else {
      return message.value;
    }
  }

  String? _findPlaceholders(
    String locale,
    Message message,
    String? buffer, [
    Map<String, dynamic> args = const {},
  ]) {
    if (buffer == null) return null;
    final countPlaceholder = message.isPlural ? message.getCountPlaceholder() : null;
    var placeholders = message.placeholders;
    for (var i = 0; i < placeholders.length; i++) {
      final placeholder = placeholders[i];
      final value = args[placeholder?.name];
      final optionals = {
        for (final parameter in placeholder!.optionalParameters) parameter.name: parameter.value
      };
      String result;
      if (placeholder.isDate) {
        result = intl.DateFormat(placeholder.format, locale).format(value as DateTime);
      } else if (placeholder.isNumber || placeholder == countPlaceholder) {
        final name = optionals['name'] as String?;
        final symbol = optionals['symbol'] as String?;
        final decimalDigits = optionals['decimalDigits'] as int?;
        final customPattern = optionals['customPattern'] as String?;
        switch (placeholder.format) {
          case 'compact':
            result = intl.NumberFormat.compact(locale: locale).format(value);
            break;
          case 'compactCurrency':
            result = intl.NumberFormat.compactCurrency(
              locale: locale,
              name: name,
              symbol: symbol,
              decimalDigits: decimalDigits,
            ).format(value);
            break;
          case 'compactSimpleCurrency':
            result = intl.NumberFormat.compactSimpleCurrency(
              locale: locale,
              name: name,
              decimalDigits: decimalDigits,
            ).format(value);
            break;
          case 'compactLong':
            result = intl.NumberFormat.compactLong(locale: locale).format(value);
            break;
          case 'currency':
            result = intl.NumberFormat.currency(
              locale: locale,
              name: name,
              symbol: symbol,
              decimalDigits: decimalDigits,
              customPattern: customPattern,
            ).format(value);
            break;
          case 'decimalPattern':
            result = intl.NumberFormat.decimalPattern().format(value);
            break;
          case 'decimalPercentPattern':
            result = intl.NumberFormat.decimalPercentPattern(
              locale: locale,
              decimalDigits: decimalDigits,
            ).format(value);
            break;
          case 'percentPattern':
            result = intl.NumberFormat.percentPattern().format(value);
            break;
          case 'scientificPattern':
            result = intl.NumberFormat.scientificPattern().format(value);
            break;
          case 'simpleCurrency':
            result = intl.NumberFormat.simpleCurrency(
              locale: locale,
              name: name,
              decimalDigits: decimalDigits,
            ).format(value);
            break;
          default:
            result = value.toString();
        }
      } else {
        result = value.toString();
      }
      buffer = buffer?.replaceAll('{${placeholder.name}}', result);
    }
    return buffer;
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

    var easyMessage = message.value;
    for (final placeholder in message.placeholders.values) {
      easyMessage = easyMessage.replaceAll('{${placeholder.name}}', '#${placeholder.name}#');
    }
    var extractedPlurals = pluralIds
        .map((key) => _findPlural(easyMessage, key))
        .map((extracted) => message.placeholders.values.fold<String?>(
              extracted,
              (extracted, placeholder) =>
                  extracted?.replaceAll('#${placeholder.name}#', '{${placeholder.name}}'),
            ))
        .map((normalized) => _findPlaceholders(
              locale,
              message,
              normalized,
              args,
            ))
        .toList(growable: false);

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

  String? _findPlural(String easyMessage, String pluralKey) {
    final exp = RegExp('($pluralKey)\\s*{([^}]+)}');
    final RegExpMatch? match = exp.firstMatch(easyMessage);
    if (match != null && match.groupCount == 2) {
      return match.group(2)!;
    } else {
      return null;
    }
  }
}
