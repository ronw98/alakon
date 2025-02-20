import 'package:alakon_lang/alakon_lang.dart';
import 'package:editor/src/alakon_theme.dart';
import 'package:flutter/material.dart';

extension _AnalysisErrorExt on AnalysisError {
  bool containsToken(Token token) {
    if (token.line < begin.line) return false;
    if (token.line > end.line) return false;

    // Error spans across multiple lines
    if (begin.line != end.line) {
      if (token.line == begin.line) {
        // Token is same line as start and is after, so it is contained
        return token.column >= begin.column;
      }
      if (token.line == end.line) {
        return token.column <= end.column;
      }
    }

    // Error is on a single line, token should be between begin column and end
    // column.
    return token.column <= end.column && token.column >= begin.column;
  }
}

/// An [AstVisitor] that creates a [TextSpan] from the AST.
///
/// This class is used to perform syntax highlighting on the code that produced
/// the AST.
class TextSpanBuilder implements AstVisitor<TextSpan> {
  TextSpanBuilder({
    required this.analysisResult,
    required this.rawText,
    required this.errorStyle,
    required this.theme,
  });

  /// Analysis result performed on the AST.
  ///
  /// Used to highlight errors in the resulting text span.
  final AnalysisResult? analysisResult;

  /// The Alakon code that produced the AST as a string.
  final String rawText;
  final TextStyle? errorStyle;

  /// The theme to apply to code elements.
  final Map<LanguageElement, TextStyle> theme;

  @override
  TextSpan visitAdditionExpression(AdditionExpressionNode node) {
    return _writeTwoFactorsOperation(node);
  }

  @override
  TextSpan visitBooleanExpression(BooleanExpressionNode node) {
    return _createTokenSpan(node.value, theme[LanguageElement.keyword]);
  }

  @override
  TextSpan visitDivisionExpression(DivisionExpressionNode node) {
    return _writeTwoFactorsOperation(node);
  }

  @override
  TextSpan visitMultiplicationExpression(MultiplicationExpressionNode node) {
    return _writeTwoFactorsOperation(node);
  }

  @override
  TextSpan visitNegatedExpression(NegatedExpressionNode node) {
    final minusSpan = _createTokenSpan(node.tokenMinus);
    final blankSpan = _writeBlanks(node.tokenMinus, node.expression.beginToken);
    final expressionSpan = node.expression.accept(this);
    return TextSpan(
      children: [
        minusSpan,
        blankSpan,
        expressionSpan,
      ],
    );
  }

  @override
  TextSpan visitNumberExpression(NumberExpressionNode node) {
    return _createTokenSpan(node.value, theme[LanguageElement.number]);
  }

  @override
  TextSpan visitParenthesisedExpression(ParenthesisedExpressionNode node) {
    final leftParenSpan = _createTokenSpan(node.tokenLeftParen);
    final leftSpace = _writeBlanks(
      node.tokenLeftParen,
      node.expression.beginToken,
    );
    final expressionSpan = node.expression.accept(this);
    final rightSpace = _writeBlanks(
      node.expression.endToken,
      node.tokenRightParen,
    );
    final rightParenSpan = _createTokenSpan(node.tokenRightParen);
    return TextSpan(
      children: [
        leftParenSpan,
        leftSpace,
        expressionSpan,
        rightSpace,
        rightParenSpan,
      ],
    );
  }

  @override
  TextSpan visitPrint(PrintNode node) {
    final printSpan = _createTokenSpan(node.printToken);
    final printSpace = _writeBlanks(node.printToken, node.tokenLeftParen);
    final leftParenSpan = _createTokenSpan(node.tokenLeftParen);
    final leftSpace = _writeBlanks(
      node.tokenLeftParen,
      node.expression.beginToken,
    );
    final expressionSpan = node.expression.accept(this);
    final rightSpace = _writeBlanks(
      node.expression.endToken,
      node.tokenRightParen,
    );
    final rightParenSpan = _createTokenSpan(node.tokenRightParen);
    return TextSpan(
      children: [
        printSpan,
        printSpace,
        leftParenSpan,
        leftSpace,
        expressionSpan,
        rightSpace,
        rightParenSpan,
      ],
    );
  }

