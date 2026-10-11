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
      title: l10n.saveSettingsQuestion,
      message: l10n.saveSettingsMessage,
      confirmLabel: l10n.saveSettings,
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
      showSuccess(context, l10n.settingsSaved(saved.restaurantName, saved.currencyCode, _taxRate.text));
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
    title: l10n.systemSettings,
    subtitle: l10n.configurePreferences,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.myPreferences, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(l10n.myPreferencesHint, style: const TextStyle(color: ServioColors.textMuted)),
                          const SizedBox(height: 12),
                          Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const LanguagePicker(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Panel(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.generalSettings, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _name,
                              maxLength: 100,
                              decoration: InputDecoration(labelText: l10n.restaurantName),
                              validator: (value) =>
                                  _server['RestaurantName'] ?? Validators.length(value, l10n.restaurantName, min: 2, max: 100),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    key: ValueKey(_currencies.length),
                                    initialValue: _currencyId,
                                    decoration: InputDecoration(labelText: l10n.currency, helperText: l10n.currencyHelper),
                                    items: _currencies
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c.id,
                                            child: Text(l10n.currencyOption(c.code, c.symbol, c.name)),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(() => _currencyId = value),
                                    validator: (value) => _server['CurrencyId'] ?? (value == null ? l10n.currencyRequired : null),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: IconButton.filledTonal(
                                    tooltip: l10n.addNewCurrency,
                                    onPressed: _addCurrency,
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _taxRate,
                              decoration: InputDecoration(
                                labelText: l10n.vatRatePercent,
                                hintText: 'e.g. 17',
                                helperText: l10n.vatRateHelper,
                              ),
                              validator: (value) =>
                                  _server['TaxRate'] ?? Validators.decimal(value, l10n.vatRate, min: 0, max: 100),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _settings!.updatedByName == null
                                  ? l10n.lastChanged(Formatters.dateTime(_settings!.updatedAt))
                                  : l10n.lastChangedBy(Formatters.dateTime(_settings!.updatedAt), _settings!.updatedByName!),
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
                      label: Text(l10n.saveSettings),
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}
