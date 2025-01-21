import 'package:editor/view/home_page.dart';
import 'package:editor/view/theme/theme.dart';
import 'package:editor/view/theme/util.dart';
import 'package:flutter/material.dart';

class AlakonEditorApp extends StatelessWidget {
  const AlakonEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, 'Exo', 'Mouse Memoirs');

    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      title: 'Alakon editor',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: HomePage(),
    );
  }
}
