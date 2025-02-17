part of 'value.dart';

class AlakonNumberValue extends AlakonValue {
  AlakonNumberValue(this.value);

  final num value;

  @override
  AlakonValue operator +(AlakonValue other) {
    return switch (other) {
      AlakonNumberValue(value: final value) =>
        AlakonNumberValue(this.value + value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue operator -(AlakonValue other) {
    return switch (other) {
      AlakonNumberValue(value: final value) =>
        AlakonNumberValue(this.value - value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue operator /(AlakonValue other) {
    return switch (other) {
      AlakonNumberValue(value: final value) =>
        AlakonNumberValue(this.value / value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue operator *(AlakonValue other) {
    return switch (other) {
      AlakonNumberValue(value: final value) =>
        AlakonNumberValue(this.value * value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue operator -() {
    return AlakonNumberValue(-value);
  }

  @override
  String toPrintValue() {
    return '$value';
  }
}
