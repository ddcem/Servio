import 'package:flutter/material.dart';

import '../theme/servio_colors.dart';

/// Confirmation for actions that cannot be undone (delete, cancel, payment, sending an order).
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: ServioColors.danger) : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Asks for the reason of a cancellation; returns null when the user backs out.
Future<String?> askForReason(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Cancel it',
}) => showDialog<String>(
  context: context,
  builder: (_) => _ReasonDialog(title: title, message: message, confirmLabel: confirmLabel),
);

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.title, required this.message, required this.confirmLabel});

  final String title;
  final String message;
  final String confirmLabel;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reason,
              autofocus: true,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(labelText: 'Reason', hintText: 'e.g. Guest changed their mind'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Please enter a reason.';
                if (text.length < 3) return 'Reason must be between 3 and 500 characters long.';
                return null;
              },
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: ServioColors.danger),
        onPressed: () {
          if (_formKey.currentState!.validate()) Navigator.pop(context, _reason.text.trim());
        },
        child: Text(widget.confirmLabel),
      ),
    ],
  );
}
