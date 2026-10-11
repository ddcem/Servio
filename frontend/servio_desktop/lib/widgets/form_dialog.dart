import 'package:flutter/material.dart';
import 'package:servio_shared/servio_shared.dart';

/// Add/edit form in a dialog with a close (X) button, Cancel and Save.
/// [onSave] returns normally on success; an [ApiException] keeps the dialog open.
class FormDialog extends StatefulWidget {
  const FormDialog({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSave,
    this.serverErrors,
    this.saveLabel,
    this.width = 520,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final Future<void> Function() onSave;

  /// When given, the API's field messages are shown under the matching fields.
  final ServerErrors? serverErrors;
  final String? saveLabel;
  final double width;

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    widget.serverErrors?.clear();
    if (!widget.formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave();
    } on ApiException catch (e) {
      // Field errors are shown under their fields; the general message is shown above the buttons.
      widget.serverErrors?.set(e);
      if (mounted) setState(() => _error = e.message);
      widget.formKey.currentState?.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext _) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.width, maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                IconButton(tooltip: l10n.close, icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Form(
                key: widget.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...widget.children.expand((child) => [child, const SizedBox(height: 16)]),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: ServioColors.dangerLight, borderRadius: BorderRadius.circular(10)),
                        child: Text(_error!, style: const TextStyle(color: ServioColors.danger)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(widget.saveLabel ?? l10n.save),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Keeps the API's validation messages for a form so each field can show its own under it.
class ServerErrors {
  ApiException? _exception;

  void set(Object error) => _exception = error is ApiException ? error : null;

  void clear() => _exception = null;

  String? operator [](String field) => _exception?.errorFor(field);
}
