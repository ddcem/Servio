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
      title: l10n.referenceData,
      subtitle: l10n.referenceDataSubtitle,
      child: Column(
        children: [
          ColoredBox(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: l10n.menuCategories),
                Tab(text: l10n.itemTags),
                Tab(text: l10n.tableAreas),
                Tab(text: l10n.currencies),
                Tab(text: l10n.systemLists),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _CrudTab<MenuCategory>(
                  id: (c) => c.id,
                  provider: context.read<MenuCategoryProvider>(),
                  addLabel: l10n.addCategoryButton,
                  searchHint: l10n.searchCategories,
                  columns: [l10n.columnName, l10n.columnCourse, l10n.columnPreparedAt, l10n.columnOrder, l10n.columnItems],
                  cells: (c) => [
                    c.name,
                    c.courseType.label,
                    Stations.label(c.preparationStationName),
                    '${c.sortOrder}',
                    '${c.menuItemCount}',
                  ],
                  name: (c) => c.name,
                  deleteBlockedReason: (c) => c.menuItemCount > 0 ? l10n.categoryInUse(c.menuItemCount) : null,
                  openForm: (context, c) => showCategoryForm(context, category: c),
                ),
                _CrudTab<ItemTag>(
                  id: (t) => t.id,
                  provider: context.read<ItemTagProvider>(),
                  addLabel: l10n.addTagButton,
                  searchHint: l10n.searchTags,
                  columns: [l10n.columnName, l10n.columnMenuItems],
                  cells: (t) => [t.name, '${t.menuItemCount}'],
                  name: (t) => t.name,
                  deleteBlockedReason: (t) => t.menuItemCount > 0 ? l10n.tagInUse(t.menuItemCount) : null,
                  openForm: (context, t) => showNameForm<ItemTag>(
                    context,
                    provider: context.read<ItemTagProvider>(),
                    entityLabel: l10n.entityTag,
                    hint: l10n.tagHint,
                    id: t?.id,
                    currentName: t?.name,
                  ),
                ),
                _CrudTab<TableArea>(
                  id: (a) => a.id,
                  provider: context.read<TableAreaProvider>(),
                  addLabel: l10n.addAreaButton,
                  searchHint: l10n.searchAreas,
                  columns: [l10n.columnName, l10n.columnTables],
                  cells: (a) => [a.name, '${a.tableCount}'],
                  name: (a) => a.name,
                  deleteBlockedReason: (a) => a.tableCount > 0 ? l10n.areaInUse(a.tableCount) : null,
                  openForm: (context, a) => showNameForm<TableArea>(
                    context,
                    provider: context.read<TableAreaProvider>(),
                    entityLabel: l10n.entityArea,
                    hint: l10n.areaHint,
                    id: a?.id,
                    currentName: a?.name,
                  ),
                ),
                _CrudTab<Currency>(
                  id: (c) => c.id,
                  provider: context.read<CurrencyProvider>(),
                  addLabel: l10n.addCurrencyButton,
                  searchHint: l10n.searchCurrencies,
                  columns: [l10n.columnCode, l10n.columnName, l10n.columnSymbol, l10n.columnInUse],
                  cells: (c) => [c.code, c.name, c.symbol, c.isInUse ? l10n.yes : l10n.no],
                  name: (c) => c.code,
                  deleteBlockedReason: (c) => c.isInUse ? l10n.currencyInUse : null,
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
    required this.addLabel,
    required this.searchHint,
    required this.columns,
    required this.cells,
    required this.id,
    required this.name,
    required this.deleteBlockedReason,
    required this.openForm,
  });

  final CrudProvider<T> provider;

  /// The add button's text, e.g. 'Add tag'.
  final String addLabel;
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
      title: l10n.deleteQuestion(name),
      message: l10n.removedPermanently,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await widget.provider.delete(widget.id(item));
      if (!mounted) return;
      showSuccess(context, l10n.entityDeleted(name));
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
            FilledButton.icon(onPressed: () => _open(), icon: const Icon(Icons.add), label: Text(widget.addLabel)),
          ],
        ),
        const SizedBox(height: 20),
        if (_error != null && _result == null)
          ErrorView(error: _error!, onRetry: _load)
        else if (_result == null)
          const LoadingView()
        else if (_result!.items.isEmpty)
          EmptyView(icon: Icons.category_outlined, message: l10n.nothingFound)
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
                      DataColumn(label: Text(l10n.columnActions)),
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
                                    tooltip: l10n.edit,
                                    color: ServioColors.primary,
                                    onPressed: () => _open(item),
                                  ),
                                  ActionIcon(
                                    icon: Icons.delete_outline,
                                    tooltip: l10n.delete,
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
        child: Row(
          children: [
            Icon(Icons.info_outline, color: ServioColors.primaryDark),
            SizedBox(width: 12),
            Expanded(child: Text(l10n.systemListsInfo)),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          _LookupList(title: l10n.roles, icon: Icons.badge_outlined, load: context.read<RoleProvider>().getAll),
          _LookupList(
            title: l10n.preparationStations,
            icon: Icons.soup_kitchen_outlined,
            load: context.read<PreparationStationProvider>().getAll,
          ),
          _LookupList(
            title: l10n.paymentMethods,
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
              Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('• ${_lookupLabel(item.name)}')),
          ],
        ),
      ),
    ),
  );
}

/// Roles, stations and payment methods share their API names ("Kitchen", "Cash"); shown translated.
String _lookupLabel(String name) => name == PaymentMethods.cash ? PaymentMethods.label(name) : Roles.label(name);
