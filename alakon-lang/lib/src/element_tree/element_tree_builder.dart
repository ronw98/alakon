import 'package:alakon_lang/alakon_lang.dart';

import 'elements/element.dart';

/// Utility class that builds an [AlakonProgram] from a [ProgramNode].
///
/// This is based on [_ElementTreeBuilder] that builds an element tree from an
/// AST.
///
/// This class exists to provide public typesafe tree builder.
class ElementTreeBuilder {
  AlakonProgram build(ProgramNode program) {
    return program.accept(_ElementTreeBuilder()) as AlakonProgram;
  }
}

/// Ast visitor that builds an element tree from the AST.
///
/// Sometimes this class' methods will cast values from [AlakonElement] to
/// subtypes.
/// This is because as the [AstVisitor] has a generic type, all
/// methods must return that type. But because this class knows its own
/// implementation it knows that visiting an [ExpressionNode] always returns an
/// [AlakonExpression], meaning it is safe to cast.
///
/// To avoid exposing casting in a public api, [ElementTreeBuilder] is used to
/// build a program from a program node, which is how this class is intended to
/// be used.
class _ElementTreeBuilder implements AstVisitor<AlakonElement> {
  @override
  AlakonElement visitAdditionExpression(AdditionExpressionNode node) {
    return AlakonAdd(
      // As node.left is an expression, the result is ensured to be an
      // AlakonExpression per this class definition.
      left: node.left.accept(this) as AlakonExpression,
      right: node.right.accept(this) as AlakonExpression,
    );
  }

  @override
  AlakonElement visitBooleanExpression(BooleanExpressionNode node) {
    return AlakonBoolExpression(node.value.value);
  }

  @override
  AlakonElement visitDivisionExpression(DivisionExpressionNode node) {
    return AlakonDivide(
      left: node.left.accept(this) as AlakonExpression,
      right: node.right.accept(this) as AlakonExpression,
    );
  }

  @override
  AlakonElement visitMultiplicationExpression(
      MultiplicationExpressionNode node,) {
    return AlakonMultiply(
      left: node.left.accept(this) as AlakonExpression,
      right: node.right.accept(this) as AlakonExpression,
    );
  }

  @override
  AlakonElement visitAndExpression(AndExpressionNode node) {
    return AlakonAnd(
      left: node.left.accept(this) as AlakonExpression,
      right: node.right.accept(this) as AlakonExpression,
    );
  }

  @override
  AlakonElement visitOrExpression(OrExpressionNode node) {
    return AlakonOr(
      left: node.left.accept(this) as AlakonExpression,
      right: node.right.accept(this) as AlakonExpression,
    );
  }

  @override
  AlakonElement visitNotExpression(NotExpressionNode node) {
    return AlakonNot(
      expression: node.expression.accept(this) as AlakonExpression,
    );
  }

  @override
  AlakonElement visitNegatedExpression(NegatedExpressionNode node) {
    return AlakonNegated(
      expression: node.expression.accept(this) as AlakonExpression,
    );
  }

  @override
  AlakonElement visitNumberExpression(NumberExpressionNode node) {
    return AlakonNumberExpression(node.value.value);
  }

  @override
  AlakonElement visitParenthesisedExpression(ParenthesisedExpressionNode node) {
    return AlakonParen(
        expression: node.expression.accept(this) as AlakonExpression);
  }

  @override
  AlakonElement visitPrint(PrintNode node) {
    return AlakonPrint(
        expression: node.expression.accept(this) as AlakonExpression);
  }

  @override
  AlakonElement visitProgram(ProgramNode node) {
    return AlakonProgram(
      node.statements.map(
            (statement) {
          return statement.accept(this) as AlakonStatement;
        },
      ).toList(),
    );
  }

  @override
  AlakonElement visitReferenceExpression(ReferenceExpressionNode node) {
    return AlakonReferenceExpression(variableName: node.value.value);
  }

  @override
  AlakonElement visitStringExpression(StringExpressionNode node) {
    return AlakonStringExpression(node.value.value);
  }

  @override
  AlakonElement visitSubtractionExpression(SubtractionExpressionNode node) {
    return AlakonSubtract(
      left: node.left.accept(this) as AlakonExpression,
      right: node.right.accept(this) as AlakonExpression,
    );
  }

  @override
  AlakonElement visitVariableAssign(VariableAssignNode node) {
    return AlakonVariableAssign(
      expression: node.assign.accept(this) as AlakonExpression,
      variableName: node.variableName.value,
    );
  }

  @override
  AlakonElement visitVariableDeclaration(VariableDeclarationNode node) {
    return AlakonVariableDeclaration(
      expression: node.assign?.accept(this) as AlakonExpression?,
      variableName: node.variableName.value,
      variableType: node.variableType.value,
    );
  }

  @override
  AlakonElement visitBlock(BlockNode node) {
    return AlakonBlock(
      statements: node.statements.map(
            (statement) {
          return statement.accept(this) as AlakonStatement;
        },
      ).toList(),
    );
  }

  @override
  AlakonElement visitIf(IfNode node) {
    final condition = node.condition.accept(this) as AlakonExpression;
    final ifBody = node.ifBody.accept(this) as AlakonStatementOrBlock;
    final elseBody = node.elseBody?.accept(this) as AlakonStatementOrBlock?;
    return AlakonIf(condition, ifBody, elseBody);
  }
}
