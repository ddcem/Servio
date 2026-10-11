import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../../widgets/form_dialog.dart';

/// Add or edit a record that only has a name (item tags, table areas). Returns the saved record.
Future<T?> showNameForm<T>(
  BuildContext context, {
  required CrudProvider<T> provider,
  required String entityLabel,
  required String hint,
  int? id,
  String? currentName,
}) => showDialog<T>(
  context: context,
  builder: (_) => _NameForm<T>(provider: provider, entityLabel: entityLabel, hint: hint, id: id, currentName: currentName),
);

class _NameForm<T> extends StatefulWidget {
  const _NameForm({required this.provider, required this.entityLabel, required this.hint, this.id, this.currentName});

  final CrudProvider<T> provider;
  final String entityLabel;
  final String hint;
  final int? id;
  final String? currentName;

  @override
  State<_NameForm<T>> createState() => _NameFormState<T>();
}

class _NameFormState<T> extends State<_NameForm<T>> {
  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  late final _name = TextEditingController(text: widget.currentName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) => FormDialog(
    title: widget.id == null
        ? l10n.addEntity(widget.entityLabel.toLowerCase())
        : l10n.editEntity(widget.entityLabel.toLowerCase()),
    formKey: _formKey,
    serverErrors: _server,
    width: 440,
    onSave: () async {
      final request = {'name': _name.text.trim()};
      final saved = widget.id == null ? await widget.provider.insert(request) : await widget.provider.update(widget.id!, request);
      if (!mounted) return;
      Navigator.pop(context, saved);
      showSuccess(
        context,
        widget.id == null
            ? l10n.entityAdded(widget.entityLabel, _name.text.trim())
            : l10n.entityUpdated(widget.entityLabel, _name.text.trim()),
      );
    },
    children: [
      TextFormField(
        controller: _name,
        autofocus: true,
        maxLength: 30,
        decoration: InputDecoration(labelText: l10n.name, hintText: widget.hint),
        validator: (value) => _server['Name'] ?? Validators.length(value, l10n.name, min: 2, max: 30),
      ),
    ],
  );
}

/// Add or edit a menu category. Returns the saved category.
Future<MenuCategory?> showCategoryForm(BuildContext context, {MenuCategory? category}) => showDialog<MenuCategory>(
  context: context,
  builder: (_) => _CategoryForm(category: category),
);

class _CategoryForm extends StatefulWidget {
  const _CategoryForm({this.category});

  final MenuCategory? category;

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  late final _name = TextEditingController(text: widget.category?.name);
  late final _sortOrder = TextEditingController(text: '${widget.category?.sortOrder ?? 0}');
  late CourseType? _courseType = widget.category?.courseType;
  late int? _stationId = widget.category?.preparationStationId;
  List<Lookup>? _stations;

