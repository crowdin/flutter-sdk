import 'dart:developer';

import 'package:crowdin_sdk/src/crowdin_generator.dart' as gen;

void main(List<String> arg) {
  gen.CrowdinGenerator.generate();
  log('generation done');
}