  @override
  TextSpan visitProgram(ProgramNode node) {
    final List<TextSpan> spans = [];
    for (int i = 0; i < node.statements.length; i++) {
      if (i == 0) {
        spans.add(
          TextSpan(
            text: rawText.substring(0, node.statements[i].beginToken.start),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: rawText.substring(
              node.statements[i - 1].endToken.stop,
              node.statements[i].beginToken.start,
            ),
          ),
        );
      }
      spans.add(node.statements[i].accept(this));
      if (i == node.statements.length - 1) {
        spans.add(
          TextSpan(
            text: rawText.substring(node.statements[i].endToken.stop),
          ),
        );
      }
    }

    return TextSpan(
      children: spans,
    );
  }

  @override
  TextSpan visitReferenceExpression(ReferenceExpressionNode node) {
    return _createTokenSpan(node.value, theme[LanguageElement.variableRef]);
  }

  @override
  TextSpan visitStringExpression(StringExpressionNode node) {
    final leftQuotesSpan = _createTokenSpan(
      node.leftQuotes,
      theme[LanguageElement.string],
    );
    final valueSpan = _createTokenSpan(
      node.value,
      theme[LanguageElement.string],
    );
    final rightQuotesSpan = _createTokenSpan(
      node.rightQuotes,
      theme[LanguageElement.string],
    );

    return TextSpan(
      children: [leftQuotesSpan, valueSpan, rightQuotesSpan],
    );
  }

  @override
  TextSpan visitSubtractionExpression(SubtractionExpressionNode node) {
    return _writeTwoFactorsOperation(node);
  }

  @override
  TextSpan visitVariableAssign(VariableAssignNode node) {
    final variableSpan = _createTokenSpan(
      node.variableName,
      theme[LanguageElement.variableRef],
    );
    final variableRightSpace = _writeBlanks(
      node.variableName,
      node.tokenEquals,
    );
    final equalsSpan = _createTokenSpan(node.tokenEquals);
    final equalsRightSpace = _writeBlanks(
      node.tokenEquals,
      node.assign.beginToken,
    );
    final assignSpan = node.assign.accept(this);

    return TextSpan(
      children: [
        variableSpan,
        variableRightSpace,
        equalsSpan,
        equalsRightSpace,
        assignSpan,
      ],
    );
  }

  @override
  TextSpan visitVariableDeclaration(VariableDeclarationNode node) {
    final typeSpan = _createTokenSpan(
      node.variableType,
      theme[LanguageElement.builtIn],
    );
    final typeRightSpace = _writeBlanks(node.variableType, node.variableName);
    final variableSpan = _createTokenSpan(node.variableName);
    if (node.assign != null) {
      final variableRightSpace = _writeBlanks(
        node.variableName,
        node.tokenEquals!,
      );
      final equalsSpan = _createTokenSpan(node.tokenEquals!);
      final equalsRightSpace = _writeBlanks(
        node.tokenEquals!,
        node.assign!.beginToken,
      );
      final assignSpan = node.assign!.accept(this);

      return TextSpan(
        children: [
          typeSpan,
          typeRightSpace,
          variableSpan,
          variableRightSpace,
          equalsSpan,
          equalsRightSpace,
          assignSpan,
        ],
      );
    } else {
      return TextSpan(
        children: [
          typeSpan,
          typeRightSpace,
          variableSpan,
        ],
      );
    }
  }

  /// Creates the span for the given [token].
  ///
  /// Applies [style] to the returned span.
  TextSpan _createTokenSpan(Token token, [TextStyle? style]) {
    final text = '${token.value}';
    final errors = (analysisResult?.errors ?? <AnalysisError>[]).where(
      (error) {
        return error.containsToken(token);
      },
    ).toList();

    return TextSpan(
      text: text,
      style: (style ?? TextStyle()).merge(errors.isEmpty ? null : errorStyle),
    );
  }

  /// Writes the text span for a two factor operation, such as addition,
  /// subtraction, multiplication or division.
  TextSpan _writeTwoFactorsOperation(OperationExpressionNode node) {
    final leftSpan = node.left.accept(this);
    final leftSpace = _writeBlanks(node.left.endToken, node.tokenOperand);
    final operandSpan = _createTokenSpan(node.tokenOperand);
    final rightSpace = _writeBlanks(node.tokenOperand, node.right.beginToken);
    final rightSpan = node.right.accept(this);
    return TextSpan(
      children: [
        leftSpan,
        leftSpace,
        operandSpan,
        rightSpace,
        rightSpan,
      ],
    );
  }

  /// Returns a [TextSpan] that contains all the character between current
  /// position and [stop] token.
  TextSpan _writeBlanks(Token start, Token stop) {
    return TextSpan(text: rawText.substring(start.stop, stop.start));
  }
}
