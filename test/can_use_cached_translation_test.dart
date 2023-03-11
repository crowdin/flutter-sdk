// import 'package:crowdin_sdk/src/crowdin.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   group('canUseCachedDistribution', () {
//
//
//     test('returns true when distributionTimeToUpdate is after current time', () {
//       DateTime distributionTimeToUpdate = DateTime.now().add(const Duration(minutes: 15));
//
//       bool result = _canUseCachedDistribution(
//         distributionTimeToUpdate: distributionTimeToUpdate,
//       );
//
//       expect(result, true);
//     });
//
//     test('returns false when distributionTimeToUpdate is before current time', () {
//       DateTime distributionTimeToUpdate = DateTime.now().subtract(const Duration(minutes: 15));
//
//       bool result = canUseCachedDistribution(
//         distributionTimeToUpdate: distributionTimeToUpdate,
//       );
//
//       expect(result, false);
//     });
//
//     test('returns true when distributionTimeToUpdate is null and timestamps are equal', () {
//       DateTime? distributionTimeToUpdate;
//       int? translationTimestamp = 1;
//       int? cachedTranslationTimestamp = 1;
//
//       bool result = canUseCachedDistribution(
//         distributionTimeToUpdate: distributionTimeToUpdate,
//         translationTimestamp: translationTimestamp,
//         cachedTranslationTimestamp: cachedTranslationTimestamp,
//       );
//
//       expect(result, true);
//     });
//
//     test('returns false when distributionTimeToUpdate is null and timestamps are different',
//         () {
//       int? translationTimestamp = 1;
//       int? cachedTranslationTimestamp = 2;
//
//       bool result = canUseCachedDistribution(
//         translationTimestamp: translationTimestamp,
//         cachedTranslationTimestamp: cachedTranslationTimestamp,
//       );
//
//       // Assert
//       expect(result, false);
//     });
//   });
// }
