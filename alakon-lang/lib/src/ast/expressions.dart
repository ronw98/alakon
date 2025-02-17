import 'package:petitparser/petitparser.dart';

import 'ast.dart';

abstract class ExpressionNode implements AstNode {}

class ParenthesisedExpressionNode implements ExpressionNode {
  ParenthesisedExpressionNode({
    required this.expression,
    required this.tokenLeftParen,
    required this.tokenRightParen,
  });

  final Token<String> tokenLeftParen;
  final Token<String> tokenRightParen;
  final ExpressionNode expression;

  @override
  Token get beginToken => tokenLeftParen;

  @override
  Token get endToken => tokenRightParen;

  @override
  R accept<R>(AstVisitor<R> visitor) =>
      visitor.visitParenthesisedExpression(this);
}

class NegatedExpressionNode implements ExpressionNode {
  NegatedExpressionNode({
    required this.expression,
    required this.tokenMinus,
  });

  final Token<String> tokenMinus;
  final ExpressionNode expression;

  @override
  Token get beginToken => tokenMinus;

  @override
  Token get endToken => expression.endToken;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitNegatedExpression(this);
}

abstract class LeafExpressionNode<T> implements ExpressionNode {
  LeafExpressionNode(this.value);

  final Token<T> value;

  @override
  Token get beginToken => value;

  @override
  Token get endToken => value;
}

class StringExpressionNode extends LeafExpressionNode<String> {
  StringExpressionNode({
    required Token<String> value,
    required this.leftQuotes,
    required this.rightQuotes,
  }) : super(value);

  final Token<String> leftQuotes;
  final Token<String> rightQuotes;

  @override
  Token get beginToken => leftQuotes;

  @override
  Token get endToken => rightQuotes;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitStringExpression(this);
}

class NumberExpressionNode extends LeafExpressionNode<num> {
  NumberExpressionNode(super.value);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitNumberExpression(this);
}

class BooleanExpressionNode extends LeafExpressionNode<bool> {
  BooleanExpressionNode(super.value);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitBooleanExpression(this);
}

class ReferenceExpressionNode extends LeafExpressionNode<String> {
  ReferenceExpressionNode(super.value);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitReferenceExpression(this);
}

abstract class OperationExpressionNode implements ExpressionNode {
  OperationExpressionNode({
    required this.left,
    required this.right,
    required this.tokenOperand,
  });

  final ExpressionNode left;
  final ExpressionNode right;
  final Token<String> tokenOperand;

  @override
  Token get beginToken => left.beginToken;

  @override
  Token get endToken => right.endToken;
}

class MultiplicationExpressionNode extends OperationExpressionNode {
  MultiplicationExpressionNode({
    required super.left,
    required super.right,
    required super.tokenOperand,
  });

  @override
  R accept<R>(AstVisitor<R> visitor) =>
      visitor.visitMultiplicationExpression(this);
}

class DivisionExpressionNode extends OperationExpressionNode {
  DivisionExpressionNode({
    required super.left,
    required super.right,
    required super.tokenOperand,
  });

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitDivisionExpression(this);
}

class AdditionExpressionNode extends OperationExpressionNode {
  AdditionExpressionNode({
    required super.left,
    required super.right,
    required super.tokenOperand,
  });

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitAdditionExpression(this);
}

class SubtractionExpressionNode extends OperationExpressionNode {
  SubtractionExpressionNode({
    required super.left,
    required super.right,
    required super.tokenOperand,
  });

  @override
  R accept<R>(AstVisitor<R> visitor) =>
      visitor.visitSubtractionExpression(this);
}
