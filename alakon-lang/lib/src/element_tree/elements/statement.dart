part of 'element.dart';

/// Abstract class encapsulating all Alakon statement.
///
/// A statement can be executed.
sealed class AlakonStatement implements AlakonElement {
  /// Executes the statement, performing the action it specifies.
  ///
  /// The execution is performed within a [VariableScope], which can be read or
  /// updated if the statement contains variable references.
  void execute(VariableScope variables);
}

class AlakonVariableDeclaration extends AlakonStatement {
  AlakonVariableDeclaration({
    required this.variableName,
    required this.variableType,
    required this.expression,
  });

  final String variableName;
  final String variableType;
  final AlakonExpression? expression;

  @override
  void execute(VariableScope variables) {
    final value = expression?.resolve(variables);
    // Declared variable is added to the current scope.
    variables.registerVariable(
      variableName,
      value ?? AlakonEmptyValue(),
    );
  }
}

class AlakonVariableAssign extends AlakonStatement {
  AlakonVariableAssign({
    required this.variableName,
    required this.expression,
  });

  final String variableName;
  final AlakonExpression expression;

  @override
  void execute(VariableScope variables) {
    final value = expression.resolve(variables);

    // Variable value is updated in scope.
    variables.updateVariable(variableName, value);
  }
}

class AlakonPrint extends AlakonStatement {
  AlakonPrint({required this.expression});

  final AlakonExpression expression;

  @override
  void execute(VariableScope variables) {
    // Retrieve the variable from the current scope.
    final value = expression.resolve(variables);
    AlakonProgram.printValue(value);
  }
}
