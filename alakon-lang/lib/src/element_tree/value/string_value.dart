part of 'value.dart';

class AlakonStringValue extends AlakonValue {
  AlakonStringValue(this.value);

  final String value;

  @override
  AlakonValue operator +(AlakonValue other) {
    return switch (other) {
      AlakonStringValue(value: final value) =>
        AlakonStringValue(this.value + value),
      _ => defaultValue,
    };
  }

  @override
  String toPrintValue() {
    return value;
  }
}
