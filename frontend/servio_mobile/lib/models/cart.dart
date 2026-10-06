import 'package:flutter/foundation.dart';
import 'package:servio_shared/servio_shared.dart';

class CartLine {
  CartLine(this.item);

  final MenuItem item;
  int quantity = 1;
  String? note;

  double get lineTotal => item.price * quantity;
}

/// The round of items the waiter is building before sending it to the kitchen and bar,
/// plus every suggestion that was shown while building it.
class Cart extends ChangeNotifier {
  Cart({required this.taxRate});

  /// VAT included in the prices, in percent, e.g. 17.
  final double taxRate;

  final List<CartLine> _lines = [];
  final List<(Recommendation, int)> _shown = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  int get itemCount => _lines.fold(0, (sum, line) => sum + line.quantity);
  List<int> get menuItemIds => [for (final line in _lines) line.item.id];

  /// Menu prices include VAT, so the total is simply the sum of the items.
  double get total => _round(_lines.fold(0.0, (sum, line) => sum + line.lineTotal));

  int quantityOf(int menuItemId) => _lines.where((line) => line.item.id == menuItemId).firstOrNull?.quantity ?? 0;

  /// Adds one of [item]; returns true when it is new in the cart.
  bool add(MenuItem item) {
    final existing = _lines.where((line) => line.item.id == item.id).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _lines.add(CartLine(item));
    }
    notifyListeners();
    return existing == null;
  }

  void setQuantity(CartLine line, int quantity) {
    if (quantity <= 0) {
      _lines.remove(line);
    } else {
      line.quantity = quantity.clamp(1, 50);
    }
    notifyListeners();
  }

  void setNote(CartLine line, String? note) {
    line.note = note == null || note.trim().isEmpty ? null : note.trim();
    notifyListeners();
  }

  void remove(CartLine line) {
    _lines.remove(line);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  /// Remembers that [recommendation] was suggested for [sourceMenuItemId]; the server decides whether it was accepted.
  void recordShown(int sourceMenuItemId, Recommendation recommendation) {
    final alreadyShown = _shown.any((x) => x.$2 == sourceMenuItemId && x.$1.menuItemId == recommendation.menuItemId);
    if (!alreadyShown) _shown.add((recommendation, sourceMenuItemId));
  }

  List<Map<String, dynamic>> get itemsRequest => [
    for (final line in _lines) {'menuItemId': line.item.id, 'quantity': line.quantity, 'note': line.note},
  ];

  List<Map<String, dynamic>> get shownRecommendationsRequest => [
    for (final (recommendation, sourceId) in _shown)
      {
        'sourceMenuItemId': sourceId,
        'recommendedMenuItemId': recommendation.menuItemId,
        'score': double.parse(recommendation.score.clamp(0, 1).toStringAsFixed(4)),
        'reason': recommendation.reason.length > 200 ? recommendation.reason.substring(0, 200) : recommendation.reason,
      },
  ];

  static double _round(double value) => (value * 100).roundToDouble() / 100;
}
