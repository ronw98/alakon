import 'package:alakon_lang/analyzer/analysis_result.dart';

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

class TypeMismatchError extends AnalysisError {
  TypeMismatchError({
    required super.line,
    required super.column,
    required super.message,
  });
}

class UnknownReferenceError extends AnalysisError {
  UnknownReferenceError({
    required super.message,
    required super.line,
    required super.column,
  });
}

class ReuseError extends AnalysisError {
  ReuseError({
    required super.message,
    required super.line,
    required super.column,
  });
}
