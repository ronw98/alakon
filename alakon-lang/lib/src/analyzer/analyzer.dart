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
  AnalysisResult analyze(AstNode code) {
    return code.accept(_AnalyzerVisitor());
  }
}

/// An analysis scope is a set of variables.
///
/// It contains scope variables which are variables contained within this scope.
/// It also contains variables inherited from parent scopes.
class _AnalysisScope {
  _AnalysisScope({
    required Map<String, _VariableDeclaration> scopeVariables,
    required Map<String, _VariableDeclaration> inheritedVariables,
  })  : _inheritedVariables = inheritedVariables,
        _scopeVariables = scopeVariables;

  _AnalysisScope.fromInheritance({required _AnalysisScope parent})
      : this(
          inheritedVariables: {
            ...parent._inheritedVariables,
            ...parent._scopeVariables
          },
          scopeVariables: {},
        );

  /// Retrieves the [_VariableDeclaration] for the given [variableName].
  ///
  /// Returns `null` if no variable of that name was declared.
  ///
  /// Priority is given to scope declaration and falls back on inherited
  /// declaration.
  _VariableDeclaration? getDeclarationFromReference(String variableName) {
    return _scopeVariables[variableName] ?? _inheritedVariables[variableName];
  }

  /// Whether a variable with [variableName] can be declared.
  ///
  /// This is true if no [_scopeVariables] does not contain [variableName].
  bool canDeclareVariable(String variableName) {
    return !_scopeVariables.containsKey(variableName);
  }

  _VariableDeclaration declareVariable(
      String variableName, String variableType) {
    final declaration = _VariableDeclaration(
      type: variableType,
      name: variableName,
    );
    _scopeVariables[variableName] = declaration;
    return declaration;
  }

  final Map<String, _VariableDeclaration> _scopeVariables;
  final Map<String, _VariableDeclaration> _inheritedVariables;
}

/// Context of the analysis.
///
/// Contains the list of [_AnalysisScope]s as well as the
/// [latestExpressionType].
class _AnalysisContext {
  final List<_AnalysisScope> _scopes = [
    _AnalysisScope(scopeVariables: {}, inheritedVariables: {})
  ];

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
  String? latestExpressionType;

  void openScope() {
    _scopes.add(_AnalysisScope.fromInheritance(parent: _scopes.last));
  }

  void closeScope() {
    _scopes.removeLast();
    if (_scopes.isEmpty) {
      _scopes.add(
        _AnalysisScope(scopeVariables: {}, inheritedVariables: {}),
      );
    }
  }

  T withinNewScope<T>(T Function() run) {
    openScope();
    final result = run();
    closeScope();
    return result;
  }

  /// See [_AnalysisScope.getDeclarationFromReference].
  _VariableDeclaration? getDeclarationFromReference(String variableName) {
    return _scopes.last.getDeclarationFromReference(variableName);
  }

  /// See [_AnalysisScope.canDeclareVariable].
  bool canDeclareVariable(String variableName) {
    return _scopes.last.canDeclareVariable(variableName);
  }

  /// See [_AnalysisScope.declareVariable].
  _VariableDeclaration declareVariable(
    String variableName,
    String variableType,
  ) {
    return _scopes.last.declareVariable(variableName, variableType);
  }
}

/// [AstVisitor] that returns an [AnalysisResult].
///
/// The returned result contains all the [AnalysisError]s found in the visited
/// node.
class _AnalyzerVisitor implements AstVisitor<AnalysisResult> {
  static const _kTypeBool = 'bool';
  static const _kTypeString = 'String';
  static const _kTypeNum = 'num';

  final _AnalysisContext _context = _AnalysisContext();

  String? get _latestExpressionType => _context.latestExpressionType;

  set _latestExpressionType(String? value) {
    _context.latestExpressionType = value;
  }

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
    _latestExpressionType = _kTypeBool;

