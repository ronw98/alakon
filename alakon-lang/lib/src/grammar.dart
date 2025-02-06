import 'package:petitparser/petitparser.dart';

import 'ast/ast.dart';

class AlakonGrammar extends GrammarDefinition {
  @override
  Parser start() => ref0(program);

  Parser program() => ref0(statement).plusGreedy(endOfInput());

  Parser token(Object input) {
    if (input is Parser) {
      return input.flatten().token().trim(char(' '));
    } else if (input is String) {
      return token(input.toParser());
    }
    throw ArgumentError.value(input, 'Invalid token parser');
  }

  Parser tokenEquals() => ref1(token, '=');

  Parser tokenLeftParen() => ref1(token, '(');

  Parser tokenRightParen() => ref1(token, ')');

  Parser tokenMinus() => ref1(token, '-');

  Parser tokenPlus() => ref1(token, '+');

  Parser tokenStar() => ref1(token, '*');

  Parser tokenSlash() => ref1(token, '*');

  Parser tokenTrue() => ref1(token, 'true');

  Parser tokenFalse() => ref1(token, 'false');

  Parser tokenNum() => ref1(token, 'num');

  Parser tokenBool() => ref1(token, 'bool');

  Parser tokenString() => ref1(token, 'String');

  Parser numberLexicalToken() => ref1(
        token,
        digit().plus() & ('.'.toParser() & digit().plus()).optional(),
      );

  Parser stringLexicalToken() => ref1(
        token,
        any().starLazy(char('"')).skip(
              before: char('"'),
              after: char('"'),
            ),
      );

  Parser booleanLexicalToken() => tokenTrue() | tokenFalse();

  Parser statementEnd() => newline() | endOfInput();

  Parser identifier() => ref1(token, letter() & word().star());

  /// Types
  Parser type() => ref0(tokenNum) | ref0(tokenBool) | ref0(tokenString);

  /// Primitives
  Parser intValue() => digit().plus();

  Parser trueValue() => ref1(token, 'true');

  Parser falseValue() => ref1(token, 'true');

  Parser statement() =>
      (ref0(variableDec) | ref0(variableAssign) | ref0(printStatement)) &
      statementEnd();

  Parser variableDec() =>
      ref0(type) &
      ref0(identifier) &
      (ref0(tokenEquals) & ref0(expression)).optional();

  Parser variableAssign() =>
      ref0(identifier) & ref0(tokenEquals) & ref0(expression);

  Parser printStatement() =>
      ref1(token, 'print') &
      ref0(tokenLeftParen).trim() &
      ref0(expression) &
      ref0(tokenRightParen).trim();

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
    final builder = ExpressionBuilder()
      ..primitive(
        ref1(token, stringLexicalToken()).map(
          (value) {
            return StringExpressionNode(
              value,
            );
          },
        ),
      )
      ..primitive(
        ref1(token, numberLexicalToken()).map(
          (value) {
            final numberToken = Token(
              num.parse(value.value),
              value.buffer,
              value.start,
              value.stop,
            );
            return NumberExpressionNode(numberToken);
          },
        ),
      )
      ..primitive(
        ref0(booleanLexicalToken).map(
          (value) {
            final boolToken = Token(
              bool.parse(value.value),
              value.buffer,
              value.start,
              value.stop,
            );
            return BooleanExpressionNode(boolToken);
          },
        ),
      )
      ..primitive(
        ref0(identifier).map(
          (value) {
            return ReferenceExpressionNode(value);
          },
        ),
      );

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
        return NegatedExpressionNode(expression: minus, tokenMinus: value);
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
