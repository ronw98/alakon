import 'package:petitparser/petitparser.dart';

import 'ast/ast.dart';

class AlakonGrammar extends GrammarDefinition {
  @override
  Parser start() => ref0(program);

  Parser program() =>
      ref0(statement).plus() &
      (ref0(statement) & endOfInput())
          .or(endOfInput(), failureJoiner: selectFarthest);

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

  Parser tokenEquals() => ref1(token, '=');

  Parser tokenLeftParen() => ref1(token, '(');

  Parser tokenRightParen() => ref1(token, ')');

  Parser tokenMinus() => ref1(token, '-');

  Parser tokenPlus() => ref1(token, '+');

  Parser tokenStar() => ref1(token, '*');

  Parser tokenSlash() => ref1(token, '/');

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

  Parser statement() => ref0(printStatement)
      .or(ref0(variableAssign), failureJoiner: selectFarthest)
      .or(ref0(variableDec), failureJoiner: selectFarthest);

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
      );
    return builder.build();
  }
}
