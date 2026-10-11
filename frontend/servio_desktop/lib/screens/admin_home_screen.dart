import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import 'admin/admin_shell.dart';
import 'station/station_display_screen.dart';

/// The admin's start screen: watch the kitchen or bar, or manage the restaurant.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    // Right after logout this screen is built once more before the app returns to the login screen.
    if (user == null) return const SizedBox.shrink();

    void open(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: const [LanguageMenuButton(), SizedBox(width: 16)],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.adminDashboard,
                style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(l10n.welcomeName(user.firstName), style: const TextStyle(color: Colors.white70, fontSize: 20)),
              const SizedBox(height: 8),
              Text(l10n.chooseView, style: const TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 40),
              Wrap(
                spacing: 28,
                runSpacing: 28,
                alignment: WrapAlignment.center,
                children: [
                  _ChoiceCard(
                    icon: Icons.restaurant,
                    color: ServioColors.kitchen,
                    title: l10n.kitchenView,
                    subtitle: l10n.monitorFood,
                    onTap: () => open(const StationDisplayScreen(station: Stations.kitchen, viewOnly: true)),
                  ),
                  _ChoiceCard(
                    icon: Icons.wine_bar_outlined,
                    color: ServioColors.bar,
                    title: l10n.barView,
                    subtitle: l10n.monitorDrinks,
                    onTap: () => open(const StationDisplayScreen(station: Stations.bar, viewOnly: true)),
                  ),
                  _ChoiceCard(
                    icon: Icons.verified_user_outlined,
                    color: ServioColors.primary,
                    title: l10n.adminPanel,
                    subtitle: l10n.manageSystem,
                    onTap: () => open(const AdminShell()),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                onPressed: () => context.read<AuthProvider>().logout(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    height: 260,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: ServioColors.textMuted, fontSize: 16)),
          ],
        ),
      ),
    ),
  );
}
