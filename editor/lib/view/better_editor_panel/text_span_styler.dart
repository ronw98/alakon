import 'package:flutter/material.dart';

/// See [styleCharacterAt].
class TextSpanStyler {
  int _currentIndex = 0;

  /// Method that takes a [TextSpan] and applies [textStyle] to the single 
  /// character at [position].
  /// 
  /// [onEntry] is invoked when the cursor enters the character's space and 
  /// [onExit] is called when it leaves it.
  TextSpan styleCharacterAt(
    TextSpan textSpan,
    TextStyle textStyle,
    int position,
    void Function(Offset) onEntry,
    void Function() onExit,
  ) {
    _currentIndex = 0;
    
    return _styleCharacterAt(
      textSpan,
      textStyle,
      position,
      onEntry,
      onExit,
      false,
    );
  }

  /// Recursive method that takes in a textSpan and sets [textStyle] as the
  /// style for the specific character at [position] - [_currentIndex] within
  /// the span.
  TextSpan _styleCharacterAt(
    TextSpan textSpan,
    TextStyle textStyle,
    int position,
    void Function(Offset) onEntry,
    void Function() onExit,
    // Whether or not this span is the last of the global span or not
    bool remaining,
  ) {
    // Return immediately if overshot
    if (position < _currentIndex) return textSpan;

    // Character to replace is within span text
    if (textSpan.text case final text?
        when text.length + _currentIndex >= position && text.isNotEmpty) {
      final String beforeIndex;
      final String charAtIndex;
      final String afterIndex;
      final remainingAfterText =
          remaining || (textSpan.children?.isNotEmpty ?? false);
      if (text.length + _currentIndex == position) {
        if (!remainingAfterText) {
          // Character should be added at end of line
          beforeIndex = text.substring(0, text.length - 1);
          charAtIndex = text[text.length - 1];
          afterIndex = '';
        } else {
          beforeIndex = text;
          afterIndex = '';
          charAtIndex = '';
        }
      } else {
        beforeIndex = text.substring(0, position - _currentIndex);
        charAtIndex = text[position - _currentIndex];
        afterIndex = text.substring(position - _currentIndex + 1);
      }

      _currentIndex += text.length;
      return TextSpan(
        text: beforeIndex,
        children: [
          if (charAtIndex.isNotEmpty)
            TextSpan(
              text: charAtIndex,
              style: textStyle,
              onEnter: (event) {
                onEntry(event.position);
              },
              onExit: (event) {
                onExit();
              },
            ),
          if (afterIndex.isNotEmpty) TextSpan(text: afterIndex),
          ...?textSpan.children,
        ],
        style: textSpan.style,
        locale: textSpan.locale,
        mouseCursor: textSpan.mouseCursor,
        onEnter: textSpan.onEnter,
        onExit: textSpan.onExit,
        recognizer: textSpan.recognizer,
        semanticsLabel: textSpan.semanticsLabel,
        spellOut: textSpan.spellOut,
      );
    } else {
      _currentIndex += textSpan.text?.length ?? 0;
      final newChildren = <InlineSpan>[];
      // Visit span children
      for (final child in textSpan.children ?? <InlineSpan>[]) {
        // If textspan, try to style it
        if (child is TextSpan) {
          final transformedChild = _styleCharacterAt(
            child,
            textStyle,
            position,
            onEntry,
            onExit,
            // There are more spans remaining if either there are spans after
            // current span or child is not the last one
            remaining || textSpan.children?.last != child,
          );
          newChildren.add(transformedChild);
        } else {
          // Otherwise ignore
          newChildren.add(child);
        }
      }
      return TextSpan(
        text: textSpan.text,
        children: newChildren,
        style: textSpan.style,
        locale: textSpan.locale,
        mouseCursor: textSpan.mouseCursor,
        onEnter: textSpan.onEnter,
        onExit: textSpan.onExit,
        recognizer: textSpan.recognizer,
        semanticsLabel: textSpan.semanticsLabel,
        spellOut: textSpan.spellOut,
      );
    }
  }
}