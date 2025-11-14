import 'package:flutter/material.dart';
import '../services/security_monitoring_service.dart';
import '../services/audit_log_service.dart';
import '../services/rate_limit_service.dart';
import '../widgets/breadcrumb_widget.dart';

/// Security Dashboard Page for monitoring authentication, sessions, and threats
///
/// Features:
/// - Real-time failed login attempt tracking
/// - Active sessions monitoring
/// - API usage patterns
/// - Security alerts and notifications
/// - Auto-refresh capability
class SecurityDashboardPage extends StatefulWidget {
  final String baseUrl;
  final String apiKey;
  final String docId;
  final String pageTitle;

  const SecurityDashboardPage({
    super.key,
    required this.baseUrl,
    required this.apiKey,
    required this.docId,
    this.pageTitle = 'Security Dashboard',
  });

  @override
  State<SecurityDashboardPage> createState() => _SecurityDashboardPageState();
}

class _SecurityDashboardPageState extends State<SecurityDashboardPage> {
  late SecurityMonitoringService _securityService;
  SecurityDashboardSummary? _summary;
  List<SecurityAlert>? _alerts;
  FailedLoginMetrics? _failedLoginMetrics;
  ActiveSessionsMetrics? _sessionsMetrics;
  ApiUsageMetrics? _apiMetrics;

