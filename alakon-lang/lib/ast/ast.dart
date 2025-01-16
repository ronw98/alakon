import 'package:petitparser/petitparser.dart';

import 'expressions.dart';

export 'expressions.dart';

class CodePosition {
  const CodePosition({
    required this.line,
    required this.column,
  });

  final int line;
  final int column;
}

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
  CodePosition get start;

  CodePosition get end;

  R accept<R>(AstVisitor<R> visitor);
}

class ProgramNode implements AstNode {
  ProgramNode({required this.statements});

  final List<StatementNode> statements;

  @override
  CodePosition get start => statements.first.start;

  @override
  CodePosition get end => statements.last.end;

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitProgram(this);
}

abstract class StatementNode implements AstNode {}

class VariableDeclarationNode extends StatementNode {
  VariableDeclarationNode({
    required this.variableType,
    required this.variableName,
    this.assign,
  });

  final Token<String> variableType;
  final Token<String> variableName;
  final ExpressionNode? assign;

  @override
  CodePosition get start {
    return CodePosition(
      line: variableType.line,
      column: variableType.column,
    );
  }

  @override
  CodePosition get end {
    if (assign case final assign?) return assign.end;
    return CodePosition(
      line: variableName.line,
      column: variableName.column,
    );
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitVariableDeclaration(this);
}

class VariableAssignNode extends StatementNode {
  VariableAssignNode({required this.variableName, required this.assign});

  final Token<String> variableName;
  final ExpressionNode assign;

  @override
  CodePosition get start {
    return CodePosition(
      line: variableName.line,
      column: variableName.column,
    );
  }

  @override
  CodePosition get end {
    return assign.end;
  }

  @override
  R accept<R>(AstVisitor<R> visitor) => visitor.visitVariableAssign(this);
}
