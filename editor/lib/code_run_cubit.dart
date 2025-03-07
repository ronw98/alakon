import 'dart:async';

import 'package:alakon_lang/alakon_lang.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the [CodeRunCubit].
sealed class CodeRunState extends Equatable {
  const CodeRunState();

  @override
  List<Object?> get props => [];
}

class CodeRunStateInitial extends CodeRunState {
  const CodeRunStateInitial();
}

/// Code is launching, meaning execution is preparing.
///
/// At that point a new code execution cannot be requested.
class CodeRunStateLaunching extends CodeRunState {
  const CodeRunStateLaunching();
}

/// Code has produced [outputs].
///
/// Outputs are divided into two categories. See [CodeOutput] for more details.
sealed class CodeRunStateWithOutput extends CodeRunState {
  const CodeRunStateWithOutput({required this.outputs});

  final List<CodeOutput> outputs;

  @override
  List<Object?> get props => [...super.props, ...outputs];
}

/// THe code is currently running.
class CodeRunStateRunning extends CodeRunStateWithOutput {
  const CodeRunStateRunning({required super.outputs});
}

/// Code has finished running.
///
/// A new execution can be requested.
class CodeRunStateDone extends CodeRunStateWithOutput {
  const CodeRunStateDone({required super.outputs});
}

/// A single output (print) produced by the execution.
///
/// Can be either a [CodeStdout] output or a [CodeStderr] output for errors.
sealed class CodeOutput extends Equatable {
  const CodeOutput({required this.data});

  final String data;

  @override
  List<Object?> get props => [data];
}

class CodeStdout extends CodeOutput {
  const CodeStdout({required super.data});
}

class CodeStderr extends CodeOutput {
  const CodeStderr({required super.data});
}

/// Cubit responsible for code execution.
///
/// Exposes a single method [run] for running the code.
class CodeRunCubit extends Cubit<CodeRunState> {
  CodeRunCubit() : super(const CodeRunStateInitial());

  final _parser = AlakonParser().build();
  final _analyzer = AlakonAnalyzer();
  final _elementTreeBuilder = ElementTreeBuilder();

  /// Tries to run the given [code].
  ///
  /// Parses the code, analyses it and then executes it.
  ///
  /// If parsing fails, a [CodeStderr] is emitted containing the parse error.
  /// If analysis fails, all analysis errors are emitted via [CodeStderr] (one
  /// each).
  ///
  /// It then runs the parsed AST using [ElementTreeBuilder]. Code execution
  /// errors are emitted as [CodeStderr] and simple prints as [CodeStdout]
  Future<void> run(String code) async {
    emit(const CodeRunStateLaunching());
    final parseResult = _parser.parse(code);
    switch (parseResult) {
      case final Failure f:
        final output = CodeStderr(
          data: f.toString(),
        );
        emit(
          CodeRunStateDone(
            outputs: [output],
          ),
        );
      case Success(value: final ProgramNode programNode):
        if (_analyze(programNode)) {
          _execute(programNode);
        }
      default:
    }
  }

  /// Analyses the [program] and emits a [CodeRunStateDone] with a [CodeStderr]
  /// for each encountered analysis error.
  ///
  /// Returns `true` if analysis succeeds and false otherwise.
  bool _analyze(AstNode program) {
    final result = _analyzer.analyze(program);
    if (result.hasError) {
      final outputs = <CodeOutput>[];
      for (final error in result.errors) {
        outputs.add(CodeStderr(data: error.message));
      }
      outputs.add(
        CodeStderr(data: 'Analysis failed with ${result.errorCount} errors'),
      );
      emit(CodeRunStateDone(outputs: outputs));
      return false;
    }
    return true;
  }

  /// Executes the [program].
  ///
  /// It must have passed analysis.
  ///
  /// Callbacks are added for stderr and stdout so that the cubit emits the
  /// prints and errors encountered during the execution of the program.
  void _execute(ProgramNode program) {
    final programElement = _elementTreeBuilder.build(program);
    // TODO: run in isolate to allow for stupidly long loops or computations.
    programElement.run(
      stderr: (error) {
        final newOutput = CodeStderr(data: error);
        switch (state) {
          case CodeRunStateRunning(outputs: final outputs):
            emit(CodeRunStateRunning(outputs: [...outputs, newOutput]));
          default:
            emit(CodeRunStateRunning(outputs: [newOutput]));
        }
      },
      stdout: (value) {
        final newOutput = CodeStdout(data: value);
        switch (state) {
          case CodeRunStateRunning(outputs: final outputs):
            emit(CodeRunStateRunning(outputs: [...outputs, newOutput]));
          default:
            emit(CodeRunStateRunning(outputs: [newOutput]));
        }
      },
    );
    switch (state) {
      case CodeRunStateRunning(outputs: final outputs):
        emit(CodeRunStateDone(outputs: [...outputs]));
      default:
        emit(CodeRunStateDone(outputs: []));
    }
  }
}
