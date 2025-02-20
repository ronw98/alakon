import 'package:editor/code_run_cubit.dart';
import 'package:editor/view/console_panel/console_panel.dart';
import 'package:editor/view/editor_panel/editor_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alakon editor'),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => CodeRunCubit(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: EditorPanel()),
                Gap(4),
                Expanded(child: ConsolePanel()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
