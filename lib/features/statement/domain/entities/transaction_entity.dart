/// One normalized transaction returned by the statement-import API.
class TransactionEntity {
  /// Creates an immutable transaction.
  const TransactionEntity({required this.id, required this.name, required this.date, required this.dateText, required this.amount, required this.category, this.method});

  /// Backend transaction identifier.
  final String id;
  /// Merchant or transaction description.
  final String name;
  /// Parsed transaction date, when provided by the server.
  final DateTime? date;
  /// Original date string from the submitted statement.
  final String dateText;
  /// Signed value: positive is received; negative is spend.
  final double amount;
  /// Backend-assigned spending category.
  final String category;
  /// Payment method if supplied by the backend.
  final String? method;
}
