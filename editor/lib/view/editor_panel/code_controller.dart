import 'package:alakon_lang/alakon_lang.dart';
import 'package:editor/src/alakon_theme.dart';
import 'package:editor/src/generated/alakon.dart';
import 'package:editor/view/editor_panel/text_span_builder.dart';
import 'package:editor/view/editor_panel/text_span_styler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_highlight/re_highlight.dart';

typedef ParseError = ({
  String message,
  int position,
});

/// TextEditingController of the code text field.
///
/// This class is responsible for most of the text field interactions.
/// - It launches parsing and analysis and reports errors, underlying the error
/// parts in red.
/// - It styles the text using syntax highlighting. The highlighting has two
/// modes:
///   - Basic highlighting is performed by [Highlight] when the parser fails.
///   - Complete highlighting is performed by [TextSpanBuilder] building the
///     code text spans from the parsed AST.
/// - It handles some specific key events to provide basic code editor features
///   such as:
///     - Wrapping code in quotes, parentheses...
///     - Maintain indentation on enter.
///     - Press tab to indent.
class CodeFieldController extends TextEditingController {
  CodeFieldController({
    super.text,
  }) {
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    _highlight.registerLanguage('alakon', langAlakon);
  }

  /// Current analysis result.
  ///
  /// Used for building the code text span using [TextSpanBuilder].
  /// This is null if the program could not be analysed (because of parse errors
  /// for example).
  AnalysisResult? _analysisResult;

  /// Current parse error.
  ///
  /// Used for indicating the error in the code using [TextSpanStyler].
  /// This is null if the program is successfully parsed.
  ParseError? _parseError;

  /// Current program as an AST.
  ///
  /// Null if the code could not be parsed.
  AstNode? _node;
  final Parser _alakonParser = AlakonParser().build();
  final AlakonAnalyzer _alakonAnalyzer = AlakonAnalyzer();
  late final Highlight _highlight = Highlight();

  /// Whether this controller's text field is focused.
  ///
  /// Used by [_onKeyEvent] as no event should be handled if the field is not
  /// focused.
  bool _focused = false;

  bool get focused => _focused;

  /// Text style applied to code sections containing at least one error.
  ///
  /// This is not final so that it can be set using Theme data from context.
  /// Which cannot be done in `initState`, where you would normally initialize
  /// the controller.
  TextStyle? errorStyle;

  /// Start parsing + analyzing on text change.
  @override
  set value(TextEditingValue newValue) {
    if (value.text != newValue.text) {
      _onTextChange(newValue.text);
    }
    super.value = newValue;
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    super.dispose();
  }

  /// Invoked when this controller's text changes.
  ///
  /// Parses the code and analyzes it if parsing succeeds.
  ///
  /// On parse success, [_node] and [_analysisResult] are set. [_parseError] is
  /// set to null.
  ///
  /// On parse error, [_node] and [_analysisResult] are set to null and
  /// [_parseError] is set to the encountered error.
  void _onTextChange(String newText) {
    final parseResult = _alakonParser.parse(newText);
    switch (parseResult) {
      case Success(value: final AstNode programNode):
        _node = programNode;
        _parseError = null;
        _analysisResult = _alakonAnalyzer.analyze(programNode);

      case Failure(
          position: final position,
          message: final message,
        ):
        _parseError = (position: position, message: message);
        _analysisResult = null;
        _node = null;
      default:
        _parseError = null;
        _analysisResult = null;
    }
  }

