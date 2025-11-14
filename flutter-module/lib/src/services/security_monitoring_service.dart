import 'dart:convert';
import 'package:http/http.dart' as http;
import 'audit_log_service.dart';
import 'rate_limit_service.dart';

/// Security monitoring service for the admin dashboard
///
/// Provides comprehensive security metrics:
/// - Failed login attempts tracking
/// - Active sessions monitoring
/// - API usage patterns
/// - Security alerts
/// - Anomaly detection
class SecurityMonitoringService {
  final String baseUrl;
  final String apiKey;
  final String docId;
  final AuditLogService auditLogService;
  final RateLimitService rateLimitService;

  SecurityMonitoringService({
    required this.baseUrl,
    required this.apiKey,
    required this.docId,
    required this.auditLogService,
    required this.rateLimitService,
  });

  /// Get failed login attempts for the last 24 hours
  Future<FailedLoginMetrics> getFailedLoginMetrics({
    Duration lookbackPeriod = const Duration(hours: 24),
  }) async {
    final startDate = DateTime.now().subtract(lookbackPeriod);
    final logs = await auditLogService.getAuditLogs(
      action: AuditActions.loginFailed,
      startDate: startDate,
      limit: 10000,
    );

    // Group by IP address
    final ipCounts = <String, int>{};
    final userCounts = <String, int>{};
    final timeDistribution = <String, int>{}; // Hourly distribution

    for (final log in logs) {
      final ip = log['ip_address'] as String? ?? 'unknown';
      final username = log['username'] as String? ?? 'unknown';
      final timestamp = log['timestamp'] as String;

      ipCounts[ip] = (ipCounts[ip] ?? 0) + 1;
      userCounts[username] = (userCounts[username] ?? 0) + 1;

      // Get hour bucket
      final hour = DateTime.parse(timestamp).hour;
      final hourKey = '$hour:00';
      timeDistribution[hourKey] = (timeDistribution[hourKey] ?? 0) + 1;
    }

    // Sort by count descending
    final topIPs = ipCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topUsers = userCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Detect potential brute force attacks
    final suspiciousIPs = topIPs.where((e) => e.value >= 10).map((e) => {
          'ip': e.key,
          'attempts': e.value,
          'severity': e.value >= 50
              ? 'critical'
              : e.value >= 20
                  ? 'high'
                  : 'medium',
        }).toList();

    return FailedLoginMetrics(
      totalAttempts: logs.length,
      uniqueIPs: ipCounts.length,
      uniqueUsers: userCounts.length,
      topIPs: topIPs.take(10).toList(),
      topUsers: topUsers.take(10).toList(),
      timeDistribution: timeDistribution,
      suspiciousIPs: suspiciousIPs,
    );
  }