  bool _isLoading = true;
  bool _autoRefresh = true;
  int _refreshInterval = 30; // seconds
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadData();
    _startAutoRefresh();
  }

  void _initializeServices() {
    final auditLogService = AuditLogService(
      baseUrl: widget.baseUrl,
      apiKey: widget.apiKey,
      docId: widget.docId,
    );

    final rateLimitService = RateLimitService(
      baseUrl: widget.baseUrl,
      apiKey: widget.apiKey,
      docId: widget.docId,
    );

    _securityService = SecurityMonitoringService(
      baseUrl: widget.baseUrl,
      apiKey: widget.apiKey,
      docId: widget.docId,
      auditLogService: auditLogService,
      rateLimitService: rateLimitService,
    );
  }

  void _startAutoRefresh() {
    if (_autoRefresh) {
      Future.delayed(Duration(seconds: _refreshInterval), () {
        if (mounted && _autoRefresh) {
          _loadData();
          _startAutoRefresh();
        }
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final summary = await _securityService.getDashboardSummary();
      final alerts = await _securityService.getSecurityAlerts();
      final failedLogins = await _securityService.getFailedLoginMetrics();
      final sessions = await _securityService.getActiveSessionsMetrics();
      final apiMetrics = await _securityService.getApiUsageMetrics();

      if (mounted) {
        setState(() {
          _summary = summary;
          _alerts = alerts;
          _failedLoginMetrics = failedLogins;
          _sessionsMetrics = sessions;
          _apiMetrics = apiMetrics;
          _isLoading = false;
          _lastRefresh = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
        actions: [
          // Auto-refresh toggle
          IconButton(
            icon: Icon(_autoRefresh ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _autoRefresh = !_autoRefresh;
                if (_autoRefresh) {
                  _startAutoRefresh();
                }
              });
            },
            tooltip: _autoRefresh ? 'Pause auto-refresh' : 'Resume auto-refresh',
          ),
          // Manual refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'Refresh now',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb
                    BreadcrumbWidget(
                      items: [
                        BreadcrumbItem(
                          label: 'Admin',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        BreadcrumbItem(
                          label: 'Security Dashboard',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Last refresh indicator
                    if (_lastRefresh != null)
                      Text(
                        'Last updated: ${_formatTime(_lastRefresh!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 16),

                    // Summary Cards
                    if (_summary != null) _buildSummaryCards(_summary!),
                    const SizedBox(height: 24),

                    // Security Alerts
                    if (_alerts != null && _alerts!.isNotEmpty)
                      _buildAlertsSection(_alerts!),
                    const SizedBox(height: 24),

                    // Failed Login Attempts
                    if (_failedLoginMetrics != null)
                      _buildFailedLoginsSection(_failedLoginMetrics!),
                    const SizedBox(height: 24),

                    // Active Sessions
                    if (_sessionsMetrics != null)
                      _buildActiveSessionsSection(_sessionsMetrics!),
                    const SizedBox(height: 24),

                    // API Usage
                    if (_apiMetrics != null)
                      _buildApiUsageSection(_apiMetrics!),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards(SecurityDashboardSummary summary) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildSummaryCard(
          title: 'Failed Logins (24h)',
          value: summary.failedLoginAttempts.toString(),
          icon: Icons.lock_outline,
          color: summary.failedLoginAttempts > 50 ? Colors.red : Colors.orange,
        ),
        _buildSummaryCard(
          title: 'Active Sessions',
          value: summary.activeSessions.toString(),
          icon: Icons.people_outline,
          color: Colors.blue,
        ),
        _buildSummaryCard(
          title: 'API Requests (1h)',
          value: summary.apiRequests.toString(),
          icon: Icons.api_outlined,
          color: Colors.green,
        ),
        _buildSummaryCard(
          title: 'Critical Alerts',
          value: summary.criticalAlerts.toString(),
          icon: Icons.warning_amber_rounded,
          color: summary.criticalAlerts > 0 ? Colors.red : Colors.grey,
        ),
        _buildSummaryCard(
          title: 'High Alerts',
          value: summary.highAlerts.toString(),
          icon: Icons.error_outline,
          color: summary.highAlerts > 0 ? Colors.orange : Colors.grey,
        ),
        _buildSummaryCard(
          title: 'Medium Alerts',
          value: summary.mediumAlerts.toString(),
          icon: Icons.info_outline,
          color: summary.mediumAlerts > 0 ? Colors.yellow.shade700 : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsSection(List<SecurityAlert> alerts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Security Alerts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length > 10 ? 10 : alerts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertTile(alert);
              },
            ),
            if (alerts.length > 10)
              TextButton(
                onPressed: () {
                  _showAllAlertsDialog(alerts);
                },
                child: Text('View all ${alerts.length} alerts'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTile(SecurityAlert alert) {
    Color severityColor;
    IconData severityIcon;

    switch (alert.severity) {
      case 'critical':
        severityColor = Colors.red;
        severityIcon = Icons.dangerous;
        break;
      case 'high':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case 'medium':
        severityColor = Colors.yellow.shade700;
        severityIcon = Icons.info;
        break;
      default:
        severityColor = Colors.grey;
        severityIcon = Icons.info_outline;
    }

    return ListTile(
      leading: Icon(severityIcon, color: severityColor),
      title: Text(alert.title),
      subtitle: Text(alert.description),
      trailing: Text(
        _formatTime(alert.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildFailedLoginsSection(FailedLoginMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.block, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Failed Login Attempts (24h)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Total Attempts',
                    metrics.totalAttempts.toString(),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Unique IPs',
                    metrics.uniqueIPs.toString(),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Unique Users',
                    metrics.uniqueUsers.toString(),
                  ),
                ),
              ],
            ),
            const Divider(),
            if (metrics.suspiciousIPs.isNotEmpty) ...[
              Text(
                'Suspicious IPs',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...metrics.suspiciousIPs.take(5).map((ip) {
                return Chip(
                  avatar: Icon(
                    Icons.warning,
                    color: ip['severity'] == 'critical'
                        ? Colors.red
                        : Colors.orange,
                  ),
                  label: Text('${ip['ip']}: ${ip['attempts']} attempts'),
                );
              }),
            ],
            if (metrics.topIPs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Top IPs by Failed Attempts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...metrics.topIPs.take(5).map((entry) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.computer),
                  title: Text(entry.key),
                  trailing: Text('${entry.value} attempts'),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionsSection(ActiveSessionsMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Active Sessions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.activeSessions.length > 10
                  ? 10
                  : metrics.activeSessions.length,
              itemBuilder: (context, index) {
                final session = metrics.activeSessions[index];
                return ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(session['username'] as String),
                  subtitle: Text(
                    'Last activity: ${_formatTime(DateTime.parse(session['last_activity'] as String))}',
                  ),
                  trailing: Chip(
                    label: Text(session['role'] as String? ?? 'user'),
                    backgroundColor: (session['role'] == 'admin')
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                  ),
                );
              },
            ),
            if (metrics.activeSessions.length > 10)
              TextButton(
                onPressed: () {
                  _showAllSessionsDialog(metrics.activeSessions);
                },
                child: Text('View all ${metrics.activeSessions.length} sessions'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiUsageSection(ApiUsageMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.api, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'API Usage (Last Hour)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Total Requests',
                    metrics.totalRequests.toString(),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Avg Response Time',
                    '${metrics.avgResponseTime.toStringAsFixed(1)}ms',
                  ),
                ),
              ],
            ),
            const Divider(),
            if (metrics.topActions.isNotEmpty) ...[
              Text(
                'Top Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...metrics.topActions.take(5).map((entry) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.arrow_right),
                  title: Text(entry.key),
                  trailing: Text('${entry.value} requests'),
                );
              }),
            ],
            if (metrics.suspiciousActivity.isNotEmpty) ...[
              const Divider(),
              Text(
                'Rate Limit Violations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
              const SizedBox(height: 8),
              ...metrics.suspiciousActivity.take(5).map((activity) {
                return Chip(
                  avatar: const Icon(Icons.warning, color: Colors.red),
                  label: Text(
                    '${activity['identifier']}: ${activity['request_count']} requests',
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  void _showAllAlertsDialog(List<SecurityAlert> alerts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Security Alerts'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) => _buildAlertTile(alerts[index]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAllSessionsDialog(List<Map<String, dynamic>> sessions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Active Sessions'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text(session['username'] as String),
                subtitle: Text(
                  'Last: ${_formatTime(DateTime.parse(session['last_activity'] as String))}',
                ),
                trailing: Text(session['role'] as String? ?? 'user'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _autoRefresh = false;
    super.dispose();
  }
}
