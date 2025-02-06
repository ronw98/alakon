import 'ast.dart';

class AstPrinter implements AstVisitor<String> {
  int _indent = 0;

  @override
  String visitAdditionExpression(AdditionExpressionNode node) {
    return _printNodeWithChildren(
      'AdditionExpression',
      [node.left, node.right],
    );
  }

  @override
  String visitBooleanExpression(BooleanExpressionNode node) {
    return 'BooleanExpressionNode(${node.value})';
  }

  @override
  String visitDivisionExpression(DivisionExpressionNode node) {
    return _printNodeWithChildren(
        'DivisionExpression', [node.left, node.right]);
  }

  @override
  String visitMultiplicationExpression(MultiplicationExpressionNode node) {
    return _printNodeWithChildren(
      'MultiplicationExpression',
      [node.left, node.right],
    );
  }

  @override
  String visitNegatedExpression(NegatedExpressionNode node) {
    return _printNodeWithChildren('NegatedExpression', [node.expression]);
  }

  @override
  String visitNumberExpression(NumberExpressionNode node) {
    return 'NumberExpression(${node.value})';
  }

  @override
  String visitParenthesisedExpression(ParenthesisedExpressionNode node) {
    return _printNodeWithChildren(
      'ParenthesisExpression',
      [node.expression],
    );
  }

  @override
  String visitProgram(ProgramNode node) {
    return _printNodeWithChildren('Program', node.statements);
  }

  @override
  String visitReferenceExpression(ReferenceExpressionNode node) {
    return 'ReferenceExpression(${node.value})';
  }

  @override
  String visitStringExpression(StringExpressionNode node) {
    return 'StringExpression(${node.value})';
  }

  @override
  String visitSubtractionExpression(SubtractionExpressionNode node) {
    return _printNodeWithChildren(
      'SubtractionExpression',
      [node.left, node.right],
    );
  }

  @override
  String visitVariableAssign(VariableAssignNode node) {
    return _printNodeWithChildren(
      'VariableAssign',
      [node.variableName, node.assign],
    );
  }

  @override
  String visitVariableDeclaration(VariableDeclarationNode node) {
    return _printNodeWithChildren(
      'VariableDeclaration',
      [
        node.variableType,
        node.variableName,
        if (node.assign != null) node.assign,
      ],
    );
  }

  @override
  String visitPrint(PrintNode node) {
    return _printNodeWithChildren(
      'Print',
      [node.expression],
    );
  }

  String _printNodeWithChildren(String name, List<dynamic> children) {
    final start = name;
    _indent++;
    final childrenString = children.map(
      (c) {
        if (c is AstNode) {
          return '  ' * _indent + c.accept(this);
        }
        return '  ' * _indent + c.toString();
      },
    ).join(',\n');
    _indent--;
    return '$start\n$childrenString';
  }
}
