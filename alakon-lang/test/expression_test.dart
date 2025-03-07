import 'package:alakon_lang/alakon_lang.dart';
import 'package:alakon_lang/src/grammar.dart';
import 'package:test/test.dart';

main() {
  final parser = AlakonParser();
  final expressionParser = parser.buildFrom(parser.expression());
  group('Leaf expressions', () {
    group('Numbers', () {
      test('Test integer', () {
        final result = expressionParser.parse('15');
        expect(result, isA<Success>());
        expect(result.value, isA<NumberExpressionNode>());
        expect(result.value.value.value, 15);
      });

      test('Test double', () {
        final result = expressionParser.parse('15.16');
        expect(result, isA<Success>());
        expect(result.value, isA<NumberExpressionNode>());
        expect(result.value.value.value, 15.16);
      });

      test('Test double without leading integer', () {
        final result = expressionParser.parse('.16');
        expect(result, isA<Failure>());
      });
    });

    group('Strings', () {
      test('Test empty string', () {
        final result = expressionParser.parse('""');
        expect(result, isA<Success>());
        expect(result.value, isA<StringExpressionNode>());
        expect(result.value.value.value, "");
      });

      test('Test String', () {
        final result = expressionParser.parse('"foo"');
        expect(result, isA<Success>());
        expect(result.value, isA<StringExpressionNode>());
        expect(result.value.value.value, "foo");
      });

      group('Booleans', () {
        test('Test true', () {
          final result = expressionParser.parse('true');
          expect(result, isA<Success>());
          expect(result.value, isA<BooleanExpressionNode>());
          expect(result.value.value.value, true);
        });

        test('Test false', () {
          final result = expressionParser.parse('false');
          expect(result, isA<Success>());
          expect(result.value, isA<BooleanExpressionNode>());
          expect(result.value.value.value, false);
        });

        test('Test maybe', () {
          final result = expressionParser.parse('maybe');
          expect(result.value, isNot(isA<BooleanExpressionNode>()));
        });
      });

      group('Variables', () {
        test('Test any name', () {
          final result = expressionParser.parse('Choue_ttos');
          expect(result, isA<Success>());
          expect(result.value, isA<ReferenceExpressionNode>());
          expect(result.value.value.value, 'Choue_ttos');
        });
      });
    });
  });

  group('Operation priorities', () {
    group(
      'Prefix have higher priority than multiply',
      () {
        test('Not and mult', () {
          final result = expressionParser.parse('!false * 5');
          expect(result, isA<Success>());
          expect(result.value, isA<MultiplicationExpressionNode>());
          expect(result.value.left, isA<NotExpressionNode>());
        });

        test('Mult and not', () {
          final result = expressionParser.parse('false * !5');
          expect(result, isA<Success>());
          expect(result.value, isA<MultiplicationExpressionNode>());
          expect(result.value.right, isA<NotExpressionNode>());
        });

        test('Negate and mult', () {
          final result = expressionParser.parse('-false * 5');
          expect(result, isA<Success>());
          expect(result.value, isA<MultiplicationExpressionNode>());
          expect(result.value.left, isA<NegatedExpressionNode>());
        });

        test('Mult and Negate', () {
          final result = expressionParser.parse('false * -5');
          expect(result, isA<Success>());
          expect(result.value, isA<MultiplicationExpressionNode>());
          expect(result.value.right, isA<NegatedExpressionNode>());
        });
      },
    );

    group('Mult have higher priority than add', () {
      test('Add and mult', () {
        final result = expressionParser.parse('!false * 5 + 4');
        expect(result, isA<Success>());
        expect(result.value, isA<AdditionExpressionNode>());
        expect(result.value.left, isA<MultiplicationExpressionNode>());
      });

      test('Mult and Add', () {
        final result = expressionParser.parse('4 + false * !5');
        expect(result, isA<Success>());
        expect(result.value, isA<AdditionExpressionNode>());
        expect(result.value.right, isA<MultiplicationExpressionNode>());
      });
    });
  });

  group('Operators association', () {
    test('Mult, div and && left associative', () {
        final result = expressionParser.parse('1 * 5 / 6 && true * 6');
        expect(result, isA<Success>());
        expect(result.value, isA<MultiplicationExpressionNode>());
        expect(result.value.left, isA<AndExpressionNode>());
        expect(result.value.left.left, isA<DivisionExpressionNode>());
        expect(result.value.left.left.left, isA<MultiplicationExpressionNode>());
    });

    test('Add, sub and || left associative', () {
      final result = expressionParser.parse('1 + 5 - 6 || true + 6');
      expect(result, isA<Success>());
      expect(result.value, isA<AdditionExpressionNode>());
      expect(result.value.left, isA<OrExpressionNode>());
      expect(result.value.left.left, isA<SubtractionExpressionNode>());
      expect(result.value.left.left.left, isA<AdditionExpressionNode>());
    });
  });
}
