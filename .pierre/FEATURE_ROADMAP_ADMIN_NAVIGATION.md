# Feature Roadmap: Complete Admin Dashboard & Advanced Navigation

**Project:** Odalisque
**Version:** 0.12.0 (Target)
**Date:** 2025-11-14
**Priority:** High
**Estimated Effort:** 10-12 days total

---

## Executive Summary

This roadmap outlines the implementation of two critical features for Odalisque:

1. **Complete Admin Dashboard** - Real-time monitoring, active users, performance metrics, system health
2. **Advanced Navigation** - Deep linking, breadcrumb navigation, tab-based navigation

These features will transform Odalisque into an enterprise-grade application framework with professional-level operations visibility and user experience.

---

## Current State Analysis

### Admin Dashboard (Partially Implemented)
**File:** `flutter-module/lib/src/pages/admin_dashboard_page.dart`

**What Exists:**
- ✅ System information display (app name, version, Grist document ID)
- ✅ Database summary with table list
- ✅ Record count per table
- ✅ Refresh capability (pull-to-refresh)
- ✅ Error handling with retry

**What's Missing:**
- ❌ Real-time updates (auto-refresh)
- ❌ Active users widget
- ❌ Last modified timestamps
- ❌ Performance metrics (response times, query counts)
- ❌ System health indicators (CPU, memory, disk)
- ❌ Charts and visualizations
- ❌ Activity feed
- ❌ Audit log viewer

### Navigation (Basic Implementation)
**File:** `flutter-module/lib/src/pages/home_page.dart`

**What Exists:**
- ✅ Drawer navigation with icons
- ✅ Conditional visibility based on roles
- ✅ Simple page navigation via state management

**What's Missing:**
- ❌ Deep linking (URL-based navigation)
- ❌ Breadcrumb navigation
- ❌ Tab-based navigation
- ❌ Browser back/forward support
- ❌ Shareable URLs for specific records
- ❌ Navigation history
- ❌ Bookmarkable pages

---

## Feature 1: Complete Admin Dashboard

### 1.1 Real-Time Updates ⭐
**Priority:** High
**Effort:** 1-2 days

**Implementation:**
```dart
class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
```

**Features:**
- Configurable refresh interval (15s, 30s, 60s)
- Visual indicator showing last refresh time
- Pause/resume auto-refresh toggle
- Loading indicator during background refresh (non-blocking)

**YAML Configuration:**
```yaml
pages:
  - id: "admin_dashboard"
    type: "admin_dashboard"
    title: "Admin Dashboard"
    config:
      auto_refresh:
        enabled: true
        interval_seconds: 30
        show_last_refresh: true
```

---

### 1.2 Active Users Widget ⭐
**Priority:** High
**Effort:** 2-3 days

**Data Model:**
```dart
class ActiveSession {
  final String userId;
  final String email;
  final String role;
  final DateTime lastActivity;
  final String ipAddress;
  final String userAgent;
  final bool isActive; // Active in last 5 minutes
}
```

**Implementation Approach:**
- Store session data in Grist "Sessions" table
- Update `lastActivity` timestamp on each API call
- Query sessions active in last 5 minutes
- Display user count + list of active users

**UI Components:**
```dart
// Active users card
Card(
  child: Column(
    children: [
      Text('Active Users: ${activeSessions.length}'),
      Divider(),
      ...activeSessions.map((session) => ListTile(
        leading: Icon(Icons.person),
        title: Text(session.email),
        subtitle: Text('Last active: ${_formatDuration(session.lastActivity)}'),
        trailing: Icon(Icons.circle, color: session.isActive ? Colors.green : Colors.orange),
      )),
    ],
  ),
)
```

**Grist Schema Addition:**
```yaml
# New table: Sessions
Sessions:
  columns:
    - session_id (Text)
    - user_id (Ref to Users)
    - email (Text)
    - role (Text)
    - last_activity (DateTime)
    - ip_address (Text)
    - user_agent (Text)
    - login_time (DateTime)
```

