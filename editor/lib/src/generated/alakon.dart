// ignore_for_file: prefer_single_quotes
import 'package:re_highlight/re_highlight.dart';
part 'modes.dart';

final langAlakon = Mode(
    refs: {},
    name: "Alakon",
    keywords: {
      "keyword": ["true", "false"],
      "built_in": ["String", "bool", "num"],
      "\$pattern": "[A-Za-z][A-Za-z0-9_]*"
    },
    contains: <Mode>[
      Mode(
          className: 'string',
          variants: <Mode>[Mode(begin: "\"", end: "\"", illegal: "\\n")]),
      C_NUMBER_MODE
    ]);
