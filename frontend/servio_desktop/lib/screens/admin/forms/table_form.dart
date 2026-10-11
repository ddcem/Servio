import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../../widgets/form_dialog.dart';
import 'reference_forms.dart';

/// Add or edit a restaurant table. Returns true when saved.
Future<bool?> showTableForm(BuildContext context, {RestaurantTable? table}) => showDialog<bool>(
  context: context,
  builder: (_) => _TableForm(table: table),
);

class _TableForm extends StatefulWidget {
  const _TableForm({this.table});

  final RestaurantTable? table;

  @override
  State<_TableForm> createState() => _TableFormState();
}

class _TableFormState extends State<_TableForm> {
  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  late final _number = TextEditingController(text: widget.table?.number.toString());
  late final _capacity = TextEditingController(text: widget.table?.capacity.toString());
  late int? _areaId = widget.table?.areaId;
  late bool _active = widget.table?.isActive ?? true;
  List<TableArea> _areas = [];

  bool get _editing => widget.table != null;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    final areas = await context.read<TableAreaProvider>().getAll();
    if (mounted) setState(() => _areas = areas);
  }

  Future<void> _addArea() async {
    final area = await showNameForm<TableArea>(
      context,
      provider: context.read<TableAreaProvider>(),
      entityLabel: l10n.entityArea,
      hint: l10n.areaHint,
    );
    if (area == null) return;
    await _loadAreas();
    setState(() => _areaId = area.id);
  }

  @override
  void dispose() {
    _number.dispose();
    _capacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) => FormDialog(
    title: _editing ? l10n.editTable(widget.table!.number) : l10n.addTable,
    formKey: _formKey,
    serverErrors: _server,
    width: 480,
    onSave: () async {
      final request = {
        'number': int.parse(_number.text.trim()),
        'capacity': int.parse(_capacity.text.trim()),
        'areaId': _areaId,
        'isActive': _active,
      };
      final provider = context.read<RestaurantTableProvider>();
      final saved = _editing ? await provider.update(widget.table!.id, request) : await provider.insert(request);
      if (!mounted) return;
      Navigator.pop(context, true);
      showSuccess(
        context,
        _editing
            ? l10n.tableUpdated(saved.number, l10n.seatCount(saved.capacity), saved.areaName)
            : l10n.tableAdded(saved.number, l10n.seatCount(saved.capacity), saved.areaName),
      );
    },
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: _number,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.tableNumberLabel),
              validator: (value) => _server['Number'] ?? Validators.integer(value, l10n.tableNumberLabel, min: 1, max: 999),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _capacity,
              decoration: InputDecoration(labelText: l10n.seats),
              validator: (value) => _server['Capacity'] ?? Validators.integer(value, l10n.seats, min: 1, max: 20),
            ),
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              key: ValueKey(_areas.length),
              initialValue: _areaId,
              decoration: InputDecoration(labelText: l10n.area),
              items: _areas.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
              onChanged: (value) => setState(() => _areaId = value),
              validator: (value) => _server['AreaId'] ?? (value == null ? l10n.areaRequired : null),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: IconButton.filledTonal(tooltip: l10n.addNewArea, onPressed: _addArea, icon: const Icon(Icons.add)),
          ),
        ],
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.inUse),
        subtitle: Text(l10n.notInUseHelper),
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
    ],
  );
}
