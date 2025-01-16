class AnalysisExceptions implements Exception {

  AnalysisExceptions({
    required this.message,
    required this.line,
    required this.column,
  });
  /// Exception message to display
  final String message;

  /// Number of the line causing the exception.
  final int line;

  /// Position of the exception in the line.
  final int column;

  @override
  String toString() {
    return '$runtimeType: $message\n\tPos: $line:$column';
  }
}

class TypeMismatchException extends AnalysisExceptions {
  TypeMismatchException({
    required super.line,
    required super.column,
    required super.message,
  });
}

class UnknownReferenceException extends AnalysisExceptions {
  UnknownReferenceException({
    required super.message,
    required super.line,
    required super.column,
  });
}

class ReuseException extends AnalysisExceptions {
  ReuseException({
    required super.message,
    required super.line,
    required super.column,
  });
}
