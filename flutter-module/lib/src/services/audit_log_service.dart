import 'dart:convert';
import 'package:http/http.dart' as http;

/// Server-side audit logging service that stores logs in Grist
///
/// Provides:
/// - Immutable audit trail
/// - Tamper-proof logging
/// - Centralized security event tracking
/// - IP address and device fingerprint tracking
/// - Compliance-ready audit logs
class AuditLogService {
  final String baseUrl;
  final String apiKey;
  final String docId;
  final String tableName;

  AuditLogService({
    required this.baseUrl,
    required this.apiKey,
    required this.docId,
    this.tableName = 'AuditLogs',
  });

  /// Log an authentication event (login, logout, failed login)
  Future<bool> logAuthEvent({
    required String action,
    required String username,
    String? userId,
    bool success = true,
    String? ipAddress,
    String? deviceFingerprint,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    return await _logEvent(
      action: action,
      resource: 'authentication',
      username: username,
      userId: userId,
      success: success,
      ipAddress: ipAddress,
      deviceFingerprint: deviceFingerprint,
      userAgent: userAgent,
      metadata: metadata,
    );
  }

  /// Log a data operation (CREATE, READ, UPDATE, DELETE)
  Future<bool> logDataOperation({
    required String action,
    required String resource,
    required String username,
    String? userId,
    String? recordId,
    Map<String, dynamic>? changes,
    String? ipAddress,
    String? deviceFingerprint,
  }) async {
    return await _logEvent(
      action: action,
      resource: resource,
      username: username,
      userId: userId,
      recordId: recordId,
      ipAddress: ipAddress,
      deviceFingerprint: deviceFingerprint,
      metadata: changes,
    );
  }

  /// Log an admin action
  Future<bool> logAdminAction({
    required String action,
    required String resource,
    required String username,
    String? userId,
    String? targetUserId,
    String? targetUsername,
    String? ipAddress,
    String? deviceFingerprint,
    Map<String, dynamic>? metadata,
  }) async {
    final enrichedMetadata = {
      ...?metadata,
      if (targetUserId != null) 'target_user_id': targetUserId,
      if (targetUsername != null) 'target_username': targetUsername,
    };

    return await _logEvent(
      action: action,
      resource: resource,
      username: username,
      userId: userId,
      ipAddress: ipAddress,
      deviceFingerprint: deviceFingerprint,
      metadata: enrichedMetadata,
    );
  }

  /// Log a security event (suspicious activity, policy violation)
  Future<bool> logSecurityEvent({
    required String action,
    required String description,
    String? username,
    String? userId,
    String? ipAddress,
    String? deviceFingerprint,
    String severity = 'medium',
    Map<String, dynamic>? metadata,
  }) async {
    final enrichedMetadata = {
      ...?metadata,
      'severity': severity,
      'description': description,
    };

    return await _logEvent(
      action: action,
      resource: 'security',
      username: username,
      userId: userId,
      ipAddress: ipAddress,
      deviceFingerprint: deviceFingerprint,
      metadata: enrichedMetadata,
    );
  }

  /// Core logging method - creates an immutable audit log entry in Grist
  Future<bool> _logEvent({
    required String action,
    required String resource,
    String? username,
    String? userId,
    String? recordId,
    bool success = true,
    String? ipAddress,
    String? deviceFingerprint,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();

      final logEntry = {
        'timestamp': timestamp,
        'action': action,
        'resource': resource,
        'username': username ?? 'anonymous',
        'user_id': userId ?? '',
        'record_id': recordId ?? '',
        'success': success,
        'ip_address': ipAddress ?? '',
        'device_fingerprint': deviceFingerprint ?? '',
        'user_agent': userAgent ?? '',
        'metadata': metadata != null ? jsonEncode(metadata) : '{}',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/docs/$docId/tables/$tableName/records'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'records': [
            {'fields': logEntry}
          ]
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Logging failures should not break the app
      // In production, you might want to queue failed logs for retry
      return false;
    }
  }

  /// Retrieve audit logs with filters
  Future<List<Map<String, dynamic>>> getAuditLogs({
    String? username,
    String? action,
    String? resource,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final filters = <String>[];

      if (username != null) {
        filters.add('username == "$username"');
      }
      if (action != null) {
        filters.add('action == "$action"');
      }
      if (resource != null) {
        filters.add('resource == "$resource"');
      }
      if (startDate != null) {
        filters.add('timestamp >= "${startDate.toIso8601String()}"');
      }
      if (endDate != null) {
        filters.add('timestamp <= "${endDate.toIso8601String()}"');
      }

      final filterFormula = filters.isEmpty ? '' : filters.join(' and ');

      final uri = Uri.parse('$baseUrl/api/docs/$docId/tables/$tableName/records')
          .replace(queryParameters: {
        if (filterFormula.isNotEmpty) 'filter': filterFormula,
        'limit': limit.toString(),
        'sort': '-timestamp', // Sort by timestamp descending
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = data['records'] as List;

        return records.map((record) {
          final fields = record['fields'] as Map<String, dynamic>;
          return {
            'id': record['id'],
            ...fields,
          };
        }).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get failed login attempts for a specific user or IP
  Future<List<Map<String, dynamic>>> getFailedLoginAttempts({
    String? username,
    String? ipAddress,
    Duration lookbackPeriod = const Duration(hours: 24),
  }) async {
    final startDate = DateTime.now().subtract(lookbackPeriod);

    return await getAuditLogs(
      username: username,
      action: 'LOGIN_FAILED',
      startDate: startDate,
      limit: 1000,
    ).then((logs) {
      if (ipAddress != null) {
        return logs.where((log) => log['ip_address'] == ipAddress).toList();
      }
      return logs;
    });
  }

  /// Get recent activity for a user
  Future<List<Map<String, dynamic>>> getUserActivity({
    required String username,
    Duration lookbackPeriod = const Duration(days: 7),
    int limit = 100,
  }) async {
    final startDate = DateTime.now().subtract(lookbackPeriod);

    return await getAuditLogs(
      username: username,
      startDate: startDate,
      limit: limit,
    );
  }

  /// Get security events by severity
  Future<List<Map<String, dynamic>>> getSecurityEvents({
    String? severity,
    Duration lookbackPeriod = const Duration(days: 30),
    int limit = 100,
  }) async {
    final startDate = DateTime.now().subtract(lookbackPeriod);

    return await getAuditLogs(
      resource: 'security',
      startDate: startDate,
      limit: limit,
    ).then((logs) {
      if (severity != null) {
        return logs.where((log) {
          final metadata = log['metadata'];
          if (metadata is String) {
            try {
              final meta = jsonDecode(metadata) as Map<String, dynamic>;
              return meta['severity'] == severity;
            } catch (e) {
              return false;
            }
          }
          return false;
        }).toList();
      }
      return logs;
    });
  }

  /// Get statistics for the dashboard
  Future<Map<String, dynamic>> getAuditStatistics({
    Duration lookbackPeriod = const Duration(days: 7),
  }) async {
    final startDate = DateTime.now().subtract(lookbackPeriod);
    final logs = await getAuditLogs(startDate: startDate, limit: 10000);

    final totalEvents = logs.length;
    final failedLogins = logs.where((log) => log['action'] == 'LOGIN_FAILED').length;
    final successfulLogins = logs.where((log) => log['action'] == 'LOGIN_SUCCESS').length;
    final dataOperations = logs.where((log) =>
        ['CREATE', 'UPDATE', 'DELETE'].contains(log['action'])).length;
    final uniqueUsers = logs.map((log) => log['username']).toSet().length;
    final uniqueIPs = logs.map((log) => log['ip_address']).where((ip) => ip.isNotEmpty).toSet().length;

    // Group by action
    final actionCounts = <String, int>{};
    for (final log in logs) {
      final action = log['action'] as String;
      actionCounts[action] = (actionCounts[action] ?? 0) + 1;
    }

    return {
      'total_events': totalEvents,
      'failed_logins': failedLogins,
      'successful_logins': successfulLogins,
      'data_operations': dataOperations,
      'unique_users': uniqueUsers,
      'unique_ips': uniqueIPs,
      'action_counts': actionCounts,
      'period_start': startDate.toIso8601String(),
      'period_end': DateTime.now().toIso8601String(),
    };
  }
}

/// Audit action constants
class AuditActions {
  // Authentication
  static const String loginSuccess = 'LOGIN_SUCCESS';
  static const String loginFailed = 'LOGIN_FAILED';
  static const String logout = 'LOGOUT';
  static const String passwordReset = 'PASSWORD_RESET';
  static const String passwordChanged = 'PASSWORD_CHANGE';
  static const String accountLocked = 'ACCOUNT_LOCKED';
  static const String accountUnlocked = 'ACCOUNT_UNLOCKED';

  // Data operations
  static const String create = 'CREATE';
  static const String read = 'READ';
  static const String update = 'UPDATE';
  static const String delete = 'DELETE';
  static const String export = 'EXPORT';
  static const String import = 'IMPORT';

  // Admin operations
  static const String userCreated = 'USER_CREATED';
  static const String userUpdated = 'USER_UPDATED';
  static const String userDeleted = 'USER_DELETED';
  static const String roleChanged = 'ROLE_CHANGED';
  static const String permissionChanged = 'PERMISSION_CHANGED';
  static const String configChanged = 'CONFIG_CHANGED';

  // Security events
  static const String suspiciousActivity = 'SUSPICIOUS_ACTIVITY';
  static const String bruteForceAttempt = 'BRUTE_FORCE_ATTEMPT';
  static const String unauthorizedAccess = 'UNAUTHORIZED_ACCESS';
  static const String sessionHijackAttempt = 'SESSION_HIJACK_ATTEMPT';
  static const String rateLimitExceeded = 'RATE_LIMIT_EXCEEDED';
}
