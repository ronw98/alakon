import 'package:petitparser/petitparser.dart';

import 'ast/ast.dart';

class AlakonGrammar extends GrammarDefinition {
  @override
  Parser start() => ref0(program);

  Parser program() => ref0(statement).plus() & endOfInput();

  Parser token(Object input, [String? message]) {
    if (input is Parser) {
      return input.flatten(message).token().trim(char(' '));
    } else if (input is String) {
      return token(input.toParser());
    } else if (input is Parser Function()) {
      return token(ref0(input));
    }
    throw ArgumentError.value(input, 'Invalid token parser');
  }

  Parser tokenWhile() => ref1(token, 'while');

  Parser tokenIf() => ref1(token, 'if');

  Parser tokenElse() => ref1(token, 'else');

  Parser tokenEquals() => ref1(token, '=');

  Parser tokenLeftParen() => ref1(token, '(');

  Parser tokenRightParen() => ref1(token, ')');

  Parser tokenLeftBrace() => ref1(token, '{');

  Parser tokenRightBrace() => ref1(token, '}');

  Parser tokenMinus() => ref1(token, '-');

  Parser tokenPlus() => ref1(token, '+');

  Parser tokenStar() => ref1(token, '*');

  Parser tokenSlash() => ref1(token, '/');

  Parser tokenAnd() => ref1(token, '&&');

  Parser tokenOr() => ref1(token, '||');

  Parser tokenNot() => ref1(token, '!');

  Parser tokenTrue() => ref1(token, 'true');

  Parser tokenFalse() => ref1(token, 'false');

  Parser tokenNum() => ref1(token, 'num');

  Parser tokenBool() => ref1(token, 'bool');

  Parser tokenString() => ref1(token, 'String');

  Parser numberLexicalToken() => ref1(
        token,
        digit().plus().seq(
              '.'
                  .toParser()
                  .seq(
                    digit().plus().or(
                          failure('Number cannot end with "."'),
                        ),
                  )
                  .optional(),
            ),
      );

  Parser stringLexicalToken() =>
      ref1(token, char('"')) &
      ref1(token, any().starLazy(char('"'))) &
      ref1(token, char('"').or(failure('" expected')));

  Parser booleanLexicalToken() => tokenTrue() | tokenFalse();

  Parser statementEnd() => newline() | endOfInput();

  Parser identifier() => ref2(
        token,
        letter() & word().star(),
        'identifier expected',
      );

  /// Types
  Parser type() => ref0(tokenNum)
      .or(ref0(tokenBool), failureJoiner: selectFarthest)
      .or(ref0(tokenString), failureJoiner: selectFarthest);

  /// Primitives
  Parser intValue() => digit().plus();

  Parser trueValue() => ref1(token, 'true');

  Parser falseValue() => ref1(token, 'true');

  Parser block() =>
      ref0(tokenLeftBrace) &
      whitespace().star() &
      (ref0(statement) | whitespace()).star() &
      whitespace().star() &
      ref0(tokenRightBrace);

  Parser statement() => (ref0(printStatement)
          .or(ref0(variableAssign), failureJoiner: selectFarthest)
          .or(ref0(variableDec), failureJoiner: selectFarthest)
          .or(ref0(ifElse), failureJoiner: selectFarthest))
      .or(ref0(whileLoop), failureJoiner: selectFarthest)
      .trim();

  Parser ifElse() =>
      ref0(tokenIf) &
      ref0(tokenLeftParen) &
      ref0(expression) &
      ref0(tokenRightParen) &
      whitespace().star() &
      ref0(statementOrBlock) &
      (whitespace().star() &
              ref0(tokenElse) &
              whitespace().star() &
              ref0(statementOrBlock))
          .optional();

  Parser whileLoop() =>
      ref0(tokenWhile) &
      ref0(tokenLeftParen) &
      ref0(expression) &
      ref0(tokenRightParen) &
      ref0(statementOrBlock).trim();

