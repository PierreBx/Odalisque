import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'audit_log_service.dart';
import 'security_monitoring_service.dart';

/// Security Alert Service for real-time notifications
///
/// Provides:
/// - Email alerts for security events
/// - Push notifications for critical alerts
/// - Alert throttling to prevent spam
/// - Configurable severity thresholds
/// - Multi-channel notification delivery
class SecurityAlertService {
  final EmailAlertConfig? emailConfig;
  final PushNotificationConfig? pushConfig;
  final AuditLogService? _auditLogService;

  // Alert throttling
  final Map<String, DateTime> _lastAlertTimes = {};
  final Duration throttleDuration;

  SecurityAlertService({
    this.emailConfig,
    this.pushConfig,
    AuditLogService? auditLogService,
    this.throttleDuration = const Duration(hours: 1),
  }) : _auditLogService = auditLogService;

  /// Send a security alert via configured channels
  Future<AlertResult> sendAlert({
    required SecurityAlert alert,
    List<String> emailRecipients = const [],
    List<String> pushTokens = const [],
    bool forceEmail = false,
    bool forcePush = false,
  }) async {
    // Check if we should throttle this alert
    if (!forceEmail && !forcePush && _shouldThrottle(alert)) {
      return AlertResult(
        emailSent: false,
        pushSent: false,
        message: 'Alert throttled',
      );
    }

    final results = AlertResult();

    // Send email alert
    if (emailConfig != null && emailRecipients.isNotEmpty) {
      final emailSent = await _sendEmailAlert(
        alert: alert,
        recipients: emailRecipients,
      );
      results.emailSent = emailSent;
    }

    // Send push notification
    if (pushConfig != null && pushTokens.isNotEmpty) {
      final pushSent = await _sendPushAlert(
        alert: alert,
        tokens: pushTokens,
      );
      results.pushSent = pushSent;
    }

    // Update throttle timestamp
    _lastAlertTimes[alert.id] = DateTime.now();

    // Log alert sent
    await _auditLogService?.logSecurityEvent(
      action: 'SECURITY_ALERT_SENT',
      description: alert.description,
      severity: alert.severity,
      metadata: {
        'alert_type': alert.type,
        'email_sent': results.emailSent,
        'push_sent': results.pushSent,
        'recipients_count': emailRecipients.length,
      },
    );

    return results;
  }

  /// Send multiple alerts for a list of security events
  Future<List<AlertResult>> sendAlerts({
    required List<SecurityAlert> alerts,
    required List<String> emailRecipients,
    required List<String> pushTokens,
    String? severityThreshold, // Only send alerts at or above this severity
  }) async {
    final results = <AlertResult>[];

    // Filter by severity if threshold is set
    var filteredAlerts = alerts;
    if (severityThreshold != null) {
      filteredAlerts = alerts.where((alert) {
        return _getSeverityLevel(alert.severity) >= _getSeverityLevel(severityThreshold);
      }).toList();
    }

    for (final alert in filteredAlerts) {
      final result = await sendAlert(
        alert: alert,
        emailRecipients: emailRecipients,
        pushTokens: pushTokens,
      );
      results.add(result);
    }

    return results;
  }

  /// Send daily security summary
  Future<bool> sendDailySummary({
    required SecurityDashboardSummary summary,
    required List<SecurityAlert> alerts,
    required List<String> emailRecipients,
  }) async {
    if (emailConfig == null || emailRecipients.isEmpty) {
      return false;
    }

    final html = _buildDailySummaryHtml(summary, alerts);

    try {
      final smtpServer = _getSmtpServer();
      final message = Message()
        ..from = Address(emailConfig!.fromEmail, emailConfig!.fromName)
        ..recipients.addAll(emailRecipients)
        ..subject = 'Daily Security Summary - ${DateTime.now().toString().split(' ')[0]}'
        ..html = html;

      final sendReport = await send(message, smtpServer);

      await _auditLogService?.logSecurityEvent(
        action: 'DAILY_SUMMARY_SENT',
        description: 'Daily security summary email sent',
        severity: 'low',
        metadata: {
          'recipients_count': emailRecipients.length,
          'alerts_count': alerts.length,
        },
      );

      return true;
    } catch (e) {
      await _auditLogService?.logSecurityEvent(
        action: 'DAILY_SUMMARY_FAILED',
        description: 'Failed to send daily summary: $e',
        severity: 'medium',
      );

      return false;
    }
  }

