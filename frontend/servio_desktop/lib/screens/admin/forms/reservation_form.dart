import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../../widgets/form_dialog.dart';

/// Add or edit a reservation. Returns true when saved.
Future<bool?> showReservationForm(BuildContext context, {Reservation? reservation}) => showDialog<bool>(
  context: context,
  builder: (_) => _ReservationForm(reservation: reservation),
);

class _ReservationForm extends StatefulWidget {
  const _ReservationForm({this.reservation});

  final Reservation? reservation;

  @override
  State<_ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<_ReservationForm> {
  static const _durations = [30, 60, 90, 120, 150, 180, 240, 300, 360];

  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  late final _guestName = TextEditingController(text: widget.reservation?.guestName);
  late final _phone = TextEditingController(text: widget.reservation?.guestPhone);
  late final _email = TextEditingController(text: widget.reservation?.guestEmail);
  late final _partySize = TextEditingController(text: widget.reservation?.partySize.toString() ?? '2');
  late final _note = TextEditingController(text: widget.reservation?.note);
  late int? _tableId = widget.reservation?.tableId;
  late DateTime _date = widget.reservation?.startTime ?? DateTime.now().add(const Duration(days: 1));
  late TimeOfDay _time = widget.reservation == null
      ? const TimeOfDay(hour: 19, minute: 0)
      : TimeOfDay.fromDateTime(widget.reservation!.startTime);
  late int _duration = widget.reservation == null
      ? 120
      : widget.reservation!.endTime.difference(widget.reservation!.startTime).inMinutes;
  List<RestaurantTable> _tables = [];

  bool get _editing => widget.reservation != null;

  DateTime get _start => DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  @override
  void initState() {
    super.initState();
    context.read<RestaurantTableProvider>().getAll(filter: {'IsActive': true}).then((tables) {
      if (mounted) setState(() => _tables = tables);
    });
  }

  @override
  void dispose() {
    for (final c in [_guestName, _phone, _email, _partySize, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(now) ? now : _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
      helpText: 'Reservation date',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time, helpText: 'Arrival time');
    if (picked != null) setState(() => _time = picked);
  }

  static String _durationLabel(int minutes) =>
      minutes < 60 ? '$minutes min' : '${minutes ~/ 60} h${minutes % 60 == 0 ? '' : ' ${minutes % 60} min'}';

  String? _validateTimes() {
    if (_server['StartTime'] != null) return _server['StartTime'];
    final startChanged = !_editing || !_start.isAtSameMomentAs(widget.reservation!.startTime);
    if (startChanged && _start.isBefore(DateTime.now())) return 'Start time must be in the future.';
    return null;
  }

  @override
  Widget build(BuildContext _) {
    // An edited reservation keeps its own length even if it is not one of the presets.
    final durations = {..._durations, _duration}.toList()..sort();

    return FormDialog(
      title: _editing ? 'Edit reservation' : 'New reservation',
      formKey: _formKey,
      serverErrors: _server,
      width: 620,
      onSave: () async {
        final request = {
          'tableId': _tableId,
          'guestName': _guestName.text.trim(),
          'guestPhone': _phone.text.trim(),
          'guestEmail': _email.text.trim(),
          'partySize': int.parse(_partySize.text.trim()),
          'startTime': _start.toUtc().toIso8601String(),
          'endTime': _start.add(Duration(minutes: _duration)).toUtc().toIso8601String(),
          'note': _note.text.trim(),
        };
        final provider = context.read<ReservationProvider>();
        final saved = _editing ? await provider.update(widget.reservation!.id, request) : await provider.insert(request);
        if (!mounted) return;
        Navigator.pop(context, true);
        showSuccess(
          context,
          _editing
              ? 'The reservation for ${saved.guestName} was updated.'
              : 'Reservation for ${saved.guestName} at table ${saved.tableNumber} on ${Formatters.dateTime(saved.startTime)} was created. Confirm it to notify the guest.',
        );
      },
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _guestName,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Guest name'),
                validator: (value) => _server['GuestName'] ?? Validators.length(value, 'Guest name', min: 2, max: 100),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _partySize,
                decoration: const InputDecoration(labelText: 'Guests'),
                validator: (value) => _server['PartySize'] ?? Validators.integer(value, 'Party size', min: 1, max: 20),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone', hintText: '+387 61 123 456'),
                validator: (value) => _server['GuestPhone'] ?? Validators.phone(value, isRequired: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  helperText: 'The guest gets a confirmation email',
                ),
                validator: (value) => _server['GuestEmail'] ?? Validators.email(value, isRequired: false),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FormField<DateTime>(
                validator: (_) => _validateTimes(),
                builder: (field) => InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      errorText: field.errorText,
                    ),
                    child: Text(Formatters.date(_date)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Arrival time', prefixIcon: Icon(Icons.schedule)),
                  child: Text(_time.format(context)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _duration,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: durations.map((d) => DropdownMenuItem(value: d, child: Text(_durationLabel(d)))).toList(),
                onChanged: (value) => setState(() => _duration = value!),
                validator: (_) => _server['EndTime'],
              ),
            ),
          ],
        ),
        DropdownButtonFormField<int>(
          key: ValueKey(_tables.length),
          initialValue: _tableId,
          decoration: const InputDecoration(
            labelText: 'Table',
            helperText: 'Overlapping reservations and capacity are checked when saving',
          ),
          items: _tables
              .map((t) => DropdownMenuItem(value: t.id, child: Text('Table ${t.number} · ${t.capacity} seats · ${t.areaName}')))
              .toList(),
          onChanged: (value) => setState(() => _tableId = value),
          validator: (value) => _server['TableId'] ?? (value == null ? 'Table is required.' : null),
        ),
        TextFormField(
          controller: _note,
          maxLines: 2,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Note (optional)', hintText: 'e.g. Birthday, needs a high chair'),
          validator: (value) => _server['Note'] ?? Validators.length(value, 'Note', max: 500, isRequired: false),
        ),
      ],
    );
  }
}
