import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/user_model.dart';
import 'package:bcrypt/bcrypt.dart';

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
  /// Uses the Grist API's direct record endpoint for efficiency.
  Future<Map<String, dynamic>?> fetchRecord(
      String tableName, int recordId) async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/$tableName/records/$recordId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>?;
      } else if (response.statusCode == 404) {
        return null; // Record not found
      } else {
        throw Exception(
            'Failed to fetch record $recordId from $tableName: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching record: $e');
    }
  }

  /// Creates a new record.
  /// Returns the ID of the newly created record.
  Future<int> createRecord(
    String tableName,
    Map<String, dynamic> fields,
  ) async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/$tableName/records',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'records': [
          {'fields': fields}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final records = data['records'] as List<dynamic>?;
      if (records != null && records.isNotEmpty) {
        return records[0]['id'] as int;
      }
      throw Exception('Failed to get created record ID');
    } else {
      throw Exception('Failed to create record: ${response.statusCode}');
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

  /// Deletes a record.
  Future<void> deleteRecord(
    String tableName,
    int recordId,
  ) async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/$tableName/records',
    );

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
      body: json.encode([recordId]),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete record: ${response.statusCode}');
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

      // Find matching user
      for (var record in records) {
        final fields = record['fields'] as Map<String, dynamic>? ?? {};
        final recordEmail = fields[schema.emailField]?.toString();
        final recordPasswordHash = fields[schema.passwordField]?.toString();

        // Verify password using bcrypt
        if (recordEmail == email &&
            recordPasswordHash != null &&
            BCrypt.checkpw(password, recordPasswordHash)) {
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

  /// Hashes a password using bcrypt with a salt.
  /// This is suitable for production use.
  ///
  /// Example usage for creating a password hash to store in Grist:
  /// ```dart
  /// final hash = GristService.hashPassword('myPassword123');
  /// // Store this hash in your Grist users table
  /// ```
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
}
