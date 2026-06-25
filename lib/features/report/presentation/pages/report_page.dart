import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/core/utils/currency_helper.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/features/billing/domain/entities/invoice.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime _selectedFrom = DateTime.now().subtract(const Duration(days: 7));
  DateTime _selectedTo = DateTime.now();

  List<Invoice> _invoices = [];
  double _totalRevenue = 0;
  double _totalExpense = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final allInvoices = HiveDatabase.invoicesBox.values.toList();
    final filtered = allInvoices.where((m) =>
        m.createdAt.isAfter(_selectedFrom.subtract(const Duration(days: 1))) &&
        m.createdAt.isBefore(_selectedTo.add(const Duration(days: 1))));
    final revenue =
        filtered.fold<double>(0, (sum, m) => sum + m.totalAmount);

    setState(() {
      _invoices = filtered.map((m) => m.toEntity([])).toList();
      _totalRevenue = revenue;
      _totalExpense = 0;
      _loading = false;
    });
  }

  double get _netProfit => _totalRevenue - _totalExpense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(),
                  const SizedBox(height: 24),
                  _buildDateFilter(),
                  const SizedBox(height: 24),
                  _buildRevenueChart(),
                  const SizedBox(height: 24),
                  _buildExpensePieChart(),
                  const SizedBox(height: 24),
                  _buildTopProducts(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _SummaryCard(
          title: AppLocalizations.of(context)!.revenue,
          amount: _totalRevenue,
          color: Colors.green,
          icon: Icons.trending_up,
        ),
        const SizedBox(width: 12),
        _SummaryCard(
          title: AppLocalizations.of(context)!.expenses,
          amount: _totalExpense,
          color: Colors.red,
          icon: Icons.trending_down,
        ),
        const SizedBox(width: 12),
        _SummaryCard(
          title: AppLocalizations.of(context)!.profit,
          amount: _netProfit,
          color: AppTheme.primaryColor,
          icon: Icons.account_balance,
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Row(
      children: [
        _DateChip(AppLocalizations.of(context)!.today, () => _setDateRange(
            DateTime.now(), DateTime.now())),
        const SizedBox(width: 8),
        _DateChip(AppLocalizations.of(context)!.thisWeek, () => _setDateRange(
            DateTime.now().subtract(const Duration(days: 7)),
            DateTime.now())),
        const SizedBox(width: 8),
        _DateChip(AppLocalizations.of(context)!.thisMonth, () => _setDateRange(
            DateTime(DateTime.now().year, DateTime.now().month, 1),
            DateTime.now())),
      ],
    );
  }

  void _setDateRange(DateTime from, DateTime to) {
    setState(() {
      _selectedFrom = from;
      _selectedTo = to;
      _loading = true;
    });
    _loadData();
  }

  Widget _buildRevenueChart() {
    final maxY = _totalRevenue > 0 ? _totalRevenue * 1.2 : 1000000.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.revenue,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: _totalRevenue > 0 ? _totalRevenue / 7 * (i + 1) : 500000 + (i * 50000.0),
                        color: AppTheme.primaryColor,
                        width: 20,
                      ),
                    ]);
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormat.compact().format(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = [
                            'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(days[value.toInt()],
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePieChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.expensesByCategory,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _totalExpense > 0
                      ? _buildPieSections()
                      : [
                          PieChartSectionData(
                            value: 100,
                            title: AppLocalizations.of(context)!.noData,
                            color: Colors.grey[300]!,
                            radius: 50,
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return [
      PieChartSectionData(
          value: 40, title: 'Materials',
          color: Colors.orange, radius: 50),
      PieChartSectionData(
          value: 25, title: 'Labor',
          color: Colors.blue, radius: 50),
      PieChartSectionData(
          value: 20, title: 'Utilities',
          color: Colors.green, radius: 50),
      PieChartSectionData(
          value: 15, title: 'Other',
          color: Colors.grey, radius: 50),
    ];
  }

  Widget _buildTopProducts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.topProducts,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_invoices.isEmpty)
              ListTile(
                  leading: const Icon(Icons.inventory), title: Text(AppLocalizations.of(context)!.noData))
            else
              ...(_invoices.length > 5 ? _invoices.sublist(0, 5) : _invoices)
                  .map((inv) => ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: Text('Order #${inv.id.substring(0, 6)}'),
                        trailing: Text(CurrencyHelper.format(inv.totalAmount)),
                      )),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title, required this.amount,
    required this.color, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(CurrencyHelper.format(amount),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
