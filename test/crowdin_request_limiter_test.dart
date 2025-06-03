import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crowdin_sdk/src/crowdin_request_limiter.dart';
import 'package:crowdin_sdk/src/crowdin_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCrowdinStorage extends Mock implements CrowdinStorage {}

final DateFormat _formatter = DateFormat('yyyy-MM-dd');

@visibleForTesting
String getTodayDateString() {
  return _formatter.format(DateTime.now());
}

void main() {
  late CrowdinRequestLimiter requestLimiter;
  late CrowdinStorage storage;
  late SharedPreferences sharedPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
    storage = CrowdinStorage();
    requestLimiter = CrowdinRequestLimiter();
    await storage.init();
  });

  tearDown(() async {
    await sharedPrefs.clear();
  });

  test('should initialize with storage values', () async {
    storage.setIsPausedPermanently(true);
    await requestLimiter.init(storage);
    expect(storage.getIsPausedPermanently(), true);
    expect(requestLimiter.pauseRequests, true);
  });

  test('should increment error counter', () {
    requestLimiter.init(storage);
    requestLimiter.incrementErrorCounter();
    expect(storage.getErrorMap(), {getTodayDateString(): 1});
    requestLimiter.incrementErrorCounter();
    expect(storage.getErrorMap(), {getTodayDateString(): 2});
  });

  test('should pause requests after max errors in a day', () async {
    storage.setErrorMap({getTodayDateString(): 10});
    await requestLimiter.init(storage);
    expect(requestLimiter.pauseRequests, true);
  });

  test('should reset error map and pause state', () async {
    storage.setErrorMap({getTodayDateString(): 10});
    await requestLimiter.init(storage);
    expect(requestLimiter.pauseRequests, true);
    requestLimiter.reset();
    expect(requestLimiter.pauseRequests, false);
  });

  test('should stop requests permanently after max days in a row', () async {
    storage.setErrorMap({
      _formatter.format(DateTime.now()): 10,
      _formatter.format(DateTime.now().subtract(const Duration(days: 1))): 10,
      _formatter.format(DateTime.now().subtract(const Duration(days: 2))): 10,
    });
    await requestLimiter.init(storage);
    requestLimiter.incrementErrorCounter();
    expect(requestLimiter.pauseRequests, true);
  });
}
