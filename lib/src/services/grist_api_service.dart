import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/grist_config.dart';

/// Service for interacting with the Grist API.
class GristApiService {
  final GristConfig config;

  GristApiService(this.config);

  /// Fetches records from the configured Grist table.
  Future<List<Map<String, dynamic>>> fetchRecords() async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/${config.tableId}/records',
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
      throw Exception('Failed to fetch records: ${response.statusCode}');
    }
  }

  /// Fetches a single record by ID.
  Future<Map<String, dynamic>> fetchRecord(int recordId) async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/${config.tableId}/records/$recordId',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch record: ${response.statusCode}');
    }
  }

  /// Updates a record in the Grist table.
  Future<void> updateRecord(int recordId, Map<String, dynamic> fields) async {
    final url = Uri.parse(
      '${config.baseUrl}/api/docs/${config.documentId}/tables/${config.tableId}/records',
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
}
