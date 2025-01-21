import 'package:collection/collection.dart';

import '../ast/ast.dart';
import 'analysis_errors.dart';
import 'analysis_result.dart';

/// Analyzer of the alakon language.
class AlakonAnalyzer {
  /// Analyzes the given [code].
  ///
  /// Throws an [AnalysisException] if at least one semantic error is found.
  /// The thrown exception will contain all the errors found in the analyzed
  /// program.
  void analyze(AstNode code) {
    final result = code.accept(_AnalyzerVisitor());

    if(result.hasError) {
      throw AnalysisException(result);
    }
  }
}

/// [AstVisitor] that returns an [AnalysisResult].
///
/// The returned result contains all the [AnalysisError]s found in the visited
/// node.
class _AnalyzerVisitor implements AstVisitor<AnalysisResult> {
  final List<_VariableDeclaration> _declaredVariables = [];

  /// Stores the type of the latest expression analyzed.
  ///
  /// This can be used to retrieve the type of an expression immediately after
  /// it is analyzed.
  ///
  /// Example:
  /// ```dart
  /// expressionNode.accept(this);
  /// final expressionType = _latestExpressionType;
  /// ```
  String? _latestExpressionType;

  @override
  AnalysisResult visitAdditionExpression(AdditionExpressionNode node) {
    final leftResult = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightResult = node.right.accept(this);
    final rightType = _latestExpressionType;

    final result = AnalysisResult.fromResults([leftResult, rightResult]);
    if (leftType != rightType && leftType != null) {
      result.recordError(
        TypeMismatchError(
          message: 'Expected type $leftType but got $rightType',
          line: node.right.start.line,
          column: node.right.start.column,
        ),
      );
    }
    _latestExpressionType = leftType;
    return result;
  }

  @override
  AnalysisResult visitBooleanExpression(BooleanExpressionNode node) {
    _latestExpressionType = 'boolean';

    return AnalysisResult();
  }

  @override
  AnalysisResult visitDivisionExpression(DivisionExpressionNode node) {
    final leftResult = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightResult = node.right.accept(this);
    final rightType = _latestExpressionType;

    final result = AnalysisResult.fromResults([leftResult, rightResult]);
    if (leftType != 'num') {
      result.recordError(
        TypeMismatchError(
          message: 'Expected num but got $leftType',
          line: node.left.start.line,
          column: node.left.start.column,
        ),
      );
    }
    if (rightType != 'num') {
      result.recordError(
        TypeMismatchError(
          message: 'Expected num but got $rightType',
          line: node.right.start.line,
          column: node.right.start.column,
        ),
      );
    }
    _latestExpressionType = leftType;
    return result;
  }

