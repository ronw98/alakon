part of 'value.dart';

class AlakonBoolValue extends AlakonValue {
  AlakonBoolValue(this.value);

  @override
  final bool value;

  @override
  AlakonValue and(AlakonValue other) {
    return switch (other) {
      AlakonBoolValue(value: final value) =>
        AlakonBoolValue(this.value && value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue or(AlakonValue other) {
    return switch (other) {
      AlakonBoolValue(value: final value) =>
        AlakonBoolValue(this.value || value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue not() {
    return AlakonBoolValue(!value);
  }

  @override
  String toPrintValue() {
    return '$value';
  }
}