    return AnalysisResult();
  }

  @override
  AnalysisResult visitDivisionExpression(DivisionExpressionNode node) {
    final leftResult = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightResult = node.right.accept(this);
    final rightType = _latestExpressionType;

    final result = AnalysisResult.fromResults([leftResult, rightResult]);
    if (leftType != _kTypeNum) {
      result.recordError(
        TypeMismatchError(
          message: 'Expected $_kTypeNum but got $leftType',
          begin: node.left.beginToken,
          end: node.left.endToken,
        ),
      );
    }
    if (rightType != _kTypeNum) {
      result.recordError(
        TypeMismatchError(
          message: 'Expected $_kTypeNum but got $rightType',
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
    MultiplicationExpressionNode node,
  ) {
    final leftAnalysis = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightAnalysis = node.right.accept(this);
    final rightType = _latestExpressionType;

    final result = AnalysisResult.fromResults([leftAnalysis, rightAnalysis]);

    switch ((leftType, rightType)) {
      case (_kTypeString, _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeNum but got $_kTypeString',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, _kTypeString):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeNum but got $_kTypeString',
            begin: node.right.beginToken,
            end: node.right.endToken,
          ),
        );
      case (_kTypeBool, _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeNum but got $_kTypeBool',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, _kTypeBool):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeNum but got $_kTypeBool',
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
    if (_latestExpressionType != _kTypeNum) {
      analysisResult.recordError(
        TypeMismatchError(
          message: 'Expected $_kTypeNum but got $_latestExpressionType',
          begin: node.expression.beginToken,
          end: node.expression.beginToken,
        ),
      );
    }
    _latestExpressionType = _kTypeNum;
    return analysisResult;
  }

  @override
  AnalysisResult visitAndExpression(AndExpressionNode node) {
    final leftAnalysis = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightAnalysis = node.right.accept(this);
    final rightType = _latestExpressionType;

    final result = AnalysisResult.fromResults([leftAnalysis, rightAnalysis]);

    switch ((leftType, rightType)) {
      case (_kTypeString, _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeBool but got $_kTypeString',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, _kTypeString):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeBool but got $_kTypeString',
            begin: node.right.beginToken,
            end: node.right.endToken,
          ),
        );
      case (_kTypeNum, _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeBool but got $_kTypeNum',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, _kTypeNum):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeBool but got $_kTypeNum',
            begin: node.right.beginToken,
            end: node.right.endToken,
          ),
        );
    }
    _latestExpressionType = leftType;
    return result;
  }

  @override
  AnalysisResult visitOrExpression(OrExpressionNode node) {
    final leftAnalysis = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightAnalysis = node.right.accept(this);
    final rightType = _latestExpressionType;

    final result = AnalysisResult.fromResults([leftAnalysis, rightAnalysis]);

    switch ((leftType, rightType)) {
      case (_kTypeString, _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeBool but got $_kTypeString',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, _kTypeString):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeBool but got $_kTypeString',
            begin: node.right.beginToken,
            end: node.right.endToken,
          ),
        );
      case (_kTypeNum, _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeBool but got $_kTypeNum',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, _kTypeNum):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeBool but got $_kTypeNum',
            begin: node.right.beginToken,
            end: node.right.endToken,
          ),
        );
    }
    _latestExpressionType = leftType;
    return result;
  }

  @override
  AnalysisResult visitNotExpression(NotExpressionNode node) {
    final analysisResult = node.expression.accept(this);
    if (_latestExpressionType != _kTypeBool) {
      analysisResult.recordError(
        TypeMismatchError(
          message: 'Expected $_kTypeBool but got $_latestExpressionType',
          begin: node.expression.beginToken,
          end: node.expression.beginToken,
        ),
      );
    }
    _latestExpressionType = _kTypeBool;
    return analysisResult;
  }

  @override
  AnalysisResult visitNumberExpression(NumberExpressionNode node) {
    _latestExpressionType = _kTypeNum;
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
    final resolvedReference = _context.getDeclarationFromReference(
      variableName.value,
    );

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
    _latestExpressionType = _kTypeString;
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
      case (_kTypeString, _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeNum but got $_kTypeString',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, _kTypeString):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeNum but got $_kTypeString',
            begin: node.right.beginToken,
            end: node.right.endToken,
          ),
        );
      case (_kTypeBool, _):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeNum but got $_kTypeBool',
            begin: node.left.beginToken,
            end: node.left.endToken,
          ),
        );
      case (_, _kTypeBool):
        result.recordError(
          TypeMismatchError(
            message: 'Expected $_kTypeNum but got $_kTypeBool',
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
    final variableDec = _context.getDeclarationFromReference(
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
    final canDeclareVariable = _context.canDeclareVariable(
      node.variableName.value,
    );
    final result = AnalysisResult();
    if (!canDeclareVariable) {
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

    if (canDeclareVariable) {
      _context.declareVariable(
        node.variableName.value,
        node.variableType.value,
      );
    }

    return result;
  }

  @override
  AnalysisResult visitPrint(PrintNode node) {
    return node.expression.accept(this);
  }

  @override
  AnalysisResult visitBlock(BlockNode node) {
    return AnalysisResult.fromResults(
      [
        for (final statement in node.statements) statement.accept(this),
      ],
    );
  }

  @override
  AnalysisResult visitIf(IfNode node) {
    final result = node.condition.accept(this);
    final expressionType = _latestExpressionType;
    if (expressionType != _kTypeBool) {
      result.recordError(
        TypeMismatchError(
          begin: node.condition.beginToken,
          end: node.condition.endToken,
          message: 'Expected $_kTypeBool but got $expressionType',
        ),
      );
    }

    _context.withinNewScope(
      () => result.addResult(node.ifBody.accept(this)),
    );

    if (node.elseBody case final elseBody?) {
      _context.withinNewScope(
        () => result.addResult(elseBody.accept(this)),
      );
    }
    return result;
  }
}

class _VariableDeclaration {
  _VariableDeclaration({required this.type, required this.name});

  final String type;
  final String name;
}
