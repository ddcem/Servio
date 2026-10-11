import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';

/// The waiter's own details, profile photo and password.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final _profile = context.read<ProfileProvider>();
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  User? _user;
  Object? _error;
  bool _saving = false;
  int _imageVersion = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [_firstName, _lastName, _email, _phone]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final user = await _profile.get();
      if (!mounted) return;
      _firstName.text = user.firstName;
      _lastName.text = user.lastName;
      _email.text = user.email;
      _phone.text = user.phoneNumber ?? '';
      setState(() {
        _user = user;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final user = await _profile.update({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phoneNumber': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      });
      if (!mounted) return;
      context.read<AuthProvider>().updateUser(user);
      setState(() => _user = user);
      showSuccess(context, l10n.profileSaved);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_user?.hasProfileImage ?? false)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: ServioColors.danger),
                title: Text(l10n.removePhoto),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      if (source == 'remove') {
        await _profile.deleteImage();
      } else {
        final file = await ImagePicker().pickImage(
          source: source as ImageSource,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (file == null) return;
        await _profile.uploadImage(await file.readAsBytes(), file.name);
      }
      _imageVersion++;
      await _load();
      if (mounted && _user != null) context.read<AuthProvider>().updateUser(_user!);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _changePassword() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordDialog(profile: _profile),
    );
    if (changed == true && mounted) showSuccess(context, l10n.passwordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      appBar: GradientAppBar(title: l10n.myProfile),
      body: _error != null && user == null
          ? ErrorView(error: _error!, onRetry: _load)
          : user == null
          ? const LoadingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          AuthImage(
                            url: _profile.imageUrl(),
                            headers: context.read<ApiClient>().authHeaders,
                            hasImage: user.hasProfileImage,
                            version: _imageVersion,
                            size: 112,
                            circle: true,
                            fallback: Icons.person,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: IconButton.filled(
                              tooltip: l10n.changePhoto,
                              onPressed: _changePhoto,
                              icon: const Icon(Icons.photo_camera_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '@${user.username} · ${Roles.label(user.role)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ServioColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _firstName,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: l10n.firstName),
                      validator: (value) => Validators.length(value, l10n.firstName, min: 2, max: 50),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastName,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: l10n.lastName),
                      validator: (value) => Validators.length(value, l10n.lastName, min: 2, max: 50),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(labelText: l10n.email),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: l10n.phoneOptional, hintText: '+387 61 123 456'),
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.saveChanges)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.lock_reset),
                      label: Text(l10n.changePassword),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.profile});

  final ProfileProvider profile;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [_current, _password, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.profile.changePassword(_current.text, _password.text, _confirmation.text);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(l10n.changePassword),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _current,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.currentPassword),
              validator: (value) => Validators.required(value, l10n.currentPassword),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.newPassword, helperText: l10n.passwordHint),
              validator: Validators.newPassword,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmation,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.repeatNewPassword),
              validator: (value) => Validators.confirmation(value, _password.text),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: ServioColors.danger)),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.back)),
      FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.changePassword)),
    ],
  );
}
