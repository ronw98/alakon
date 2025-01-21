import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
            Text(
              'Console',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Gap(4),
          ],
        ),
      ),
    );
  }
}
