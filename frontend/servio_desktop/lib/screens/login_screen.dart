import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

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
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().login(
        _username.text,
        _password.text,
        allowedRoles: const {Roles.admin, Roles.kitchen, Roles.bar},
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext _) => Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      actions: const [LanguageMenuButton(), SizedBox(width: 16)],
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), ServioColors.sidebar],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: ServioColors.primary,
                        child: Icon(Icons.verified_user_outlined, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.staffLogin,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.enterCredentials,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ServioColors.textMuted),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _username,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
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
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: ServioColors.dangerLight, borderRadius: BorderRadius.circular(10)),
                          child: Text(_error!, style: const TextStyle(color: ServioColors.danger)),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const _DemoAccounts(),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _busy ? null : _login,
                        child: _busy
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(l10n.login),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DemoAccounts extends StatelessWidget {
  const _DemoAccounts();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: ServioColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
    child: DefaultTextStyle(
      style: TextStyle(color: ServioColors.textMuted, fontSize: 13, height: 1.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.demoAccounts, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(l10n.demoDesktop),
          Text(l10n.demoKitchen),
          Text(l10n.demoBar),
        ],
      ),
    ),
  );
}
