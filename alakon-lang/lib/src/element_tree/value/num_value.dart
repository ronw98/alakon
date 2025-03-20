part of 'value.dart';

class AlakonNumberValue extends AlakonValue {
  AlakonNumberValue(this.value);

  @override
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
  AlakonValue operator <(AlakonValue other) {
    return switch (other) {
      AlakonNumberValue(value: final value) =>
          AlakonBoolValue(this.value < value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue operator <=(AlakonValue other) {
    return switch (other) {
      AlakonNumberValue(value: final value) =>
          AlakonBoolValue(this.value <= value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue operator >(AlakonValue other) {
    return switch (other) {
      AlakonNumberValue(value: final value) =>
          AlakonBoolValue(this.value > value),
      _ => defaultValue,
    };
  }

  @override
  AlakonValue operator >=(AlakonValue other) {
    return switch (other) {
      AlakonNumberValue(value: final value) =>
          AlakonBoolValue(this.value >= value),
      _ => defaultValue,
    };
  }

  @override
  String toPrintValue() {
    return '$value';
  }
}
