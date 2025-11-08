import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../utils/theme_utils.dart';
import '../utils/expression_evaluator.dart';
import 'front_page.dart';
import 'data_master_page.dart';
import 'data_detail_page.dart';
import 'admin_dashboard_page.dart';

/// Main home page with drawer navigation.
class HomePage extends StatefulWidget {
  final AppConfig config;

  const HomePage({
    super.key,
    required this.config,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _currentPageId;
  final Map<String, dynamic> _pageParams = {};

  @override
  void initState() {
    super.initState();
    // Set first visible page as default
    _currentPageId = _getVisiblePages().first.id;
  }

  List<PageConfig> _getVisiblePages() {
    final user = context.read<AuthProvider>().user!;
    return widget.config.pages.where((page) {
      if (page.menu == null || page.menu!.visible == false) {
        return false;
      }
      return ExpressionEvaluator.evaluate(page.visibleIf, user);
    }).toList()
      ..sort((a, b) {
        final orderA = a.menu?.order ?? 999;
        final orderB = b.menu?.order ?? 999;
        return orderA.compareTo(orderB);
      });
  }

  void _navigateToPage(String pageId, [Map<String, dynamic>? params]) {
    setState(() {
      _currentPageId = pageId;
      if (params != null) {
        _pageParams.addAll(params);
      }
    });
    Navigator.of(context).pop(); // Close drawer
  }

  Widget _buildPage(PageConfig pageConfig) {
    switch (pageConfig.type) {
      case 'front':
        return FrontPage(config: pageConfig);
      case 'data_master':
        return DataMasterPage(
          config: pageConfig,
          onNavigate: _navigateToPage,
        );
      case 'data_detail':
        return DataDetailPage(
          config: pageConfig,
          params: _pageParams,
          onNavigate: _navigateToPage,
        );
      case 'admin_dashboard':
        return AdminDashboardPage(config: pageConfig);
      default:
        return Center(
          child: Text('Unknown page type: ${pageConfig.type}'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = widget.config.pages
        .firstWhere((p) => p.id == _currentPageId);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage.title),
      ),
      drawer: _buildDrawer(),
      body: _buildPage(currentPage),
    );
  }

  Widget _buildDrawer() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user!;
    final visiblePages = _getVisiblePages();
    final theme = widget.config.theme;
    final drawerBgColor = ThemeUtils.getDrawerBackground(theme);
    final drawerTextColor = ThemeUtils.getDrawerTextColor(theme);

    return Drawer(
      child: Column(
        children: [
          // Drawer header
          _buildDrawerHeader(drawerBgColor, drawerTextColor),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: visiblePages.map((page) {
                return ListTile(
                  leading: page.menu?.icon != null
                      ? Icon(_getIconData(page.menu!.icon!))
                      : null,
                  title: Text(page.menu?.label ?? page.title),
                  selected: _currentPageId == page.id,
                  onTap: () => _navigateToPage(page.id),
                );
              }).toList(),
            ),
          ),

          // Drawer footer
          _buildDrawerFooter(user, authProvider),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(Color bgColor, Color textColor) {
    final headerSettings = widget.config.navigation.drawerHeader;

    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: bgColor,
        image: headerSettings?.backgroundImage != null
            ? DecorationImage(
                image: AssetImage(headerSettings!.backgroundImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      accountName: Text(
        headerSettings?.title ?? widget.config.app.name,
        style: TextStyle(color: textColor),
      ),
      accountEmail: Text(
        headerSettings?.subtitle ?? '',
        style: TextStyle(color: textColor.withOpacity(0.8)),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: textColor.withOpacity(0.3),
        child: Icon(
          Icons.business,
          color: textColor,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(User user, AuthProvider authProvider) {
    final footerSettings = widget.config.navigation.drawerFooter;

    if (footerSettings == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User info
          if (footerSettings.showUserInfo)
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(user.email),
              subtitle: Text(user.role),
            ),

          // Logout button
          if (footerSettings.showLogoutButton)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                if (footerSettings.logoutConfirmation) {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await authProvider.logout();
                  }
                } else {
                  await authProvider.logout();
                }
              },
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Map common Material icon names to IconData
    const iconMap = {
      'home': Icons.home,
      'inventory': Icons.inventory,
      'people': Icons.people,
      'admin_panel_settings': Icons.admin_panel_settings,
      'dashboard': Icons.dashboard,
      'settings': Icons.settings,
      'analytics': Icons.analytics,
      'shopping_cart': Icons.shopping_cart,
      'business': Icons.business,
    };

    return iconMap[iconName] ?? Icons.circle;
  }
}