  Parser statementOrBlock() =>
      ref0(statement).or(ref0(block), failureJoiner: selectFarthest);

  Parser variableDec() =>
      ref0(type) &
      ref0(identifier) &
      (statementEnd() |
          (ref0(tokenEquals) &
              ref0(expression).or(failure('Expression expected'),
                  failureJoiner: selectFarthest) &
              statementEnd()));

  Parser variableAssign() =>
      ref0(identifier) &
      ref0(tokenEquals) &
      ref0(expression).or(failure('Expression expected')) &
      statementEnd();

  Parser printStatement() =>
      ref1(token, 'print') &
      ref0(tokenLeftParen) &
      ref0(expression).or(
        failure('Expression expected'),
        failureJoiner: selectFarthest,
      ) &
      ref0(tokenRightParen) &
      statementEnd();

  Parser identifierExpression() => ref0(identifier);

  Parser primitiveExpression() => ref0(numberLexicalToken)
      .or(ref0(booleanLexicalToken), failureJoiner: selectFarthest)
      .or(ref0(stringLexicalToken), failureJoiner: selectFarthest)
      .or(ref0(identifierExpression), failureJoiner: selectFarthest);

  /// Expressions
  ///
  /// ### Primitives (in descending order of priority):
  /// * literal string
  /// * literal number
  /// * literal boolean
  /// * variable identifier
  ///
  /// ### Operators (in descending order of priority):
  /// * parenthesis `(expr)`
  /// * negation `- expr`
  /// * multiplication (same priority)
  ///   * multiply `expr * expr`
  ///   * divide `expr / expr`
  /// * addition (same priority)
  ///   * add `expr + expr`
  ///   * subtract `expr - expr`
  Parser expression() {
    final builder = ExpressionBuilder()..primitive(ref0(primitiveExpression));

    builder.group().wrapper(
      ref0(tokenLeftParen).trim(),
      ref0(tokenRightParen).trim(),
      (left, value, right) {
        return ParenthesisedExpressionNode(
          tokenLeftParen: left,
          expression: value,
          tokenRightParen: right,
        );
      },
    );

    builder.group().prefix(
      ref0(tokenMinus).trim(),
      (minus, value) {
        return NegatedExpressionNode(expression: value, tokenMinus: minus);
      },
    );

    builder.group().prefix(
      ref0(tokenNot).trim(),
      (not, value) {
        return NotExpressionNode(
          expression: value,
          tokenNot: not,
        );
      },
    );

    builder.group()
      ..left(
        ref0(tokenStar).trim(),
        (left, tokenStar, right) {
          return MultiplicationExpressionNode(
            left: left,
            right: right,
            tokenOperand: tokenStar,
          );
        },
      )
      ..left(
        ref0(tokenSlash).trim(),
        (left, tokenSlash, right) {
          return DivisionExpressionNode(
            left: left,
            right: right,
            tokenOperand: tokenSlash,
          );
        },
      )
      ..left(
        ref0(tokenAnd).trim(),
        (left, tokenAnd, right) {
          return AndExpressionNode(
            left: left,
            right: right,
            tokenOperand: tokenAnd,
          );
        },
      );

    builder.group()
      ..left(
        ref0(tokenMinus).trim(),
        (left, tokenMinus, right) {
          return SubtractionExpressionNode(
            left: left,
            right: right,
            tokenOperand: tokenMinus,
          );
        },
      )
      ..left(
        ref0(tokenPlus).trim(),
        (left, tokenPlus, right) {
          return AdditionExpressionNode(
            left: left,
            right: right,
            tokenOperand: tokenPlus,
          );
        },
      )
      ..left(
        ref0(tokenOr).trim(),
        (left, tokenOr, right) {
          return OrExpressionNode(
            left: left,
            right: right,
            tokenOperand: tokenOr,
          );
        },
      );
    return builder.build();
  }
}
