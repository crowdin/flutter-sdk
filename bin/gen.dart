import 'dart:developer';

import 'package:crowdin_sdk/src/gen/crowdin_generator.dart' as gen;

void main(List<String> arg) {
  gen.CrowdinGenerator.generate();
  log('generation done');
}
