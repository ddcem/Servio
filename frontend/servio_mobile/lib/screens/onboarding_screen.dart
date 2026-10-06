import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The waiter guide shown on first launch; it can be reopened from the tables screen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  static const seenKey = 'waiter_guide_seen';

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  static const _steps = [
    (
      'Select Tables',
      'Choose from available tables with capacity and status tracking. Green means available, red means occupied.',
      _Illustration.tables,
    ),
    (
      'Take Orders',
      'Browse the menu by category. Your favorites and best sellers are one tap away, and items sold out today are greyed out.',
      _Illustration.menu,
    ),
    (
      'Smart Suggestions',
      'After you add an item, Servio suggests what usually goes with it, based on what guests order together.',
      _Illustration.suggestion,
    ),
    (
      'Serve & Get Paid',
      'You are notified when the kitchen or bar has an order ready. Take payment in cash or by card through PayPal, with a tip.',
      _Illustration.payment,
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<SharedPreferences>().setBool(OnboardingScreen.seenKey, true);
    widget.onDone();
  }

  void _next() {
    if (_index == _steps.length - 1) {
      _finish();
    } else {
      _pages.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ServioColors.primary, Color(0xFF1E40AF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.grid_view_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Waiter Guide',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (index) => setState(() => _index = index),
                  children: [
                    for (final (title, text, illustration) in _steps)
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            _IllustrationView(illustration),
                            const SizedBox(height: 40),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: const Color(0xFFF3F4FA), borderRadius: BorderRadius.circular(18)),
                              child: Column(
                                children: [
                                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF4B5563)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ServioColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _next,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _index == _steps.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

enum _Illustration { tables, menu, suggestion, payment }

class _IllustrationView extends StatelessWidget {
  const _IllustrationView(this.kind);

  final _Illustration kind;

  @override
  Widget build(BuildContext context) => switch (kind) {
    _Illustration.tables => Wrap(
      spacing: 14,
      runSpacing: 14,
      alignment: WrapAlignment.center,
      children: [
        for (final (number, seats, color) in [
          (1, 2, ServioColors.available),
          (2, 4, ServioColors.occupied),
          (3, 2, ServioColors.available),
          (4, 6, ServioColors.reserved),
          (5, 4, ServioColors.available),
          (6, 4, ServioColors.occupied),
        ])
          Container(
            width: 92,
            height: 80,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$number',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Text('$seats seats', style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
      ],
    ),
    _Illustration.menu => Wrap(
      spacing: 14,
      runSpacing: 14,
      alignment: WrapAlignment.center,
      children: [
        for (final (icon, name) in [
          (Icons.set_meal, 'Ribeye Steak'),
          (Icons.ramen_dining, 'Carbonara'),
          (Icons.local_drink, 'Coca Cola'),
          (Icons.bakery_dining, 'Bruschetta'),
        ])
          _whiteCard(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: ServioColors.primary, size: 30),
                    const Icon(Icons.star, color: Color(0xFFFACC15), size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    ),
    _Illustration.suggestion => _whiteCard(
      width: 300,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFFFACC15)),
              SizedBox(width: 8),
              Text('Upsell Suggestion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          Text('Would your guest like a drink with that?'),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.wine_bar, color: ServioColors.bar),
              SizedBox(width: 10),
              Expanded(
                child: Text('Red Wine', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Chip(label: Text('+ Add')),
            ],
          ),
        ],
      ),
    ),
    _Illustration.payment => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (icon, label, color) in [
          (Icons.payments_outlined, 'Cash', ServioColors.success),
          (Icons.credit_card, 'Card', ServioColors.primary),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _whiteCard(
              width: 130,
              child: Column(
                children: [
                  Icon(icon, color: color, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  };

  static Widget _whiteCard({required double width, required Widget child}) => Container(
    width: width,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: child,
  );
}
