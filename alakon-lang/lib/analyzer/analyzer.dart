import 'package:collection/collection.dart';

import '../ast/ast.dart';
import 'analysis_exceptions.dart';

class _VariableDeclaration {
  final String type;
  final String name;

  _VariableDeclaration({required this.type, required this.name});
}

class Analyzer implements AstVisitor<void> {
  final List<_VariableDeclaration> _declaredVariables = [];
  String? _latestExpressionType;

  @override
  void visitAdditionExpression(AdditionExpressionNode node) {
    node.left.accept(this);
    final leftType = _latestExpressionType;
    node.right.accept(this);
    final rightType = _latestExpressionType;
    if (leftType != rightType || leftType == null) {
      throw TypeMismatchException(
        'Expected type $leftType but got $rightType',
      );
    }
    _latestExpressionType = leftType;
  }

  @override
  void visitBooleanExpression(BooleanExpressionNode node) {
    _latestExpressionType = 'boolean';
  }

  @override
  void visitDivisionExpression(DivisionExpressionNode node) {
    node.left.accept(this);
    final leftType = _latestExpressionType;
    node.right.accept(this);
    final rightType = _latestExpressionType;
    if (leftType != rightType || leftType != 'num') {
      throw TypeMismatchException(
        'Expected num but got $leftType',
      );
    }
    _latestExpressionType = leftType;
  }

  @override
  void visitMultiplicationExpression(MultiplicationExpressionNode node) {
    node.left.accept(this);
    final leftType = _latestExpressionType;
    node.right.accept(this);
    final rightType = _latestExpressionType;
    switch ((leftType, rightType)) {
      case ('String', _):
        throw TypeMismatchException('Expected num but got String');
      case (_, 'String'):
        throw TypeMismatchException('Expected num but got String');
      case ('bool', _):
        throw TypeMismatchException('Expected num but got bool');
      case (_, 'bool'):
        throw TypeMismatchException('Expected num but got bool');
    }
    _latestExpressionType = leftType;
  }

  @override
  void visitNegatedExpression(NegatedExpressionNode node) {
    node.expression.accept(this);
    if (_latestExpressionType != 'num') {
      throw TypeMismatchException(
        'Expected num but got $_latestExpressionType',
      );
    }
    _latestExpressionType = 'num';
  }

  @override
  void visitNumberExpression(NumberExpressionNode node) {
    _latestExpressionType = 'num';
  }

  @override
  void visitParenthesisedExpression(ParenthesisedExpressionNode node) {
    node.expression.accept(this);
  }

  @override
  void visitReferenceExpression(ReferenceExpressionNode node) {
    final variableName = node.value;
    final variableType = _declaredVariables
        .firstWhereOrNull((dec) => dec.name == variableName.value)
        ?.type;

    if (variableType == null) {
      throw UnknownReferenceException(
        'Variable $variableName is referenced before it is declared',
      );
    }
    _latestExpressionType = variableType;
  }

  @override
  void visitStringExpression(StringExpressionNode node) {
    _latestExpressionType = 'String';
  }

  @override
  void visitSubtractionExpression(SubtractionExpressionNode node) {
    node.left.accept(this);
    final leftType = _latestExpressionType;
    node.right.accept(this);
    final rightType = _latestExpressionType;
    switch ((leftType, rightType)) {
      case ('String', _):
        throw TypeMismatchException('Expected num but got String');
      case (_, 'String'):
        throw TypeMismatchException('Expected num but got String');
      case ('bool', _):
        throw TypeMismatchException('Expected num but got bool');
      case (_, 'bool'):
        throw TypeMismatchException('Expected num but got bool');
    }
    _latestExpressionType = leftType;
  }

  @override
  void visitProgram(ProgramNode node) {
    for (final statement in node.statements) {
      statement.accept(this);
    }
  }

  @override
  void visitVariableAssign(VariableAssignNode node) {
    final variableDec = _getVariableDecFromName(
      node.variableName.value,
    );
    if (variableDec == null) {
      throw UnknownReferenceException(
        'Variable ${node.variableName} is referenced before it is declared',
      );
    }
    node.assign.accept(this);
    final assignType = _latestExpressionType;
    if (variableDec.type != assignType) {
      throw TypeMismatchException(
          'Expected ${variableDec.type} but got $assignType');
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclarationNode node) {
    final variableDec = _getVariableDecFromName(node.variableName.value);
    if (variableDec != null) {
      throw ReuseException(
        'Name ${node.variableName} is already used',
      );
    }
    if (node.assign case final assign?) {
      assign.accept(this);
      final assignType = _latestExpressionType;
      if (node.variableType.value != assignType) {
        // TODO: errors with position
        throw TypeMismatchException(
          'Expected ${node.variableType} but got $assignType',
        );
      }
    }

    _declaredVariables.add(
      _VariableDeclaration(
          type: node.variableType.value, name: node.variableName.value),
    );
  }

  _VariableDeclaration? _getVariableDecFromName(String variableName) {
    return _declaredVariables.firstWhereOrNull(
      (dec) => dec.name == variableName,
    );
  }
}
