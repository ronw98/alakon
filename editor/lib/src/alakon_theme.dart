import 'package:editor/view/theme/theme.dart';
import 'package:flutter/material.dart';

enum LanguageElement {
  /// Language keyword, such as true, false, if, false...
  keyword,

  /// Builtin types
  builtIn,

  /// Reference to a previously declared variable
  variableRef,

  /// Number lexical token
  number,

  /// String lexical token
  string,
}

/// Syntax highlighting theme for Alakon editor.
class AlakonCodeTheme {
  /// Full AST highlighting theme.
  static Map<LanguageElement, TextStyle> buildAstTheme(BuildContext context) {
    final extensions = Theme.of(context).editorColors;
    return {
      LanguageElement.keyword: TextStyle(color: extensions.keyword.color),
      LanguageElement.number: TextStyle(color: extensions.number.color),
      LanguageElement.string: TextStyle(color: extensions.string.color),
      LanguageElement.builtIn: TextStyle(color: extensions.keyword.color),
      LanguageElement.variableRef: TextStyle(color: Colors.purple.shade200),
    };
  }

  /// Basic highlighting theme.
  static Map<String, TextStyle> buildReTheme(BuildContext context) {
    final extensions = Theme.of(context).editorColors;
    return {
      LanguageElement.keyword.name: TextStyle(color: extensions.keyword.color),
      LanguageElement.string.name: TextStyle(color: extensions.string.color),
      LanguageElement.number.name: TextStyle(color: extensions.number.color),
      LanguageElement.builtIn.name: TextStyle(color: extensions.keyword.color),
    };
  }
}
