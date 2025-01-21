import 'package:editor/src/generated/alakon.dart';
import 'package:editor/view/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

class AlakonCodeTheme {
  static Map<String, TextStyle> buildTheme(BuildContext context) {
    final extensions = Theme.of(context).editorColors;
    return {
      'built_in': TextStyle(color: extensions.keyword.color),
      'string': TextStyle(color: extensions.string.color),
      'number': TextStyle(color: extensions.number.color),
      'keyword': TextStyle(color: extensions.keyword.color),
    };
  }

  static Map<String, CodeHighlightThemeMode> get language => {
        'alakon': CodeHighlightThemeMode(mode: langAlakon),
      };
}
