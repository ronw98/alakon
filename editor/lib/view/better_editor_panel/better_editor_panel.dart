import 'package:alakon_lang/alakon_lang.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:editor/assets.dart';
import 'package:editor/src/alakon_theme.dart';
import 'package:editor/view/better_editor_panel/text_span_styler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:re_editor/re_editor.dart';

typedef ParseError = ({
  String message,
  int line,
  int column,
});

class BetterEditorPanel extends StatefulWidget {
  const BetterEditorPanel({super.key});

  @override
  State<BetterEditorPanel> createState() => _BetterEditorPanelState();
}

class _BetterEditorPanelState extends State<BetterEditorPanel> {
  static const _kOverlayDebounce = 'overlay-debounce';
  AnalysisResult? _analysisResult;
  ParseError? _parseError;
  late final CodeLineEditingController _controller;
  final Parser _alakonParser = AlakonParser().build();
  final AlakonAnalyzer _alakonAnalyzer = AlakonAnalyzer();

  OverlayEntry? _overlayEntry;
  Offset? _entryOffset;
  final ValueNotifier<List<String>> _errorMessagesToDisplay = ValueNotifier([]);

  void _removeEntry() {
    if (_overlayEntry case final entry?) entry.remove();
    _overlayEntry = null;
  }

  void _showEntry() {
    final textTheme = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    final entry = OverlayEntry(
      canSizeOverlay: true,
      builder: (context) {
        return ValueListenableBuilder(
            valueListenable: _errorMessagesToDisplay,
            builder: (context, value, _) {
              if (value.isEmpty) {
                return const SizedBox();
              }
              final left = (_entryOffset?.dx ?? 0) + 10;
              final top = (_entryOffset?.dy ?? 0) + 10;
              return Positioned(
                left: left,
                top: top,
                child: MouseRegion(
                  onEnter: (_) {
                    EasyDebounce.cancel(_kOverlayDebounce);
                  },
                  onExit: (_) => _clearErrorMessages(),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: Border.fromBorderSide(
                        BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: value.map(
                        (message) {
                          return Text(
                            message,
                            style: textTheme,
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              );
            });
      },
    );
    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  void _addErrorMessage(String message, Offset offset) {
    EasyDebounce.cancel(_kOverlayDebounce);
    _entryOffset = offset;
    _errorMessagesToDisplay.value =
        {..._errorMessagesToDisplay.value, message}.toList();
  }

  void _removeErrorMessage(String message) {
    EasyDebounce.debounce(
      _kOverlayDebounce,
      const Duration(milliseconds: 500),
      () {
        _errorMessagesToDisplay.value = _errorMessagesToDisplay.value
            .where(
              (m) => m != message,
            )
            .toList();
      },
    );
  }

  void _clearErrorMessages() {
    EasyDebounce.debounce(
      _kOverlayDebounce,
      const Duration(milliseconds: 500),
      () {
        _errorMessagesToDisplay.value = [];
      },
    );
  }

  @override
  void deactivate() {
    _removeEntry();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _showEntry();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _showEntry());
    _controller = CodeLineEditingController(spanBuilder: _buildTextSpan)
      ..addListener(
        () {
          final parseResult = _alakonParser.parse(_controller.text);
          switch (parseResult) {
            case Success(value: final AstNode programNode):
              _parseError = null;
              try {
                _alakonAnalyzer.analyze(programNode);
                _analysisResult = null;
              } on AnalysisException catch (e) {
                _analysisResult = e.result;
              }
            case Failure(
                buffer: final buffer,
                position: final position,
                message: final message,
              ):
              final lineAndColumn = Token.lineAndColumnOf(buffer, position);
              final (line, column) = (lineAndColumn[0], lineAndColumn[1]);
              _parseError = (line: line, column: column, message: message);
              _analysisResult = null;
            default:
              _parseError = null;
              _analysisResult = null;
          }
        },
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextSpan _buildTextSpan({
    required BuildContext context,
    required int index,
    required CodeLine codeLine,
    required TextSpan textSpan,
    required TextStyle style,
  }) {
    final errorStyle = TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(context).colorScheme.errorContainer,
      decorationStyle: TextDecorationStyle.double,
      decorationThickness: 5,
    );
    if (_parseError case final parseError? when parseError.line - 1 == index) {
      return _styleCharacterAt(
        textSpan,
        errorStyle,
        parseError.column - 1,
        (offset) => _addErrorMessage(parseError.message, offset),
        () => _removeErrorMessage(parseError.message),
      );
    }
    final analysisErrorLines =
        _analysisResult?.errors.where((error) => error.line - 1 == index) ?? [];
    TextSpan resultSpan = textSpan;
    for (final error in analysisErrorLines) {
      resultSpan = _styleCharacterAt(
        resultSpan,
        errorStyle,
        error.column - 1,
        (offset) => _addErrorMessage(error.message, offset),
        () => _removeErrorMessage(error.message),
      );
    }
    return resultSpan;
  }

  TextSpan _styleCharacterAt(
    TextSpan textSpan,
    TextStyle textStyle,
    int index,
    void Function(Offset) onEntry,
    void Function() onExit,
  ) {
    final styler = TextSpanStyler();
    return styler.styleCharacterAt(
      textSpan,
      textStyle,
      index,
      onEntry,
      onExit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: CodeEditor(
        controller: _controller,
        border: Border.fromBorderSide(
          BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        style: CodeEditorStyle(
          fontFamily: Fonts.monocraft,
          codeTheme: CodeHighlightTheme(
            languages: AlakonCodeTheme.language,
            theme: AlakonCodeTheme.buildTheme(context),
          ),
        ),
      ),
    );
  }
}
