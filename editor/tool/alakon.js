/*
Language: Alakon
Requires: markdown.js
Author: Maxim Dikun <dikmax@gmail.com>
Description: Dart a modern, object-oriented language developed by Google. For more information see https://www.dartlang.org/
Website: https://dart.dev
Category: scripting
*/

/** @type LanguageFn */
function alakon(hljs) {
  const STRING = {
    className: 'string',
    variants: [
      {
        begin: '"',
        end: '"',
        illegal: '\\n'
      }
    ]
  };

  const BUILT_IN_TYPES = [
    'String',
    'bool',
    'num'
  ];
  const BASIC_KEYWORDS = ['true', 'false'];

  const KEYWORDS = {
    keyword: BASIC_KEYWORDS,
    built_in: BUILT_IN_TYPES,
    $pattern: /[A-Za-z][A-Za-z0-9_]*/
  };

  return {
    name: 'Alakon',
    keywords: KEYWORDS,
    contains: [
      STRING,
      hljs.C_NUMBER_MODE,
      // TODO: variable should be contained within specific cases (such as variable dec or variable assign matches). Setting it like that will transform keywords into variables.
//      {
//        className: 'variable',
//        match: /[A-Za-z][A-Za-z0-9_]*/
//      }
    ]
  };
}

exports.alakon = alakon;
