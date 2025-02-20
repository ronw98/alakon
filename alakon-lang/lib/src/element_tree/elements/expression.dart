part of 'element.dart';

/// Represents an Alakon expression
sealed class AlakonExpression implements AlakonElement {
  /// Resolves the expression to return its [AlakonValue].
  ///
  /// The expression is resolved within a [VariableScope] to access declared
  /// variable values.
  AlakonValue resolve(VariableScope variables);
}

class AlakonAdd extends AlakonExpression {
  AlakonAdd({required this.left, required this.right});

  final AlakonExpression left;
  final AlakonExpression right;

  @override
  AlakonValue resolve(VariableScope variables) {
    return left.resolve(variables) + right.resolve(variables);
  }
}

class AlakonSubtract extends AlakonExpression {
  AlakonSubtract({required this.left, required this.right});

  final AlakonExpression left;
  final AlakonExpression right;

  @override
  AlakonValue resolve(VariableScope variables) {
    return left.resolve(variables) - right.resolve(variables);
  }
}

class AlakonMultiply extends AlakonExpression {
  AlakonMultiply({required this.left, required this.right});

  final AlakonExpression left;
  final AlakonExpression right;

  @override
  AlakonValue resolve(VariableScope variables) {
    return left.resolve(variables) * right.resolve(variables);
  }
}

class AlakonDivide extends AlakonExpression {
  AlakonDivide({required this.left, required this.right});

  final AlakonExpression left;
  final AlakonExpression right;

  @override
  AlakonValue resolve(VariableScope variables) {
    final leftValue = left.resolve(variables);
    final rightValue = right.resolve(variables);
    return leftValue / rightValue;
  }
}

class AlakonParen extends AlakonExpression {
  AlakonParen({required this.expression});

  final AlakonExpression expression;

  @override
  AlakonValue resolve(VariableScope variables) {
    return expression.resolve(variables);
  }
}

class AlakonNegated extends AlakonExpression {
  AlakonNegated({required this.expression});

  final AlakonExpression expression;

  @override
  AlakonValue resolve(VariableScope variables) {
    return -expression.resolve(variables);
  }
}

class AlakonNumberExpression extends AlakonExpression {
  AlakonNumberExpression(this.value);

  final num value;

  @override
  AlakonValue resolve(VariableScope variables) {
    return AlakonNumberValue(value);
  }
}

class AlakonStringExpression extends AlakonExpression {
  AlakonStringExpression(this.value);

  final String value;

  @override
  AlakonValue resolve(VariableScope variables) {
    return AlakonStringValue(value);
  }
}

class AlakonBoolExpression extends AlakonExpression {
  AlakonBoolExpression(this.value);

  final bool value;

  @override
  AlakonValue resolve(VariableScope variables) {
    return AlakonBoolValue(value);
  }
}

class AlakonReferenceExpression extends AlakonExpression {
  AlakonReferenceExpression({required this.variableName});

  final String variableName;

  @override
  AlakonValue resolve(VariableScope variables) {
    final variable = variables.variable(variableName);
    if (variable == null) throw UnimplementedError();
    return variable.value;
  }
}
