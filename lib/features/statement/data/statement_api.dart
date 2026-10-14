import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/entities/statement_entity.dart';
import '../domain/entities/transaction_entity.dart';

/// Connection settings configurable at build time with `--dart-define`.
abstract final class StatementApiConfig {
  static const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.85.252.229:8000');
  static const uploadPath = String.fromEnvironment('API_UPLOAD_PATH', defaultValue: '/api/v1/upload/csv');
  static const maxFileBytes = 5 * 1024 * 1024;
}

/// Performs multipart imports and translates JSON into domain entities.
class StatementApi {
  /// Creates an API client, optionally with a test HTTP client.
  StatementApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// Uploads [file] unchanged and returns the server's normalized statement.
  Future<StatementEntity> importCsv(File file) async {
    if (await file.length() > StatementApiConfig.maxFileBytes) throw const StatementApiException('The selected file is larger than 5 MB.');
    final request = http.MultipartRequest('POST', Uri.parse('${StatementApiConfig.baseUrl}${StatementApiConfig.uploadPath}'));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    try {
      final streamed = await _client.send(request).timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed).timeout(const Duration(seconds: 30));
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) throw StatementApiException(json['message']?.toString() ?? 'The statement could not be imported.');
      return _fromJson(json, file.uri.pathSegments.last);
    } on SocketException {
      throw const StatementApiException('Unable to reach the import service.');
    } on FormatException {
      throw const StatementApiException('The server returned an invalid statement response.');
    }
  }

  StatementEntity _fromJson(Map<String, dynamic> json, String fallbackName) => StatementEntity(
    fileName: json['fileName']?.toString() ?? fallbackName,
    importedAt: DateTime.tryParse(json['importedAt']?.toString() ?? '') ?? DateTime.now(),
    transactions: (json['transactions'] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().map((row) => TransactionEntity(
      id: row['id']?.toString() ?? '', name: row['name']?.toString() ?? 'Unknown', date: DateTime.tryParse(row['date']?.toString() ?? ''),
      dateText: row['dateText']?.toString() ?? '', amount: (row['amount'] as num?)?.toDouble() ?? 0, category: row['category']?.toString() ?? 'Other', method: row['method']?.toString(),
    )).toList(),
  );
}

/// A server or network import error safe to present to the user.
class StatementApiException implements Exception {
  /// Creates a presentation-safe import error.
  const StatementApiException(this.message);
  /// The snackbar message.
  final String message;
}

/// Small device cache for the last successful normalized API response.
/// It intentionally stores the response, never the original bank CSV.
class StatementCache {
  /// Loads the cache or returns null when no successful import exists yet.
  Future<StatementEntity?> load() async {
    final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}pocketly_statement.json');
    if (!await file.exists()) return null;
    try {
      return _fromJson(jsonDecode(await file.readAsString()) as Map<String, dynamic>, 'statement.csv');
    } catch (_) {
      return null;
    }
  }

  /// Atomically replaces the last cached response after a successful import.
  Future<void> save(StatementEntity statement) async {
    final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}pocketly_statement.json');
    final temporary = File('${file.path}.new');
    await temporary.writeAsString(jsonEncode({
      'fileName': statement.fileName,
      'importedAt': statement.importedAt.toIso8601String(),
      'transactions': statement.transactions.map((item) => {
        'id': item.id, 'name': item.name, 'date': item.date?.toIso8601String(), 'dateText': item.dateText,
        'amount': item.amount, 'category': item.category, 'method': item.method,
      }).toList(),
    }));
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
  }

  static StatementEntity _fromJson(Map<String, dynamic> json, String fallbackName) => StatementEntity(
    fileName: json['fileName']?.toString() ?? fallbackName,
    importedAt: DateTime.tryParse(json['importedAt']?.toString() ?? '') ?? DateTime.now(),
    transactions: (json['transactions'] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().map((row) => TransactionEntity(
      id: row['id']?.toString() ?? '', name: row['name']?.toString() ?? 'Unknown', date: DateTime.tryParse(row['date']?.toString() ?? ''),
      dateText: row['dateText']?.toString() ?? '', amount: (row['amount'] as num?)?.toDouble() ?? 0, category: row['category']?.toString() ?? 'Other', method: row['method']?.toString(),
    )).toList(),
  );
}
