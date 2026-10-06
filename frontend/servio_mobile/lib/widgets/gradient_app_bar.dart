import 'package:flutter/material.dart';
import 'package:servio_shared/servio_shared.dart';

/// The blue header from the designs: a title with an optional subtitle underneath.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({super.key, required this.title, this.subtitle, this.actions, this.bottom});

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(68 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 68,
    titleSpacing: Navigator.of(context).canPop() ? 0 : 20,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    ),
    actions: actions,
    bottom: bottom,
    flexibleSpace: const DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [ServioColors.primary, Color(0xFF1D4ED8)])),
    ),
  );
}

/// A square, lightly tinted button for the header, as in the designs.
class HeaderButton extends StatelessWidget {
  const HeaderButton({super.key, required this.icon, required this.tooltip, required this.onPressed, this.badge = 0});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int badge;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Badge(
      isLabelVisible: badge > 0,
      label: Text('$badge'),
      backgroundColor: ServioColors.danger,
      child: IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white24,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    ),
  );
}
