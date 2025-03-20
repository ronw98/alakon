import 'package:alakon_lang/alakon_lang.dart';

/// Exception signifying the analysis of the program has encountered
/// [AnalysisErrors].
///
/// This is only raised at the end of the analysis if the program of errors.
/// It contains the [AnalysisResult] of the program.
///
/// In that case, [AnalysisResult.hasErrors] is always `true`.
class AnalysisException implements Exception {
  AnalysisException(this.result);

  final AnalysisResult result;

  @override
  String toString() {
    return 'Error analyzing program.\n$result';
  }
}

/// Base error encountered when analyzing an alakon program.
///
/// **Note**: This is not a dart [Error], rather a data class containing
/// data about a semantic error in an alakon program.
class AnalysisError {
  AnalysisError({
    required this.message,
    required this.begin,
    required this.end,
  });

  /// Exception message to display
  final String message;

  /// Number of the line causing the exception.
  final Token begin;

  /// Position of the exception in the line.
  final Token end;

  @override
  String toString() {
    return '$runtimeType: $message\n\tPos: ${begin.line}:${end.column}';
  }
}

class TypeMismatchError extends AnalysisError {
  TypeMismatchError({
    required super.begin,
    required super.end,
    required super.message,
  });
}

class OperatorError extends AnalysisError {
  OperatorError({
    required super.begin,
    required super.end,
    required super.message,
  });
}

class UnknownReferenceError extends AnalysisError {
  UnknownReferenceError({
    required super.message,
    required super.begin,
    required super.end,
  });
}

class ReuseError extends AnalysisError {
  ReuseError({
    required super.message,
    required super.begin,
    required super.end,
  });
}
