import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/wide_table.dart';
import '../../widgets/action_icon.dart';
import '../../widgets/admin_page.dart';
import '../../widgets/search_field.dart';
import 'forms/reference_forms.dart';

/// All reference data in one place: categories, tags, table areas and currencies can be managed;
/// roles, preparation stations and payment methods are fixed because the system depends on their names.
class ReferenceDataScreen extends StatelessWidget {
  const ReferenceDataScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 5,
    child: AdminPage(
      title: 'Reference Data',
      subtitle: 'Lists used by the menu, tables and payments',
      child: Column(
        children: [
          const ColoredBox(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Menu categories'),
                Tab(text: 'Item tags'),
                Tab(text: 'Table areas'),
                Tab(text: 'Currencies'),
                Tab(text: 'System lists'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _CrudTab<MenuCategory>(
                  id: (c) => c.id,
                  provider: context.read<MenuCategoryProvider>(),
                  entityLabel: 'category',
                  searchHint: 'Search categories',
                  columns: const ['NAME', 'COURSE', 'PREPARED AT', 'ORDER', 'ITEMS'],
                  cells: (c) => [c.name, c.courseType.label, c.preparationStationName, '${c.sortOrder}', '${c.menuItemCount}'],
                  name: (c) => c.name,
                  deleteBlockedReason: (c) => c.menuItemCount > 0
                      ? 'Used by ${c.menuItemCount} menu item(s), including removed items kept for order history.'
                      : null,
                  openForm: (context, c) => showCategoryForm(context, category: c),
                ),
                _CrudTab<ItemTag>(
                  id: (t) => t.id,
                  provider: context.read<ItemTagProvider>(),
                  entityLabel: 'tag',
                  searchHint: 'Search tags',
                  columns: const ['NAME', 'MENU ITEMS'],
                  cells: (t) => [t.name, '${t.menuItemCount}'],
                  name: (t) => t.name,
                  deleteBlockedReason: (t) =>
                      t.menuItemCount > 0 ? 'Used by ${t.menuItemCount} menu item(s). Remove it from those items first.' : null,
                  openForm: (context, t) => showNameForm<ItemTag>(
                    context,
                    provider: context.read<ItemTagProvider>(),
                    entityLabel: 'Tag',
                    hint: 'e.g. Spicy',
                    id: t?.id,
                    currentName: t?.name,
                  ),
                ),
                _CrudTab<TableArea>(
                  id: (a) => a.id,
                  provider: context.read<TableAreaProvider>(),
                  entityLabel: 'area',
                  searchHint: 'Search areas',
                  columns: const ['NAME', 'TABLES'],
                  cells: (a) => [a.name, '${a.tableCount}'],
                  name: (a) => a.name,
                  deleteBlockedReason: (a) =>
                      a.tableCount > 0 ? 'Has ${a.tableCount} table(s). Move or delete them first.' : null,
                  openForm: (context, a) => showNameForm<TableArea>(
                    context,
                    provider: context.read<TableAreaProvider>(),
                    entityLabel: 'Area',
                    hint: 'e.g. Garden',
                    id: a?.id,
                    currentName: a?.name,
                  ),
                ),
                _CrudTab<Currency>(
                  id: (c) => c.id,
                  provider: context.read<CurrencyProvider>(),
                  entityLabel: 'currency',
                  searchHint: 'Search currencies',
                  columns: const ['CODE', 'NAME', 'SYMBOL', 'IN USE'],
                  cells: (c) => [c.code, c.name, c.symbol, c.isInUse ? 'Yes' : 'No'],
                  name: (c) => c.code,
                  deleteBlockedReason: (c) => c.isInUse ? 'Used by the restaurant settings or by existing orders.' : null,
                  openForm: (context, c) => showCurrencyForm(context, currency: c),
                ),
                const _SystemLists(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CrudTab<T> extends StatefulWidget {
  const _CrudTab({
    super.key,
    required this.provider,
    required this.entityLabel,
    required this.searchHint,
    required this.columns,
    required this.cells,
    required this.id,
    required this.name,
    required this.deleteBlockedReason,
    required this.openForm,
  });

  final CrudProvider<T> provider;
  final String entityLabel;
  final String searchHint;
  final List<String> columns;
  final List<String> Function(T) cells;
  final int Function(T) id;
  final String Function(T) name;
  final String? Function(T) deleteBlockedReason;
  final Future<Object?> Function(BuildContext, T?) openForm;

  @override
  State<_CrudTab<T>> createState() => _CrudTabState<T>();
}

class _CrudTabState<T> extends State<_CrudTab<T>> with AutomaticKeepAliveClientMixin {
  PagedResult<T>? _result;
  Object? _error;
  String _search = '';
  int _page = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await widget.provider.getPage(page: _page, filter: {'FTS': _search});
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

  Future<void> _open([T? item]) async {
    if (await widget.openForm(context, item) != null) await _load();
  }

  Future<void> _delete(T item) async {
    final name = widget.name(item);
    final confirmed = await confirmAction(
      context,
      title: 'Delete $name?',
      message: 'The ${widget.entityLabel} is removed permanently.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await widget.provider.delete(widget.id(item));
      if (!mounted) return;
      showSuccess(context, '${widget.entityLabel[0].toUpperCase()}${widget.entityLabel.substring(1)} "$name" was deleted.');
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext _) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Row(
          children: [
            SearchField(
              hint: widget.searchHint,
              onChanged: (value) {
                setState(() {
                  _search = value;
                  _page = 1;
                });
                _load();
              },
            ),
            const Spacer(),
            FilledButton.icon(onPressed: () => _open(), icon: const Icon(Icons.add), label: Text('Add ${widget.entityLabel}')),
          ],
        ),
        const SizedBox(height: 20),
        if (_error != null && _result == null)
          ErrorView(error: _error!, onRetry: _load)
        else if (_result == null)
          const LoadingView()
        else if (_result!.items.isEmpty)
          EmptyView(icon: Icons.category_outlined, message: 'Nothing found.')
        else
          Panel(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                WideTable(
                  child: DataTable(
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: ServioColors.textMuted),
                    columns: [
                      for (final c in widget.columns) DataColumn(label: Text(c)),
                      const DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: [
                      for (final item in _result!.items)
                        DataRow(
                          cells: [
                            for (final value in widget.cells(item)) DataCell(Text(value)),
                            DataCell(
                              Row(
                                children: [
                                  ActionIcon(
                                    icon: Icons.edit_outlined,
                                    tooltip: 'Edit',
                                    color: ServioColors.primary,
                                    onPressed: () => _open(item),
                                  ),
                                  ActionIcon(
                                    icon: Icons.delete_outline,
                                    tooltip: 'Delete',
                                    color: ServioColors.danger,
                                    disabledReason: widget.deleteBlockedReason(item),
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
          ),
      ],
    );
  }
}

class _SystemLists extends StatelessWidget {
  const _SystemLists();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ServioColors.infoLight, borderRadius: BorderRadius.circular(12)),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: ServioColors.primaryDark),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'These lists are fixed. Roles decide what each employee may do, stations decide where orders are sent, '
                'and payment methods are tied to the cash and PayPal flows, so renaming or deleting them would break those features.',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          _LookupList(title: 'Roles', icon: Icons.badge_outlined, load: context.read<RoleProvider>().getAll),
          _LookupList(
            title: 'Preparation stations',
            icon: Icons.soup_kitchen_outlined,
            load: context.read<PreparationStationProvider>().getAll,
          ),
          _LookupList(
            title: 'Payment methods',
            icon: Icons.payments_outlined,
            load: context.read<PaymentMethodProvider>().getAll,
          ),
        ],
      ),
    ],
  );
}

class _LookupList extends StatelessWidget {
  const _LookupList({required this.title, required this.icon, required this.load});

  final String title;
  final IconData icon;
  final Future<List<Lookup>> Function({Map<String, dynamic>? filter}) load;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Panel(
      child: FutureBuilder<List<Lookup>>(
        future: load(),
        builder: (context, snapshot) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: ServioColors.primary),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (snapshot.hasError) Text('${snapshot.error}', style: const TextStyle(color: ServioColors.danger)),
            if (!snapshot.hasData && !snapshot.hasError) const LinearProgressIndicator(),
            for (final item in snapshot.data ?? const <Lookup>[])
              Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('• ${item.name}')),
          ],
        ),
      ),
    ),
  );
}
