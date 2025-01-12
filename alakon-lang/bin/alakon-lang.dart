import 'dart:isolate';

import 'package:alakon_lang/analyzer/analyzer.dart';
import 'package:alakon_lang/ast/ast.dart';
import 'package:alakon_lang/ast/ast_printer.dart';
import 'package:alakon_lang/generator/generator.dart';
import 'package:alakon_lang/parser.dart';

main() async {
  final parser = AlakonParser().build();
  final result = parser.parse('''
  num variable = (3 + 5) - 757/2
  String b = 2
''');
  final programNode = result.value as AstNode;
  print(programNode.accept(AstPrinter()));

  programNode.accept(Analyzer());
  final generatedDart = programNode.accept(Generator());

  final uri = Uri.dataFromString(generatedDart, mimeType: 'application/dart');

  // https://stackoverflow.com/questions/13585082/how-do-i-execute-dynamically-like-eval-in-dart
  await Isolate.spawnUri(uri, [], null);
}
