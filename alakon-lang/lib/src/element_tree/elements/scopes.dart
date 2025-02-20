part of 'element.dart';

typedef VariableName = String;

/// A variable scope.
///
/// Contains a reference to all variables visible within this scope, along with
/// their values.
class VariableScope {
  /// The list of inherited variables.
  ///
  /// This map cannot be modified. Only the [AlakonVariable.value] can be
  /// edited.
  Map<VariableName, AlakonVariable> _inheritedVariables = {};

  /// The list of variables declared within this scope.
  ///
  /// This map can be modified (variables can be added).
  final Map<VariableName, AlakonVariable> _variables = {};

  /// Inherits the given [scope], setting [_inheritedVariables] to the variables
  /// of the [scope].
  void inherit(VariableScope scope) {
    _inheritedVariables = scope.allVariables;
  }

  /// Retrieves the variable from its [name].
  ///
  /// The variable is retrieved from scope [_variables] if possible or from
  /// [_inheritedVariables].
  AlakonVariable? variable(String name) {
    return _variables[name] ?? _inheritedVariables[name];
  }

  /// Registers the given variable with [variableName] and [value] in this
  /// scope.
  void registerVariable(String variableName, AlakonValue value) {
    _variables[variableName] = AlakonVariable(variableName, value);
  }

  /// Registers the given variable with [variableName] and [value] in this
  /// scope.
  void updateVariable(String variableName, AlakonValue value) {
    if (_variables.containsKey(variableName)) {
      _variables[variableName]!.value = value;
    } else if (_inheritedVariables.containsKey(variableName)) {
      _inheritedVariables[variableName]!.value = value;
    }
  }

  /// Returns the entire list of variables within this scope (inherited and
  /// local).
  ///
  /// Note that inherited variables are shadowed by local variables with the
  /// same name.
  Map<String, AlakonVariable> get allVariables {
    return {..._inheritedVariables, ..._variables};
  }
}

/// Mixin for any Alakon element that has a variable scope (such as statement).
mixin HasVariableScope {
  final VariableScope scope = VariableScope();
}