---

### 1.3 Performance Metrics Widget ⭐
**Priority:** Medium
**Effort:** 2-3 days

**Metrics to Track:**
- Average API response time (last 100 requests)
- Total requests (today, this week)
- Error rate (percentage)
- Slow queries (>1s)
- Most accessed tables
- Peak usage times

**Data Collection:**
- Enhance GristService to track timing
- Store metrics in memory (last 1000 requests)
- Aggregate statistics

**Implementation:**
```dart
class PerformanceMetrics {
  final List<RequestLog> recentRequests = [];

  void logRequest(String endpoint, Duration duration, bool success) {
    recentRequests.add(RequestLog(
      endpoint: endpoint,
      duration: duration,
      timestamp: DateTime.now(),
      success: success,
    ));

    // Keep only last 1000
    if (recentRequests.length > 1000) {
      recentRequests.removeAt(0);
    }
  }

  double get avgResponseTime {
    if (recentRequests.isEmpty) return 0;
    return recentRequests
      .map((r) => r.duration.inMilliseconds)
      .reduce((a, b) => a + b) / recentRequests.length;
  }

  double get errorRate {
    if (recentRequests.isEmpty) return 0;
    final errors = recentRequests.where((r) => !r.success).length;
    return (errors / recentRequests.length) * 100;
  }
}
```

**UI with Charts:**
```dart
// Use fl_chart package
Card(
  child: Column(
    children: [
      Text('Performance Metrics'),
      SizedBox(height: 16),
      Row(
        children: [
          _buildMetricCard('Avg Response', '${metrics.avgResponseTime}ms'),
          _buildMetricCard('Error Rate', '${metrics.errorRate}%'),
          _buildMetricCard('Total Requests', '${metrics.totalRequests}'),
        ],
      ),
      LineChart(...), // Response time trend
    ],
  ),
)
```

---

### 1.4 System Health Indicators ⭐
**Priority:** Medium
**Effort:** 1-2 days

**Metrics:**
- Grist API status (reachable / unreachable)
- Database connectivity
- Last successful backup time
- Disk usage (if available via API)
- Memory usage (client-side)

**Implementation:**
```dart
class SystemHealth {
  bool gristApiReachable = false;
  bool databaseConnected = false;
  DateTime? lastBackup;
  String status; // healthy, degraded, down

  Future<void> checkHealth() async {
    try {
      // Ping Grist API
      await gristService.fetchTables();
      gristApiReachable = true;
      databaseConnected = true;
    } catch (e) {
      gristApiReachable = false;
      databaseConnected = false;
    }

    status = (gristApiReachable && databaseConnected) ? 'healthy' : 'degraded';
  }
}
```

**UI:**
```dart
Card(
  color: health.status == 'healthy' ? Colors.green.shade50 : Colors.red.shade50,
  child: Column(
    children: [
      Icon(
        health.status == 'healthy' ? Icons.check_circle : Icons.error,
        color: health.status == 'healthy' ? Colors.green : Colors.red,
        size: 48,
      ),
      Text('System Status: ${health.status.toUpperCase()}'),
      Divider(),
      _buildHealthRow('Grist API', health.gristApiReachable),
      _buildHealthRow('Database', health.databaseConnected),
    ],
  ),
)
```

---

### 1.5 Activity Feed Widget ⭐
**Priority:** Low
**Effort:** 2 days

**Features:**
- Recent user actions (from audit log)
- Recent record changes (create/update/delete)
- System events (login/logout)
- Limit to last 50 events

**Implementation:**
```dart
// Use existing AuditLogger
final recentLogs = await AuditLogger.getLogs(limit: 50);

ListView.builder(
  itemCount: recentLogs.length,
  itemBuilder: (context, index) {
    final log = recentLogs[index];
    return ListTile(
      leading: _getActionIcon(log.action),
      title: Text('${log.userId} - ${log.action}'),
      subtitle: Text(log.details),
      trailing: Text(_formatTimestamp(log.timestamp)),
    );
  },
)
```

