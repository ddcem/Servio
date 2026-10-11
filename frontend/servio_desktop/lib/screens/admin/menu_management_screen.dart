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
      showSuccess(context, available ? l10n.availableAgain(item.name) : l10n.nowHidden(item.name));
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _delete(MenuItem item) async {
    final confirmed = await confirmAction(
      context,
      title: l10n.removeItemQuestion(item.name),
      message: l10n.removeItemMessage,
      confirmLabel: l10n.remove,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _items.delete(item.id);
      if (!mounted) return;
      showSuccess(context, l10n.itemRemoved(item.name));
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: l10n.menuManagement,
    subtitle: l10n.manageMenuSubtitle,
    actions: [
      Tooltip(
        message: _categories.isEmpty ? l10n.addCategoryFirst : '',
        child: FilledButton.icon(
          onPressed: _categories.isEmpty ? null : () => _openForm(),
          icon: const Icon(Icons.add),
          label: Text(l10n.addItem),
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
            SearchField(hint: l10n.searchByNameOrDescription, onChanged: (value) => _filter(() => _search = value)),
            FilterDropdown<int>(
              label: l10n.category,
              value: _categoryId,
              items: {for (final c in _categories) c.id: c.name},
              onChanged: (value) => _filter(() => _categoryId = value),
            ),
            FilterDropdown<bool>(
              label: l10n.availableToday,
              value: _available,
              items: {true: l10n.availableLabel, false: l10n.unavailable},
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
    if (_result == null) return LoadingView();
    if (_result!.items.isEmpty) {
      return EmptyView(icon: Icons.inventory_2_outlined, message: l10n.noMenuItemsMatch);
    }

    final api = context.read<ApiClient>();
    return Panel(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          WideTable(
            child: DataTable(
              headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: ServioColors.textMuted),
              dataRowMinHeight: 64,
              dataRowMaxHeight: 72,
              columns: [
                DataColumn(label: Text(l10n.columnItem)),
                DataColumn(label: Text(l10n.columnCategory)),
                DataColumn(label: Text(l10n.columnType)),
                DataColumn(label: Text(l10n.columnPrice), numeric: true),
                DataColumn(label: Text(l10n.columnAvailableToday)),
                DataColumn(label: Text(l10n.columnActions)),
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
                          item.isDrink ? l10n.drinkWord : l10n.food,
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
                              item.isAvailableToday ? l10n.availableLabel : l10n.unavailable,
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
                              tooltip: l10n.edit,
                              color: ServioColors.primary,
                              onPressed: () => _openForm(item),
                            ),
                            ActionIcon(
                              icon: Icons.delete_outline,
                              tooltip: l10n.removeFromMenu,
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
