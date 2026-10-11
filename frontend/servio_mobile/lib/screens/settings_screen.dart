import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';
import 'onboarding_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';

/// The waiter's settings: app language, account and help.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _open(BuildContext context, Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  Future<void> _logout(BuildContext context) async {
    final confirmed = await confirmAction(context, title: l10n.logout, message: l10n.logoutQuestion, confirmLabel: l10n.logout);
    if (confirmed && context.mounted) await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: GradientAppBar(title: l10n.settings, subtitle: user?.fullName),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: l10n.language,
            icon: Icons.language,
            children: [
              const LanguagePicker(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(l10n.languageHint, style: const TextStyle(color: ServioColors.textMuted)),
              ),
            ],
          ),
          _Section(
            title: l10n.account,
            icon: Icons.person_outline,
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(l10n.myProfileMenu),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, const ProfileScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(l10n.orderHistory),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, const OrderHistoryScreen()),
              ),
            ],
          ),
          _Section(
            title: l10n.help,
            icon: Icons.help_outline,
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l10n.waiterGuide),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, OnboardingScreen(onDone: () => Navigator.of(context).pop())),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: ServioColors.danger,
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: ServioColors.danger),
            ),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: ServioColors.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    ),
  );
}