  @override
  AnalysisResult visitMultiplicationExpression(
      MultiplicationExpressionNode node) {
    final leftAnalysis = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightAnalysis = node.right.accept(this);
    final rightType = _latestExpressionType;

    final result = AnalysisResult.fromResults([leftAnalysis, rightAnalysis]);

    switch ((leftType, rightType)) {
      case ('String', _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got String',
            line: node.left.start.line,
            column: node.left.start.column,
          ),
        );
      case (_, 'String'):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got String',
            line: node.right.start.line,
            column: node.right.start.column,
          ),
        );
      case ('bool', _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got bool',
            line: node.left.start.line,
            column: node.left.start.column,
          ),
        );
      case (_, 'bool'):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got bool',
            line: node.right.start.line,
            column: node.right.start.column,
          ),
        );
    }
    _latestExpressionType = leftType;
    return result;
  }

  @override
  AnalysisResult visitNegatedExpression(NegatedExpressionNode node) {
    final analysisResult = node.expression.accept(this);
    if (_latestExpressionType != 'num') {
      analysisResult.recordError(
        TypeMismatchError(
          message: 'Expected num but got $_latestExpressionType',
          line: node.expression.start.line,
          column: node.expression.start.column,
        ),
      );
    }
    _latestExpressionType = 'num';
    return analysisResult;
  }

  @override
  AnalysisResult visitNumberExpression(NumberExpressionNode node) {
    _latestExpressionType = 'num';
    return AnalysisResult();
  }

  @override
  AnalysisResult visitParenthesisedExpression(
    ParenthesisedExpressionNode node,
  ) {
    return node.expression.accept(this);
  }

  @override
  AnalysisResult visitReferenceExpression(ReferenceExpressionNode node) {
    final variableName = node.value;
    final resolvedReference = _declaredVariables
        .firstWhereOrNull((dec) => dec.name == variableName.value);

    final result = AnalysisResult();
    if (resolvedReference == null) {
      result.recordError(
        UnknownReferenceError(
          message:
              'Variable "${variableName.value}" is referenced before it is '
              'declared',
          column: variableName.column,
          line: variableName.line,
        ),
      );
    }
    _latestExpressionType = resolvedReference?.type;
    return result;
  }

  @override
  AnalysisResult visitStringExpression(StringExpressionNode node) {
    _latestExpressionType = 'String';
    return AnalysisResult();
  }

  @override
  AnalysisResult visitSubtractionExpression(SubtractionExpressionNode node) {
    final leftResult = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightResult = node.right.accept(this);
    final rightType = _latestExpressionType;

    final result = AnalysisResult.fromResults(
      [
        leftResult,
        rightResult,
      ],
    );
    switch ((leftType, rightType)) {
      case ('String', _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got String',
            line: node.left.start.line,
            column: node.left.start.column,
          ),
        );
      case (_, 'String'):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got String',
            line: node.right.start.line,
            column: node.right.start.column,
          ),
        );
      case ('bool', _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got bool',
            line: node.left.start.line,
            column: node.left.start.column,
          ),
        );
      case (_, 'bool'):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got bool',
            line: node.right.start.line,
            column: node.right.start.column,
          ),
        );
    }
    _latestExpressionType = leftType;
    return result;
  }

  @override
  AnalysisResult visitProgram(ProgramNode node) {
    return AnalysisResult.fromResults(
      [
        for (final statement in node.statements) statement.accept(this),
      ],
    );
  }

  @override
  AnalysisResult visitVariableAssign(VariableAssignNode node) {
    final variableDec = _getVariableDecFromName(
      node.variableName.value,
    );
    final result = AnalysisResult();
    if (variableDec == null) {
      result.recordError(
        UnknownReferenceError(
          message: 'Variable ${node.variableName.value} is referenced before '
              'it is declared',
          line: node.variableName.start,
          column: node.variableName.column,
        ),
      );
    }
    final assignResult = node.assign.accept(this);
    result.addResult(assignResult);
    final assignType = _latestExpressionType;
    if (variableDec?.type case final type? when type != assignType) {
      result.recordError(
        TypeMismatchError(
          message: 'Expected $type but got $assignType',
          line: node.assign.start.line,
          column: node.assign.start.column,
        ),
      );
    }
    return result;
  }

  @override
  AnalysisResult visitVariableDeclaration(VariableDeclarationNode node) {
    final variableDec = _getVariableDecFromName(node.variableName.value);
    final result = AnalysisResult();
    if (variableDec != null) {
      result.recordError(
        ReuseError(
          message: 'Name ${node.variableName.value} is already used',
          line: node.variableName.line,
          column: node.variableName.column,
        ),
      );
    }
    if (node.assign case final assign?) {
      final assignResult = assign.accept(this);
      result.addResult(assignResult);
      final assignType = _latestExpressionType;
      if (node.variableType.value != assignType && assignType != null) {
        result.recordError(
          TypeMismatchError(
            message: 'Expected ${node.variableType.value} but got $assignType',
            line: assign.start.line,
            column: assign.start.column,
          ),
        );
      }
    }

    _declaredVariables.add(
      _VariableDeclaration(
        type: node.variableType.value,
        name: node.variableName.value,
      ),
    );
    return result;
  }

  _VariableDeclaration? _getVariableDecFromName(String variableName) {
    return _declaredVariables.firstWhereOrNull(
      (dec) => dec.name == variableName,
    );
  }
}


class _VariableDeclaration {
  _VariableDeclaration({required this.type, required this.name});

  final String type;
  final String name;
}