class AlakonRuntimeException implements Exception {
  AlakonRuntimeException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}