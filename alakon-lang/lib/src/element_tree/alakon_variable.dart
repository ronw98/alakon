import 'package:alakon_lang/src/element_tree/value/value.dart';

/// Non final data class that represent s a variable during code execution.
///
/// This class is mutable because the variable value might change, even though
/// the variable is still one and the same (meaning the reference hasn't
/// changed, only the value referenced).
class AlakonVariable {
  AlakonVariable(this.name, this.value);

  final String name;
  AlakonValue value;
}
