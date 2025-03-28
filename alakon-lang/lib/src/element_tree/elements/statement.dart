part of 'element.dart';

sealed class AlakonStatementOrBlock implements AlakonElement {
  /// Executes the statement or block, performing the action it specifies.
  ///
  /// The execution is performed within a [VariableScope], which can be read or
  /// updated if the statement contains variable references.
  FutureOr<void> execute(VariableScope variables);
}

class AlakonBlock extends AlakonStatementOrBlock with HasVariableScope {
  AlakonBlock({required this.statements});

  final List<AlakonStatement> statements;

  @override
  void execute(VariableScope variables) {
    scope.inherit(variables);
    for (final statement in statements) {
      statement.execute(scope);
    }
  }
}

/// Abstract class encapsulating all Alakon statement.
///
/// A statement can be executed.
sealed class AlakonStatement extends AlakonStatementOrBlock {}

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

class AlakonIf extends AlakonStatement {
  AlakonIf(
    this.condition,
    this.ifBody,
    this.elseBody,
  );

  final AlakonExpression condition;
  final AlakonStatementOrBlock ifBody;
  final AlakonStatementOrBlock? elseBody;

  @override
  void execute(VariableScope variables) {
    final conditionValue = condition.resolve(variables);
    if (conditionValue is AlakonBoolValue) {
      if (conditionValue.value) {
        ifBody.execute(variables);
      } else {
        elseBody?.execute(variables);
      }
    } else {
      throw AlakonRuntimeException(
        '${conditionValue.toPrintValue()} cannot be resolved too bool',
      );
    }
  }
}

class AlakonWhile extends AlakonStatement {
  AlakonWhile(
    this.condition,
    this.body,
  );

  final AlakonExpression condition;
  final AlakonStatementOrBlock body;

  @override
  Future<void> execute(VariableScope variables) async {
    AlakonValue conditionValue = condition.resolve(variables);
    if (conditionValue is AlakonBoolValue) {
      while (conditionValue.value) {
        body.execute(variables);
        // Re execute condition after body
        conditionValue = condition.resolve(variables);
      }
    } else {
      throw AlakonRuntimeException(
        '${conditionValue.toPrintValue()} cannot be resolved too bool',
      );
    }
  }
}
