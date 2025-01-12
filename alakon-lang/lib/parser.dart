import 'package:petitparser/parser.dart';

import 'ast/ast.dart';
import 'grammar.dart';

class AlakonParser extends AlakonGrammar {
  @override
  Parser variableDec() => super.variableDec().map(
        (value) {
          return switch (value) {
            [
              final type,
              final name,
              [_, final assign],
            ] =>
              VariableDeclarationNode(
                variableType: type,
                variableName: name,
                assign: assign,
              ),
            [final type, final name, ...] => VariableDeclarationNode(
                variableType: type,
                variableName: name,
              ),
            _ => throw Error(),
          };
        },
      );

  @override
  Parser variableAssign() => super.variableAssign().map(
        (value) {
          return switch (value) {
            [final variable, _, final assign] => VariableAssignNode(
                variableName: variable,
                assign: assign,
              ),
            _ => throw Error(),
          };
        },
      );

  @override
  Parser statement() => super.statement().map(
        (value) {
          return switch (value) {
            [final StatementNode statement, _] => statement,
            _ => throw Error(),
          };
        },
      );

  @override
  Parser program() => super.program().map(
        (value) {
          return ProgramNode(statements: value.cast<StatementNode>());
        },
      );
}
