import 'package:alakon_lang/alakon_lang.dart';
import 'package:alakon_lang/src/ast/ast_printer.dart';
import 'package:petitparser/debug.dart';

/// This is a test/example file, do not consider this
main() async {
  final parser = AlakonParser().build();
  final result = trace(parser).parse('''
print(1 + 1 < 2 && false)
''');
  final programNode = result.value as AstNode;
  print(programNode.accept(AstPrinter()));
  final analyzer = AlakonAnalyzer();
  final analysisResult = analyzer.analyze(programNode);
  if (analysisResult.hasError) {
    throw AnalysisException(analysisResult);
  }
  final elementTree = ElementTreeBuilder().build(programNode as ProgramNode);
  elementTree.run();
}
