import 'package:alakon_lang/alakon_lang.dart';
import 'package:alakon_lang/src/ast/ast_printer.dart';

/// This is a test/example file, do not consider this
main() async {
  final parser = AlakonParser().build();
  final result = parser.parse('''
print(-2)
''');
  final programNode = result.value as AstNode;
  programNode.accept(AstPrinter());
  final analyzer = AlakonAnalyzer();
  final analysisResult = analyzer.analyze(programNode);
  if (analysisResult.hasError) {
    throw AnalysisException(analysisResult);
  }
  final elementTree = ElementTreeBuilder().build(programNode as ProgramNode);
  elementTree.run();
}
