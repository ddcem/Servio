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
      title: l10n.deleteNameQuestion(user.fullName),
      message: l10n.accountRemovedPermanently,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _users.delete(user.id);
      if (!mounted) return;
      showSuccess(context, l10n.accountDeleted(user.fullName));
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: l10n.employeeManagement,
    subtitle: l10n.manageStaff,
    actions: [
      FilledButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.person_add_alt), label: Text(l10n.addEmployee)),
    ],
    child: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            SearchField(hint: l10n.searchEmployees, onChanged: (value) => _filter(() => _search = value)),
            FilterDropdown<int>(
              label: l10n.role,
              value: _roleId,
              items: {for (final r in _roles) r.id: Roles.label(r.name)},
              onChanged: (value) => _filter(() => _roleId = value),
            ),
            FilterDropdown<bool>(
              label: 'Status',
              value: _active,
              items: {true: l10n.active, false: l10n.inactive},
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
    if (_result!.items.isEmpty) return EmptyView(icon: Icons.people_outline, message: l10n.noEmployeesMatch);

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
                                Text(Roles.label(user.role), style: const TextStyle(color: ServioColors.textMuted, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.usernameAndEmail(user.username, user.email),
                                  style: const TextStyle(color: ServioColors.textMuted, fontSize: 12),
                                ),
                                Text(
                                  user.lastLoginAt == null
                                      ? l10n.neverLoggedIn
                                      : l10n.lastLogin(Formatters.dateTime(user.lastLoginAt!)),
                                  style: const TextStyle(color: ServioColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            user.isActive ? l10n.active : l10n.inactive,
                            color: user.isActive ? ServioColors.success : ServioColors.textMuted,
                            background: user.isActive ? ServioColors.successLight : ServioColors.background,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(onPressed: () => _openForm(user), child: Text(l10n.edit)),
                          ),
                          const SizedBox(width: 8),
                          ActionIcon(
                            icon: Icons.delete_outline,
                            tooltip: l10n.deleteEmployee,
                            color: ServioColors.danger,
                            disabledReason: user.id == me.id
                                ? l10n.cannotDeleteOwnAccount
                                : user.hasActivity
                                ? l10n.employeeHasActivity
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
