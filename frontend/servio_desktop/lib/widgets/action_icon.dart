import 'package:flutter/material.dart';

/// Row action that stays visible when unavailable and explains why in its tooltip.
class ActionIcon extends StatelessWidget {
  const ActionIcon({super.key, required this.icon, required this.tooltip, this.onPressed, this.disabledReason, this.color});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final String? disabledReason;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final enabled = disabledReason == null && onPressed != null;
    return Tooltip(
      message: enabled ? tooltip : (disabledReason ?? tooltip),
      child: IconButton(
        icon: Icon(icon, color: enabled ? color : null),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
