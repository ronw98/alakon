import 'package:collection/collection.dart';

import '../ast/ast.dart';
import 'analysis_exceptions.dart';

class _VariableDeclaration {
  _VariableDeclaration({required this.type, required this.name});

  final String type;
  final String name;
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
        message: 'Expected type $leftType but got $rightType',
        line: node.right.start.line,
        column: node.right.start.column,
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
    if (leftType != 'num') {
      throw TypeMismatchException(
        message: 'Expected num but got $leftType',
        line: node.left.start.line,
        column: node.left.start.column,
      );
    }
    if (rightType != 'num') {
      throw TypeMismatchException(
        message: 'Expected num but got $rightType',
        line: node.right.start.line,
        column: node.right.start.column,
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
        throw TypeMismatchException(
          message: 'Expected num but got String',
          line: node.left.start.line,
          column: node.left.start.column,
        );
      case (_, 'String'):
        throw TypeMismatchException(
          message: 'Expected num but got String',
          line: node.right.start.line,
          column: node.right.start.column,
        );
      case ('bool', _):
        throw TypeMismatchException(
          message: 'Expected num but got bool',
          line: node.left.start.line,
          column: node.left.start.column,
        );
      case (_, 'bool'):
        throw TypeMismatchException(
          message: 'Expected num but got bool',
          line: node.right.start.line,
          column: node.right.start.column,
        );
    }
    _latestExpressionType = leftType;
  }

  @override
  void visitNegatedExpression(NegatedExpressionNode node) {
    node.expression.accept(this);
    if (_latestExpressionType != 'num') {
      throw TypeMismatchException(
        message: 'Expected num but got $_latestExpressionType',
        line: node.expression.start.line,
        column: node.expression.start.column,
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
    final resolvedReference = _declaredVariables
        .firstWhereOrNull((dec) => dec.name == variableName.value);

    if (resolvedReference == null) {
      throw UnknownReferenceException(
        message: 'Variable "${variableName.value}" is referenced before it is '
            'declared',
        column: variableName.column,
        line: variableName.line,
      );
    }
    _latestExpressionType = resolvedReference.type;
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
        throw TypeMismatchException(
          message: 'Expected num but got String',
          line: node.left.start.line,
          column: node.left.start.column,
        );
      case (_, 'String'):
        throw TypeMismatchException(
          message: 'Expected num but got String',
          line: node.right.start.line,
          column: node.right.start.column,
        );
      case ('bool', _):
        throw TypeMismatchException(
          message: 'Expected num but got bool',
          line: node.left.start.line,
          column: node.left.start.column,
        );
      case (_, 'bool'):
        throw TypeMismatchException(
          message: 'Expected num but got bool',
          line: node.right.start.line,
          column: node.right.start.column,
        );
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
        message: 'Variable ${node.variableName.value} is referenced before '
            'it is declared',
        line: node.variableName.start,
        column: node.variableName.column,
      );
    }
    node.assign.accept(this);
    final assignType = _latestExpressionType;
    if (variableDec.type != assignType) {
      throw TypeMismatchException(
        message: 'Expected ${variableDec.type} but got $assignType',
        line: node.assign.start.line,
        column: node.assign.start.column,
      );
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclarationNode node) {
    final variableDec = _getVariableDecFromName(node.variableName.value);
    if (variableDec != null) {
      throw ReuseException(
        message: 'Name ${node.variableName.value} is already used',
        line: node.variableName.line,
        column: node.variableName.column,
      );
    }
    if (node.assign case final assign?) {
      assign.accept(this);
      final assignType = _latestExpressionType;
      if (node.variableType.value != assignType) {
        throw TypeMismatchException(
          message: 'Expected ${node.variableType.value} but got $assignType',
          line: assign.start.line,
          column: assign.start.column,
        );
      }
    }

    _declaredVariables.add(
      _VariableDeclaration(
        type: node.variableType.value,
        name: node.variableName.value,
      ),
    );
  }

  _VariableDeclaration? _getVariableDecFromName(String variableName) {
    return _declaredVariables.firstWhereOrNull(
      (dec) => dec.name == variableName,
    );
  }
}
