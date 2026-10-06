import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../models/cart.dart';
import '../widgets/cart_sheet.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/upsell_dialog.dart';

/// Builds one round of items for a table: a new order ([guestCount] set) or more items for [order].
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.tableId, required this.tableNumber, this.guestCount, this.order})
    : assert((guestCount == null) != (order == null), 'Either start a new order or add to an existing one.');

  final int tableId;
  final int tableNumber;
  final int? guestCount;
  final Order? order;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final _menu = context.read<MenuItemProvider>();

  List<MenuItem>? _items;
  List<MenuCategory> _categories = [];
  Cart? _cart;
  String _currency = '';
  Object? _error;

  /// null = favorites.
  int? _categoryId;
  String _search = '';
  bool _searching = false;
  bool _sending = false;

  /// Items whose suggestions were already offered in this round, so the dialog is not repeated.
  final _suggestedFor = <int>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cart?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final settings = context.read<SettingsProvider>().get();
      final categories = context.read<MenuCategoryProvider>().getAll();
      final items = await _menu.getAll();
      final loadedSettings = await settings;
      final loadedCategories = (await categories).where((c) => c.menuItemCount > 0).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      if (!mounted) return;
      setState(() {
        _items = items;
        _categories = loadedCategories;
        _currency = widget.order?.currencySymbol ?? loadedSettings.currencySymbol;
        if (_cart == null) {
          _cart = Cart(taxRate: widget.order?.taxRate ?? loadedSettings.taxRate);
          _cart!.addListener(() => setState(() {}));
        }
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Favorites first, then the waiter's own best sellers.
  List<MenuItem> get _favorites {
    final items = [...?_items?.where((item) => item.isFavorite || item.soldByMeCount > 0)];
    items.sort((a, b) {
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
      return b.soldByMeCount.compareTo(a.soldByMeCount);
    });
    return items.take(12).toList();
  }

  List<MenuItem> get _visible {
    final query = _search.trim().toLowerCase();
    if (query.isNotEmpty) {
      return [
        ...?_items?.where(
          (item) => item.name.toLowerCase().contains(query) || (item.description ?? '').toLowerCase().contains(query),
        ),
      ];
    }
    return _categoryId == null ? _favorites : [...?_items?.where((item) => item.categoryId == _categoryId)];
  }

  Future<void> _add(MenuItem item) async {
    final cart = _cart!;
    cart.add(item);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
          content: Text('${item.name} added (${cart.quantityOf(item.id)} in this round)'),
        ),
      );

    if (!_suggestedFor.add(item.id)) return;
    try {
      final alreadyOrdered = [...?widget.order?.items.map((x) => x.menuItemId)];
      final suggestions = await _menu.recommend(item.id, {...cart.menuItemIds, ...alreadyOrdered}.toList());
      if (!mounted || suggestions.isEmpty) return;
      for (final suggestion in suggestions) {
        cart.recordShown(item.id, suggestion);
      }
      final chosen = await showUpsellDialog(context, source: item, suggestions: suggestions, currency: _currency);
      if (!mounted || chosen == null) return;
      final menuItem = _items!.where((x) => x.id == chosen.menuItemId).firstOrNull;
      if (menuItem != null) {
        _suggestedFor.add(menuItem.id);
        cart.add(menuItem);
        showSuccess(context, '${menuItem.name} added.');
      }
    } on ApiException {
      // Suggestions are optional; ordering carries on without them.
    }
  }

  Future<void> _toggleFavorite(MenuItem item) async {
    try {
      await _menu.setFavorite(item.id, !item.isFavorite);
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _openCart() async {
    final send = await showCartSheet(context, cart: _cart!, currency: _currency, order: widget.order);
    if (send == true) await _send();
  }

  Future<void> _send() async {
    final cart = _cart!;
    if (cart.isEmpty) return;
    setState(() => _sending = true);
    try {
      final orders = context.read<OrderProvider>();
      final order = widget.order == null
          ? await orders.create(widget.tableId, widget.guestCount!, cart.itemsRequest, cart.shownRecommendationsRequest)
          : await orders.addItems(widget.order!.id, cart.itemsRequest, cart.shownRecommendationsRequest);
      if (!mounted) return;
      final stations = {for (final ticket in order.tickets) ticket.stationName.toLowerCase()};
      showSuccess(context, 'Order sent to the ${stations.join(' and ')}.');
      cart.clear();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<bool> _confirmLeave() async {
    if (_cart == null || _cart!.isEmpty) return true;
    return confirmAction(
      context,
      title: 'Discard this round?',
      message: 'The ${_cart!.itemCount} items in the cart have not been sent yet.',
      confirmLabel: 'Discard',
      destructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    final count = cart?.itemCount ?? 0;

    return PopScope(
      canPop: cart == null || cart.isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmLeave()) {
          cart?.clear();
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: GradientAppBar(
          title: 'Table ${widget.tableNumber}',
          subtitle: widget.order == null
              ? '${widget.guestCount} guests · $count items'
              : 'Adding to ${widget.order!.orderNumber} · $count items',
          actions: [
            HeaderButton(
              icon: _searching ? Icons.search_off : Icons.search,
              tooltip: _searching ? 'Close search' : 'Search the menu',
              onPressed: () => setState(() {
                _searching = !_searching;
                _search = '';
              }),
            ),
            HeaderButton(
              icon: Icons.shopping_cart_outlined,
              tooltip: 'Current order',
              badge: count,
              onPressed: cart == null ? () {} : _openCart,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_searching ? 64 : 56),
            child: Container(
              color: const Color(0xFF1F2937),
              height: _searching ? 64 : 56,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: _searching
                  ? TextField(
                      autofocus: true,
                      onChanged: (value) => setState(() => _search = value),
                      decoration: const InputDecoration(
                        hintText: 'Search by name or description',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryTab(
                          label: 'Favorites',
                          icon: Icons.star,
                          selected: _categoryId == null,
                          onTap: () => setState(() => _categoryId = null),
                        ),
                        for (final category in _categories)
                          _CategoryTab(
                            label: category.name,
                            selected: _categoryId == category.id,
                            onTap: () => setState(() => _categoryId = category.id),
                          ),
                      ],
                    ),
            ),
          ),
        ),
        body: _error != null && _items == null
            ? ErrorView(error: _error!, onRetry: _load)
            : _items == null
            ? const LoadingView()
            : _buildItems(),
        bottomNavigationBar: count == 0
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _sending ? null : _openCart,
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_cart_outlined),
                          const SizedBox(width: 10),
                          Text('$count items', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                            _sending ? 'Sending…' : 'Review · ${Formatters.money(cart!.total, _currency)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildItems() {
    final items = _visible;
    final showingFavorites = _categoryId == null && _search.trim().isEmpty;

    return CustomScrollView(
      slivers: [
        if (showingFavorites)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFFACC15)),
                      SizedBox(width: 8),
                      Text('Favorites', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your starred and most sold items · Updates based on your sales',
                    style: TextStyle(color: ServioColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              icon: showingFavorites ? Icons.star_border : Icons.search_off,
              message: showingFavorites
                  ? 'No favorites yet. Tap the star on any item to pin it here; your best sellers appear automatically.'
                  : 'No items found.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 166,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return _MenuItemCard(
                  item: item,
                  currency: _currency,
                  inCart: _cart?.quantityOf(item.id) ?? 0,
                  imageUrl: _menu.imageUrl(item.id),
                  onTap: item.isAvailableToday && !_sending ? () => _add(item) : null,
                  onFavorite: () => _toggleFavorite(item),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Material(
      color: selected ? ServioColors.primary : const Color(0xFF374151),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, color: const Color(0xFFFACC15), size: 20), const SizedBox(width: 6)],
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.item,
    required this.currency,
    required this.inCart,
    required this.imageUrl,
    required this.onTap,
    required this.onFavorite,
  });

  final MenuItem item;
  final String currency;
  final int inCart;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final available = item.isAvailableToday;
    return Opacity(
      opacity: available ? 1 : 0.55,
      child: Material(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: inCart > 0 ? const BorderSide(color: ServioColors.primary, width: 2) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthImage(url: imageUrl, headers: context.read<ApiClient>().authHeaders, hasImage: item.hasImage, size: 52),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: item.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      onPressed: onFavorite,
                      icon: Icon(
                        item.isFavorite ? Icons.star : Icons.star_border,
                        color: item.isFavorite ? const Color(0xFFFACC15) : ServioColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Formatters.money(item.price, currency),
                        style: const TextStyle(color: ServioColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (!available)
                      const _Pill('Sold out', ServioColors.dangerLight, ServioColors.danger)
                    else if (inCart > 0)
                      _Pill('×$inCart', ServioColors.primary, Colors.white)
                    else if (item.soldByMeCount > 0)
                      _Pill('${item.soldByMeCount} sold', const Color(0xFFFACC15), ServioColors.textPrimary),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.background, this.foreground);

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
    child: Text(
      text,
      style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );
}
