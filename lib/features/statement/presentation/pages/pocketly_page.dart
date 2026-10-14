import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/statement_api.dart';
import '../../domain/entities/statement_calculations.dart';
import '../../domain/entities/statement_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import 'analysis_page.dart';

/// Pocketly home dashboard and analysis view. It deliberately uses only local
/// StatefulWidget variables, not an application state-management package.
class PocketlyPage extends StatefulWidget {
  /// Creates Pocketly's main experience.
  const PocketlyPage({super.key});

  @override
  State<PocketlyPage> createState() => _PocketlyPageState();
}

class _PocketlyPageState extends State<PocketlyPage> {
  final StatementApi _api = StatementApi();
  final StatementCache _cache = StatementCache();
  StatementEntity? _statement;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedStatement();
  }

  Future<void> _loadSavedStatement() async {
    final saved = await _cache.load();
    if (mounted && saved != null) setState(() => _statement = saved);
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: const ['csv']);
    if (result == null || result.files.single.path == null) return;
    setState(() => _isUploading = true);
    try {
      final statement = await _api.importCsv(File(result.files.single.path!));
      await _cache.save(statement);
      if (!mounted) return;
      setState(() => _statement = statement);
      if (mounted) _openAnalysis(statement);
    } on StatementApiException catch (error) {
      _toast(error.message);
    } catch (_) {
      _toast('The statement could not be imported.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.ink, behavior: SnackBarBehavior.floating));

  void _openAnalysis(StatementEntity? statement) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AnalysisPage(statement: statement)));

  @override
  Widget build(BuildContext context) {
    final summary = StatementCalculations.summary(_statement);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: _home(summary),
          ),
        ),
      ),
    );
  }

  Widget _home(SummaryEntity summary) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _circleButton(Icons.person_outline, AppColors.pink, 'Profile and settings', _settings),
        const SizedBox(width: 12), const _Brand(label: 'Pocketly'),
      ]),
      const SizedBox(height: 20), const _TwoToneTitle(first: 'Money', second: 'Overview'), const SizedBox(height: 18),
      _statGrid(summary), const SizedBox(height: 18),
      _Pressable(onTap: () => _openAnalysis(_statement), child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 19), decoration: const ShapeDecoration(color: AppColors.yellow, shape: StadiumBorder()),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Detail Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink)), SizedBox(width: 10), Icon(Icons.arrow_forward, color: AppColors.ink)]),
      )),
      const SizedBox(height: 18),
      _Pressable(onTap: _isUploading ? null : _pickAndUpload, child: Container(
        padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.ink, borderRadius: BorderRadius.circular(28)),
        child: Row(children: [
          const CircleAvatar(radius: 24, backgroundColor: AppColors.yellow, child: Icon(Icons.upload_outlined, color: AppColors.ink)), const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Upload transaction statement', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 3),
            Text(_isUploading ? 'Importing your statement…' : _statement == null ? '.csv format · tap to choose a file' : '${_statement!.fileName} · imported ${_shortDate(_statement!.importedAt)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ])), if (_isUploading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.yellow, strokeWidth: 2)),
        ]),
      )),
    ]),
  );

  // ignore: unused_element
  Widget _detailPanel(CategorySpendEntity? category) {
    if (category == null) {
      return _detailContainer(const Text('Tap a slice to see all its transactions.', style: TextStyle(color: Colors.white70)));
    }
    final merchants = category.merchantTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _detailContainer(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Paid for ${category.category} · ${category.percent.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)), const SizedBox(height: 8),
      ...merchants.map((entry) => Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [Expanded(child: Text(entry.key, style: const TextStyle(color: Colors.white70))), Text(_money(entry.value), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]))),
    ]));
  }

  Widget _detailContainer(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.ink, borderRadius: BorderRadius.circular(28)), child: child);

  Widget _statGrid(SummaryEntity summary) => GridView.count(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.12,
    children: [_StatCard(label: 'Money\nreceived', value: _money(summary.moneyReceived), color: AppColors.yellow, burst: AppColors.ink), _StatCard(label: 'Total\nspend', value: _money(summary.totalSpend), color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.ink, burst: AppColors.yellow, foreground: Colors.white), _StatCard(label: 'Net cash\nflow', value: _money(summary.netCashFlow), color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.ink, burst: AppColors.yellow, foreground: summary.netCashFlow < 0 ? AppColors.red : AppColors.yellow), _StatCard(label: 'Trans-\nactions', value: '${summary.transactionCount}', color: AppColors.pink, burst: Colors.white)],
  );

  Widget _circleButton(IconData icon, Color color, String label, VoidCallback onTap) => Semantics(label: label, button: true, child: _Pressable(onTap: onTap, child: CircleAvatar(radius: 24, backgroundColor: color, child: Icon(icon, color: AppColors.ink))));

  void _settings() => showModalBottomSheet<void>(context: context, backgroundColor: Theme.of(context).colorScheme.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))), builder: (context) => Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 30), child: Column(mainAxisSize: MainAxisSize.min, children: ['Profile', 'Currency', 'Notifications', 'Theme', 'Log out'].map((item) => ListTile(title: Text(item), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pop(context))).toList())));

  // ignore: unused_element
  void _transactions(CategorySpendEntity category) => showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: .94), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))), builder: (context) => DraggableScrollableSheet(initialChildSize: .62, minChildSize: .35, maxChildSize: .92, expand: false, builder: (context, controller) => Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 18, 12, 10), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(category.category, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)), Text('${_money(category.total)} · ${category.transactions.length} transactions', style: const TextStyle(color: AppColors.muted))])), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), tooltip: 'Close transactions')])) ,
    Expanded(child: ListView.builder(controller: controller, itemCount: category.transactions.length, itemBuilder: (context, index) => _transactionRow(category.transactions[index]))),
  ])));

  Widget _transactionRow(TransactionEntity item) => ListTile(leading: CircleAvatar(backgroundColor: AppColors.yellow, child: Text(item.name.isEmpty ? '?' : item.name[0], style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700))), title: Text(item.name), subtitle: Text('${item.date == null ? item.dateText : _shortDate(item.date!)}${item.method == null ? '' : ' · ${item.method}'}'), trailing: Text(_money(item.amount), style: const TextStyle(fontWeight: FontWeight.w700)));
}

