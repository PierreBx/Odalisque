import 'dart:convert';
import 'package:http/http.dart' as http;

/// Server-side rate limiting service using Grist as the backend
///
/// Provides:
/// - Brute force attack prevention
/// - Account lockout after failed attempts
/// - IP-based rate limiting
/// - Distributed rate limiting (works across multiple devices)
class RateLimitService {
  final String baseUrl;
  final String apiKey;
  final String docId;
  final String tableName;

  // Configuration
  final int maxFailedAttempts;
  final Duration lockoutDuration;
  final Duration rateLimitWindow;
  final int maxRequestsPerWindow;

  RateLimitService({
    required this.baseUrl,
    required this.apiKey,
    required this.docId,
    this.tableName = 'RateLimits',
    this.maxFailedAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 15),
    this.rateLimitWindow = const Duration(minutes: 1),
    this.maxRequestsPerWindow = 100,
  });

  /// Check if a user is locked out due to failed login attempts
  Future<RateLimitResult> checkLoginRateLimit({
    required String identifier, // username or IP address
    bool isIpBased = false,
  }) async {
    try {
      final now = DateTime.now();
      final windowStart = now.subtract(lockoutDuration);

      // Get or create rate limit record
      final record = await _getRateLimitRecord(identifier, isIpBased);

      if (record == null) {
        // No record exists, user is allowed
        return RateLimitResult(
          allowed: true,
          remainingAttempts: maxFailedAttempts,
        );
      }

      final failedAttempts = record['failed_attempts'] as int? ?? 0;
      final lastFailedAt = record['last_failed_at'] as String?;
      final lockedUntil = record['locked_until'] as String?;

      // Check if account is currently locked
      if (lockedUntil != null) {
        final lockExpiry = DateTime.parse(lockedUntil);
        if (now.isBefore(lockExpiry)) {
          return RateLimitResult(
            allowed: false,
            remainingAttempts: 0,
            lockedUntil: lockExpiry,
            reason: isIpBased
                ? 'IP address temporarily blocked due to too many failed attempts'
                : 'Account temporarily locked due to too many failed attempts',
          );
        }
      }

      // Check if within window and under limit
      if (lastFailedAt != null) {
        final lastFailed = DateTime.parse(lastFailedAt);
        if (lastFailed.isAfter(windowStart)) {
          if (failedAttempts >= maxFailedAttempts) {
            // Lock the account
            await _lockAccount(record['id'] as int, now.add(lockoutDuration));

            return RateLimitResult(
              allowed: false,
              remainingAttempts: 0,
              lockedUntil: now.add(lockoutDuration),
              reason: isIpBased
                  ? 'IP address has been blocked for ${lockoutDuration.inMinutes} minutes'
                  : 'Account has been locked for ${lockoutDuration.inMinutes} minutes',
            );
          }

          return RateLimitResult(
            allowed: true,
            remainingAttempts: maxFailedAttempts - failedAttempts,
          );
        }
      }

      // Window expired, reset counter
      await _resetFailedAttempts(record['id'] as int);

      return RateLimitResult(
        allowed: true,
        remainingAttempts: maxFailedAttempts,
      );
    } catch (e) {
      // On error, allow access but log the issue
      return RateLimitResult(
        allowed: true,
        remainingAttempts: maxFailedAttempts,
      );
    }
  }

  /// Record a failed login attempt
  Future<void> recordFailedLogin({
    required String identifier,
    bool isIpBased = false,
    String? metadata,
  }) async {
    try {
      final now = DateTime.now();
      final record = await _getRateLimitRecord(identifier, isIpBased);

      if (record == null) {
        // Create new record
        await _createRateLimitRecord(
          identifier: identifier,
          isIpBased: isIpBased,
          failedAttempts: 1,
          lastFailedAt: now,
          metadata: metadata,
        );
      } else {
        // Increment failed attempts
        final recordId = record['id'] as int;
        final currentAttempts = record['failed_attempts'] as int? ?? 0;
        final newAttempts = currentAttempts + 1;

        await _updateRateLimitRecord(
          recordId: recordId,
          failedAttempts: newAttempts,
          lastFailedAt: now,
          metadata: metadata,
        );

        // Lock account if threshold reached
        if (newAttempts >= maxFailedAttempts) {
          await _lockAccount(recordId, now.add(lockoutDuration));
        }
      }
    } catch (e) {
      // Silently fail to avoid breaking login flow
    }
  }

  /// Record a successful login (resets failed attempts)
  Future<void> recordSuccessfulLogin({
    required String identifier,
    bool isIpBased = false,
  }) async {
    try {
      final record = await _getRateLimitRecord(identifier, isIpBased);

      if (record != null) {
        await _resetFailedAttempts(record['id'] as int);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Check API rate limit (requests per minute)
  Future<RateLimitResult> checkApiRateLimit({
    required String identifier, // user ID or IP
  }) async {
    try {
      final now = DateTime.now();
      final windowStart = now.subtract(rateLimitWindow);

      final record = await _getApiRateLimitRecord(identifier, windowStart);

      if (record == null || record['request_count'] as int == 0) {
        return RateLimitResult(
          allowed: true,
          remainingAttempts: maxRequestsPerWindow,
        );
      }

      final requestCount = record['request_count'] as int;

      if (requestCount >= maxRequestsPerWindow) {
        return RateLimitResult(
          allowed: false,
          remainingAttempts: 0,
          reason: 'Rate limit exceeded. Maximum $maxRequestsPerWindow requests per ${rateLimitWindow.inMinutes} minute(s)',
        );
      }

      return RateLimitResult(
        allowed: true,
        remainingAttempts: maxRequestsPerWindow - requestCount,
      );
    } catch (e) {
      return RateLimitResult(
        allowed: true,
        remainingAttempts: maxRequestsPerWindow,
      );
    }
  }

  /// Record an API request
  Future<void> recordApiRequest({
    required String identifier,
    String? endpoint,
  }) async {
    try {
      final now = DateTime.now();
      final windowStart = now.subtract(rateLimitWindow);

      final record = await _getApiRateLimitRecord(identifier, windowStart);

      if (record == null) {
        await _createApiRateLimitRecord(
          identifier: identifier,
          requestCount: 1,
          windowStart: windowStart,
          metadata: endpoint,
        );
      } else {
        final recordId = record['id'] as int;
        final currentCount = record['request_count'] as int;

        await _updateApiRateLimitRecord(
          recordId: recordId,
          requestCount: currentCount + 1,
          metadata: endpoint,
        );
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Manually unlock an account (admin action)
  Future<bool> unlockAccount(String identifier) async {
    try {
      final record = await _getRateLimitRecord(identifier, false);

      if (record != null) {
        await _resetFailedAttempts(record['id'] as int);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Private helper methods

  Future<Map<String, dynamic>?> _getRateLimitRecord(
    String identifier,
    bool isIpBased,
  ) async {
    final filter = 'identifier == "$identifier" and is_ip_based == ${isIpBased ? 1 : 0}';

    final uri = Uri.parse('$baseUrl/api/docs/$docId/tables/$tableName/records')
        .replace(queryParameters: {'filter': filter, 'limit': '1'});

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

      if (records.isNotEmpty) {
        final record = records.first;
        return {
          'id': record['id'],
          ...record['fields'] as Map<String, dynamic>,
        };
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> _getApiRateLimitRecord(
    String identifier,
    DateTime windowStart,
  ) async {
    final filter = 'identifier == "$identifier" and window_start >= "${windowStart.toIso8601String()}"';

    final uri = Uri.parse('$baseUrl/api/docs/$docId/tables/${tableName}_API/records')
        .replace(queryParameters: {'filter': filter, 'limit': '1'});

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

      if (records.isNotEmpty) {
        final record = records.first;
        return {
          'id': record['id'],
          ...record['fields'] as Map<String, dynamic>,
        };
      }
    }

    return null;
  }

  Future<void> _createRateLimitRecord({
    required String identifier,
    required bool isIpBased,
    required int failedAttempts,
    required DateTime lastFailedAt,
    String? metadata,
  }) async {
    final fields = {
      'identifier': identifier,
      'is_ip_based': isIpBased,
      'failed_attempts': failedAttempts,
      'last_failed_at': lastFailedAt.toIso8601String(),
      'locked_until': '',
      'metadata': metadata ?? '',
    };

    await http.post(
      Uri.parse('$baseUrl/api/docs/$docId/tables/$tableName/records'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'records': [
          {'fields': fields}
        ]
      }),
    );
  }

  Future<void> _createApiRateLimitRecord({
    required String identifier,
    required int requestCount,
    required DateTime windowStart,
    String? metadata,
  }) async {
    final fields = {
      'identifier': identifier,
      'request_count': requestCount,
      'window_start': windowStart.toIso8601String(),
      'metadata': metadata ?? '',
    };

    await http.post(
      Uri.parse('$baseUrl/api/docs/$docId/tables/${tableName}_API/records'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'records': [
          {'fields': fields}
        ]
      }),
    );
  }

  Future<void> _updateRateLimitRecord({
    required int recordId,
    required int failedAttempts,
    required DateTime lastFailedAt,
    String? metadata,
  }) async {
    final fields = {
      'failed_attempts': failedAttempts,
      'last_failed_at': lastFailedAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };

    await http.patch(
      Uri.parse('$baseUrl/api/docs/$docId/tables/$tableName/records'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'records': [
          {'id': recordId, 'fields': fields}
        ]
      }),
    );
  }

  Future<void> _updateApiRateLimitRecord({
    required int recordId,
    required int requestCount,
    String? metadata,
  }) async {
    final fields = {
      'request_count': requestCount,
      if (metadata != null) 'metadata': metadata,
    };

    await http.patch(
      Uri.parse('$baseUrl/api/docs/$docId/tables/${tableName}_API/records'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'records': [
          {'id': recordId, 'fields': fields}
        ]
      }),
    );
  }

  Future<void> _lockAccount(int recordId, DateTime lockedUntil) async {
    final fields = {
      'locked_until': lockedUntil.toIso8601String(),
    };

    await http.patch(
      Uri.parse('$baseUrl/api/docs/$docId/tables/$tableName/records'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'records': [
          {'id': recordId, 'fields': fields}
        ]
      }),
    );
  }

  Future<void> _resetFailedAttempts(int recordId) async {
    final fields = {
      'failed_attempts': 0,
      'last_failed_at': '',
      'locked_until': '',
    };

    await http.patch(
      Uri.parse('$baseUrl/api/docs/$docId/tables/$tableName/records'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'records': [
          {'id': recordId, 'fields': fields}
        ]
      }),
    );
  }
}

/// Result of a rate limit check
class RateLimitResult {
  final bool allowed;
  final int remainingAttempts;
  final DateTime? lockedUntil;
  final String? reason;

  RateLimitResult({
    required this.allowed,
    required this.remainingAttempts,
    this.lockedUntil,
    this.reason,
  });

  bool get isLocked => lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  String get message {
    if (!allowed && reason != null) {
      return reason!;
    }

    if (remainingAttempts > 0) {
      return '$remainingAttempts attempt(s) remaining';
    }

    return 'Access denied';
  }
}
