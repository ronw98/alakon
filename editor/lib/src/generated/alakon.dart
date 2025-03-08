// ignore_for_file: prefer_single_quotes
import 'package:re_highlight/re_highlight.dart';
part 'modes.dart';

final langAlakon = Mode(
    refs: {},
    name: "Alakon",
    keywords: {
      "keyword": ["true", "false", "if", "else", "while"],
      "builtIn": ["String", "bool", "num"],
      "\$pattern": "[A-Za-z][A-Za-z0-9_]*"
    },
    contains: <Mode>[
      Mode(
          className: 'string',
          variants: <Mode>[Mode(begin: "\"", end: "\"", illegal: "\\n")]),
      Mode(scope: 'number', match: "[0-9]+(\\.[0-9]+)?")
    ]);
