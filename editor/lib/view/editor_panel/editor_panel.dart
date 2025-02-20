import 'package:editor/assets.dart';
import 'package:editor/code_run_cubit.dart';
import 'package:editor/view/editor_panel/code_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
/// Pane of the app containing the code edition text field.
class EditorPanel extends StatefulWidget {
  const EditorPanel({super.key});

  @override
  State<EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends State<EditorPanel> {
  /// Code controller, where most of the text editing logic / code analysis is
  /// performed.
  late final CodeFieldController _controller;

  /// Focus node of the code text field.
  ///
  /// Used to prevent flutter from processing tab key input on edition.
  late final FocusNode _fieldFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = CodeFieldController();
    _fieldFocusNode = FocusNode(
      onKeyEvent: (_, event) {
        // If text field is focused, then tab key should be ignored by flutter
        // as it is used by the controller to add indentation.
        if (event.logicalKey == LogicalKeyboardKey.tab && _controller.focused) {
          return KeyEventResult.skipRemainingHandlers;
        }
        return KeyEventResult.ignored;
      },
    );
    _fieldFocusNode.addListener(() {
      if(_fieldFocusNode.hasPrimaryFocus) {
        _controller.setFocused();
      } else {
        _controller.clearFocused();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Setup controller error style (cannot be done in init state as it depends
    // on Theme).
    _controller.errorStyle = TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(context).colorScheme.errorContainer,
      decorationStyle: TextDecorationStyle.double,
      decorationThickness: 5,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Code field
        Expanded(
          child: FractionallySizedBox(
            widthFactor: 1,
            child: TextField(
              focusNode: _fieldFocusNode,
              controller: _controller,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              expands: true,
              minLines: null,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              style: TextStyle(
                fontFamily: Fonts.monocraft,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Gap(8),

        // Run button
        BlocBuilder<CodeRunCubit, CodeRunState>(
          builder: (context, state) {
            final canRun = switch (state) {
              CodeRunStateInitial() || CodeRunStateDone() => true,
              _ => false,
            };
            final icon = switch (state) {
              CodeRunStateInitial() ||
              CodeRunStateDone() ||
              CodeRunStateRunning() =>
                Icon(Icons.play_arrow),
              CodeRunStateLaunching() => CircularProgressIndicator(),
            };
            return ElevatedButton.icon(
              onPressed: canRun
                  ? () {
                      context.read<CodeRunCubit>().run(_controller.text);
                    }
                  : null,
              icon: icon,
              label: Text('Run'),
            );
          },
        ),
      ],
    );
  }
}
