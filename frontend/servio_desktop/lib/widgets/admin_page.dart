import 'package:flutter/material.dart';
import 'package:servio_shared/servio_shared.dart';

/// Header (back arrow, title, subtitle, actions) and scrollable body of an admin panel section.
class AdminPage extends StatelessWidget {
  const AdminPage({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    this.backTooltip,
    required this.child,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  /// Defaults to "Back to dashboard"; pages opened from a section go back to that section.
  final String? backTooltip;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 20, 28, 20),
        child: Row(
          children: [
            IconButton(
              tooltip: backTooltip ?? l10n.backToDashboardShort,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: ServioColors.textMuted, fontSize: 15)),
                ],
              ),
            ),
            ...actions.expand((action) => [const SizedBox(width: 12), action]),
          ],
        ),
      ),
      const Divider(height: 1),
      Expanded(child: child),
    ],
  );
}

/// White rounded panel used for tables and forms.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: padding, child: child),
  );
}

/// Previous / next paging under a list.
class Pager extends StatelessWidget {
  const Pager({super.key, required this.page, required this.pageCount, required this.totalCount, required this.onChanged});

  final int page;
  final int pageCount;
  final int totalCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Row(
      children: [
        Text(l10n.resultsCount(totalCount), style: const TextStyle(color: ServioColors.textMuted)),
        const Spacer(),
        IconButton(
          tooltip: l10n.previousPage,
          onPressed: page > 1 ? () => onChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(l10n.pageOf(page, pageCount)),
        IconButton(
          tooltip: l10n.nextPage,
          onPressed: page < pageCount ? () => onChanged(page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    ),
  );
}
