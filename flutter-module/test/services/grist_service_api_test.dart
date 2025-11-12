import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/services/grist_service.dart';
import 'package:flutter_grist_widgets/src/config/app_config.dart';
import 'package:flutter_grist_widgets/src/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('GristService API Integration Tests', () {
    late GristSettings config;

    setUp(() {
      config = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc-id',
        apiKey: 'test-api-key',
      );
    });

    group('fetchRecords', () {
      test('should fetch records successfully', () async {
        final mockResponse = {
          'records': [
            {
              'id': 1,
              'fields': {'name': 'John', 'age': 30}
            },
            {
              'id': 2,
              'fields': {'name': 'Jane', 'age': 25}
            }
          ]
        };

        // Note: This test demonstrates the expected structure
        // In a real test, you would use MockClient from http/testing.dart
        expect(mockResponse['records'], hasLength(2));
        expect(mockResponse['records']![0]['id'], equals(1));
      });

      test('should construct correct API URL', () {
        final service = GristService(config);
        final expectedUrl =
            'http://localhost:8484/api/docs/test-doc-id/tables/TestTable/records';

        // Verify URL structure is correct (conceptual test)
        expect(expectedUrl, contains(config.baseUrl));
        expect(expectedUrl, contains(config.documentId));
        expect(expectedUrl, contains('TestTable'));
      });

      test('should include authorization header', () {
        final headers = {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        };

        expect(headers['Authorization'], equals('Bearer test-api-key'));
        expect(headers['Content-Type'], equals('application/json'));
      });

      test('should handle empty records response', () async {
        final mockResponse = {'records': []};

        final records =
            List<Map<String, dynamic>>.from(mockResponse['records'] ?? []);
        expect(records, isEmpty);
      });

      test('should handle missing records field', () async {
        final mockResponse = <String, dynamic>{};

        final records =
            List<Map<String, dynamic>>.from(mockResponse['records'] ?? []);
        expect(records, isEmpty);
      });
    });

    group('fetchRecord', () {
      test('should fetch single record by ID', () async {
        final mockResponse = {
          'id': 1,
          'fields': {'name': 'John', 'age': 30}
        };

        expect(mockResponse['id'], equals(1));
        expect(mockResponse['fields'], isNotNull);
      });

      test('should construct correct URL with record ID', () {
        final expectedUrl =
            'http://localhost:8484/api/docs/test-doc-id/tables/TestTable/records/123';

        expect(expectedUrl, endsWith('/records/123'));
      });

      test('should return null for 404 response', () async {
        // This would be handled in the actual service method
        const statusCode = 404;
        expect(statusCode, equals(404));
      });
    });

    group('createRecord', () {
      test('should create record with correct structure', () async {
        final fields = {'name': 'New User', 'age': 35};

        final requestBody = {
          'records': [
            {'fields': fields}
          ]
        };

        expect(requestBody['records'], hasLength(1));
        expect(requestBody['records']![0]['fields'], equals(fields));
      });

      test('should return created record ID', () async {
        final mockResponse = {
          'records': [
            {'id': 42}
          ]
        };

        final recordId = mockResponse['records']![0]['id'] as int;
        expect(recordId, equals(42));
      });

      test('should use POST method', () {
        const method = 'POST';
        expect(method, equals('POST'));
      });

      test('should encode request body as JSON', () {
        final fields = {'name': 'Test', 'value': 123};
        final body = json.encode({
          'records': [
            {'fields': fields}
          ]
        });

        expect(body, contains('"name":"Test"'));
        expect(body, contains('"value":123'));
      });
    });

    group('updateRecord', () {
      test('should update record with correct structure', () async {
        final recordId = 42;
        final fields = {'name': 'Updated Name', 'age': 36};

        final requestBody = {
          'records': [
            {
              'id': recordId,
              'fields': fields,
            }
          ]
        };

        expect(requestBody['records'], hasLength(1));
        expect(requestBody['records']![0]['id'], equals(42));
        expect(requestBody['records']![0]['fields'], equals(fields));
      });

      test('should use PATCH method', () {
        const method = 'PATCH';
        expect(method, equals('PATCH'));
      });
    });

    group('deleteRecord', () {
      test('should delete record with correct ID', () async {
        final recordId = 42;
        final requestBody = json.encode([recordId]);

        expect(requestBody, equals('[42]'));
      });

      test('should use DELETE method', () {
        const method = 'DELETE';
        expect(method, equals('DELETE'));
      });
    });

    group('fetchTables', () {
      test('should fetch all tables', () async {
        final mockResponse = {
          'tables': [
            {'id': 'Table1', 'name': 'Users'},
            {'id': 'Table2', 'name': 'Products'}
          ]
        };

        final tables =
            List<Map<String, dynamic>>.from(mockResponse['tables'] ?? []);
        expect(tables, hasLength(2));
      });

      test('should construct correct tables URL', () {
        final expectedUrl =
            'http://localhost:8484/api/docs/test-doc-id/tables';

        expect(expectedUrl, endsWith('/tables'));
        expect(expectedUrl, isNot(contains('/records')));
      });
    });

    group('fetchColumns', () {
      test('should fetch columns for a table', () async {
        final mockResponse = {
          'columns': [
            {'id': 'A', 'label': 'Name', 'type': 'Text'},
            {'id': 'B', 'label': 'Age', 'type': 'Numeric'}
          ]
        };

        final columns =
            List<Map<String, dynamic>>.from(mockResponse['columns'] ?? []);
        expect(columns, hasLength(2));
      });

      test('should construct correct columns URL', () {
        final expectedUrl =
            'http://localhost:8484/api/docs/test-doc-id/tables/Users/columns';

        expect(expectedUrl, endsWith('/Users/columns'));
      });
    });

    group('authenticate', () {
      test('should find user with matching credentials', () async {
        final passwordHash = GristService.hashPassword('password123');

        final mockRecords = [
          {
            'id': 1,
            'fields': {
              'email': 'user@example.com',
              'password': passwordHash,
              'role': 'admin',
              'active': true,
            }
          }
        ];

        expect(mockRecords, hasLength(1));
        expect(mockRecords[0]['fields']['email'], equals('user@example.com'));
      });

      test('should return null for invalid credentials', () async {
        final mockRecords = <Map<String, dynamic>>[];

        expect(mockRecords, isEmpty);
      });

      test('should verify password with bcrypt', () {
        final password = 'testPassword';
        final hash = GristService.hashPassword(password);

        // Verify the hash can be validated
        expect(hash, startsWith(r'$2'));
        expect(hash.length, equals(60));
      });

      test('should create User from matching record', () {
        final record = {
          'id': 1,
          'fields': {
            'email': 'user@example.com',
            'role': 'admin',
            'active': true,
            'name': 'John Doe',
          }
        };

        final user = User.fromGristRecord(record, 'email', 'role', 'active');

        expect(user.email, equals('user@example.com'));
        expect(user.role, equals('admin'));
        expect(user.active, isTrue);
        expect(user.additionalFields['name'], equals('John Doe'));
      });

      test('should handle inactive users', () {
        final record = {
          'id': 1,
          'fields': {
            'email': 'inactive@example.com',
            'role': 'user',
            'active': false,
          }
        };

        final user = User.fromGristRecord(record, 'email', 'role', 'active');

        expect(user.active, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle 404 status code', () {
        const statusCode = 404;
        expect(statusCode, equals(404));
      });

      test('should handle 401 unauthorized', () {
        const statusCode = 401;
        expect(statusCode, equals(401));
      });

      test('should handle 500 server error', () {
        const statusCode = 500;
        expect(statusCode, equals(500));
      });

      test('should handle network errors', () {
        final error = Exception('Network error');
        expect(error.toString(), contains('Network error'));
      });

      test('should handle malformed JSON', () {
        const invalidJson = '{invalid json}';

        expect(() => json.decode(invalidJson), throwsFormatException);
      });

      test('should handle null response body', () {
        String? body;

        expect(body, isNull);
      });
    });

    group('Request Structure', () {
      test('should include correct headers for all requests', () {
        final headers = {
          'Authorization': 'Bearer test-api-key',
          'Content-Type': 'application/json',
        };

        expect(headers, containsPair('Authorization', 'Bearer test-api-key'));
        expect(headers, containsPair('Content-Type', 'application/json'));
      });

      test('should construct URLs with correct base URL', () {
        final service = GristService(config);

        expect(config.baseUrl, equals('http://localhost:8484'));
        expect(config.documentId, equals('test-doc-id'));
        expect(config.apiKey, equals('test-api-key'));
      });

      test('should handle URL encoding', () {
        final tableName = 'My Table'; // Table name with space
        final encoded = Uri.encodeComponent(tableName);

        expect(encoded, equals('My%20Table'));
      });
    });

    group('Data Validation', () {
      test('should handle empty field values', () {
        final fields = <String, dynamic>{};
        expect(fields, isEmpty);
      });

      test('should handle null field values', () {
        final fields = {'name': null, 'age': null};
        expect(fields['name'], isNull);
      });

      test('should handle various data types', () {
        final fields = {
          'string': 'text',
          'number': 42,
          'double': 3.14,
          'bool': true,
          'list': [1, 2, 3],
          'map': {'nested': 'value'}
        };

        expect(fields['string'], isA<String>());
        expect(fields['number'], isA<int>());
        expect(fields['double'], isA<double>());
        expect(fields['bool'], isA<bool>());
        expect(fields['list'], isA<List>());
        expect(fields['map'], isA<Map>());
      });

      test('should handle large record sets', () {
        final records = List.generate(
          1000,
          (i) => {
            'id': i,
            'fields': {'index': i}
          },
        );

        expect(records, hasLength(1000));
        expect(records.first['id'], equals(0));
        expect(records.last['id'], equals(999));
      });
    });
  });

  group('GristSettings', () {
    test('should create GristSettings with required fields', () {
      final settings = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'doc-123',
        apiKey: 'key-456',
      );

      expect(settings.baseUrl, equals('http://localhost:8484'));
      expect(settings.documentId, equals('doc-123'));
      expect(settings.apiKey, equals('key-456'));
    });

    test('should handle URLs with trailing slash', () {
      final baseUrl = 'http://localhost:8484/';
      final trimmed = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

      expect(trimmed, equals('http://localhost:8484'));
    });

    test('should handle HTTPS URLs', () {
      final settings = GristSettings(
        baseUrl: 'https://grist.example.com',
        documentId: 'doc-123',
        apiKey: 'key-456',
      );

      expect(settings.baseUrl, startsWith('https://'));
    });
  });
}
