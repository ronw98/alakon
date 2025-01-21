import '../ast/ast.dart';

class Generator implements AstVisitor<String> {
  @override
  String visitAdditionExpression(AdditionExpressionNode node) {
    final left = node.left.accept(this);
    final right = node.right.accept(this);

    return '$left + $right';
  }

  @override
  String visitBooleanExpression(BooleanExpressionNode node) {
    return '${node.value.value}';
  }

  @override
  String visitDivisionExpression(DivisionExpressionNode node) {
    final left = node.left.accept(this);
    final right = node.right.accept(this);

    return '$left / $right';
  }

  @override
  String visitMultiplicationExpression(MultiplicationExpressionNode node) {
    final left = node.left.accept(this);
    final right = node.right.accept(this);

    return '$left * $right';
  }

  @override
  String visitNegatedExpression(NegatedExpressionNode node) {
    final expr = node.expression.accept(this);

    return '-$expr';
  }

  @override
  String visitNumberExpression(NumberExpressionNode node) {
    return '${node.value.value}';
  }

  @override
  String visitParenthesisedExpression(ParenthesisedExpressionNode node) {
    final exp = node.expression.accept(this);

    return '($exp)';
  }

  @override
  String visitProgram(ProgramNode node) {
    final statements = node.statements.map(
      (s) => s.accept(this),
    );
    return '''
    void main() {
      ${statements.join('\n')}
    }
    ''';
  }

  @override
  String visitReferenceExpression(ReferenceExpressionNode node) {
    return node.value.value;
  }

  @override
  String visitStringExpression(StringExpressionNode node) {
    return node.value.value;
  }

  @override
  String visitSubtractionExpression(SubtractionExpressionNode node) {
    final left = node.left.accept(this);
    final right = node.right.accept(this);

    return '$left - $right';
  }

  @override
  String visitVariableAssign(VariableAssignNode node) {
    final ref = node.variableName.value;
    final expr = node.assign.accept(this);

    return '$ref = $expr;';
  }

  @override
  String visitVariableDeclaration(VariableDeclarationNode node) {
    final type = node.variableType.value;
    final ref = node.variableName.value;

    final expr = node.assign?.accept(this);
    final result = StringBuffer(type)..write(' $ref');
    if (expr != null) {
      result.write(' = $expr');
    }

    result.write(';');
    return result.toString();
  }
}
