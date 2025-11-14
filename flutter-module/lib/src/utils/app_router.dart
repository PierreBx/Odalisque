import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

/// Router configuration for deep linking support.
///
/// Provides URL-based navigation with routes for:
/// - / - Home page
/// - /login - Login page
/// - /page/:pageId - Specific page by ID
/// - /page/:pageId/record/:recordId - Specific record on a page
/// - /admin - Admin dashboard (shortcut to admin page)
class AppRouter {
  final AppConfig config;

  AppRouter({required this.config});

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isAuthenticated) {
            return LoginPage(config: config);
          }
          return HomePage(config: config);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(config: config),
      ),
      GoRoute(
        path: '/page/:pageId',
        name: 'page',
        builder: (context, state) {
          final pageId = state.pathParameters['pageId']!;
          return HomePage(
            config: config,
            initialPageId: pageId,
          );
        },
      ),
      GoRoute(
        path: '/page/:pageId/record/:recordId',
        name: 'record',
        builder: (context, state) {
          final pageId = state.pathParameters['pageId']!;
          final recordId = state.pathParameters['recordId']!;
          return HomePage(
            config: config,
            initialPageId: pageId,
            initialRecordId: recordId,
          );
        },
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) {
          // Find admin dashboard page ID from config
          final adminPage = config.pages.firstWhere(
            (p) => p.type == 'admin_dashboard',
            orElse: () => config.pages.first,
          );
          return HomePage(
            config: config,
            initialPageId: adminPage.id,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // Redirect to login if not authenticated and not already on login page
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      // Redirect to home if logged in and on login page
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Navigation service for programmatic navigation.
///
/// Provides helper methods to navigate to specific pages and records.
class NavigationService {
  /// Navigate to home page.
  static void goHome(BuildContext context) {
    context.go('/');
  }

  /// Navigate to login page.
  static void goLogin(BuildContext context) {
    context.go('/login');
  }

  /// Navigate to a specific page by ID.
  static void goToPage(BuildContext context, String pageId) {
    context.go('/page/$pageId');
  }

  /// Navigate to a specific record on a page.
  static void goToRecord(
    BuildContext context,
    String pageId,
    String recordId,
  ) {
    context.go('/page/$pageId/record/$recordId');
  }

  /// Navigate to admin dashboard.
  static void goToAdmin(BuildContext context) {
    context.go('/admin');
  }

  /// Get the current URL path.
  static String getCurrentPath(BuildContext context) {
    final router = GoRouter.of(context);
    return router.routerDelegate.currentConfiguration.uri.path;
  }

  /// Check if currently on a specific path.
  static bool isCurrentPath(BuildContext context, String path) {
    return getCurrentPath(context) == path;
  }

  /// Go back to previous page (if available).
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // If can't pop, go home
      goHome(context);
    }
  }

  /// Replace current route with a new one.
  static void replace(BuildContext context, String path) {
    context.replace(path);
  }

  /// Push a new route on top of the current one.
  static void push(BuildContext context, String path) {
    context.push(path);
  }
}
