class CrowdinException implements Exception {
  final String? message;

  CrowdinException(this.message);

  @override
  String toString() {
    return '$CrowdinException: $message';
  }
}
