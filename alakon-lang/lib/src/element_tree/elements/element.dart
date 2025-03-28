import 'dart:async';
import 'dart:isolate';

import 'package:alakon_lang/src/element_tree/alakon_runtime_exception.dart';
import 'package:alakon_lang/src/element_tree/alakon_variable.dart';
import 'package:alakon_lang/src/element_tree/value/value.dart';

part 'expression.dart';
part 'program.dart';
part 'scopes.dart';
part 'statement.dart';

/// Base alakon element.
///
/// All elements implement this.
sealed class AlakonElement {}
