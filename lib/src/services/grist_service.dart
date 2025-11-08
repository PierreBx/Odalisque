import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/user_model.dart';
import 'package:crypto/crypto.dart';

/// Service for interacting with the Grist API.
class GristService {
  final GristSettings config;

  GristService(this.config);

  /// Fetches all records from a table.
  Future<List<Map<String, dynamic>>> fetchRecords(String tableName) async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/$tableName/records',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['records'] ?? []);
    } else {
      throw Exception(
          'Failed to fetch records from $tableName: ${response.statusCode}');
    }
  }

  /// Fetches a single record by ID.
  Future<Map<String, dynamic>?> fetchRecord(
      String tableName, int recordId) async {
    final records = await fetchRecords(tableName);
    try {
      return records.firstWhere(
        (r) => r['id'] == recordId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Updates a record.
  Future<void> updateRecord(
    String tableName,
    int recordId,
    Map<String, dynamic> fields,
  ) async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/$tableName/records',
    );

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'records': [
          {
            'id': recordId,
            'fields': fields,
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update record: ${response.statusCode}');
    }
  }

  /// Authenticates a user against the users table.
  Future<User?> authenticate(
    String email,
    String password,
    AuthSettings authSettings,
  ) async {
    try {
      final records = await fetchRecords(authSettings.usersTable);
      final schema = authSettings.usersTableSchema;

      // Hash the password
      final passwordHash = _hashPassword(password);

      // Find matching user
      for (var record in records) {
        final fields = record['fields'] as Map<String, dynamic>? ?? {};
        final recordEmail = fields[schema.emailField]?.toString();
        final recordPasswordHash = fields[schema.passwordField]?.toString();

        if (recordEmail == email && recordPasswordHash == passwordHash) {
          return User.fromGristRecord(
            record,
            schema.emailField,
            schema.roleField,
            schema.activeField,
          );
        }
      }

      return null;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  /// Fetches all tables in the document.
  Future<List<Map<String, dynamic>>> fetchTables() async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['tables'] ?? []);
    } else {
      throw Exception('Failed to fetch tables: ${response.statusCode}');
    }
  }

  /// Fetches column definitions for a table.
  Future<List<Map<String, dynamic>>> fetchColumns(String tableName) async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/$tableName/columns',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['columns'] ?? []);
    } else {
      throw Exception(
          'Failed to fetch columns for $tableName: ${response.statusCode}');
    }
  }

  /// Simple password hashing (SHA256).
  /// Note: In production, use proper password hashing like bcrypt.
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
