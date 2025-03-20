import '../ast/ast.dart';
import 'analysis_errors.dart';
import 'analysis_result.dart';

part 'default_methods.dart';

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
    _AnalysisScope(
      scopeVariables: {},
      inheritedVariables: {},
    )
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
    return _visitOperationExpression(
      node,
      AlakonOperator.add,
      takesLeftType: true,
    );
  }

  @override
  AnalysisResult visitBooleanExpression(BooleanExpressionNode node) {
    _latestExpressionType = _kTypeBool;

    return AnalysisResult();
  }

  @override
  AnalysisResult visitDivisionExpression(DivisionExpressionNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.divide,
      takesLeftType: true,
    );
  }

  @override
  AnalysisResult visitMultiplicationExpression(
    MultiplicationExpressionNode node,
  ) {
    return _visitOperationExpression(
      node,
      AlakonOperator.multiply,
      takesLeftType: true,
    );
  }

  @override
  AnalysisResult visitNegatedExpression(NegatedExpressionNode node) {
    final analysisResult = node.expression.accept(this);
    final expressionType = _latestExpressionType;

    if (expressionType == null) return analysisResult;

    final expressionTypeEnum = AlakonType.from(expressionType);

    final operatorDefined = DefaultOperators.isOperatorDefined(
        expressionTypeEnum, AlakonOperator.minus);

    if (!operatorDefined) {
      analysisResult.recordError(
        OperatorError(
          message: 'Operator "!" is not defined for type $expressionType.',
          begin: node.tokenMinus,
          end: node.tokenMinus,
        ),
      );
    }

    return analysisResult;
  }

  @override
  AnalysisResult visitAndExpression(AndExpressionNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.and,
      expressionType: AlakonType.bool,
    );
  }

  @override
  AnalysisResult visitOrExpression(OrExpressionNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.or,
      expressionType: AlakonType.bool,
    );
  }

  @override
  AnalysisResult visitEq(EqualComparisonNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.eq,
      expressionType: AlakonType.bool,
    );
  }

  @override
  AnalysisResult visitGEq(GEqComparisonNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.geq,
      expressionType: AlakonType.bool,
    );
  }

  @override
  AnalysisResult visitGT(GTComparisonNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.gt,
      expressionType: AlakonType.bool,
    );
  }

  @override
  AnalysisResult visitLEq(LEqComparisonNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.leq,
      expressionType: AlakonType.bool,
    );
  }

  @override
  AnalysisResult visitLT(LTComparisonNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.lt,
      expressionType: AlakonType.bool,
    );
  }

  @override
  AnalysisResult visitNEq(NEqComparisonNode node) {
    return _visitOperationExpression(
      node,
      AlakonOperator.neq,
      expressionType: AlakonType.bool,
    );
  }

  @override
  AnalysisResult visitNotExpression(NotExpressionNode node) {
    final analysisResult = node.expression.accept(this);
    final expressionType = _latestExpressionType;

    if (expressionType == null) return analysisResult;

    final expressionTypeEnum = AlakonType.from(expressionType);

    final operatorDefined = DefaultOperators.isOperatorDefined(
        expressionTypeEnum, AlakonOperator.not);

    if (!operatorDefined) {
      analysisResult.recordError(
        OperatorError(
          message: 'Operator "!" is not defined for type $expressionType.',
          begin: node.tokenNot,
          end: node.tokenNot,
        ),
      );
    }

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
    return _visitOperationExpression(
      node,
      AlakonOperator.subtract,
      takesLeftType: true,
    );
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

  @override
  AnalysisResult visitWhile(WhileNode node) {
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
    return result;
  }

  AnalysisResult _visitOperationExpression(
    OperationExpressionNode node,
    AlakonOperator operator, {
    AlakonType? expressionType,
    bool takesLeftType = false,
  }) {
    final leftResult = node.left.accept(this);
    final leftType = _latestExpressionType;

    final rightResult = node.right.accept(this);
    final rightType = _latestExpressionType;

    // TODO: add an invalidType type to handle the case where the expression is
    //      wrong.
    if (expressionType != null) {
      _latestExpressionType = expressionType.value;
    } else if (takesLeftType) {
      _latestExpressionType = leftType;
    } else {
      _latestExpressionType = rightType;
    }
    final result = AnalysisResult.fromResults([leftResult, rightResult]);
    // Left and right should not be null, if so return the result.
    if (leftType == null || rightType == null) return result;

    final leftTypeEnum = AlakonType.from(leftType);
    final rightTypeEnum = AlakonType.from(rightType);
    final operatorDefined =
        DefaultOperators.isOperatorDefined(leftTypeEnum, operator);

    if (!operatorDefined) {
      result.recordError(
        OperatorError(
          message: 'Operator ${operator.name} is not defined for type $leftType.',
          begin: node.tokenOperand,
          end: node.tokenOperand,
        ),
      );
      // Do not check right type validity if operator is incompatible with left.
      return result;
    }
    final rightTypeValid = DefaultOperators.isOperatorValidForTypes(
        operator, leftTypeEnum, rightTypeEnum);
    if (!rightTypeValid) {
      result.recordError(
        TypeMismatchError(
          message: 'Unexpected $rightType',
          begin: node.right.beginToken,
          end: node.right.endToken,
        ),
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