  @override
  void initState() {
    super.initState();
    context.read<PreparationStationProvider>().getAll().then((stations) {
      if (mounted) setState(() => _stations = stations);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    final editing = widget.category != null;
    return FormDialog(
      title: editing ? l10n.editCategory : l10n.addCategory,
      formKey: _formKey,
      serverErrors: _server,
      onSave: () async {
        final request = {
          'name': _name.text.trim(),
          'courseType': enumToApi(_courseType!),
          'preparationStationId': _stationId,
          'sortOrder': int.parse(_sortOrder.text.trim()),
        };
        final provider = context.read<MenuCategoryProvider>();
        final saved = editing ? await provider.update(widget.category!.id, request) : await provider.insert(request);
        if (!mounted) return;
        Navigator.pop(context, saved);
        showSuccess(context, editing ? l10n.categoryUpdated(saved.name) : l10n.categoryAdded(saved.name));
      },
      children: [
        TextFormField(
          controller: _name,
          autofocus: true,
          maxLength: 50,
          decoration: InputDecoration(labelText: l10n.name, hintText: l10n.categoryNameHint),
          validator: (value) => _server['Name'] ?? Validators.length(value, l10n.name, min: 2, max: 50),
        ),
        DropdownButtonFormField<CourseType>(
          initialValue: _courseType,
          decoration: InputDecoration(labelText: l10n.courseType, helperText: l10n.courseTypeHelper),
          items: CourseType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
          onChanged: (value) => setState(() => _courseType = value),
          validator: (value) => _server['CourseType'] ?? (value == null ? l10n.courseTypeRequired : null),
        ),
        DropdownButtonFormField<int>(
          initialValue: _stationId,
          decoration: InputDecoration(labelText: l10n.preparedAt, helperText: l10n.preparedAtHelper),
          items: (_stations ?? []).map((e) => DropdownMenuItem(value: e.id, child: Text(Stations.label(e.name)))).toList(),
          onChanged: (value) => setState(() => _stationId = value),
          validator: (value) => _server['PreparationStationId'] ?? (value == null ? l10n.stationRequired : null),
        ),
        TextFormField(
          controller: _sortOrder,
          decoration: InputDecoration(labelText: l10n.sortOrder, helperText: l10n.sortOrderHelper),
          validator: (value) => _server['SortOrder'] ?? Validators.integer(value, l10n.sortOrder, min: 0, max: 999),
        ),
      ],
    );
  }
}

/// Add or edit a currency. Returns the saved currency.
Future<Currency?> showCurrencyForm(BuildContext context, {Currency? currency}) => showDialog<Currency>(
  context: context,
  builder: (_) => _CurrencyForm(currency: currency),
);

class _CurrencyForm extends StatefulWidget {
  const _CurrencyForm({this.currency});

  final Currency? currency;

  @override
  State<_CurrencyForm> createState() => _CurrencyFormState();
}

class _CurrencyFormState extends State<_CurrencyForm> {
  static final _codePattern = RegExp(r'^[A-Z]{3}$');

  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  late final _code = TextEditingController(text: widget.currency?.code);
  late final _name = TextEditingController(text: widget.currency?.name);
  late final _symbol = TextEditingController(text: widget.currency?.symbol);

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _symbol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    final editing = widget.currency != null;
    final codeLocked = widget.currency?.isInUse ?? false;
    return FormDialog(
      title: editing ? l10n.editCurrency : l10n.addCurrency,
      formKey: _formKey,
      serverErrors: _server,
      width: 460,
      onSave: () async {
        final request = {'code': _code.text.trim().toUpperCase(), 'name': _name.text.trim(), 'symbol': _symbol.text.trim()};
        final provider = context.read<CurrencyProvider>();
        final saved = editing ? await provider.update(widget.currency!.id, request) : await provider.insert(request);
        if (!mounted) return;
        Navigator.pop(context, saved);
        showSuccess(context, editing ? l10n.currencyUpdated(saved.code) : l10n.currencyAdded(saved.code));
      },
      children: [
        TextFormField(
          controller: _code,
          enabled: !codeLocked,
          maxLength: 3,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: l10n.code,
            hintText: l10n.codeHint,
            helperText: codeLocked ? l10n.codeLocked : null,
          ),
          validator: (value) =>
              _server['Code'] ?? (_codePattern.hasMatch(value?.trim().toUpperCase() ?? '') ? null : l10n.currencyCodeInvalid),
        ),
        TextFormField(
          controller: _name,
          maxLength: 50,
          decoration: InputDecoration(labelText: l10n.name, hintText: l10n.currencyNameHint),
          validator: (value) => _server['Name'] ?? Validators.length(value, l10n.name, min: 2, max: 50),
        ),
        TextFormField(
          controller: _symbol,
          maxLength: 5,
          decoration: InputDecoration(labelText: l10n.symbol, hintText: 'KM, €'),
          validator: (value) => _server['Symbol'] ?? Validators.length(value, l10n.symbol, min: 1, max: 5),
        ),
      ],
    );
  }
}
