import 'package:crowdin_sdk/src/crowdin_storage.dart';
import 'package:intl/intl.dart';

const int maxErrors = 10;
const int maxDaysInRow = 3;

class CrowdinRequestLimiter {
  CrowdinRequestLimiter._();

  static final CrowdinRequestLimiter _instance = CrowdinRequestLimiter._();

  factory CrowdinRequestLimiter() {
    return _instance;
  }

  late CrowdinStorage _storage;

  final DateFormat _formatter = DateFormat('yyyy-MM-dd');
  Map<String, int> _todayErrorMap = {};
  bool _pauseRequests = false;
  bool _stopPermanently = false;

  bool get pauseRequests =>
      _stopPermanently || _pauseRequests || _checkIsPausedForToday();

  init(CrowdinStorage storage) {
    _storage = storage;
    _stopPermanently = _storage.getIsPausedPermanently() ?? false;
    _todayErrorMap = _storage.getErrorMap() ?? {};
  }

  bool _checkIsPausedForToday() {
    String currentDateString = _formatter.format(DateTime.now());
    if (_todayErrorMap[currentDateString] != null &&
        _todayErrorMap[currentDateString]! >= maxErrors) {
      _pauseRequests = true;
      return true;
    } else {
      _pauseRequests = false;
      return false;
    }
  }

  void incrementErrorCounter() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String currentDateString = formatter.format(DateTime.now());
    if (_todayErrorMap[currentDateString] != null) {
      if (_todayErrorMap[currentDateString]! < maxErrors) {
        _todayErrorMap[currentDateString] =
            _todayErrorMap[currentDateString]! + 1;
      } else if (_todayErrorMap[currentDateString]! >= maxErrors) {
        checkPausedDays(currentDateString);
      }
    } else {
      _todayErrorMap = {currentDateString: 1};
    }
    _storage.setErrorMap(_todayErrorMap);
  }

  reset() {
    if (!_stopPermanently) {
      _pauseRequests = false;
      _todayErrorMap = {};
      _storage.setErrorMap(_todayErrorMap);
    }
  }

  void checkPausedDays(String newDate) {
    int daysInRow = 0;
    if (_todayErrorMap.length >= maxDaysInRow) {
      DateTime currentDate = DateTime.parse(newDate);
      for (String date in _todayErrorMap.keys) {
        if (DateTime.parse(date).isAfter(
                currentDate.add(const Duration(days: -maxDaysInRow))) &&
            _todayErrorMap[date]! >= maxErrors) {
          daysInRow++;
          _pauseRequests = true;
        } else {
          _todayErrorMap.remove(date);
        }
      }
      if (daysInRow >= maxDaysInRow) {
        _todayErrorMap.clear();
        _stopRequestsPermanently();
      }
    }
    _storage.setErrorMap(_todayErrorMap);
  }

  void _stopRequestsPermanently() {
    _pauseRequests = true;
    _stopPermanently = true;
    _storage.setIsPausedPermanently(true);
    _storage.setErrorMap(_todayErrorMap);
  }
}
