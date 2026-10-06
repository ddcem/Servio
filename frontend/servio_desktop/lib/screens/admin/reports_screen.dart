import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/wide_table.dart';
import '../../widgets/admin_page.dart';

/// Sales & Analytics: today's numbers compared with yesterday, analysis of any period
/// and the two printable PDF reports.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ReportProvider _reports = context.read<ReportProvider>();

  late DateTimeRange _range = _lastDays(30);
  SalesReport? _today;
  SalesReport? _yesterday;
  int _openOrders = 0;
  SalesReport? _sales;
  StaffReport? _staff;
  Object? _error;

  static DateTimeRange _lastDays(int days) {
    final today = DateUtils.dateOnly(DateTime.now());
    return DateTimeRange(
      start: today.subtract(Duration(days: days - 1)),
      end: today,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadToday();
    _loadPeriod();
  }

  Future<void> _loadToday() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    try {
      final results = await Future.wait([
        _reports.getSales(today, today),
        _reports.getSales(yesterday, yesterday),
        context.read<OrderProvider>().getPage(filter: {'Status': 'Open'}, pageSize: 1),
      ]);
      if (!mounted) return;
      setState(() {
        _today = results[0] as SalesReport;
        _yesterday = results[1] as SalesReport;
        _openOrders = (results[2] as PagedResult<Order>).totalCount;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _loadPeriod() async {
    setState(() {
      _sales = null;
      _staff = null;
    });
    try {
      final results = await Future.wait([
        _reports.getSales(_range.start, _range.end),
        _reports.getStaff(_range.start, _range.end),
      ]);
      if (!mounted) return;
      setState(() {
        _sales = results[0] as SalesReport;
        _staff = results[1] as StaffReport;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _pickRange() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final range = await showDateRangePicker(
      context: context,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today,
      initialDateRange: _range,
      helpText: 'Report period',
    );
    if (range != null) {
      setState(() => _range = range);
      await _loadPeriod();
    }
  }

  Future<void> _exportPdf({required bool sales, required bool print}) async {
    final name = sales ? 'sales' : 'staff';
    final fileName =
        'servio-$name-report-${DateFormat('yyyyMMdd').format(_range.start)}-${DateFormat('yyyyMMdd').format(_range.end)}.pdf';
    try {
      final Uint8List bytes = sales
          ? await _reports.getSalesPdf(_range.start, _range.end)
          : await _reports.getStaffPdf(_range.start, _range.end);
      if (print) {
        await Printing.layoutPdf(name: fileName, onLayout: (_) async => bytes);
        return;
      }
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );
      if (location == null) return;
      await XFile.fromData(bytes, mimeType: 'application/pdf', name: fileName).saveTo(location.path);
      if (mounted) showSuccess(context, 'The ${sales ? 'sales' : 'staff performance'} report was saved to ${location.path}.');
    } catch (e) {
      if (mounted) showError(context, e is ApiException ? e : ApiException('The report could not be saved: $e'));
    }
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: 'Sales & Analytics',
    subtitle: 'Track performance and revenue metrics',
    actions: [
      _PdfMenu(
        label: 'Sales report',
        onSelected: (print) => _exportPdf(sales: true, print: print),
      ),
      _PdfMenu(
        label: 'Staff report',
        onSelected: (print) => _exportPdf(sales: false, print: print),
      ),
    ],
    child: _error != null && _today == null
        ? ErrorView(
            error: _error!,
            onRetry: () {
              _loadToday();
              _loadPeriod();
            },
          )
        : ListView(
            padding: const EdgeInsets.all(28),
            children: [
              _buildToday(),
              const SizedBox(height: 32),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                children: [
                  const Text('Period analysis', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _pickRange,
                    icon: const Icon(Icons.date_range),
                    label: Text('${Formatters.date(_range.start)} – ${Formatters.date(_range.end)}'),
                  ),
                  const SizedBox(width: 8),
                  for (final days in [7, 30, 90])
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: TextButton(
                        onPressed: () {
                          setState(() => _range = _lastDays(days));
                          _loadPeriod();
                        },
                        child: Text('Last $days days'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_sales == null || _staff == null) const LoadingView() else _buildPeriod(_sales!, _staff!),
            ],
          ),
  );

  Widget _buildToday() {
    final today = _today;
    final yesterday = _yesterday;
    if (today == null || yesterday == null) return const LoadingView();
    final s = today.currencySymbol;

    String change(double now, double before, String suffix) {
      if (before == 0) return now == 0 ? 'Same as $suffix' : 'First sales compared to $suffix';
      final percent = ((now - before) / before * 100).round();
      return '${percent >= 0 ? '+' : ''}$percent% from $suffix';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _KpiCard(
              colors: const [Color(0xFF3B82F6), ServioColors.primary],
              icon: Icons.attach_money,
              label: "Today's revenue",
              value: Formatters.money(today.revenue, s),
              footer: change(today.revenue, yesterday.revenue, 'yesterday'),
            ),
            _KpiCard(
              colors: const [Color(0xFF22C55E), ServioColors.success],
              icon: Icons.inventory_2_outlined,
              label: 'Paid orders',
              value: '${today.orderCount}',
              footer: '$_openOrders active now',
            ),
            _KpiCard(
              colors: const [Color(0xFFA855F7), ServioColors.bar],
              icon: Icons.trending_up,
              label: 'Average bill',
              value: Formatters.money(today.averageBill, s),
              footer: change(today.averageBill, yesterday.averageBill, 'yesterday'),
            ),
            _KpiCard(
              colors: const [Color(0xFFF97316), ServioColors.kitchen],
              icon: Icons.people_outline,
              label: 'Guests',
              value: '${today.guestCount}',
              footer: '${today.orderCount} tables served',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Popular items today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (today.topItems.isEmpty) const Text('No sales yet today.', style: TextStyle(color: ServioColors.textMuted)),
              for (final item in today.topItems.take(5)) _ItemRow(item: item, symbol: s),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriod(SalesReport sales, StaffReport staff) {
    final s = sales.currencySymbol;
    String money(double v) => Formatters.money(v, s);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _Metric('Revenue', money(sales.revenue)),
            _Metric('Net revenue (after refunds)', money(sales.netRevenue)),
            _Metric('Paid orders', '${sales.orderCount}'),
            _Metric('Average bill', money(sales.averageBill)),
            _Metric('Guests', '${sales.guestCount}'),
            _Metric('Tips', money(sales.tips)),
            _Metric('Refunds', money(sales.refunds)),
            _Metric('Cancelled orders', '${sales.cancelledOrderCount}'),
          ],
        ),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily revenue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: _RevenueChart(daily: sales.daily, symbol: s),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Best-selling items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final item in sales.topItems) _ItemRow(item: item, symbol: s),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Least-selling items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Candidates for a promotion or removal', style: TextStyle(color: ServioColors.textMuted)),
                        const SizedBox(height: 8),
                        for (final item in sales.leastSoldItems) _ItemRow(item: item, symbol: s, highlight: ServioColors.danger),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sales by category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (final c in sales.categories) _LabelValue(c.categoryName, '${c.quantity} sold · ${money(c.revenue)}'),
                        const Divider(height: 24),
                        const Text('Payments by method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        for (final p in sales.paymentMethods)
                          _LabelValue(p.paymentMethod, '${p.paymentCount} payments · ${money(p.amount)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Staff performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              WideTable(
                child: DataTable(
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: ServioColors.textMuted),
                  columns: const [
                    DataColumn(label: Text('WAITER')),
                    DataColumn(label: Text('ORDERS'), numeric: true),
                    DataColumn(label: Text('REVENUE'), numeric: true),
                    DataColumn(label: Text('AVG. BILL'), numeric: true),
                    DataColumn(label: Text('TIPS'), numeric: true),
                    DataColumn(label: Text('SUGGESTIONS ACCEPTED'), numeric: true),
                  ],
                  rows: [
                    for (final w in staff.waiters)
                      DataRow(
                        cells: [
                          DataCell(Text(w.isActive ? w.name : '${w.name} (inactive)')),
                          DataCell(Text('${w.orderCount}')),
                          DataCell(Text(money(w.revenue))),
                          DataCell(Text(money(w.averageBill))),
                          DataCell(Text(money(w.tips))),
                          DataCell(
                            Text(
                              w.suggestionAcceptanceRate == null
                                  ? '–'
                                  : '${Formatters.percent(w.suggestionAcceptanceRate!)} of ${w.suggestionsShown}',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final st in staff.stations)
                    _Metric(
                      '${st.stationName}: ${st.ticketCount} tickets',
                      st.averageMinutesToReady == null ? '–' : '${st.averageMinutesToReady!.toStringAsFixed(1)} min to ready',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PdfMenu extends StatelessWidget {
  const _PdfMenu({required this.label, required this.onSelected});

  final String label;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton<bool>(
    tooltip: '$label (PDF) for the selected period',
    onSelected: onSelected,
    itemBuilder: (_) => const [
      PopupMenuItem(
        value: false,
        child: ListTile(leading: Icon(Icons.download), title: Text('Save as PDF')),
      ),
      PopupMenuItem(
        value: true,
        child: ListTile(leading: Icon(Icons.print_outlined), title: Text('Print')),
      ),
    ],
    child: IgnorePointer(
      child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf_outlined), label: Text(label)),
    ),
  );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.colors, required this.icon, required this.label, required this.value, required this.footer});

  final List<Color> colors;
  final IconData icon;
  final String label;
  final String value;
  final String footer;

  @override
  Widget build(BuildContext context) => Container(
    width: 290,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
    ),
    child: DefaultTextStyle(
      style: const TextStyle(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ),
              Icon(icon, color: Colors.white, size: 32),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(footer, style: const TextStyle(fontSize: 15, color: Colors.white70)),
        ],
      ),
    ),
  );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.symbol, this.highlight = ServioColors.success});

  final ItemSales item;
  final String symbol;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: ServioColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          AuthImage(
            url: context.read<MenuItemProvider>().imageUrl(item.menuItemId),
            headers: api.authHeaders,
            hasImage: item.hasImage,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${item.quantity} sold · ${item.categoryName}',
                  style: const TextStyle(color: ServioColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            Formatters.money(item.revenue, symbol),
            style: TextStyle(color: highlight, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: ServioColors.textMuted, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.daily, required this.symbol});

  final List<DailySales> daily;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final maxRevenue = daily.fold<double>(0, (max, d) => d.revenue > max ? d.revenue : max);
    final labelEvery = (daily.length / 8).ceil().clamp(1, 1000);

    return BarChart(
      BarChartData(
        maxY: maxRevenue == 0 ? 100 : maxRevenue * 1.15,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${Formatters.date(daily[group.x].date)}\n${Formatters.money(rod.toY, symbol)} · ${daily[group.x].orderCount} orders',
              const TextStyle(color: Colors.white),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) => Text('$symbol${value.round()}', style: const TextStyle(fontSize: 11)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index % labelEvery != 0 || index >= daily.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('dd.MM').format(daily[index].date), style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < daily.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: daily[i].revenue,
                  width: daily.length > 60 ? 4 : 12,
                  color: ServioColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
