import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/admin_page.dart';
import '../../widgets/form_dialog.dart';
import 'forms/reference_forms.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  final _name = TextEditingController();
  final _taxRate = TextEditingController();
  int? _currencyId;
  List<Currency> _currencies = [];
  RestaurantSettings? _settings;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _taxRate.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([context.read<SettingsProvider>().get(), context.read<CurrencyProvider>().getAll()]);
      if (!mounted) return;
      final settings = results[0] as RestaurantSettings;
      setState(() {
        _settings = settings;
        _currencies = results[1] as List<Currency>;
        _name.text = settings.restaurantName;
        _taxRate.text = settings.taxRate.toStringAsFixed(settings.taxRate % 1 == 0 ? 0 : 2);
        _currencyId = settings.currencyId;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _addCurrency() async {
    final currency = await showCurrencyForm(context);
    if (currency == null || !mounted) return;
    final currencies = await context.read<CurrencyProvider>().getAll();
    setState(() {
      _currencies = currencies;
      _currencyId = currency.id;
    });
  }

  Future<void> _save() async {
    _server.clear();
    if (!_formKey.currentState!.validate()) return;
    final confirmed = await confirmAction(
      context,
      title: 'Save settings?',
      message: 'New orders use the new VAT rate and currency. Open orders keep the values they were opened with.',
      confirmLabel: 'Save Settings',
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);
    try {
      final saved = await context.read<SettingsProvider>().update({
        'restaurantName': _name.text.trim(),
        'currencyId': _currencyId,
        'taxRate': Validators.parseDecimal(_taxRate.text),
      });
      if (!mounted) return;
      setState(() => _settings = saved);
      showSuccess(context, 'Settings saved: ${saved.restaurantName}, ${saved.currencyCode}, VAT ${_taxRate.text}%.');
    } catch (e) {
      _server.set(e);
      _formKey.currentState!.validate();
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: 'System Settings',
    subtitle: 'Configure restaurant preferences',
    child: _error != null && _settings == null
        ? ErrorView(error: _error!, onRetry: _load)
        : _settings == null
        ? const LoadingView()
        : ListView(
            padding: const EdgeInsets.all(28),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Panel(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('General Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _name,
                              maxLength: 100,
                              decoration: const InputDecoration(labelText: 'Restaurant name'),
                              validator: (value) =>
                                  _server['RestaurantName'] ?? Validators.length(value, 'Restaurant name', min: 2, max: 100),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    key: ValueKey(_currencies.length),
                                    initialValue: _currencyId,
                                    decoration: const InputDecoration(
                                      labelText: 'Currency',
                                      helperText: 'PayPal payments are charged in this currency',
                                    ),
                                    items: _currencies
                                        .map(
                                          (c) =>
                                              DropdownMenuItem(value: c.id, child: Text('${c.code} (${c.symbol}) – ${c.name}')),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(() => _currencyId = value),
                                    validator: (value) =>
                                        _server['CurrencyId'] ?? (value == null ? 'Currency is required.' : null),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: IconButton.filledTonal(
                                    tooltip: 'Add a new currency',
                                    onPressed: _addCurrency,
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _taxRate,
                              decoration: const InputDecoration(
                                labelText: 'VAT rate (%)',
                                hintText: 'e.g. 17',
                                helperText: 'Included in menu prices; receipts show how much of the total is VAT',
                              ),
                              validator: (value) => _server['TaxRate'] ?? Validators.decimal(value, 'VAT rate', min: 0, max: 100),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Last changed ${Formatters.dateTime(_settings!.updatedAt)}'
                              '${_settings!.updatedByName == null ? '' : ' by ${_settings!.updatedByName}'}',
                              style: const TextStyle(color: ServioColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 56)),
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}
