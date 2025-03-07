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
    return _writeList([node.value.toBuilder(theme[LanguageElement.keyword])]);
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
  TextSpan visitAndExpression(AndExpressionNode node) {
    return _writeTwoFactorsOperation(node);
  }

  @override
  TextSpan visitOrExpression(OrExpressionNode node) {
    return _writeTwoFactorsOperation(node);
  }

  @override
  TextSpan visitNotExpression(NotExpressionNode node) {
    return _writeList(
      [
        node.tokenNot.toBuilder(),
        node.expression.toBuilder(),
      ],
    );
  }

  @override
  TextSpan visitNegatedExpression(NegatedExpressionNode node) {
    return _writeList(
      [
        node.tokenMinus.toBuilder(),
        node.expression.toBuilder(),
      ],
    );
  }

  @override
  TextSpan visitNumberExpression(NumberExpressionNode node) {
    return _writeList([node.value.toBuilder(theme[LanguageElement.number])]);
  }

  @override
  TextSpan visitParenthesisedExpression(ParenthesisedExpressionNode node) {
    return _writeList(
      [
        node.tokenLeftParen.toBuilder(),
        node.expression.toBuilder(),
        node.tokenRightParen.toBuilder(),
      ],
    );
  }

  @override
  TextSpan visitPrint(PrintNode node) {
    return _writeList(
      [
        node.printToken.toBuilder(),
        node.tokenLeftParen.toBuilder(),
        node.expression.toBuilder(),
        node.tokenRightParen.toBuilder(),
      ],
    );
  }

  @override
  TextSpan visitProgram(ProgramNode node) {
    final startBlank = _writeBlanks(
      null,
      node.statements.firstOrNull?.beginToken,
    );
    final statements = _writeList(node.statements.toBuilder());
    // Do not write anything if no statements as it would duplicate
    // [startBlank].
    final endBlank = node.statements.isEmpty
        ? null
        : _writeBlanks(node.statements.last.endToken, null);

    return TextSpan(
      children: [startBlank, statements, endBlank].nonNulls.toList(),
    );
  }

  @override
  TextSpan visitReferenceExpression(ReferenceExpressionNode node) {
    return _writeList(
      [node.value.toBuilder(theme[LanguageElement.variableRef])],
    );
  }

  @override
  TextSpan visitStringExpression(StringExpressionNode node) {
    return _writeList(
      [
        node.leftQuotes.toBuilder(theme[LanguageElement.string]),
        node.value.toBuilder(theme[LanguageElement.string]),
        node.rightQuotes.toBuilder(theme[LanguageElement.string]),
      ],
    );
  }

  @override
  TextSpan visitSubtractionExpression(SubtractionExpressionNode node) {
    return _writeTwoFactorsOperation(node);
  }

  @override
  TextSpan visitVariableAssign(VariableAssignNode node) {
    return _writeList(
      [
        node.variableName.toBuilder(theme[LanguageElement.variableRef]),
        node.tokenEquals.toBuilder(),
        node.assign.toBuilder(),
      ],
    );
  }

  @override
  TextSpan visitVariableDeclaration(VariableDeclarationNode node) {
    return _writeList(
      [
        node.variableType.toBuilder(theme[LanguageElement.builtIn]),
        node.variableName.toBuilder(),
        node.tokenEquals?.toBuilder(),
        node.assign?.toBuilder(),
      ].nonNulls.toList(),
    );
  }

  @override
  TextSpan visitBlock(BlockNode node) {
    return _writeList(
      [
        node.leftBrace.toBuilder(),
        ...node.statements.toBuilder(),
        node.rightBrace.toBuilder()
      ],
    );
  }

  @override
  TextSpan visitIf(IfNode node) {
    return _writeList(
      [
        node.ifToken.toBuilder(theme[LanguageElement.keyword]),
        node.ifCondLeftParen.toBuilder(),
        node.condition.toBuilder(),
        node.ifCondRightParen.toBuilder(),
        node.ifBody.toBuilder(),
        node.elseToken?.toBuilder(theme[LanguageElement.keyword]),
        node.elseBody?.toBuilder(),
      ].nonNulls.toList(),
    );
  }

  /// Writes the text span for a two factor operation, such as addition,
  /// subtraction, multiplication or division.
  TextSpan _writeTwoFactorsOperation(OperationExpressionNode node) {
    return _writeList(
      [
        node.left.toBuilder(),
        node.tokenOperand.toBuilder(),
        node.right.toBuilder(),
      ],
    );
  }

  /// Returns a [TextSpan] that contains all the characters [start] and [stop]
  /// token.
  ///
  /// If [start] is `null`, returns all characters from beginning to [stop].
  /// If [stop] is `null`, returns all characters from [start] to end.
  ///
  /// If both are `null` returns [rawText].
  TextSpan _writeBlanks(Token? start, Token? stop) {
    return TextSpan(text: rawText.substring(start?.stop ?? 0, stop?.start));
  }

  /// Writes the list of given elements.
  ///
  /// This is a utility method to build the spans for the given elements, mainly
  /// automatically building the blank characters.
  TextSpan _writeList(List<_ElementBuilder> elements) {
    final List<TextSpan> spans = [];
    for (int i = 0; i < elements.length; i++) {
      final current = elements[i];
      if (i != 0) {
        final prev = elements[i - 1];
        // Write blanks between current statement and previous statement
        final start = switch (prev) {
          _NodeBuilder(node: final node) => node.endToken,
          _TokenBuilder(token: final token) => token,
        };

        final stop = switch (current) {
          _NodeBuilder(node: final node) => node.beginToken,
          _TokenBuilder(token: final token) => token,
        };
        spans.add(_writeBlanks(start, stop));
      }
      final TextSpan currentSpan = switch (current) {
        final _NodeBuilder nodeBuilder => nodeBuilder.createSpan(this),
        final _TokenBuilder tokenBuilder =>
          tokenBuilder.createSpan(analysisResult, errorStyle),
      };
      spans.add(currentSpan);
    }

    return TextSpan(
      children: spans,
    );
  }
}

/// An element builder that builds a text span for a single element.
sealed class _ElementBuilder {}

/// Builds a text span for an [AstNode].
class _NodeBuilder extends _ElementBuilder {
  _NodeBuilder({required this.node});

  final AstNode node;

  TextSpan createSpan(TextSpanBuilder visitor) {
    return node.accept(visitor);
  }
}

/// Builds a text span fora [Token].
///
/// The span is styled with [style].
class _TokenBuilder extends _ElementBuilder {
  _TokenBuilder({
    required this.token,
    this.style,
  });

  final Token token;
  final TextStyle? style;

  /// Creates the span for the given [token].
  ///
  /// Applies [style] to the returned span.
  TextSpan createSpan(AnalysisResult? analysisResult, TextStyle? errorStyle) {
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
}

extension _TokenExt on Token {
  _TokenBuilder toBuilder([TextStyle? style]) {
    return _TokenBuilder(token: this, style: style);
  }
}

extension _NodeExt on AstNode {
  _NodeBuilder toBuilder() => _NodeBuilder(node: this);
}

extension _NodeListExt on List<AstNode> {
  List<_NodeBuilder> toBuilder() => map((e) => e.toBuilder()).toList();
}