  /// Get active sessions
  Future<ActiveSessionsMetrics> getActiveSessionsMetrics() async {
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));

    // Get recent successful logins
    final logs = await auditLogService.getAuditLogs(
      action: AuditActions.loginSuccess,
      startDate: fiveMinutesAgo.subtract(const Duration(hours: 24)),
      limit: 1000,
    );

    // Get recent activity (any action in last 5 minutes means active)
    final recentActivity = await auditLogService.getAuditLogs(
      startDate: fiveMinutesAgo,
      limit: 10000,
    );

    // Map of username to last activity
    final activeUsers = <String, Map<String, dynamic>>{};

    for (final log in recentActivity) {
      final username = log['username'] as String? ?? 'unknown';
      final timestamp = log['timestamp'] as String;
      final action = log['action'] as String;
      final ipAddress = log['ip_address'] as String? ?? '';

      if (!activeUsers.containsKey(username) ||
          DateTime.parse(timestamp).isAfter(
            DateTime.parse(activeUsers[username]!['last_activity'] as String),
          )) {
        activeUsers[username] = {
          'username': username,
          'last_activity': timestamp,
          'last_action': action,
          'ip_address': ipAddress,
        };
      }
    }

    // Get role information from recent login logs
    for (final user in activeUsers.values) {
      final username = user['username'] as String;
      final loginLog = logs.firstWhere(
        (log) => log['username'] == username,
        orElse: () => <String, dynamic>{},
      );

      if (loginLog.isNotEmpty) {
        final metadata = loginLog['metadata'] as String? ?? '{}';
        try {
          final meta = jsonDecode(metadata) as Map<String, dynamic>;
          user['role'] = meta['role'] ?? 'user';
          user['email'] = meta['email'] ?? '';
        } catch (e) {
          user['role'] = 'user';
          user['email'] = '';
        }
      }
    }

    // Detect anomalies: multiple IPs for same user
    final userIPMap = <String, Set<String>>{};
    for (final log in logs) {
      final username = log['username'] as String? ?? 'unknown';
      final ip = log['ip_address'] as String? ?? '';

      if (ip.isNotEmpty) {
        userIPMap.putIfAbsent(username, () => {}).add(ip);
      }
    }

    final suspiciousUsers = userIPMap.entries
        .where((e) => e.value.length >= 3)
        .map((e) => {
              'username': e.key,
              'ip_count': e.value.length,
              'ips': e.value.toList(),
              'severity': 'medium',
            })
        .toList();

    return ActiveSessionsMetrics(
      totalActiveSessions: activeUsers.length,
      activeSessions: activeUsers.values.toList(),
      suspiciousUsers: suspiciousUsers,
    );
  }

  /// Get API usage patterns
  Future<ApiUsageMetrics> getApiUsageMetrics({
    Duration lookbackPeriod = const Duration(hours: 1),
  }) async {
    final startDate = DateTime.now().subtract(lookbackPeriod);
    final logs = await auditLogService.getAuditLogs(
      startDate: startDate,
      limit: 50000,
    );

    // Count by action type
    final actionCounts = <String, int>{};
    final userCounts = <String, int>{};
    final ipCounts = <String, int>{};

    // Response time tracking (from metadata if available)
    final responseTimes = <double>[];

    for (final log in logs) {
      final action = log['action'] as String;
      final username = log['username'] as String? ?? 'unknown';
      final ip = log['ip_address'] as String? ?? 'unknown';

      actionCounts[action] = (actionCounts[action] ?? 0) + 1;
      userCounts[username] = (userCounts[username] ?? 0) + 1;
      ipCounts[ip] = (ipCounts[ip] ?? 0) + 1;

      // Try to extract response time from metadata
      final metadata = log['metadata'] as String? ?? '{}';
      try {
        final meta = jsonDecode(metadata) as Map<String, dynamic>;
        if (meta.containsKey('response_time_ms')) {
          responseTimes.add((meta['response_time_ms'] as num).toDouble());
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    // Calculate statistics
    final totalRequests = logs.length;
    final avgResponseTime = responseTimes.isEmpty
        ? 0.0
        : responseTimes.reduce((a, b) => a + b) / responseTimes.length;

    // Sort for top endpoints/users
    final topActions = actionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topUsers = userCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topIPs = ipCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Detect rate limit violations
    final suspiciousActivity = <Map<String, dynamic>>[];

    // Users exceeding 100 requests/hour
    for (final entry in topUsers) {
      if (entry.value > 100) {
        suspiciousActivity.add({
          'type': 'user',
          'identifier': entry.key,
          'request_count': entry.value,
          'severity': entry.value > 500 ? 'high' : 'medium',
        });
      }
    }

    // IPs exceeding 200 requests/hour
    for (final entry in topIPs) {
      if (entry.value > 200) {
        suspiciousActivity.add({
          'type': 'ip',
          'identifier': entry.key,
          'request_count': entry.value,
          'severity': entry.value > 1000 ? 'high' : 'medium',
        });
      }
    }

    return ApiUsageMetrics(
      totalRequests: totalRequests,
      avgResponseTime: avgResponseTime,
      topActions: topActions.take(10).toList(),
      topUsers: topUsers.take(10).toList(),
      topIPs: topIPs.take(10).toList(),
      suspiciousActivity: suspiciousActivity,
    );
  }

  /// Get security alerts
  Future<List<SecurityAlert>> getSecurityAlerts({
    Duration lookbackPeriod = const Duration(hours: 24),
  }) async {
    final alerts = <SecurityAlert>[];

    // Get failed login metrics
    final failedLogins = await getFailedLoginMetrics(
      lookbackPeriod: lookbackPeriod,
    );

    // Alert on suspicious IPs
    for (final suspiciousIP in failedLogins.suspiciousIPs) {
      alerts.add(SecurityAlert(
        id: 'failed_login_${suspiciousIP['ip']}',
        type: 'brute_force_attempt',
        severity: suspiciousIP['severity'] as String,
        title: 'Brute Force Attack Detected',
        description:
            'IP ${suspiciousIP['ip']} attempted ${suspiciousIP['attempts']} failed logins',
        timestamp: DateTime.now(),
        metadata: suspiciousIP,
      ));
    }

    // Get active sessions metrics
    final sessions = await getActiveSessionsMetrics();

    // Alert on suspicious users (multiple IPs)
    for (final suspiciousUser in sessions.suspiciousUsers) {
      alerts.add(SecurityAlert(
        id: 'multi_ip_${suspiciousUser['username']}',
        type: 'suspicious_activity',
        severity: suspiciousUser['severity'] as String,
        title: 'Multiple IP Addresses Detected',
        description:
            'User ${suspiciousUser['username']} accessed from ${suspiciousUser['ip_count']} different IPs',
        timestamp: DateTime.now(),
        metadata: suspiciousUser,
      ));
    }

    // Get API usage metrics
    final apiUsage = await getApiUsageMetrics(
      lookbackPeriod: const Duration(hours: 1),
    );

    // Alert on rate limit violations
    for (final suspicious in apiUsage.suspiciousActivity) {
      alerts.add(SecurityAlert(
        id: 'rate_limit_${suspicious['identifier']}',
        type: 'rate_limit_exceeded',
        severity: suspicious['severity'] as String,
        title: 'Rate Limit Exceeded',
        description:
            '${suspicious['type'] == 'user' ? 'User' : 'IP'} ${suspicious['identifier']} made ${suspicious['request_count']} requests in 1 hour',
        timestamp: DateTime.now(),
        metadata: suspicious,
      ));
    }

    // Get recent security events from audit log
    final securityEvents = await auditLogService.getSecurityEvents(
      lookbackPeriod: lookbackPeriod,
      limit: 100,
    );

    for (final event in securityEvents) {
      final metadata = event['metadata'] as String? ?? '{}';
      Map<String, dynamic> meta = {};

      try {
        meta = jsonDecode(metadata) as Map<String, dynamic>;
      } catch (e) {
        // Ignore parsing errors
      }

      alerts.add(SecurityAlert(
        id: 'security_event_${event['id']}',
        type: event['action'] as String,
        severity: meta['severity'] as String? ?? 'medium',
        title: meta['description'] as String? ?? 'Security Event',
        description: meta['description'] as String? ?? 'A security event occurred',
        timestamp: DateTime.parse(event['timestamp'] as String),
        metadata: meta,
      ));
    }

    // Sort by severity and timestamp
    alerts.sort((a, b) {
      final severityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
      final severityCompare = (severityOrder[a.severity] ?? 99)
          .compareTo(severityOrder[b.severity] ?? 99);

      if (severityCompare != 0) return severityCompare;

      return b.timestamp.compareTo(a.timestamp);
    });

    return alerts;
  }

  /// Get security dashboard summary
  Future<SecurityDashboardSummary> getDashboardSummary() async {
    final failedLogins = await getFailedLoginMetrics();
    final sessions = await getActiveSessionsMetrics();
    final apiUsage = await getApiUsageMetrics();
    final alerts = await getSecurityAlerts();

    // Count alerts by severity
    final criticalAlerts = alerts.where((a) => a.severity == 'critical').length;
    final highAlerts = alerts.where((a) => a.severity == 'high').length;
    final mediumAlerts = alerts.where((a) => a.severity == 'medium').length;

    return SecurityDashboardSummary(
      failedLoginAttempts: failedLogins.totalAttempts,
      activeSessions: sessions.totalActiveSessions,
      apiRequests: apiUsage.totalRequests,
      criticalAlerts: criticalAlerts,
      highAlerts: highAlerts,
      mediumAlerts: mediumAlerts,
      totalAlerts: alerts.length,
    );
  }
}

// Data classes for metrics

class FailedLoginMetrics {
  final int totalAttempts;
  final int uniqueIPs;
  final int uniqueUsers;
  final List<MapEntry<String, int>> topIPs;
  final List<MapEntry<String, int>> topUsers;
  final Map<String, int> timeDistribution;
  final List<Map<String, dynamic>> suspiciousIPs;

  FailedLoginMetrics({
    required this.totalAttempts,
    required this.uniqueIPs,
    required this.uniqueUsers,
    required this.topIPs,
    required this.topUsers,
    required this.timeDistribution,
    required this.suspiciousIPs,
  });
}

class ActiveSessionsMetrics {
  final int totalActiveSessions;
  final List<Map<String, dynamic>> activeSessions;
  final List<Map<String, dynamic>> suspiciousUsers;

  ActiveSessionsMetrics({
    required this.totalActiveSessions,
    required this.activeSessions,
    required this.suspiciousUsers,
  });
}

class ApiUsageMetrics {
  final int totalRequests;
  final double avgResponseTime;
  final List<MapEntry<String, int>> topActions;
  final List<MapEntry<String, int>> topUsers;
  final List<MapEntry<String, int>> topIPs;
  final List<Map<String, dynamic>> suspiciousActivity;

  ApiUsageMetrics({
    required this.totalRequests,
    required this.avgResponseTime,
    required this.topActions,
    required this.topUsers,
    required this.topIPs,
    required this.suspiciousActivity,
  });
}

class SecurityAlert {
  final String id;
  final String type;
  final String severity;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SecurityAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.metadata,
  });
}

class SecurityDashboardSummary {
  final int failedLoginAttempts;
  final int activeSessions;
  final int apiRequests;
  final int criticalAlerts;
  final int highAlerts;
  final int mediumAlerts;
  final int totalAlerts;

  SecurityDashboardSummary({
    required this.failedLoginAttempts,
    required this.activeSessions,
    required this.apiRequests,
    required this.criticalAlerts,
    required this.highAlerts,
    required this.mediumAlerts,
    required this.totalAlerts,
  });
}
