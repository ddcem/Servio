import 'package:flutter/material.dart';

/// Stretches a table to the available width and scrolls it sideways when the window is too narrow.
class WideTable extends StatelessWidget {
  const WideTable({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: child,
        ),
      ),
    );
  }
}
