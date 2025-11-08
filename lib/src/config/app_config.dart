/// Complete application configuration loaded from YAML.
class AppConfig {
  final AppSettings app;
  final GristSettings grist;
  final AuthSettings auth;
  final ThemeSettings theme;
  final NavigationSettings navigation;
  final List<PageConfig> pages;

  const AppConfig({
    required this.app,
    required this.grist,
    required this.auth,
    required this.theme,
    required this.navigation,
    required this.pages,
  });

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      app: AppSettings.fromMap(map['app'] ?? {}),
      grist: GristSettings.fromMap(map['grist'] ?? {}),
      auth: AuthSettings.fromMap(map['auth'] ?? {}),
      theme: ThemeSettings.fromMap(map['theme'] ?? {}),
      navigation: NavigationSettings.fromMap(map['navigation'] ?? {}),
      pages: (map['pages'] as List<dynamic>?)
              ?.map((p) => PageConfig.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Application settings
class AppSettings {
  final String name;
  final String version;
  final ErrorHandlingSettings? errorHandling;
  final LoadingSettings? loading;

  const AppSettings({
    required this.name,
    this.version = '1.0.0',
    this.errorHandling,
    this.loading,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      name: map['name'] as String? ?? 'My App',
      version: map['version'] as String? ?? '1.0.0',
      errorHandling: map['error_handling'] != null
          ? ErrorHandlingSettings.fromMap(map['error_handling'])
          : null,
      loading:
          map['loading'] != null ? LoadingSettings.fromMap(map['loading']) : null,
    );
  }
}

/// Error handling configuration
class ErrorHandlingSettings {
  final bool showErrorDetails;
  final String defaultErrorMessage;
  final bool retryEnabled;

  const ErrorHandlingSettings({
    this.showErrorDetails = false,
    this.defaultErrorMessage = 'Something went wrong',
    this.retryEnabled = true,
  });

  factory ErrorHandlingSettings.fromMap(Map<String, dynamic> map) {
    return ErrorHandlingSettings(
      showErrorDetails: map['show_error_details'] as bool? ?? false,
      defaultErrorMessage:
          map['default_error_message'] as String? ?? 'Something went wrong',
      retryEnabled: map['retry_enabled'] as bool? ?? true,
    );
  }
}

/// Loading state configuration
class LoadingSettings {
  final bool showSkeleton;
  final String spinnerType;
  final int timeoutSeconds;

  const LoadingSettings({
    this.showSkeleton = true,
    this.spinnerType = 'circular',
    this.timeoutSeconds = 30,
  });

  factory LoadingSettings.fromMap(Map<String, dynamic> map) {
    return LoadingSettings(
      showSkeleton: map['show_skeleton'] as bool? ?? true,
      spinnerType: map['spinner_type'] as String? ?? 'circular',
      timeoutSeconds: map['timeout_seconds'] as int? ?? 30,
    );
  }
}

/// Grist connection settings
class GristSettings {
  final String baseUrl;
  final String apiKey;
  final String documentId;

  const GristSettings({
    required this.baseUrl,
    required this.apiKey,
    required this.documentId,
  });

  factory GristSettings.fromMap(Map<String, dynamic> map) {
    return GristSettings(
      baseUrl: map['base_url'] as String? ?? 'https://docs.getgrist.com',
      apiKey: map['api_key'] as String? ?? '',
      documentId: map['document_id'] as String? ?? '',
    );
  }
}

/// Authentication settings
class AuthSettings {
  final String usersTable;
  final UsersTableSchema usersTableSchema;
  final SessionSettings? session;
  final LoginPageSettings? loginPage;

  const AuthSettings({
    required this.usersTable,
    required this.usersTableSchema,
    this.session,
    this.loginPage,
  });

  factory AuthSettings.fromMap(Map<String, dynamic> map) {
    return AuthSettings(
      usersTable: map['users_table'] as String? ?? 'Users',
      usersTableSchema: UsersTableSchema.fromMap(
          map['users_table_schema'] as Map<String, dynamic>? ?? {}),
      session: map['session'] != null
          ? SessionSettings.fromMap(map['session'])
          : null,
      loginPage: map['login_page'] != null
          ? LoginPageSettings.fromMap(map['login_page'])
          : null,
    );
  }
}

/// Users table schema mapping
class UsersTableSchema {
  final String emailField;
  final String passwordField;
  final String roleField;
  final String activeField;

  const UsersTableSchema({
    this.emailField = 'email',
    this.passwordField = 'password_hash',
    this.roleField = 'role',
    this.activeField = 'active',
  });

  factory UsersTableSchema.fromMap(Map<String, dynamic> map) {
    return UsersTableSchema(
      emailField: map['email_field'] as String? ?? 'email',
      passwordField: map['password_field'] as String? ?? 'password_hash',
      roleField: map['role_field'] as String? ?? 'role',
      activeField: map['active_field'] as String? ?? 'active',
    );
  }
}

/// Session management settings
class SessionSettings {
  final int timeoutMinutes;
  final bool rememberMe;
  final bool autoLogoutOnTimeout;

  const SessionSettings({
    this.timeoutMinutes = 60,
    this.rememberMe = true,
    this.autoLogoutOnTimeout = true,
  });

  factory SessionSettings.fromMap(Map<String, dynamic> map) {
    return SessionSettings(
      timeoutMinutes: map['timeout_minutes'] as int? ?? 60,
      rememberMe: map['remember_me'] as bool? ?? true,
      autoLogoutOnTimeout: map['auto_logout_on_timeout'] as bool? ?? true,
    );
  }
}

/// Login page configuration
class LoginPageSettings {
  final String title;
  final String? logo;
  final String? backgroundImage;
  final String? welcomeText;

  const LoginPageSettings({
    this.title = 'Login',
    this.logo,
    this.backgroundImage,
    this.welcomeText,
  });

  factory LoginPageSettings.fromMap(Map<String, dynamic> map) {
    return LoginPageSettings(
      title: map['title'] as String? ?? 'Login',
      logo: map['logo'] as String?,
      backgroundImage: map['background_image'] as String?,
      welcomeText: map['welcome_text'] as String?,
    );
  }
}

/// Theme settings
class ThemeSettings {
  final String primaryColor;
  final String secondaryColor;
  final String drawerBackground;
  final String drawerTextColor;
  final String? errorColor;
  final String? successColor;

  const ThemeSettings({
    this.primaryColor = '#2196F3',
    this.secondaryColor = '#FFC107',
    this.drawerBackground = '#263238',
    this.drawerTextColor = '#FFFFFF',
    this.errorColor,
    this.successColor,
  });

  factory ThemeSettings.fromMap(Map<String, dynamic> map) {
    return ThemeSettings(
      primaryColor: map['primary_color'] as String? ?? '#2196F3',
      secondaryColor: map['secondary_color'] as String? ?? '#FFC107',
      drawerBackground: map['drawer_background'] as String? ?? '#263238',
      drawerTextColor: map['drawer_text_color'] as String? ?? '#FFFFFF',
      errorColor: map['error_color'] as String?,
      successColor: map['success_color'] as String?,
    );
  }
}

/// Navigation settings
class NavigationSettings {
  final DrawerHeaderSettings? drawerHeader;
  final DrawerFooterSettings? drawerFooter;

  const NavigationSettings({
    this.drawerHeader,
    this.drawerFooter,
  });

  factory NavigationSettings.fromMap(Map<String, dynamic> map) {
    return NavigationSettings(
      drawerHeader: map['drawer_header'] != null
          ? DrawerHeaderSettings.fromMap(map['drawer_header'])
          : null,
      drawerFooter: map['drawer_footer'] != null
          ? DrawerFooterSettings.fromMap(map['drawer_footer'])
          : null,
    );
  }
}

/// Drawer header configuration
class DrawerHeaderSettings {
  final String? title;
  final String? subtitle;
  final String? backgroundImage;

  const DrawerHeaderSettings({
    this.title,
    this.subtitle,
    this.backgroundImage,
  });

  factory DrawerHeaderSettings.fromMap(Map<String, dynamic> map) {
    return DrawerHeaderSettings(
      title: map['title'] as String?,
      subtitle: map['subtitle'] as String?,
      backgroundImage: map['background_image'] as String?,
    );
  }
}

/// Drawer footer configuration
class DrawerFooterSettings {
  final bool showUserInfo;
  final bool showLogoutButton;
  final bool logoutConfirmation;

  const DrawerFooterSettings({
    this.showUserInfo = true,
    this.showLogoutButton = true,
    this.logoutConfirmation = true,
  });

  factory DrawerFooterSettings.fromMap(Map<String, dynamic> map) {
    return DrawerFooterSettings(
      showUserInfo: map['show_user_info'] as bool? ?? true,
      showLogoutButton: map['show_logout_button'] as bool? ?? true,
      logoutConfirmation: map['logout_confirmation'] as bool? ?? true,
    );
  }
}

/// Page configuration
class PageConfig {
  final String id;
  final String type;
  final String title;
  final MenuConfig? menu;
  final String? visibleIf;
  final Map<String, dynamic>? config; // Type-specific configuration

  const PageConfig({
    required this.id,
    required this.type,
    required this.title,
    this.menu,
    this.visibleIf,
    this.config,
  });

  factory PageConfig.fromMap(Map<String, dynamic> map) {
    return PageConfig(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      menu: map['menu'] != null ? MenuConfig.fromMap(map['menu']) : null,
      visibleIf: map['visible_if'] as String?,
      config: map,
    );
  }
}

/// Menu item configuration
class MenuConfig {
  final String? label;
  final String? icon;
  final int? order;
  final bool visible;

  const MenuConfig({
    this.label,
    this.icon,
    this.order,
    this.visible = true,
  });

  factory MenuConfig.fromMap(Map<String, dynamic> map) {
    return MenuConfig(
      label: map['label'] as String?,
      icon: map['icon'] as String?,
      order: map['order'] as int?,
      visible: map['visible'] as bool? ?? true,
    );
  }
}
