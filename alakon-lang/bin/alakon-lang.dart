import 'dart:isolate';

import 'package:alakon_lang/src/analyzer/analyzer.dart';
import 'package:alakon_lang/src/ast/ast.dart';
import 'package:alakon_lang/src/ast/ast_printer.dart';
import 'package:alakon_lang/src/generator/generator.dart';
import 'package:alakon_lang/src/parser.dart';

main() async {
  final parser = AlakonParser().build();
  final result = parser.parse('''
String b = "oui" + 2
num variable = (3 + 5) - 757/"2"
''');
  final programNode = result.value as AstNode;
  print(programNode.accept(AstPrinter()));

  final analyzer = AlakonAnalyzer();
  analyzer.analyze(programNode);



  final generatedDart = programNode.accept(Generator());

  final uri = Uri.dataFromString(generatedDart, mimeType: 'application/dart');

  // https://stackoverflow.com/questions/13585082/how-do-i-execute-dynamically-like-eval-in-dart
  await Isolate.spawnUri(uri, [], null);
}
