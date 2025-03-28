part of 'analyzer.dart';

/// List of operators that exist in alakon
enum AlakonOperator {
  add,
  subtract,
  multiply,
  divide,
  // -
  minus,
  // !
  not,
  and,
  or,
  gt,
  geq,
  lt,
  leq,
  eq,
  neq,
}

/// Builtin types in alakon
enum AlakonType {
  bool('bool'),
  string('String'),
  num('num');

  const AlakonType(this.value);

  factory AlakonType.from(String value) {
    return switch (value) {
      'bool' => bool,
      'String' => string,
      'num' => num,
      // This should not be possible
      _ => throw Error(),
    };
  }

  final String value;
}

/// Defines which operators are available for which types in alakon.
///
/// This will be used until methods are added.
class DefaultOperators {
  const DefaultOperators._();

  static const Map<AlakonType, Map<AlakonOperator, List<AlakonType>>>
      _dualOperators = {
    AlakonType.bool: {
      AlakonOperator.and: [AlakonType.bool],
      AlakonOperator.or: [AlakonType.bool],
    },
    AlakonType.num: {
      AlakonOperator.add: [AlakonType.num],
      AlakonOperator.minus: [AlakonType.num],
      AlakonOperator.multiply: [AlakonType.num],
      AlakonOperator.divide: [AlakonType.num],
      AlakonOperator.gt: [AlakonType.num],
      AlakonOperator.geq: [AlakonType.num],
      AlakonOperator.lt: [AlakonType.num],
      AlakonOperator.leq: [AlakonType.num],
    },
    AlakonType.string: {}
  };

  static const _singleOperators = {
    AlakonType.bool: {AlakonOperator.not},
    AlakonType.num: {AlakonOperator.minus}
  };

  static const _globallyAvailableOperators = {
    AlakonOperator.eq,
    AlakonOperator.neq,
  };

  static bool isOperatorDefined(AlakonType type, AlakonOperator operator) {
    if (_dualOperators[type]?[operator] != null) {
      return true;
    }
    if (_singleOperators[type]?.contains(operator) ?? false) {
      return true;
    }
    if (_globallyAvailableOperators.contains(operator)) {
      return true;
    }
    return false;
  }

  static bool isOperatorValidForTypes(
    AlakonOperator operator,
    AlakonType left,
    AlakonType right,
  ) {
    return _dualOperators[left]?[operator]?.contains(right) ?? false;
  }
}
