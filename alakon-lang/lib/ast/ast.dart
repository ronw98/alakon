import 'package:petitparser/petitparser.dart';

import 'expressions.dart';

export 'expressions.dart';

abstract interface class AstVisitor<R> {
  R visitProgram(ProgramNode node);

  R visitStringExpression(StringExpressionNode node);

  R visitBooleanExpression(BooleanExpressionNode node);

  R visitNumberExpression(NumberExpressionNode node);

  R visitReferenceExpression(ReferenceExpressionNode node);

  R visitMultiplicationExpression(MultiplicationExpressionNode node);

  R visitDivisionExpression(DivisionExpressionNode node);

  R visitAdditionExpression(AdditionExpressionNode node);

  R visitSubtractionExpression(SubtractionExpressionNode node);

  R visitParenthesisedExpression(ParenthesisedExpressionNode node);

  R visitNegatedExpression(NegatedExpressionNode node);

  R visitVariableDeclaration(VariableDeclarationNode node);

  R visitVariableAssign(VariableAssignNode node);
}

abstract interface class AstNode {
  R accept<R>(AstVisitor<R> visitor);
}

class ProgramNode implements AstNode {
  final List<StatementNode> statements;

  ProgramNode({required this.statements});

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitProgram(this);
}

abstract class StatementNode implements AstNode {}

class VariableDeclarationNode extends StatementNode {
  final Token<String> variableType;
  final Token<String> variableName;
  final ExpressionNode? assign;

  VariableDeclarationNode({
    required this.variableType,
    required this.variableName,
    this.assign,
  });

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitVariableDeclaration(this);
}

class VariableAssignNode extends StatementNode {
  final Token<String> variableName;
  final ExpressionNode assign;

  VariableAssignNode({required this.variableName, required this.assign});

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitVariableAssign(this);
}
