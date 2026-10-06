import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/action_icon.dart';
import '../../widgets/admin_page.dart';
import '../../widgets/search_field.dart';
import 'forms/employee_form.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late final UserProvider _users = context.read<UserProvider>();

  PagedResult<User>? _result;
  Object? _error;
  List<Lookup> _roles = [];
  int _page = 1;
  String _search = '';
  int? _roleId;
  bool? _active;

  @override
  void initState() {
    super.initState();
    context.read<RoleProvider>().getAll().then((roles) {
      if (mounted) setState(() => _roles = roles);
    });
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _users.getPage(
        page: _page,
        pageSize: 12,
        filter: {'FTS': _search, 'RoleId': _roleId, 'IsActive': _active},
      );
      if (mounted) {
        setState(() {
          _result = result;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _filter(VoidCallback change) {
    setState(() {
      change();
      _page = 1;
    });
    _load();
  }

  Future<void> _openForm([User? user]) async {
    if (await showEmployeeForm(context, user: user) == true) {
      if (user == null) setState(() => _page = 1);
      await _load();
    }
  }

  Future<void> _delete(User user) async {
    final confirmed = await confirmAction(
      context,
      title: 'Delete ${user.fullName}?',
      message: 'The account is removed permanently. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _users.delete(user.id);
      if (!mounted) return;
      showSuccess(context, '${user.fullName}\'s account was deleted.');
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: 'Employee Management',
    subtitle: 'Manage staff members',
    actions: [
      FilledButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.person_add_alt), label: const Text('Add Employee')),
    ],
    child: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            SearchField(hint: 'Search by name, username or email', onChanged: (value) => _filter(() => _search = value)),
            FilterDropdown<int>(
              label: 'Role',
              value: _roleId,
              items: {for (final r in _roles) r.id: r.name},
              onChanged: (value) => _filter(() => _roleId = value),
            ),
            FilterDropdown<bool>(
              label: 'Status',
              value: _active,
              items: const {true: 'Active', false: 'Inactive'},
              onChanged: (value) => _filter(() => _active = value),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildCards(),
      ],
    ),
  );

  Widget _buildCards() {
    if (_error != null && _result == null) return ErrorView(error: _error!, onRetry: _load);
    if (_result == null) return const LoadingView();
    if (_result!.items.isEmpty) return const EmptyView(icon: Icons.people_outline, message: 'No employees match the filters.');

    final api = context.read<ApiClient>();
    final me = context.read<AuthProvider>().user!;

    return Column(
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            for (final user in _result!.items)
              SizedBox(
                width: 420,
                child: Panel(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthImage(
                            url: _users.imageUrl(user.id),
                            headers: api.authHeaders,
                            hasImage: user.hasProfileImage,
                            size: 64,
                            circle: true,
                            fallback: Icons.people_outline,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text(user.role, style: const TextStyle(color: ServioColors.textMuted, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(
                                  '@${user.username} · ${user.email}',
                                  style: const TextStyle(color: ServioColors.textMuted, fontSize: 12),
                                ),
                                Text(
                                  user.lastLoginAt == null
                                      ? 'Never logged in'
                                      : 'Last login ${Formatters.dateTime(user.lastLoginAt!)}',
                                  style: const TextStyle(color: ServioColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            user.isActive ? 'active' : 'inactive',
                            color: user.isActive ? ServioColors.success : ServioColors.textMuted,
                            background: user.isActive ? ServioColors.successLight : ServioColors.background,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(onPressed: () => _openForm(user), child: const Text('Edit')),
                          ),
                          const SizedBox(width: 8),
                          ActionIcon(
                            icon: Icons.delete_outline,
                            tooltip: 'Delete employee',
                            color: ServioColors.danger,
                            disabledReason: user.id == me.id
                                ? 'You cannot delete your own account.'
                                : user.hasActivity
                                ? 'Has orders, reservations or payments in the system. Deactivate the account instead.'
                                : null,
                            onPressed: () => _delete(user),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        Pager(
          page: _page,
          pageCount: _result!.pageCount,
          totalCount: _result!.totalCount,
          onChanged: (page) {
            setState(() => _page = page);
            _load();
          },
        ),
      ],
    );
  }
}