  /// Check if alert should be throttled
  bool _shouldThrottle(SecurityAlert alert) {
    final lastAlert = _lastAlertTimes[alert.id];

    if (lastAlert == null) {
      return false;
    }

    final timeSinceLastAlert = DateTime.now().difference(lastAlert);
    return timeSinceLastAlert < throttleDuration;
  }

  /// Send email alert
  Future<bool> _sendEmailAlert({
    required SecurityAlert alert,
    required List<String> recipients,
  }) async {
    if (emailConfig == null) {
      return false;
    }

    try {
      final smtpServer = _getSmtpServer();

      final html = _buildAlertEmailHtml(alert);

      final message = Message()
        ..from = Address(emailConfig!.fromEmail, emailConfig!.fromName)
        ..recipients.addAll(recipients)
        ..subject = '[${alert.severity.toUpperCase()}] ${alert.title}'
        ..html = html;

      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Send push notification alert
  Future<bool> _sendPushAlert({
    required SecurityAlert alert,
    required List<String> tokens,
  }) async {
    if (pushConfig == null) {
      return false;
    }

    try {
      // Send to Firebase Cloud Messaging
      for (final token in tokens) {
        await _sendFCMNotification(
          token: token,
          title: alert.title,
          body: alert.description,
          data: {
            'alert_id': alert.id,
            'severity': alert.severity,
            'type': alert.type,
            'timestamp': alert.timestamp.toIso8601String(),
          },
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Send FCM notification
  Future<void> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    if (pushConfig == null || pushConfig!.fcmServerKey == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=${pushConfig!.fcmServerKey}',
      },
      body: jsonEncode({
        'to': token,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
          'priority': 'high',
        },
        if (data != null) 'data': data,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('FCM notification failed: ${response.body}');
    }
  }

  /// Get SMTP server configuration
  SmtpServer _getSmtpServer() {
    if (emailConfig == null) {
      throw Exception('Email configuration not set');
    }

    switch (emailConfig!.provider) {
      case 'gmail':
        return gmail(emailConfig!.username, emailConfig!.password);
      case 'smtp':
        return SmtpServer(
          emailConfig!.smtpHost!,
          port: emailConfig!.smtpPort,
          ssl: emailConfig!.useSsl,
          username: emailConfig!.username,
          password: emailConfig!.password,
        );
      default:
        throw Exception('Unknown email provider: ${emailConfig!.provider}');
    }
  }

  /// Build alert email HTML
  String _buildAlertEmailHtml(SecurityAlert alert) {
    final severityColor = _getSeverityColor(alert.severity);

    return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: $severityColor; color: white; padding: 20px; border-radius: 5px 5px 0 0; }
    .content { background: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; }
    .alert-info { background: white; padding: 15px; border-left: 4px solid $severityColor; margin: 10px 0; }
    .footer { text-align: center; color: #777; margin-top: 20px; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>🔒 Security Alert: ${alert.title}</h2>
      <p style="margin: 0;">Severity: ${alert.severity.toUpperCase()}</p>
    </div>
    <div class="content">
      <div class="alert-info">
        <p><strong>Description:</strong></p>
        <p>${alert.description}</p>

        <p><strong>Alert Type:</strong> ${alert.type}</p>
        <p><strong>Timestamp:</strong> ${alert.timestamp}</p>

        ${alert.metadata.isNotEmpty ? '<p><strong>Additional Information:</strong></p><pre>${jsonEncode(alert.metadata)}</pre>' : ''}
      </div>

      <p><strong>Recommended Action:</strong></p>
      <p>${_getRecommendedAction(alert)}</p>
    </div>
    <div class="footer">
      <p>This is an automated security alert from Odalisque Security Monitor</p>
      <p>Please do not reply to this email</p>
    </div>
  </div>
</body>
</html>
''';
  }

  /// Build daily summary email HTML
  String _buildDailySummaryHtml(
    SecurityDashboardSummary summary,
    List<SecurityAlert> alerts,
  ) {
    final criticalAlerts = alerts.where((a) => a.severity == 'critical').toList();
    final highAlerts = alerts.where((a) => a.severity == 'high').toList();

    return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 700px; margin: 0 auto; padding: 20px; }
    .header { background: #2c3e50; color: white; padding: 20px; border-radius: 5px; }
    .metrics { display: flex; flex-wrap: wrap; gap: 10px; margin: 20px 0; }
    .metric { flex: 1; min-width: 200px; background: #ecf0f1; padding: 15px; border-radius: 5px; }
    .metric-value { font-size: 24px; font-weight: bold; color: #2c3e50; }
    .alerts-section { margin: 20px 0; }
    .alert-item { background: #fff; border-left: 4px solid #e74c3c; padding: 10px; margin: 10px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>📊 Daily Security Summary</h2>
      <p style="margin: 0;">${DateTime.now().toString().split(' ')[0]}</p>
    </div>

    <div class="metrics">
      <div class="metric">
        <div class="metric-value">${summary.failedLoginAttempts}</div>
        <div>Failed Login Attempts</div>
      </div>
      <div class="metric">
        <div class="metric-value">${summary.activeSessions}</div>
        <div>Active Sessions</div>
      </div>
      <div class="metric">
        <div class="metric-value">${summary.apiRequests}</div>
        <div>API Requests (1h)</div>
      </div>
      <div class="metric">
        <div class="metric-value">${summary.totalAlerts}</div>
        <div>Total Alerts</div>
      </div>
    </div>

    ${criticalAlerts.isNotEmpty ? '''
    <div class="alerts-section">
      <h3 style="color: #e74c3c;">🚨 Critical Alerts (${criticalAlerts.length})</h3>
      ${criticalAlerts.map((a) => '<div class="alert-item"><strong>${a.title}</strong><br>${a.description}</div>').join('')}
    </div>
    ''' : ''}

    ${highAlerts.isNotEmpty ? '''
    <div class="alerts-section">
      <h3 style="color: #f39c12;">⚠️ High Priority Alerts (${highAlerts.length})</h3>
      ${highAlerts.map((a) => '<div class="alert-item" style="border-color: #f39c12;"><strong>${a.title}</strong><br>${a.description}</div>').join('')}
    </div>
    ''' : ''}

    <p style="margin-top: 20px; color: #777; font-size: 12px;">
      This is an automated daily security summary from Odalisque Security Monitor
    </p>
  </div>
</body>
</html>
''';
  }

  /// Get severity level as integer for comparison
  int _getSeverityLevel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  /// Get severity color for HTML
  String _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return '#e74c3c';
      case 'high':
        return '#f39c12';
      case 'medium':
        return '#f1c40f';
      default:
        return '#3498db';
    }
  }

  /// Get recommended action for alert
  String _getRecommendedAction(SecurityAlert alert) {
    switch (alert.type) {
      case 'brute_force_attempt':
        return 'Review the IP address and consider adding it to the blocklist. Check if the account needs additional protection.';
      case 'suspicious_activity':
        return 'Investigate the user activity and verify if it is legitimate. Consider contacting the user if necessary.';
      case 'rate_limit_exceeded':
        return 'Review the API usage patterns and determine if this is abuse or a legitimate spike in traffic.';
      case 'certificate_pinning_failure':
        return 'CRITICAL: Possible Man-in-the-Middle attack. Investigate immediately and verify SSL certificates.';
      default:
        return 'Review the security logs and take appropriate action based on the alert details.';
    }
  }
}

/// Email alert configuration
class EmailAlertConfig {
  final String provider; // 'gmail' or 'smtp'
  final String fromEmail;
  final String fromName;
  final String username;
  final String password;

  // SMTP-specific
  final String? smtpHost;
  final int smtpPort;
  final bool useSsl;

  EmailAlertConfig({
    required this.provider,
    required this.fromEmail,
    required this.fromName,
    required this.username,
    required this.password,
    this.smtpHost,
    this.smtpPort = 587,
    this.useSsl = true,
  });

  factory EmailAlertConfig.gmail({
    required String email,
    required String appPassword,
    String name = 'Odalisque Security',
  }) {
    return EmailAlertConfig(
      provider: 'gmail',
      fromEmail: email,
      fromName: name,
      username: email,
      password: appPassword,
    );
  }

  factory EmailAlertConfig.smtp({
    required String host,
    required int port,
    required String email,
    required String username,
    required String password,
    String name = 'Odalisque Security',
    bool useSsl = true,
  }) {
    return EmailAlertConfig(
      provider: 'smtp',
      fromEmail: email,
      fromName: name,
      username: username,
      password: password,
      smtpHost: host,
      smtpPort: port,
      useSsl: useSsl,
    );
  }
}

/// Push notification configuration
class PushNotificationConfig {
  final String? fcmServerKey;
  final FirebaseMessaging? messaging;

  PushNotificationConfig({
    this.fcmServerKey,
    this.messaging,
  });
}

/// Alert result
class AlertResult {
  bool emailSent;
  bool pushSent;
  String message;

  AlertResult({
    this.emailSent = false,
    this.pushSent = false,
    this.message = '',
  });

  bool get success => emailSent || pushSent;
}
