import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../../widgets/form_dialog.dart';

/// Add or edit an employee. Returns true when saved.
Future<bool?> showEmployeeForm(BuildContext context, {User? user}) => showDialog<bool>(
  context: context,
  builder: (_) => _EmployeeForm(user: user),
);

class _EmployeeForm extends StatefulWidget {
  const _EmployeeForm({this.user});

  final User? user;

  @override
  State<_EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<_EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  late final _firstName = TextEditingController(text: widget.user?.firstName);
  late final _lastName = TextEditingController(text: widget.user?.lastName);
  late final _username = TextEditingController(text: widget.user?.username);
  late final _email = TextEditingController(text: widget.user?.email);
  late final _phone = TextEditingController(text: widget.user?.phoneNumber);
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  late int? _roleId = widget.user?.roleId;
  late bool _active = widget.user?.isActive ?? true;
  bool _changePassword = false;
  List<Lookup> _roles = [];

  bool get _editing => widget.user != null;

  @override
  void initState() {
    super.initState();
    context.read<RoleProvider>().getAll().then((roles) {
      if (mounted) setState(() => _roles = roles);
    });
  }

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _username, _email, _phone, _password, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    final isSelf = widget.user?.id == context.read<AuthProvider>().user?.id;
    final askPassword = !_editing || _changePassword;

    return FormDialog(
      title: _editing ? 'Edit employee' : 'Add employee',
      formKey: _formKey,
      serverErrors: _server,
      width: 600,
      onSave: () async {
        final request = <String, dynamic>{
          'firstName': _firstName.text.trim(),
          'lastName': _lastName.text.trim(),
          'username': _username.text.trim(),
          'email': _email.text.trim(),
          'phoneNumber': _phone.text.trim(),
          'roleId': _roleId,
          'isActive': _active,
          if (!_editing) ...{'password': _password.text, 'passwordConfirmation': _confirmation.text},
          if (_editing && _changePassword) ...{'newPassword': _password.text, 'newPasswordConfirmation': _confirmation.text},
        };
        final provider = context.read<UserProvider>();
        final saved = _editing ? await provider.update(widget.user!.id, request) : await provider.insert(request);
        if (!mounted) return;
        Navigator.pop(context, true);
        showSuccess(
          context,
          _editing ? '${saved.fullName}\'s account was updated.' : '${saved.fullName} was added as ${saved.role.toLowerCase()}.',
        );
      },
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstName,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (value) => _server['FirstName'] ?? Validators.length(value, 'First name', min: 2, max: 50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (value) => _server['LastName'] ?? Validators.length(value, 'Last name', min: 2, max: 50),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _username,
          decoration: const InputDecoration(labelText: 'Username', helperText: 'Used to log in, e.g. john.smith'),
          validator: (value) => _server['Username'] ?? Validators.username(value),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email', hintText: 'name@example.com'),
                validator: (value) => _server['Email'] ?? Validators.email(value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone (optional)', hintText: '+387 61 123 456'),
                validator: (value) => _server['PhoneNumber'] ?? Validators.phone(value),
              ),
            ),
          ],
        ),
        DropdownButtonFormField<int>(
          key: ValueKey(_roles.length),
          initialValue: _roleId,
          decoration: InputDecoration(
            labelText: 'Role',
            helperText: isSelf
                ? 'You cannot change your own role'
                : 'The role decides which app and screens the employee can use',
          ),
          items: _roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
          onChanged: isSelf ? null : (value) => setState(() => _roleId = value),
          validator: (value) => _server['RoleId'] ?? (value == null ? 'Role is required.' : null),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Active'),
          subtitle: Text(isSelf ? 'You cannot deactivate your own account' : 'Inactive employees cannot log in'),
          value: _active,
          onChanged: isSelf ? null : (value) => setState(() => _active = value),
        ),
        if (_editing)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Change password'),
            subtitle: const Text('The employee is logged out on all devices after the change'),
            value: _changePassword,
            onChanged: (value) => setState(() => _changePassword = value ?? false),
          ),
        if (askPassword) ...[
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: _editing ? 'New password' : 'Password'),
            validator: (value) => _server[_editing ? 'NewPassword' : 'Password'] ?? Validators.newPassword(value),
          ),
          TextFormField(
            controller: _confirmation,
            obscureText: true,
            decoration: InputDecoration(labelText: _editing ? 'Repeat new password' : 'Repeat password'),
            validator: (value) =>
                _server[_editing ? 'NewPasswordConfirmation' : 'PasswordConfirmation'] ??
                Validators.confirmation(value, _password.text),
          ),
        ],
      ],
    );
  }
}
