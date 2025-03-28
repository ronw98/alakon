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

  static void printError(AlakonRuntimeException error) {
    if (stderr case final stderr?) {
      stderr(error.message);
    } else {
      print(error.message);
    }
  }

  final List<AlakonStatement> statements;

  /// Runs the program.
  ///
  /// Specify [stdout] and [stderr] to redirect prints and errors from the
  /// program.
  Future<void> run({
    StdCallback? stdout,
    StdCallback? stderr,
  }) async {
    final completer = Completer<void>();
    final receivePort = ReceivePort();
    receivePort.listen((message) {
      if(message == 'DONE') {
        receivePort.close();
        completer.complete();
      } else {
        final value = message['value'];
        final isError = message['type'] == 'err';
        if (isError) {
          stderr?.call(value);
        } else {
          stdout?.call(value);
        }
      }
    });
    final isolate = await Isolate.spawn(_runProgram, receivePort.sendPort, paused: true);
    isolate.addOnExitListener(receivePort.sendPort, response: 'DONE');
    isolate.resume(isolate.pauseCapability!);
    return completer.future;
  }

  Future<void> _runProgram(SendPort port) async {
    AlakonProgram.stdout = (value) {
      port.send(
          {
            'value': value,
            'type': 'out',
          },
        );
    };
    AlakonProgram.stderr = (value) {
      port.send(
          {
            'value': value,
            'type': 'err',
          },
        );
    };
    try {
      for (final statement in statements) {
        statement.execute(scope);
      }
    } on AlakonRuntimeException catch (e) {
      printError(e);
    }
  }
}
