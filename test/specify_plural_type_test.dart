import 'package:crowdin_sdk/src/crowdin_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Returns the input type for Dart 2.19 or later', () {
    var version1 = '2.19.0';
    var version2 = '3.0.0';
    expect(specifyPluralType('int', version1), 'int');
    expect(specifyPluralType('double', version1), 'double');
    expect(specifyPluralType('num', version1), 'num');
    expect(specifyPluralType('int', version2), 'int');
    expect(specifyPluralType('double', version2), 'double');
    expect(specifyPluralType('num', version2), 'num');
  });

  test('Returns num type for Dart earlier than 2.19', () {
    var version = '2.18.0';
    expect(specifyPluralType('int', version), 'num');
    expect(specifyPluralType('double', version), 'num');
    expect(specifyPluralType('num', version), 'num');
  });
}