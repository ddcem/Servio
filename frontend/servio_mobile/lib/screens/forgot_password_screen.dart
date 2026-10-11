import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

/// Password reset in two steps: request a 6-digit code by email, then set a new password with it.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _message;
  String? _error;

  @override
  void dispose() {
    for (final controller in [_email, _code, _password, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = context.read<ApiClient>();
    try {
      if (!_codeSent) {
        final json = await api.post('auth/forgot-password', {'email': _email.text.trim()}) as Map<String, dynamic>;
        setState(() {
          _codeSent = true;
          _message = json['message'] as String?;
        });
      } else {
        await api.post('auth/reset-password', {
          'email': _email.text.trim(),
          'code': _code.text.trim(),
          'newPassword': _password.text,
          'newPasswordConfirmation': _confirmation.text,
        });
        if (!mounted) return;
        showSuccess(context, l10n.passwordChangedLogIn);
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l10n.resetPassword)),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _codeSent ? l10n.resetEnterCode : l10n.resetEnterEmail,
                style: const TextStyle(fontSize: 15, color: ServioColors.textMuted),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _email,
                enabled: !_codeSent,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.email, prefixIcon: Icon(Icons.email_outlined)),
                validator: Validators.email,
              ),
              if (_codeSent) ...[
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!, style: const TextStyle(color: ServioColors.success)),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(labelText: l10n.resetCode, prefixIcon: Icon(Icons.pin_outlined)),
                  validator: (value) => RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '') ? null : l10n.resetCodeInvalid,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    helperText: l10n.passwordHint,
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: Validators.newPassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmation,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.repeatNewPassword, prefixIcon: Icon(Icons.lock_outline)),
                  validator: (value) => Validators.confirmation(value, _password.text),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: ServioColors.danger)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(_codeSent ? l10n.changePassword : l10n.sendCode),
                ),
              ),
              if (_codeSent)
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _codeSent = false;
                          _error = null;
                        }),
                  child: Text(l10n.sendNewCode),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
