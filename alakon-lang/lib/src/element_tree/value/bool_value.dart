part of 'value.dart';

class AlakonBoolValue extends AlakonValue {
  AlakonBoolValue(this.value);

  final bool value;

  @override
  String toPrintValue() {
    return '$value';
  }
}
