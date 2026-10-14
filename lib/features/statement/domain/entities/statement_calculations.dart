import 'statement_entity.dart';
import 'transaction_entity.dart';

/// Derived totals displayed by the dashboard cards.
class SummaryEntity {
  /// Creates dashboard totals.
  const SummaryEntity({required this.moneyReceived, required this.totalSpend, required this.netCashFlow, required this.transactionCount});
  /// Sum of all positive transactions.
  final double moneyReceived;
  /// Absolute sum of all negative transactions.
  final double totalSpend;
  /// Received money less total spend.
  final double netCashFlow;
  /// Number of transactions retained from the API response.
  final int transactionCount;
}

/// A spend category and all data required to render it dynamically.
class CategorySpendEntity {
  /// Creates a category breakdown item.
  const CategorySpendEntity({required this.category, required this.total, required this.percent, required this.transactions, required this.merchantTotals});
  /// Category label from the backend.
  final String category;
  /// Positive spend amount for the category.
  final double total;
  /// Share of total spend.
  final double percent;
  /// Category transactions ordered newest first.
  final List<TransactionEntity> transactions;
  /// Aggregated positive spend amount by merchant.
  final Map<String, double> merchantTotals;
}

/// Pure-domain calculation helpers with no UI, file, or HTTP dependencies.
abstract final class StatementCalculations {
  /// Builds totals from a statement.
  static SummaryEntity summary(StatementEntity? statement) {
    final values = statement?.transactions ?? const <TransactionEntity>[];
    final received = values.where((item) => item.amount > 0).fold<double>(0, (sum, item) => sum + item.amount);
    final spend = values.where((item) => item.amount < 0).fold<double>(0, (sum, item) => sum + -item.amount);
    return SummaryEntity(moneyReceived: received, totalSpend: spend, netCashFlow: received - spend, transactionCount: values.length);
  }

  /// Builds up to six chart slices, joining smaller categories as Other.
  static List<CategorySpendEntity> categories(StatementEntity? statement) {
    final spent = (statement?.transactions ?? const <TransactionEntity>[]).where((item) => item.amount < 0).toList();
    final totalSpend = spent.fold<double>(0, (sum, item) => sum + -item.amount);
    final groups = <String, List<TransactionEntity>>{};
    for (final item in spent) {
      (groups[item.category.trim().isEmpty ? 'Other' : item.category] ??= []).add(item);
    }
    final result = groups.entries.map((entry) => _build(entry.key, entry.value, totalSpend)).toList()..sort((a, b) => b.total.compareTo(a.total));
    if (result.length <= 6) return result;
    final remaining = result.sublist(5).expand((item) => item.transactions).toList();
    result.removeRange(5, result.length);
    result.add(_build('Other', remaining, totalSpend));
    return result;
  }

  static CategorySpendEntity _build(String category, List<TransactionEntity> source, double grandTotal) {
    final rows = [...source]..sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
    final total = rows.fold<double>(0, (sum, item) => sum + -item.amount);
    final merchants = <String, double>{};
    for (final row in rows) {
      merchants[row.name] = (merchants[row.name] ?? 0) + -row.amount;
    }
    return CategorySpendEntity(category: category, total: total, percent: grandTotal == 0 ? 0 : total / grandTotal * 100, transactions: rows, merchantTotals: merchants);
  }
}
