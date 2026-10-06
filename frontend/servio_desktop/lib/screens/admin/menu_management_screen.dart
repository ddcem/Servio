import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/wide_table.dart';
import '../../widgets/action_icon.dart';
import '../../widgets/admin_page.dart';
import '../../widgets/search_field.dart';
import 'forms/menu_item_form.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  late final MenuItemProvider _items = context.read<MenuItemProvider>();

  PagedResult<MenuItem>? _result;
  Object? _error;
  List<MenuCategory> _categories = [];
  String _currency = '';
  int _page = 1;
  String _search = '';
  int? _categoryId;
  bool? _available;
  int _imageVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
    _load();
  }

  Future<void> _loadReferenceData() async {
    try {
      final results = await Future.wait([context.read<MenuCategoryProvider>().getAll(), context.read<SettingsProvider>().get()]);
      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<MenuCategory>;
        _currency = (results[1] as RestaurantSettings).currencySymbol;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _load() async {
    try {
      final result = await _items.getPage(
        page: _page,
        filter: {'FTS': _search, 'CategoryId': _categoryId, 'IsAvailableToday': _available, 'NewestFirst': true},
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

  Future<void> _openForm([MenuItem? item]) async {
    final saved = await showMenuItemForm(context, item: item);
    if (saved == true) {
      setState(() {
        _imageVersion++;
        if (item == null) _page = 1;
      });
      await _loadReferenceData();
      await _load();
    }
  }

  Future<void> _toggleAvailability(MenuItem item, bool available) async {
    try {
      await _items.setAvailability(item.id, available);
      if (!mounted) return;
      showSuccess(
        context,
        available ? '${item.name} is available again today.' : '${item.name} is now hidden from the waiters\' menu.',
      );
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _delete(MenuItem item) async {
    final confirmed = await confirmAction(
      context,
      title: 'Remove "${item.name}"?',
      message: 'The item disappears from the menu. Past orders keep it, so sales reports stay correct.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _items.delete(item.id);
      if (!mounted) return;
      showSuccess(context, '"${item.name}" was removed from the menu.');
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: 'Menu Management',
    subtitle: 'Manage menu items and availability',
    actions: [
      Tooltip(
        message: _categories.isEmpty ? 'Add a menu category first (Reference Data → Categories).' : '',
        child: FilledButton.icon(
          onPressed: _categories.isEmpty ? null : () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ),
    ],
    child: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            SearchField(hint: 'Search by name or description', onChanged: (value) => _filter(() => _search = value)),
            FilterDropdown<int>(
              label: 'Category',
              value: _categoryId,
              items: {for (final c in _categories) c.id: c.name},
              onChanged: (value) => _filter(() => _categoryId = value),
            ),
            FilterDropdown<bool>(
              label: 'Available today',
              value: _available,
              items: const {true: 'Available', false: 'Unavailable'},
              onChanged: (value) => _filter(() => _available = value),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTable(),
      ],
    ),
  );

  Widget _buildTable() {
    if (_error != null && _result == null) return ErrorView(error: _error!, onRetry: _load);
    if (_result == null) return const LoadingView();
    if (_result!.items.isEmpty) {
      return const EmptyView(icon: Icons.inventory_2_outlined, message: 'No menu items match the filters.');
    }

    final api = context.read<ApiClient>();
    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          WideTable(
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: ServioColors.textMuted),
              dataRowMinHeight: 64,
              dataRowMaxHeight: 72,
              columns: const [
                DataColumn(label: Text('ITEM')),
                DataColumn(label: Text('CATEGORY')),
                DataColumn(label: Text('TYPE')),
                DataColumn(label: Text('PRICE'), numeric: true),
                DataColumn(label: Text('AVAILABLE TODAY')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: [
                for (final item in _result!.items)
                  DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            AuthImage(
                              url: _items.imageUrl(item.id),
                              headers: api.authHeaders,
                              hasImage: item.hasImage,
                              size: 40,
                              version: _imageVersion,
                            ),
                            const SizedBox(width: 14),
                            Flexible(
                              child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(item.categoryName)),
                      DataCell(
                        StatusBadge(
                          item.isDrink ? 'drink' : 'food',
                          color: item.isDrink ? ServioColors.bar : ServioColors.kitchenDark,
                          background: item.isDrink ? const Color(0xFFF3E8FF) : const Color(0xFFFFEDD5),
                        ),
                      ),
                      DataCell(
                        Text(Formatters.money(item.price, _currency), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Switch(value: item.isAvailableToday, onChanged: (value) => _toggleAvailability(item, value)),
                            const SizedBox(width: 8),
                            Text(
                              item.isAvailableToday ? 'Available' : 'Unavailable',
                              style: TextStyle(color: item.isAvailableToday ? ServioColors.success : ServioColors.danger),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            ActionIcon(
                              icon: Icons.edit_outlined,
                              tooltip: 'Edit',
                              color: ServioColors.primary,
                              onPressed: () => _openForm(item),
                            ),
                            ActionIcon(
                              icon: Icons.delete_outline,
                              tooltip: 'Remove from menu',
                              color: ServioColors.danger,
                              onPressed: () => _delete(item),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Pager(
              page: _page,
              pageCount: _result!.pageCount,
              totalCount: _result!.totalCount,
              onChanged: (page) {
                setState(() => _page = page);
                _load();
              },
            ),
          ),
        ],
      ),
    );
  }
}
