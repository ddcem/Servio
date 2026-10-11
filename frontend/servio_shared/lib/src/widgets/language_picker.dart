import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/language.dart';
import '../theme/servio_colors.dart';
import 'feedback.dart';

/// The list of languages for a settings screen; the current one is checked.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageController>();
    return RadioGroup<String>(
      groupValue: language.code,
      onChanged: (code) => _select(context, code),
      child: Column(
        children: [
          for (final MapEntry(key: code, value: name) in LanguageController.names.entries)
            RadioListTile<String>(
              value: code,
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: _translatedName(code) == name ? null : Text(_translatedName(code)),
              secondary: _Flag(code),
            ),
        ],
      ),
    );
  }

  /// The language's name in the current app language: "Bosanski" is "Bosnian" in an English app.
  static String _translatedName(String code) => code == 'bs' ? l10n.languageBosnian : l10n.languageEnglish;

  static Future<void> _select(BuildContext context, String? code) async {
    if (code == null) return;
    try {
      await context.read<LanguageController>().select(code);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

/// A compact language switch for screens without a settings page, such as the login screen.
class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key, this.color = Colors.white});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageController>();
    return PopupMenuButton<String>(
      tooltip: l10n.language,
      initialValue: language.code,
      onSelected: (code) => LanguagePicker._select(context, code),
      itemBuilder: (_) => [
        for (final MapEntry(key: code, value: name) in LanguageController.names.entries)
          PopupMenuItem(value: code, child: Text(name)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              LanguageController.names[language.code]!,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            Icon(Icons.arrow_drop_down, color: color),
          ],
        ),
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag(this.code);

  final String code;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 18,
    backgroundColor: ServioColors.infoLight,
    child: Text(
      code.toUpperCase(),
      style: const TextStyle(color: ServioColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );
}
