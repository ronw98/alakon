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

  R visitAndExpression(AndExpressionNode node);

  R visitOrExpression(OrExpressionNode node);

  R visitParenthesisedExpression(ParenthesisedExpressionNode node);

  R visitNegatedExpression(NegatedExpressionNode node);
  R visitNotExpression(NotExpressionNode node);

  R visitVariableDeclaration(VariableDeclarationNode node);

  R visitVariableAssign(VariableAssignNode node);

  R visitPrint(PrintNode node);

  R visitBlock(BlockNode node);

  R visitIf(IfNode node);
}

abstract class AstNode {
  Token get beginToken;

  Token get endToken;

  R accept<R>(AstVisitor<R> visitor);
}

class ProgramNode implements AstNode {
  ProgramNode({required this.statements});

  final List<StatementNode> statements;

  @override
  Token get beginToken => statements.first.beginToken;

  @override
  Token get endToken => statements.first.endToken;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitProgram(this);
}

sealed class StatementOrBlockNode implements AstNode {}

class BlockNode extends StatementOrBlockNode {
  BlockNode({
    required this.leftBrace,
    required this.rightBrace,
    required this.statements,
  });

  final Token<String> leftBrace;
  final Token<String> rightBrace;
  final List<StatementNode> statements;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitBlock(this);

  @override
  Token get beginToken => leftBrace;

  @override
  Token get endToken => rightBrace;
}

abstract class StatementNode extends StatementOrBlockNode {}

class PrintNode extends StatementNode {
  PrintNode({
    required this.printToken,
    required this.expression,
    required this.tokenRightParen,
    required this.tokenLeftParen,
  });

  final Token<String> printToken;
  final Token<String> tokenLeftParen;
  final Token<String> tokenRightParen;
  final ExpressionNode expression;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitPrint(this);

  @override
  Token get beginToken => printToken;

  @override
  Token get endToken => tokenRightParen;
}

class VariableDeclarationNode extends StatementNode {
  VariableDeclarationNode({
    required this.variableType,
    required this.variableName,
    this.tokenEquals,
    this.assign,
  });

  final Token<String> variableType;
  final Token<String> variableName;

  final Token<String>? tokenEquals;
  final ExpressionNode? assign;

  @override
  Token get beginToken => variableType;

  @override
  Token get endToken => assign?.endToken ?? variableName;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitVariableDeclaration(this);
}

class VariableAssignNode extends StatementNode {
  VariableAssignNode({
    required this.variableName,
    required this.assign,
    required this.tokenEquals,
  });

  final Token<String> variableName;
  final Token<String> tokenEquals;
  final ExpressionNode assign;

  @override
  Token get beginToken => variableName;

  @override
  Token get endToken => assign.endToken;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitVariableAssign(this);
}

class IfNode extends StatementNode {
  IfNode({
    required this.ifToken,
    required this.ifCondLeftParen,
    required this.condition,
    required this.ifCondRightParen,
    required this.ifBody,
    this.elseToken,
    this.elseBody,
  });

  final Token<String> ifToken;
  final Token<String> ifCondLeftParen;
  final ExpressionNode condition;
  final Token<String> ifCondRightParen;
  final StatementOrBlockNode ifBody;
  final Token<String>? elseToken;
  final StatementOrBlockNode? elseBody;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitIf(this);

  @override
  Token get beginToken => ifToken;

  @override
  Token get endToken => elseBody?.endToken ?? ifBody.endToken;
}
