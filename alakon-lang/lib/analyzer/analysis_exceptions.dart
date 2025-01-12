class AnalysisExceptions implements Exception {
  final String message;

  AnalysisExceptions(this.message);

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}

class TypeMismatchException extends AnalysisExceptions {
  TypeMismatchException(super.message);
}

class UnknownReferenceException extends AnalysisExceptions {
  UnknownReferenceException(super.message);
}

class ReuseException extends AnalysisExceptions {
  ReuseException(super.message);
}
