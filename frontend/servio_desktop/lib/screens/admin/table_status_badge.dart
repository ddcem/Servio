import 'package:flutter/material.dart';
import 'package:servio_shared/servio_shared.dart';

class TableStatusBadge extends StatelessWidget {
  const TableStatusBadge(this.status, {super.key});

  final TableStatus status;

  @override
  Widget build(BuildContext context) => switch (status) {
    TableStatus.available => StatusBadge(l10n.available, color: ServioColors.success, background: ServioColors.successLight),
    TableStatus.occupied => StatusBadge(l10n.occupied, color: ServioColors.danger, background: ServioColors.dangerLight),
    TableStatus.reserved => StatusBadge(l10n.reserved, color: ServioColors.warning, background: ServioColors.warningLight),
  };
}
