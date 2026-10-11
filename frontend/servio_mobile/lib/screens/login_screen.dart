import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _error = context.read<AuthProvider>().takeSessionMessage();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().login(_username.text, _password.text, allowedRoles: const {Roles.waiter});
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ServioColors.primary, Color(0xFF1E40AF)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            const Align(alignment: Alignment.topRight, child: LanguageMenuButton()),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: ServioColors.primary,
                            child: Icon(Icons.people_outline, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.waiterLogin,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.enterCredentials,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ServioColors.textMuted, fontSize: 15),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _username,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: InputDecoration(labelText: l10n.username, prefixIcon: Icon(Icons.person_outline)),
                            validator: (value) => Validators.required(value, l10n.username),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (value) => Validators.required(value, l10n.password),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                              child: Text(l10n.forgotPassword),
                            ),
                          ),
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: ServioColors.dangerLight, borderRadius: BorderRadius.circular(10)),
                              child: Text(_error!, style: const TextStyle(color: ServioColors.danger)),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: ServioColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(color: ServioColors.textMuted, fontSize: 13),
                                children: [
                                  TextSpan(text: l10n.demoAccount),
                                  TextSpan(
                                    text: 'mobile',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: ' / '),
                                  TextSpan(
                                    text: 'test',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _busy ? null : _login,
                              child: _busy
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(l10n.login, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
