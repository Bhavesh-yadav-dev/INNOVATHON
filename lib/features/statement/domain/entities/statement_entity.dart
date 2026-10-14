import 'transaction_entity.dart';

/// The complete imported statement and its metadata.
class StatementEntity {
  /// Creates a statement returned from a successful import.
  const StatementEntity({required this.fileName, required this.importedAt, required this.transactions});
  /// Name of the uploaded CSV file.
  final String fileName;
  /// Time that the backend imported the statement.
  final DateTime importedAt;
  /// All normalized rows returned by the backend.
  final List<TransactionEntity> transactions;
}