---

### 1.6 Charts & Visualizations 📊
**Priority:** Low
**Effort:** 2-3 days

**Dependencies:**
- `fl_chart: ^0.66.0` - Professional charts

**Charts to Add:**
1. **Line Chart**: Response time over time (last 100 requests)
2. **Bar Chart**: Requests per table
3. **Pie Chart**: Records by table
4. **Sparklines**: Trend indicators (↑↓)

**Implementation:**
```dart
import 'package:fl_chart/fl_chart.dart';

LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: metrics.recentRequests
          .asMap()
          .entries
          .map((e) => FlSpot(
            e.key.toDouble(),
            e.value.duration.inMilliseconds.toDouble(),
          ))
          .toList(),
      ),
    ],
  ),
)
```

---

## Feature 2: Advanced Navigation

### 2.1 Deep Linking (URL-based Navigation) ⭐⭐⭐
**Priority:** Critical
**Effort:** 3-4 days

**Goals:**
- Navigate to specific pages via URL
- Navigate to specific records (e.g., `/orders/123`)
- Shareable URLs
- Browser back/forward support
- Bookmarkable pages

**Implementation with go_router:**
```dart
// Add dependency: go_router: ^13.0.0

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(config: appConfig),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(config: appConfig),
    ),
    GoRoute(
      path: '/page/:pageId',
      builder: (context, state) {
        final pageId = state.pathParameters['pageId']!;
        return HomePage(config: appConfig, initialPageId: pageId);
      },
    ),
    GoRoute(
      path: '/page/:pageId/record/:recordId',
      builder: (context, state) {
        final pageId = state.pathParameters['pageId']!;
        final recordId = state.pathParameters['recordId']!;
        return HomePage(
          config: appConfig,
          initialPageId: pageId,
          recordId: recordId,
        );
      },
    ),
  ],
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;

    if (!isLoggedIn && state.location != '/login') {
      return '/login';
    }

    return null;
  },
);
```

**Updated main.dart:**
```dart
MaterialApp.router(
  routerConfig: router,
  theme: themeProvider.getTheme(isDark: false),
  darkTheme: themeProvider.getTheme(isDark: true),
)
```

**URL Structure:**
- `/` - Home page (first visible page)
- `/login` - Login page
- `/page/dashboard` - Specific page by ID
- `/page/orders/record/123` - Specific record
- `/admin` - Admin dashboard

---

### 2.2 Breadcrumb Navigation ⭐
**Priority:** High
**Effort:** 2 days

