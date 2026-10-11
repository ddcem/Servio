import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

/// Suggestions after the waiter adds [source]. Returns the suggestion the waiter added, or null.
Future<Recommendation?> showUpsellDialog(
  BuildContext context, {
  required MenuItem source,
  required List<Recommendation> suggestions,
  required String currency,
}) => showDialog<Recommendation>(
  context: context,
  builder: (context) {
    final menu = context.read<MenuItemProvider>();
    final headers = context.read<ApiClient>().authHeaders;
    final hasDrink = suggestions.any((x) => x.courseType == CourseType.drink);

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      title: Row(
        children: [
          Icon(Icons.lightbulb, color: Color(0xFFFACC15)),
          SizedBox(width: 8),
          Expanded(
            child: Text(l10n.upsellSuggestion, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasDrink && source.courseType != CourseType.drink
                  ? l10n.upsellDrinkQuestion(source.name)
                  : l10n.upsellOftenAdd(source.name),
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            for (final suggestion in suggestions)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    AuthImage(
                      url: menu.imageUrl(suggestion.menuItemId),
                      headers: headers,
                      hasImage: suggestion.hasImage,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(suggestion.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                            Formatters.money(suggestion.price, currency),
                            style: const TextStyle(color: ServioColors.textMuted),
                          ),
                          Text(suggestion.reason, style: const TextStyle(color: ServioColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                      onPressed: () => Navigator.pop(context, suggestion),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.add),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: ServioColors.border, foregroundColor: ServioColors.textPrimary),
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.notNow, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  },
);
