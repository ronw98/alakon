import 'package:editor/view/better_editor_panel/better_editor_panel.dart';
import 'package:editor/view/console_panel/console_panel.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alakon editor'),
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(child: BetterEditorPanel()),
            Expanded(child: ConsolePanel()),
          ],
        ),
      ),
    );
  }
}
