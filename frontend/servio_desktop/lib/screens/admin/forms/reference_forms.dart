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
    title: widget.id == null ? 'Add ${widget.entityLabel.toLowerCase()}' : 'Edit ${widget.entityLabel.toLowerCase()}',
    formKey: _formKey,
    serverErrors: _server,
    width: 440,
    onSave: () async {
      final request = {'name': _name.text.trim()};
      final saved = widget.id == null ? await widget.provider.insert(request) : await widget.provider.update(widget.id!, request);
      if (!mounted) return;
      Navigator.pop(context, saved);
      showSuccess(context, '${widget.entityLabel} "${_name.text.trim()}" was ${widget.id == null ? 'added' : 'updated'}.');
    },
    children: [
      TextFormField(
        controller: _name,
        autofocus: true,
        maxLength: 30,
        decoration: InputDecoration(labelText: 'Name', hintText: widget.hint),
        validator: (value) => _server['Name'] ?? Validators.length(value, 'Name', min: 2, max: 30),
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
      title: editing ? 'Edit category' : 'Add category',
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
        showSuccess(context, 'Category "${saved.name}" was ${editing ? 'updated' : 'added'}.');
      },
      children: [
        TextFormField(
          controller: _name,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Main Course'),
          validator: (value) => _server['Name'] ?? Validators.length(value, 'Name', min: 2, max: 50),
        ),
        DropdownButtonFormField<CourseType>(
          initialValue: _courseType,
          decoration: const InputDecoration(labelText: 'Course type', helperText: 'Used by the recommender to complete a meal'),
          items: CourseType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
          onChanged: (value) => setState(() => _courseType = value),
          validator: (value) => _server['CourseType'] ?? (value == null ? 'Course type is required.' : null),
        ),
        DropdownButtonFormField<int>(
          initialValue: _stationId,
          decoration: const InputDecoration(
            labelText: 'Prepared at',
            helperText: 'Items of this category are sent to this station',
          ),
          items: (_stations ?? []).map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
          onChanged: (value) => setState(() => _stationId = value),
          validator: (value) => _server['PreparationStationId'] ?? (value == null ? 'Preparation station is required.' : null),
        ),
        TextFormField(
          controller: _sortOrder,
          decoration: const InputDecoration(labelText: 'Sort order', helperText: 'Lower numbers are shown first in the menu'),
          validator: (value) => _server['SortOrder'] ?? Validators.integer(value, 'Sort order', min: 0, max: 999),
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
      title: editing ? 'Edit currency' : 'Add currency',
      formKey: _formKey,
      serverErrors: _server,
      width: 460,
      onSave: () async {
        final request = {'code': _code.text.trim().toUpperCase(), 'name': _name.text.trim(), 'symbol': _symbol.text.trim()};
        final provider = context.read<CurrencyProvider>();
        final saved = editing ? await provider.update(widget.currency!.id, request) : await provider.insert(request);
        if (!mounted) return;
        Navigator.pop(context, saved);
        showSuccess(context, 'Currency ${saved.code} was ${editing ? 'updated' : 'added'}.');
      },
      children: [
        TextFormField(
          controller: _code,
          enabled: !codeLocked,
          maxLength: 3,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'Code',
            hintText: 'e.g. EUR',
            helperText: codeLocked ? 'The code cannot change while orders or the settings use this currency' : null,
          ),
          validator: (value) =>
              _server['Code'] ??
              (_codePattern.hasMatch(value?.trim().toUpperCase() ?? '')
                  ? null
                  : 'Currency code must be exactly 3 uppercase letters (ISO 4217), e.g. EUR.'),
        ),
        TextFormField(
          controller: _name,
          maxLength: 50,
          decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Euro'),
          validator: (value) => _server['Name'] ?? Validators.length(value, 'Name', min: 2, max: 50),
        ),
        TextFormField(
          controller: _symbol,
          maxLength: 5,
          decoration: const InputDecoration(labelText: 'Symbol', hintText: 'e.g. €'),
          validator: (value) => _server['Symbol'] ?? Validators.length(value, 'Symbol', min: 1, max: 5),
        ),
      ],
    );
  }
}
