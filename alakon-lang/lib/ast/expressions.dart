import 'package:petitparser/petitparser.dart';

import 'ast.dart';

abstract class ExpressionNode implements AstNode {}

class ParenthesisedExpressionNode implements ExpressionNode {
  final ExpressionNode expression;

  ParenthesisedExpressionNode(this.expression);

  @override
  R accept<R>(AstVisitor<R> visitor) =>
      visitor.visitParenthesisedExpression(this);
}

class NegatedExpressionNode implements ExpressionNode {
  final ExpressionNode expression;

  NegatedExpressionNode(this.expression);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitNegatedExpression(this);
}

abstract class LeafExpressionNode<T> implements ExpressionNode {
  LeafExpressionNode(this.value);

  final Token<T> value;
}

class StringExpressionNode extends LeafExpressionNode<String> {
  StringExpressionNode(super.value);

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
  final ExpressionNode left;
  final ExpressionNode right;

  OperationExpressionNode(this.left, this.right);
}

class MultiplicationExpressionNode extends OperationExpressionNode {
  MultiplicationExpressionNode(super.left, super.right);

  @override
  R accept<R>(AstVisitor<R> visitor) =>
      visitor.visitMultiplicationExpression(this);
}

class DivisionExpressionNode extends OperationExpressionNode {
  DivisionExpressionNode(super.left, super.right);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitDivisionExpression(this);
}

class AdditionExpressionNode extends OperationExpressionNode {
  AdditionExpressionNode(super.left, super.right);

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitAdditionExpression(this);
}

class SubtractionExpressionNode extends OperationExpressionNode {
  SubtractionExpressionNode(super.left, super.right);

  @override
  R accept<R>(AstVisitor<R> visitor) =>
      visitor.visitSubtractionExpression(this);
}
