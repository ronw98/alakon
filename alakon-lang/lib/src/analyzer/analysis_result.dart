
import 'analysis_errors.dart';

/// Contains the result of analyzing a chunk of code.
///
/// Contains the list of [AnalysisError]s contained in the code.
///
/// Can be combined with other results when new chunks of code are analyzed.
class AnalysisResult {
  AnalysisResult() : _errors = [];

  AnalysisResult.fromErrors(this._errors);

  AnalysisResult.fromResults(List<AnalysisResult> results)
      : _errors = results.fold(
          [],
          (acc, result) => [
            ...acc,
            ...result._errors,
          ],
        );

  final List<AnalysisError> _errors;

  void recordError(AnalysisError error) {
    _errors.add(error);
  }

  void addResult(AnalysisResult result) {
    _errors.addAll(result._errors);
  }

  int get errorCount => _errors.length;

  bool get hasError => errorCount > 0;

  List<AnalysisError> get errors => List.unmodifiable(_errors);

  @override
  String toString() {
    return '\t- ${_errors.join('\n\t- ')}';
  }
}
