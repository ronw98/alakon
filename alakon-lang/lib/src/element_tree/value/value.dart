part 'bool_value.dart';
part 'num_value.dart';
part 'string_value.dart';

/// A value in the alakon language.
///
/// This value is "terminal" meaning that it is the actual data held by
/// variables or returned by methods.
///
/// The value defines methods and operators to interact with other values.
/// By default, these methods and operators throw an exception. The relevant
/// operators should be implemented by subclasses depending on their
/// capabilities.
///
/// Implementations should return [defaultValue] for cases that they cannot
/// handle.
sealed class AlakonValue {
  AlakonValue get defaultValue => throw UnimplementedError();

  AlakonValue operator +(AlakonValue other) {
    return defaultValue;
  }

  AlakonValue operator -(AlakonValue other) {
    return defaultValue;
  }

  AlakonValue operator /(AlakonValue other) {
    return defaultValue;
  }

  AlakonValue operator *(AlakonValue other) {
    return defaultValue;
  }

  AlakonValue operator -() {
    return defaultValue;
  }

  AlakonValue and(AlakonValue other) {
    return defaultValue;
  }

  AlakonValue or(AlakonValue other) {
    return defaultValue;
  }

  AlakonValue not() {
    return defaultValue;
  }

  String toPrintValue();
}

class AlakonEmptyValue extends AlakonValue {
  @override
  String toPrintValue() {
    throw UnimplementedError();
  }
}
