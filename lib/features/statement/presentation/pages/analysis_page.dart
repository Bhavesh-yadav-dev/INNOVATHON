import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/statement_calculations.dart';
import '../../domain/entities/statement_entity.dart';

/// A pushed route that displays analysis for the statement supplied by Home.
class AnalysisPage extends StatefulWidget {
  /// Creates an analysis route for [statement].
  const AnalysisPage({super.key, required this.statement});

  /// The exact statement selected or uploaded on the Home route.
  final StatementEntity? statement;

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final summary = StatementCalculations.summary(widget.statement);
    final categories = StatementCalculations.categories(widget.statement);
    final selected = _selectedIndex == null ? null : categories[_selectedIndex!];
    return Scaffold(
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new), tooltip: 'Back'), const SizedBox(width: 8), const Text('✦ Your Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 20), _cards(summary), const SizedBox(height: 24),
          const Text.rich(TextSpan(children: [TextSpan(text: 'Spending ', style: TextStyle(fontWeight: FontWeight.w300, color: AppColors.muted, fontSize: 30)), TextSpan(text: 'by category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30))])),
          const SizedBox(height: 18), Center(child: _CategoryRing(categories: categories, selectedIndex: _selectedIndex, onSelect: (index) => setState(() => _selectedIndex = _selectedIndex == index ? null : index))),
          if (categories.isEmpty) const Center(child: Padding(padding: EdgeInsets.only(bottom: 14), child: Text('Upload a .csv statement to get started.', style: TextStyle(color: AppColors.muted)))),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: List.generate(categories.length, (index) => ChoiceChip(label: Text(categories[index].category), selected: _selectedIndex == index, selectedColor: AppColors.yellow, onSelected: (_) => setState(() => _selectedIndex = _selectedIndex == index ? null : index)))),
          const SizedBox(height: 18), _detail(selected),
        ])),
      ))),
    );
  }

  Widget _cards(SummaryEntity summary) => GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2, children: [
    _AnalysisCard('Money\nreceived', _money(summary.moneyReceived), AppColors.yellow, AppColors.ink),
    _AnalysisCard('Total\nspend', _money(summary.totalSpend), AppColors.ink, Colors.white),
    _AnalysisCard('Net cash\nflow', _money(summary.netCashFlow), AppColors.ink, summary.netCashFlow < 0 ? AppColors.red : AppColors.yellow),
    _AnalysisCard('Trans-\nactions', '${summary.transactionCount}', AppColors.pink, AppColors.ink),
  ]);

  Widget _detail(CategorySpendEntity? category) {
    if (category == null) return _panel(const Text('Tap a slice to see all its transactions.', style: TextStyle(color: Colors.white70)));
    final merchants = category.merchantTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Paid for ${category.category} · ${category.percent.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
      ...merchants.map((entry) => Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [Expanded(child: Text(entry.key, style: const TextStyle(color: Colors.white70))), Text(_money(entry.value), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]))),
    ]));
  }

  Widget _panel(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(28)), child: child);
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard(this.label, this.value, this.background, this.foreground);
  final String label;
  final String value;
  final Color background;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(28)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: foreground.withValues(alpha: .72))), Text(value, style: TextStyle(color: foreground, fontSize: 23, fontWeight: FontWeight.w700))]));
}

class _CategoryRing extends StatelessWidget {
  const _CategoryRing({required this.categories, required this.selectedIndex, required this.onSelect});
  final List<CategorySpendEntity> categories;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(0, (sum, item) => sum + item.total);
    return SizedBox(width: 240, height: 240, child: Stack(alignment: Alignment.center, children: [
      SizedBox(width: 190, height: 190, child: CircularProgressIndicator(value: total == 0 ? 0 : 1, strokeWidth: 34, color: AppColors.yellow, backgroundColor: AppColors.line)),
      Text(selectedIndex == null ? _money(total) : _money(categories[selectedIndex!].total), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
    ]));
  }
}

String _money(double amount) => '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}';