  /// This method styles the code so that it has syntax highlighting.
  ///
  /// If [_node] is `null`, it uses [Highlight] to perform basic syntax
  /// highlighting. The highlighting settings are in [AlakonCodeTheme].
  /// Additionally if [_parseError] is non-null (which it should be), it uses
  /// [TextSpanStyler] to highlight the parse error in the text.
  ///
  /// If [_node] is non-null, it uses [TextSpanBuilder] to perform context-based
  /// syntax highlighting, using the AST to precisely highlight each code
  /// element and highlight analysis errors from the [_analysisResult].
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_node == null) {
      final renderer = TextSpanRenderer(
        style,
        AlakonCodeTheme.buildReTheme(context),
      );
      final result = _highlight.highlight(
        code: text,
        language: 'alakon',
      );
      result.render(renderer);
      final resultSpan = renderer.span ?? TextSpan(text: text, style: style);
      if (_parseError case final error?) {
        return TextSpanStyler().styleCharacterAt(
          resultSpan,
          errorStyle,
          error.position,
          (_) {},
          () {},
        );
      }
      return resultSpan;
    }
    final spanBuilder = TextSpanBuilder(
      analysisResult: _analysisResult,
      rawText: text,
      theme: AlakonCodeTheme.buildAstTheme(context),
      errorStyle: errorStyle,
    );

    return TextSpan(
      style: style,
      children: [
        _node!.accept(spanBuilder),
      ],
    );
  }

  // Specific key handling section

  /// Invoked when a key event occurs.
  ///
  /// Checks what the event was and dispatches to specific methods.
  /// This method is the entry point for writing `()` when only pressing `(` and
  /// other code format ide features.
  bool _onKeyEvent(KeyEvent event) {
    // If field is not focused, to not handle anything.
    if (!_focused) return false;

    switch (event) {
      case KeyDownEvent(character: '"'):
        quotePressed();
        return true;
      case KeyDownEvent(character: '('):
        leftParenPressed();
        return true;
      case KeyDownEvent(character: ')'):
        return rightParenPressed();
      case KeyDownEvent(character: '['):
        leftBracketPressed();
        return true;
      case KeyDownEvent(character: ']'):
        return rightParenPressed();
      case KeyDownEvent(character: '{'):
        leftBracePressed();
        return true;
      case KeyDownEvent(character: '}'):
        return rightParenPressed();
      case KeyDownEvent(
          logicalKey: LogicalKeyboardKey.enter || LogicalKeyboardKey.numpadEnter
        ):
        enterPressed();
        return true;
      case KeyDownEvent(logicalKey: LogicalKeyboardKey.tab):
        tabPressed();
        return true;
    }
    return false;
  }

  /// Generic method to call when a wrapper key is pressed.
  ///
  /// A wrapper key is a key begin a pair of characters, one opening and one
  /// closing that usually contains some other text, such as `()`, `[]` or `""`.
  ///
  /// If a portion of text is selected, this method wraps the selected text in
  /// the pair of characters. The selection is maintained around the originally
  /// selected text (it does not change to include the wrappers).
  ///
  /// If no text is selected, the empty pair is added at cursor.
  void _wrapperStartKeyPressed(String leftCharacter, String rightCharacter) {
    if (value.selection.baseOffset == value.selection.extentOffset) {
      final currentOffset = value.selection.baseOffset;
      final newValue =
          value.replaced(selection, '$leftCharacter$rightCharacter');
      value = newValue.copyWith(
        selection: TextSelection(
            baseOffset: currentOffset + 1, extentOffset: currentOffset + 1),
      );
    } else {
      final newValue = value.replaced(
        value.selection,
        '$leftCharacter${value.selection.textInside(text)}'
        '$rightCharacter',
      );
      final baseOffset = newValue.selection.baseOffset;
      final extentOffset = newValue.selection.extentOffset;

      if (baseOffset < extentOffset) {
        value = newValue.copyWith(
          selection: TextSelection(
              baseOffset: baseOffset + 1, extentOffset: extentOffset - 1),
        );
      } else {
        value = newValue.copyWith(
          selection: TextSelection(
              baseOffset: baseOffset - 1, extentOffset: extentOffset + 1),
        );
      }
    }
  }

  /// Generic method invoked when wrapper end key is pressed.
  ///
  /// If the cursor is immediately before a wrapper end character, this method
  /// moves the cursor after that character (as if the user had typed with
  /// "inser" on).
  ///
  /// Otherwise this method does nothing.
  ///
  /// Note: the selection has to be empty for the cursor move to occur.
  ///
  /// Returns with `true` if the event was handled and false otherwise.
  bool _wrapperEndKeyPressed(String character) {
    // If no selection and next character is ", just move selection after
    if (selection.start == selection.end) {
      if (selection.start < text.length) {
        if (text[selection.start] == character) {
          value = value.copyWith(
            selection: TextSelection(
              baseOffset: selection.start + 1,
              extentOffset: selection.start + 1,
            ),
          );
          return true;
        }
      }
    }
    return false;
  }

  /// Invoked when a quote key is pressed.
  ///
  /// Tries to end quote wrapper and if it cannot, insert both quotes using
  /// [_wrapperStartKeyPressed].
  void quotePressed() {
    if (_wrapperEndKeyPressed('"')) return;
    _wrapperStartKeyPressed('"', '"');
  }

  /// Invokes [_wrapperStartKeyPressed] with parenthesis (`(`) wrapper.
  void leftParenPressed() {
    _wrapperStartKeyPressed('(', ')');
  }

  /// Invokes [_wrapperEndKeyPressed] with parenthesis (`)`) wrapper.
  bool rightParenPressed() {
    return _wrapperEndKeyPressed(')');
  }

  /// Invokes [_wrapperStartKeyPressed] with bracket (`[`) wrapper.
  void leftBracketPressed() {
    _wrapperStartKeyPressed('[', ']');
  }

  /// Invokes [_wrapperEndKeyPressed] with bracket (`]`) wrapper.
  bool rightBracketPressed() {
    return _wrapperEndKeyPressed(']');
  }

  /// Invokes [_wrapperStartKeyPressed] with brace (`{`) wrapper.
  void leftBracePressed() {
    _wrapperStartKeyPressed('{', '}');
  }

  /// Invokes [_wrapperEndKeyPressed] with brace (`}`) wrapper.
  bool rightBracePressed() {
    return _wrapperEndKeyPressed('}');
  }

  /// Handles the enter key press event.
  ///
  /// This method overrides the default behavior of the enter key to include
  /// indentation.
  ///
  /// When enter is tapped, a new line is added and its indentation is the same
  /// as the indentation of the line where the cursor was before the key was
  /// pressed.
  ///
  /// If text was selected, the reference line is the one of the text selection
  /// start.
  void enterPressed() {
    final selectionPosition = selection.start;
    final lines = text.split('\n');
    int currentPos = 0;
    String lineOfPosition = lines.last;
    for (final line in lines) {
      if (line.length + currentPos >= selectionPosition) {
        lineOfPosition = line;
        break;
      } else {
        currentPos += line.length + 1;
      }
    }

    final indent =
        RegExp(r' *').matchAsPrefix(lineOfPosition)?.group(0)?.length ?? 0;

    value = value.replaced(
      selection,
      '\n${' ' * indent}',
    );
  }

  /// Adds double space on tab pressed.
  void tabPressed() {
    value = value.replaced(selection, '  ');
  }

  void setFocused() {
    _focused = true;
  }

  void clearFocused() {
    _focused = false;
  }
}
