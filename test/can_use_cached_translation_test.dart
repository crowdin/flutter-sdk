import 'package:crowdin_sdk/src/crowdin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('canUseCachedDistribution', () {
    test(
        'returns true when distributionTimeToUpdate is null and translationTimestamp and cachedTranslationTimestamp match',
        () {
      const translationTimestamp = 123;
      const cachedTranslationTimestamp = 123;

      final result = canUseCachedTranslation(
        distributionTimeToUpdate: null,
        translationTimestamp: translationTimestamp,
        cachedTranslationTimestamp: cachedTranslationTimestamp,
      );

      expect(result, isTrue);
    });

    test(
        'returns false when distributionTimeToUpdate is null and translationTimestamp and cachedTranslationTimestamp do not match',
        () {
      const translationTimestamp = 123;
      const cachedTranslationTimestamp = 456;

      final result = canUseCachedTranslation(
        distributionTimeToUpdate: null,
        translationTimestamp: translationTimestamp,
        cachedTranslationTimestamp: cachedTranslationTimestamp,
      );

      expect(result, isFalse);
    });

    test('returns true when distributionTimeToUpdate is after the current time',
        () {
      final distributionTimeToUpdate =
          DateTime.now().add(const Duration(minutes: 1));

      final result = canUseCachedTranslation(
        distributionTimeToUpdate: distributionTimeToUpdate,
        translationTimestamp: null,
        cachedTranslationTimestamp: null,
      );

      expect(result, isTrue);
    });

    test(
        'returns false when distributionTimeToUpdate is before the current time',
        () {
      final distributionTimeToUpdate =
          DateTime.now().subtract(const Duration(minutes: 1));

      final result = canUseCachedTranslation(
        distributionTimeToUpdate: distributionTimeToUpdate,
        translationTimestamp: null,
        cachedTranslationTimestamp: null,
      );

      expect(result, isFalse);
    });
  });
}
