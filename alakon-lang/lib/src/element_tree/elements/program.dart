part of 'element.dart';

typedef StdCallback = void Function(String value);

/// Defines a runnable Alakon program.
///
/// This program contains a list of [AlakonStatement]s.
///
/// Call [run] to execute the program.
class AlakonProgram with HasVariableScope implements AlakonElement {
  AlakonProgram(this.statements);

  static StdCallback? stdout;
  static StdCallback? stderr;

  static void printValue(AlakonValue value) {
    if (stdout case final stdout?) {
      stdout(value.toPrintValue());
    } else {
      print(value.toPrintValue());
    }
  }

  final List<AlakonStatement> statements;

  /// Runs the program.
  ///
  /// Specify [stdout] and [stderr] to redirect prints and errors from the
  /// program.
  void run({
    StdCallback? stdout,
    StdCallback? stderr,
  }) {
    AlakonProgram.stdout = stdout;
    AlakonProgram.stderr = stderr;

    for (final statement in statements) {
      statement.execute(scope);
    }
  }
}