String _money(double amount) => '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}';
String _shortDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
Color _sliceColor(int index, Brightness brightness) => [AppColors.yellow, brightness == Brightness.dark ? Colors.white : AppColors.ink, AppColors.pink, AppColors.red, AppColors.muted, const Color(0xFFD9D9DE)][index % 6];

class _Brand extends StatelessWidget {
  const _Brand({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Row(children: [_Burst(color: AppColors.yellow, size: 25), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20))]);
}

class _TwoToneTitle extends StatelessWidget {
  const _TwoToneTitle({required this.first, required this.second});
  final String first;
  final String second;
  final double size = 40;
  @override
  Widget build(BuildContext context) => Text.rich(TextSpan(children: [TextSpan(text: '$first\n', style: TextStyle(fontSize: size, height: 1.05, letterSpacing: -1, fontWeight: FontWeight.w300, color: AppColors.muted)), TextSpan(text: second, style: TextStyle(fontSize: size, height: 1.05, letterSpacing: -1, fontWeight: FontWeight.w700))]));
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color, required this.burst, this.foreground = AppColors.ink});
  final String label;
  final String value;
  final Color color;
  final Color burst;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(28)),
    child: Stack(children: [
      Align(alignment: Alignment.topRight, child: _Burst(color: burst, size: 30)),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: foreground.withValues(alpha: .78), fontSize: 14)),
        Text(value, style: TextStyle(color: foreground, fontSize: 23, fontWeight: FontWeight.w700, letterSpacing: -.5)),
      ]),
    ]),
  );
}
class _Pressable extends StatefulWidget { const _Pressable({required this.child, this.onTap}); final Widget child; final VoidCallback? onTap; @override State<_Pressable> createState() => _PressableState(); }
class _PressableState extends State<_Pressable> { bool down = false; @override Widget build(BuildContext context) => GestureDetector(onTap: widget.onTap, onTapDown: widget.onTap == null ? null : (_) => setState(() => down = true), onTapUp: widget.onTap == null ? null : (_) => setState(() => down = false), onTapCancel: () => setState(() => down = false), child: AnimatedScale(scale: down ? .96 : 1, duration: const Duration(milliseconds: 100), child: widget.child)); }
class _Burst extends StatelessWidget { const _Burst({required this.color, required this.size}); final Color color; final double size; @override Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _BurstPainter(color)); }
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final center = size.center(Offset.zero);
    for (var i = 0; i < 32; i++) {
      final angle = -math.pi / 2 + i * math.pi / 16;
      final radius = size.width * (i.isEven ? .5 : .38);
      final point = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }
  @override
  bool shouldRepaint(_BurstPainter old) => old.color != color;
}
// ignore: unused_element
class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.categories, required this.selectedIndex, required this.onSelected});
  final List<CategorySpendEntity> categories;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(0, (sum, item) => sum + item.total);
    final selected = selectedIndex == null ? null : categories[selectedIndex!];
    return SizedBox(width: 270, height: 270, child: Stack(alignment: Alignment.center, children: [
      CustomPaint(
        size: const Size.square(250),
        painter: _DonutPainter(categories, selectedIndex, Theme.of(context).brightness),
        child: GestureDetector(onTapUp: (details) {
          final vector = details.localPosition - const Offset(125, 125);
          if (vector.distance < 62 || vector.distance > 125 || total == 0) return;
          final angle = (math.atan2(vector.dy, vector.dx) + math.pi / 2 + 2 * math.pi) % (2 * math.pi);
          var cursor = 0.0;
          for (var i = 0; i < categories.length; i++) {
            cursor += categories[i].total / total * 2 * math.pi;
            if (angle <= cursor) { onSelected(i); return; }
          }
        }),
      ),
      Column(mainAxisSize: MainAxisSize.min, children: [Text(selected?.category ?? 'Total spend', style: const TextStyle(color: AppColors.muted, fontSize: 12)), Text(_money(selected?.total ?? total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700))]),
    ]));
  }
}
class _DonutPainter extends CustomPainter { _DonutPainter(this.items, this.selected, this.brightness); final List<CategorySpendEntity> items; final int? selected; final Brightness brightness; @override void paint(Canvas canvas, Size size) { final c = size.center(Offset.zero); final total = items.fold<double>(0, (sum, item) => sum + item.total); if (total == 0) { canvas.drawCircle(c, 90, Paint()..color = AppColors.line..style = PaintingStyle.stroke..strokeWidth = 34); return; } var start = -math.pi / 2; for (var i = 0; i < items.length; i++) { final sweep = items[i].total / total * 2 * math.pi; final middle = start + sweep / 2; final offset = selected == i ? Offset(math.cos(middle) * 9, math.sin(middle) * 9) : Offset.zero; canvas.drawArc(Rect.fromCircle(center: c + offset, radius: 90), start, sweep, false, Paint()..color = _sliceColor(i, brightness)..style = PaintingStyle.stroke..strokeWidth = 34..strokeCap = StrokeCap.butt); start += sweep; } } @override bool shouldRepaint(_DonutPainter old) => old.items != items || old.selected != selected || old.brightness != brightness; }
