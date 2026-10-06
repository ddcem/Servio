import 'package:flutter/material.dart';
import 'package:servio_shared/servio_shared.dart';

class TableStatusBadge extends StatelessWidget {
  const TableStatusBadge(this.status, {super.key});

  final TableStatus status;

  @override
  Widget build(BuildContext context) => switch (status) {
    TableStatus.available => const StatusBadge('Available', color: ServioColors.success, background: ServioColors.successLight),
    TableStatus.occupied => const StatusBadge('Occupied', color: ServioColors.danger, background: ServioColors.dangerLight),
    TableStatus.reserved => const StatusBadge('Reserved', color: ServioColors.warning, background: ServioColors.warningLight),
  };
}
