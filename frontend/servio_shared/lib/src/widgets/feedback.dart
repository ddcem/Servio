import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../theme/servio_colors.dart';

void showSuccess(BuildContext context, String message) => _show(context, message, ServioColors.success, Icons.check_circle);

void showError(BuildContext context, Object error) => _show(
  context,
  error is ApiException ? error.message : 'Something went wrong. Please try again.',
  ServioColors.danger,
  Icons.error,
);

void _show(BuildContext context, String message, Color color, IconData icon) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