**Features:**
- Show navigation path (Home > Orders > Order #123)
- Clickable breadcrumb links
- Auto-generated from current route
- Customizable separator

**Implementation:**
```dart
class BreadcrumbWidget extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final String separator;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          InkWell(
            onTap: items[i].onTap,
            child: Text(
              items[i].label,
              style: TextStyle(
                color: i == items.length - 1
                  ? Theme.of(context).textTheme.bodyLarge!.color
                  : Colors.blue,
                fontWeight: i == items.length - 1
                  ? FontWeight.bold
                  : FontWeight.normal,
              ),
            ),
          ),
          if (i < items.length - 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(separator),
            ),
        ],
      ],
    );
  }
}

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  BreadcrumbItem({required this.label, this.onTap});
}
```

**Usage:**
```dart
// In HomePage AppBar
AppBar(
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(currentPage.title),
      BreadcrumbWidget(
        items: _buildBreadcrumbs(),
        separator: '›',
      ),
    ],
  ),
)
```

---

### 2.3 Tab-Based Navigation ⭐
**Priority:** Medium
**Effort:** 2-3 days

**Features:**
- Group related pages in tabs
- Persistent tab state
- Configurable via YAML
- Swipe navigation on mobile

**YAML Configuration:**
```yaml
navigation:
  tabs:
    enabled: true
    position: "top"  # top or bottom
    groups:
      - id: "main"
        label: "Main"
        icon: "home"
        pages: ["dashboard", "orders"]
      - id: "admin"
        label: "Admin"
        icon: "admin_panel_settings"
        pages: ["admin_dashboard", "users"]
```

**Implementation:**
```dart
class TabbedHomePage extends StatefulWidget {
  final AppConfig config;

  @override
  State<TabbedHomePage> createState() => _TabbedHomePageState();
}

class _TabbedHomePageState extends State<TabbedHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabGroups = widget.config.navigation.tabs?.groups ?? [];
    _tabController = TabController(length: tabGroups.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final tabGroups = widget.config.navigation.tabs?.groups ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.app.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabGroups.map((group) => Tab(
            icon: Icon(_getIconData(group.icon)),
            text: group.label,
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabGroups.map((group) =>
          _buildTabContent(group)
        ).toList(),
      ),
    );
  }

  Widget _buildTabContent(TabGroup group) {
    return ListView(
      children: group.pages.map((pageId) {
        final page = widget.config.pages.firstWhere((p) => p.id == pageId);
        return ListTile(
          title: Text(page.title),
          onTap: () => _navigateToPage(pageId),
        );
      }).toList(),
    );
  }
}
```

---

### 2.4 Navigation History ⭐
**Priority:** Low
**Effort:** 1 day

**Features:**
- Track navigation history
- Back button support (custom)
- Forward navigation
- Clear history option

**Implementation:**
```dart
class NavigationHistory {
  final List<NavigationEntry> _history = [];
  int _currentIndex = -1;

  void push(String pageId, Map<String, dynamic>? params) {
    // Remove forward history when pushing
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    _history.add(NavigationEntry(pageId, params));
    _currentIndex++;
  }

  NavigationEntry? back() {
    if (canGoBack) {
      _currentIndex--;
      return _history[_currentIndex];
    }
    return null;
  }

  NavigationEntry? forward() {
    if (canGoForward) {
      _currentIndex++;
      return _history[_currentIndex];
    }
    return null;
  }

  bool get canGoBack => _currentIndex > 0;
  bool get canGoForward => _currentIndex < _history.length - 1;
}
```

---

## Implementation Plan

### Phase 1: Admin Dashboard Enhancements (Week 1)
**Duration:** 5 days

- **Day 1**: Real-time auto-refresh + last refresh indicator
- **Day 2-3**: Active users widget + Sessions table
- **Day 3-4**: Performance metrics tracking + UI
- **Day 5**: System health indicators + testing

**Deliverables:**
- Auto-refreshing admin dashboard
- Active users list with real-time updates
- Performance metrics cards
- System health status

---

### Phase 2: Advanced Navigation - Deep Links (Week 2)
**Duration:** 4 days

- **Day 1**: Integrate go_router package
- **Day 2**: Define all routes (/, /login, /page/:pageId, etc.)
- **Day 3**: Update HomePage to support initial route params
- **Day 4**: Browser back/forward testing + bug fixes

**Deliverables:**
- Shareable URLs for all pages
- Browser back/forward support
- Bookmarkable pages

---

### Phase 3: Breadcrumbs & Tabs (Week 2 cont.)
**Duration:** 3 days

- **Day 5**: Breadcrumb widget + route-based generation
- **Day 6**: Tab-based navigation implementation
- **Day 7**: YAML configuration + testing

**Deliverables:**
- Breadcrumb navigation in AppBar
- Tab-based page grouping
- YAML-configurable tabs

---

### Phase 4: Polish & Charts (Optional - Week 3)
**Duration:** 2-3 days

- **Day 1-2**: Add fl_chart package + charts in admin dashboard
- **Day 3**: Activity feed widget + audit log integration

**Deliverables:**
- Visual charts for metrics
- Activity feed with recent events

---

## New Dependencies

```yaml
dependencies:
  # Navigation
  go_router: ^13.0.0

  # Charts (optional)
  fl_chart: ^0.66.0
```

---

## Configuration Schema Updates

### New NavigationSettings
```dart
class NavigationSettings {
  final TabsConfig? tabs;
  final BreadcrumbsConfig? breadcrumbs;

  // Existing fields...
}

class TabsConfig {
  final bool enabled;
  final String position; // 'top' or 'bottom'
  final List<TabGroup> groups;
}

class TabGroup {
  final String id;
  final String label;
  final String icon;
  final List<String> pages;
}

class BreadcrumbsConfig {
  final bool enabled;
  final String separator;
  final bool showHome;
}
```

---

## Testing Strategy

### Unit Tests
- Navigation history (back/forward)
- Breadcrumb generation from routes
- Performance metrics calculations
- System health status determination

### Widget Tests
- Admin dashboard with mocked data
- Breadcrumb widget rendering
- Tab navigation behavior
- Active users list

### Integration Tests
- Deep link navigation
- Tab switching with state preservation
- Auto-refresh behavior
- Performance tracking accuracy

---

## Success Metrics

| Metric | Before | After Target |
|--------|--------|--------------|
| **Admin Dashboard Features** | 3 | 8+ |
| **Navigation Methods** | 1 (drawer) | 4 (drawer, deep links, breadcrumbs, tabs) |
| **Real-time Updates** | Manual refresh only | Auto-refresh every 30s |
| **URL Navigation** | ❌ | ✅ Full deep linking |
| **Active User Visibility** | ❌ | ✅ Real-time display |
| **Performance Monitoring** | ❌ | ✅ Metrics + charts |

---

## Migration Guide

### For Existing Apps

**Navigation Updates:**
```yaml
# Old (still supported)
navigation:
  drawer_header:
    title: "My App"

# New (enhanced)
navigation:
  drawer_header:
    title: "My App"
  tabs:
    enabled: true
    position: "top"
    groups:
      - id: "main"
        label: "Main"
        pages: ["dashboard", "orders"]
  breadcrumbs:
    enabled: true
    separator: "›"
```

**Admin Dashboard Updates:**
```yaml
# Old (still supported)
pages:
  - id: "admin"
    type: "admin_dashboard"

# New (enhanced)
pages:
  - id: "admin"
    type: "admin_dashboard"
    config:
      auto_refresh:
        enabled: true
        interval_seconds: 30
      widgets:
        - type: "active_users"
        - type: "performance_metrics"
        - type: "system_health"
        - type: "database_summary"
          grist_tables: ["Users", "Orders", "Products"]
```

---

## Breaking Changes

**None** - All changes are backward compatible with opt-in features.

---

## Future Enhancements (v0.13.0+)

- **Multi-window support** - Open multiple pages in separate windows
- **Custom navigation animations** - Slide, fade, zoom transitions
- **Navigation shortcuts** - Keyboard shortcuts for navigation
- **Favorites/bookmarks** - User-saved page shortcuts
- **Recently viewed** - Track and display recent pages
- **Navigation search** - Search across all pages

---

## Appendix: File Structure

```
flutter-module/lib/src/
├── pages/
│   ├── admin_dashboard_page.dart (ENHANCED)
│   ├── home_page.dart (ENHANCED for deep linking)
│   └── tabbed_home_page.dart (NEW)
├── widgets/
│   ├── breadcrumb_widget.dart (NEW)
│   ├── active_users_widget.dart (NEW)
│   ├── performance_metrics_widget.dart (NEW)
│   └── system_health_widget.dart (NEW)
├── utils/
│   ├── navigation_history.dart (NEW)
│   └── performance_metrics.dart (NEW)
├── config/
│   ├── app_config.dart (ENHANCED)
│   └── navigation_config.dart (NEW)
└── services/
    └── grist_service.dart (ENHANCED for performance tracking)
```

---

**Ready to implement?** Let me know if you'd like to proceed with Phase 1 (Admin Dashboard) or Phase 2 (Deep Linking) first!
