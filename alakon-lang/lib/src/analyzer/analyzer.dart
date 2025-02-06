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
          begin: node.right.beginToken,
          end: node.right.endToken,
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
          begin: node.left.beginToken,
          end: node.left.endToken,
        ),
      );
    }
    if (rightType != 'num') {
      result.recordError(
        TypeMismatchError(
          message: 'Expected num but got $rightType',
          begin: node.right.beginToken,
          end: node.right.endToken,
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
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, 'String'):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got String',
            begin: node.right.beginToken,
            end: node.right.endToken,
          ),
        );
      case ('bool', _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got bool',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, 'bool'):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got bool',
            begin: node.right.beginToken,
            end: node.right.endToken,
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
          begin: node.expression.beginToken,
          end: node.expression.beginToken,
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
          begin: variableName,
          end: variableName,
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
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, 'String'):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got String',
            begin: node.right.beginToken,
            end: node.right.endToken,
          ),
        );
      case ('bool', _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got bool',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, 'bool'):
        result.recordError(
          TypeMismatchError(
            message: 'Expected num but got bool',
            begin: node.right.beginToken,
            end: node.right.endToken,
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
          begin: node.variableName,
          end: node.variableName,
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
          begin: node.assign.beginToken,
          end: node.assign.endToken,
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
          begin: node.variableName,
          end: node.variableName,
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
            begin: assign.beginToken,
            end: assign.endToken,
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

  @override
  AnalysisResult visitPrint(PrintNode node) {
    return node.expression.accept(this);
  }
}


class _VariableDeclaration {
  _VariableDeclaration({required this.type, required this.name});

  final String type;
  final String name;
}