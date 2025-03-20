import 'package:petitparser/core.dart';
import 'package:petitparser/parser.dart';

import 'ast/ast.dart';
import 'grammar.dart';

class AlakonParser extends AlakonGrammar {
  @override
  Parser variableDec() => super.variableDec().map(
        (value) {
          return switch (value) {
            [
              final type,
              final name,
              [final tokenEq, final assign, _],
            ] =>
              VariableDeclarationNode(
                variableType: type,
                variableName: name,
                tokenAssign: tokenEq,
                assign: assign,
              ),
            [final type, final name, ...] => VariableDeclarationNode(
                variableType: type,
                variableName: name,
              ),
            _ => throw Error(),
          };
        },
      );

  @override
  Parser variableAssign() => super.variableAssign().map(
        (value) {
          return switch (value) {
            [final variable, final tokenEq, final assign, _] =>
              VariableAssignNode(
                variableName: variable,
                assign: assign,
                tokenAssign: tokenEq,
              ),
            _ => throw Error(),
          };
        },
      );

  @override
  Parser printStatement() => super.printStatement().map(
        (value) {
          return switch (value) {
            [
              final Token<String> print,
              final leftParen,
              final exp,
              final rightParen,
              _,
            ] =>
              PrintNode(
                printToken: print,
                expression: exp,
                tokenLeftParen: leftParen,
                tokenRightParen: rightParen,
              ),
            _ => throw Error(),
          };
        },
      );

  @override
  Parser statement() => super.statement().map(
        (value) {
          return switch (value) {
            final StatementNode statement => statement,
            _ => throw Error(),
          };
        },
      );

  @override
  Parser program() => super.program().map(
        (value) {
          return switch (value) {
            [final List statements, _]
                when statements.all((e) => e is StatementNode) =>
              ProgramNode(
                statements: statements.whereType<StatementNode>().toList(),
              ),
            _ => throw Error(),
          };
        },
      );

  @override
  Parser numberLexicalToken() => super.numberLexicalToken().map(
        (value) {
          final numberToken = Token(
            num.parse(value.value),
            value.buffer,
            value.start,
            value.stop,
          );
          return NumberExpressionNode(numberToken);
        },
      );

  @override
  Parser booleanLexicalToken() => super.booleanLexicalToken().map(
        (value) {
          final boolToken = Token(
            bool.parse(value.value),
            value.buffer,
            value.start,
            value.stop,
          );
          return BooleanExpressionNode(boolToken);
        },
      );

  @override
  Parser stringLexicalToken() => super.stringLexicalToken().map(
        (value) {
          return switch (value) {
            [final leftQuote, final value, final rightQuote] =>
              StringExpressionNode(
                value: value,
                leftQuotes: leftQuote,
                rightQuotes: rightQuote,
              ),
            _ => throw Error(),
          };
        },
      );

  @override
  Parser identifierExpression() => super.identifierExpression().map(
        (value) {
          return ReferenceExpressionNode(value);
        },
      );

  @override
  Parser block() => super.block().map(
        (value) {
          return switch (value) {
            [
              final Token<String> leftBrace,
              _,
              final List statements,
              _,
              final Token<String> rightBrace
            ] =>
              BlockNode(
                leftBrace: leftBrace,
                rightBrace: rightBrace,
                statements: statements.whereType<StatementNode>().toList(),
              ),
            _ => throw Exception()
          };
        },
      );

  @override
  Parser ifElse() => super.ifElse().map(
        (value) {
          return switch (value) {
            [
              final Token<String> ifToken,
              final Token<String> ifCondLeftParen,
              final ExpressionNode condition,
              final Token<String> ifCondRightParen,
              _,
              final StatementOrBlockNode ifBody,
              [
                _,
                final Token<String> elseToken,
                _,
                final StatementOrBlockNode elseBody,
              ],
            ] =>
              IfNode(
                ifToken: ifToken,
                ifCondLeftParen: ifCondLeftParen,
                condition: condition,
                ifCondRightParen: ifCondRightParen,
                ifBody: ifBody,
                elseToken: elseToken,
                elseBody: elseBody,
              ),
            [
              final Token<String> ifToken,
              final Token<String> ifCondLeftParen,
              final ExpressionNode condition,
              final Token<String> ifCondRightParen,
              _,
              final StatementOrBlockNode ifBody,
              _
            ] =>
              IfNode(
                ifToken: ifToken,
                ifCondLeftParen: ifCondLeftParen,
                condition: condition,
                ifCondRightParen: ifCondRightParen,
                ifBody: ifBody,
              ),
            _ => throw Exception(),
          };
        },
      );

  @override
  Parser whileLoop() => super.whileLoop().map((value) {
        return switch (value) {
          [
            final Token<String> whileToken,
            final Token<String> condLeftParen,
            final ExpressionNode condition,
            final Token<String> condRightParen,
            final StatementOrBlockNode body,
          ] =>
            WhileNode(
              whileToken: whileToken,
              condLeftParen: condLeftParen,
              condition: condition,
              condRightParen: condRightParen,
              body: body,
            ),
          _ => throw Exception(),
        };
      });
}

extension ListExt<T> on List<T> {
  bool all(bool Function(T) predicate) {
    return !this.any((e) => !predicate(e));
  }
}
