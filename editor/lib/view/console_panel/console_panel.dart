import 'package:editor/assets.dart';
import 'package:editor/code_run_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Pane of the app containing the output console.
///
/// Builds according to [CodeRunCubit] using the [CodeOutput].
class ConsolePanel extends StatelessWidget {
  const ConsolePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          border: Border.fromBorderSide(
            BorderSide(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<CodeRunCubit, CodeRunState>(
              builder: (context, state) {
                final spans = switch (state) {
                  CodeRunStateInitial() => <TextSpan>[],
                  CodeRunStateLaunching() => <TextSpan>[],
                  CodeRunStateRunning(outputs: final outputs) ||
                  CodeRunStateDone(outputs: final outputs) =>
                    outputs.map(
                      (output) {
                        if (output is CodeStdout) {
                          return TextSpan(text: '${output.data}\n');
                        }
                        return TextSpan(
                          text: '${output.data}\n',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        );
                      },
                    ).toList(),
                };
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Console\n',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      ...spans
                    ],
                    style: TextStyle(
                      fontFamily: Fonts.monocraft,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
            Gap(4),
          ],
        ),
      ),
    );
  }
}
