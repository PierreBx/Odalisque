import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/config/app_config.dart';
import 'package:flutter_grist_widgets/src/config/yaml_loader.dart';

void main() {
  group('YamlConfigLoader', () {
    test('should parse basic YAML configuration', () {
      const yamlString = '''
app:
  name: Test App
  version: 1.0.0

grist:
  base_url: https://grist.example.com
  api_key: test-key
  document_id: test-doc

auth:
  users_table: Users
  users_table_schema:
    email_field: email
    password_field: password_hash
    role_field: role
    active_field: active

theme:
  primary_color: '#2196F3'
  secondary_color: '#FFC107'

navigation:
  drawer_header: Test App
  drawer_image: null

pages: []
''';

      final config = YamlConfigLoader.loadFromString(yamlString);

      expect(config.app.name, equals('Test App'));
      expect(config.app.version, equals('1.0.0'));
      expect(config.grist.baseUrl, equals('https://grist.example.com'));
      expect(config.grist.apiKey, equals('test-key'));
      expect(config.pages, isEmpty);
    });

    test('should handle empty YAML', () {
      const yamlString = '{}';

      expect(() => YamlConfigLoader.loadFromString(yamlString), returnsNormally);
    });

    test('should handle minimal YAML with defaults', () {
      const yamlString = '''
app:
  name: Minimal App

grist:
  base_url: http://localhost:8484
  api_key: key
  document_id: doc

auth:
  users_table: Users
  users_table_schema: {}

theme: {}

navigation:
  drawer_header: Menu

pages: []
''';

      final config = YamlConfigLoader.loadFromString(yamlString);

      expect(config.app.name, equals('Minimal App'));
      expect(config.theme.primaryColor, equals('#2196F3')); // Default
    });

    test('should throw on invalid YAML syntax', () {
      const invalidYaml = '''
app:
  name: Test
  - invalid list item
''';

      expect(
        () => YamlConfigLoader.loadFromString(invalidYaml),
        throwsException,
      );
    });

    test('should parse nested structures', () {
      const yamlString = '''
app:
  name: Test App
  error_handling:
    show_error_details: true
    default_error_message: Custom error
    retry_enabled: false
  loading:
    show_skeleton: false
    spinner_type: linear
    timeout_seconds: 60

grist:
  base_url: http://localhost
  api_key: key
  document_id: doc

auth:
  users_table: Users
  users_table_schema: {}

theme: {}

navigation:
  drawer_header: Menu

pages: []
''';

      final config = YamlConfigLoader.loadFromString(yamlString);

      expect(config.app.errorHandling, isNotNull);
      expect(config.app.errorHandling!.showErrorDetails, isTrue);
      expect(config.app.errorHandling!.defaultErrorMessage, equals('Custom error'));
      expect(config.app.errorHandling!.retryEnabled, isFalse);

      expect(config.app.loading, isNotNull);
      expect(config.app.loading!.showSkeleton, isFalse);
      expect(config.app.loading!.spinnerType, equals('linear'));
      expect(config.app.loading!.timeoutSeconds, equals(60));
    });

    test('should parse session settings', () {
      const yamlString = '''
app:
  name: Test App

grist:
  base_url: http://localhost
  api_key: key
  document_id: doc

auth:
  users_table: Users
  users_table_schema: {}
  session:
    timeout_minutes: 120
    remember_me: false
    auto_logout_on_timeout: false

theme: {}

navigation:
  drawer_header: Menu

pages: []
''';

      final config = YamlConfigLoader.loadFromString(yamlString);

      expect(config.auth.session, isNotNull);
      expect(config.auth.session!.timeoutMinutes, equals(120));
      expect(config.auth.session!.rememberMe, isFalse);
      expect(config.auth.session!.autoLogoutOnTimeout, isFalse);
    });

    test('should parse login page settings', () {
      const yamlString = '''
app:
  name: Test App

grist:
  base_url: http://localhost
  api_key: key
  document_id: doc

auth:
  users_table: Users
  users_table_schema: {}
  login_page:
    title: Welcome
    logo: assets/logo.png
    background_image: assets/bg.jpg
    welcome_text: Please login to continue

theme: {}

navigation:
  drawer_header: Menu

pages: []
''';

      final config = YamlConfigLoader.loadFromString(yamlString);

      expect(config.auth.loginPage, isNotNull);
      expect(config.auth.loginPage!.title, equals('Welcome'));
      expect(config.auth.loginPage!.logo, equals('assets/logo.png'));
      expect(config.auth.loginPage!.backgroundImage, equals('assets/bg.jpg'));
      expect(config.auth.loginPage!.welcomeText, equals('Please login to continue'));
    });
  });

  group('AppSettings', () {
    test('should parse with all fields', () {
      final map = {
        'name': 'My App',
        'version': '2.0.0',
        'error_handling': {
          'show_error_details': true,
          'default_error_message': 'Error occurred',
          'retry_enabled': true,
        },
        'loading': {
          'show_skeleton': true,
          'spinner_type': 'circular',
          'timeout_seconds': 45,
        }
      };

      final settings = AppSettings.fromMap(map);

      expect(settings.name, equals('My App'));
      expect(settings.version, equals('2.0.0'));
      expect(settings.errorHandling, isNotNull);
      expect(settings.loading, isNotNull);
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final settings = AppSettings.fromMap(map);

      expect(settings.name, equals('My App'));
      expect(settings.version, equals('1.0.0'));
      expect(settings.errorHandling, isNull);
      expect(settings.loading, isNull);
    });
  });

  group('GristSettings', () {
    test('should parse all fields', () {
      final map = {
        'base_url': 'https://grist.example.com',
        'api_key': 'secret-key',
        'document_id': 'my-doc-123',
      };

      final settings = GristSettings.fromMap(map);

      expect(settings.baseUrl, equals('https://grist.example.com'));
      expect(settings.apiKey, equals('secret-key'));
      expect(settings.documentId, equals('my-doc-123'));
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final settings = GristSettings.fromMap(map);

      expect(settings.baseUrl, equals('https://docs.getgrist.com'));
      expect(settings.apiKey, isEmpty);
      expect(settings.documentId, isEmpty);
    });
  });

  group('AuthSettings', () {
    test('should parse with all fields', () {
      final map = {
        'users_table': 'CustomUsers',
        'users_table_schema': {
          'email_field': 'user_email',
          'password_field': 'pwd_hash',
          'role_field': 'user_role',
          'active_field': 'is_active',
        },
        'session': {
          'timeout_minutes': 30,
          'remember_me': true,
          'auto_logout_on_timeout': true,
        },
        'login_page': {
          'title': 'Sign In',
          'logo': 'logo.png',
        }
      };

      final settings = AuthSettings.fromMap(map);

      expect(settings.usersTable, equals('CustomUsers'));
      expect(settings.usersTableSchema.emailField, equals('user_email'));
      expect(settings.session, isNotNull);
      expect(settings.loginPage, isNotNull);
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final settings = AuthSettings.fromMap(map);

      expect(settings.usersTable, equals('Users'));
      expect(settings.usersTableSchema.emailField, equals('email'));
      expect(settings.session, isNull);
      expect(settings.loginPage, isNull);
    });
  });

  group('UsersTableSchema', () {
    test('should parse all fields', () {
      final map = {
        'email_field': 'user_email',
        'password_field': 'pwd_hash',
        'role_field': 'user_role',
        'active_field': 'is_active',
      };

      final schema = UsersTableSchema.fromMap(map);

      expect(schema.emailField, equals('user_email'));
      expect(schema.passwordField, equals('pwd_hash'));
      expect(schema.roleField, equals('user_role'));
      expect(schema.activeField, equals('is_active'));
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final schema = UsersTableSchema.fromMap(map);

      expect(schema.emailField, equals('email'));
      expect(schema.passwordField, equals('password_hash'));
      expect(schema.roleField, equals('role'));
      expect(schema.activeField, equals('active'));
    });
  });

  group('SessionSettings', () {
    test('should parse all fields', () {
      final map = {
        'timeout_minutes': 45,
        'remember_me': false,
        'auto_logout_on_timeout': false,
      };

      final settings = SessionSettings.fromMap(map);

      expect(settings.timeoutMinutes, equals(45));
      expect(settings.rememberMe, isFalse);
      expect(settings.autoLogoutOnTimeout, isFalse);
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final settings = SessionSettings.fromMap(map);

      expect(settings.timeoutMinutes, equals(60));
      expect(settings.rememberMe, isTrue);
      expect(settings.autoLogoutOnTimeout, isTrue);
    });
  });

  group('LoginPageSettings', () {
    test('should parse all fields', () {
      final map = {
        'title': 'Welcome Back',
        'logo': 'assets/logo.png',
        'background_image': 'assets/bg.jpg',
        'welcome_text': 'Sign in to continue',
      };

      final settings = LoginPageSettings.fromMap(map);

      expect(settings.title, equals('Welcome Back'));
      expect(settings.logo, equals('assets/logo.png'));
      expect(settings.backgroundImage, equals('assets/bg.jpg'));
      expect(settings.welcomeText, equals('Sign in to continue'));
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final settings = LoginPageSettings.fromMap(map);

      expect(settings.title, equals('Login'));
      expect(settings.logo, isNull);
      expect(settings.backgroundImage, isNull);
      expect(settings.welcomeText, isNull);
    });
  });

  group('ThemeSettings', () {
    test('should parse all fields', () {
      final map = {
        'primary_color': '#FF5722',
        'secondary_color': '#4CAF50',
        'drawer_background': '#000000',
        'drawer_text_color': '#FFFFFF',
        'error_color': '#F44336',
        'success_color': '#4CAF50',
      };

      final settings = ThemeSettings.fromMap(map);

      expect(settings.primaryColor, equals('#FF5722'));
      expect(settings.secondaryColor, equals('#4CAF50'));
      expect(settings.drawerBackground, equals('#000000'));
      expect(settings.drawerTextColor, equals('#FFFFFF'));
      expect(settings.errorColor, equals('#F44336'));
      expect(settings.successColor, equals('#4CAF50'));
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final settings = ThemeSettings.fromMap(map);

      expect(settings.primaryColor, equals('#2196F3'));
      expect(settings.secondaryColor, equals('#FFC107'));
      expect(settings.drawerBackground, equals('#263238'));
      expect(settings.drawerTextColor, equals('#FFFFFF'));
      expect(settings.errorColor, isNull);
      expect(settings.successColor, isNull);
    });
  });

  group('ErrorHandlingSettings', () {
    test('should parse all fields', () {
      final map = {
        'show_error_details': true,
        'default_error_message': 'Custom error',
        'retry_enabled': false,
      };

      final settings = ErrorHandlingSettings.fromMap(map);

      expect(settings.showErrorDetails, isTrue);
      expect(settings.defaultErrorMessage, equals('Custom error'));
      expect(settings.retryEnabled, isFalse);
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final settings = ErrorHandlingSettings.fromMap(map);

      expect(settings.showErrorDetails, isFalse);
      expect(settings.defaultErrorMessage, equals('Something went wrong'));
      expect(settings.retryEnabled, isTrue);
    });
  });

  group('LoadingSettings', () {
    test('should parse all fields', () {
      final map = {
        'show_skeleton': false,
        'spinner_type': 'linear',
        'timeout_seconds': 120,
      };

      final settings = LoadingSettings.fromMap(map);

      expect(settings.showSkeleton, isFalse);
      expect(settings.spinnerType, equals('linear'));
      expect(settings.timeoutSeconds, equals(120));
    });

    test('should use defaults when fields missing', () {
      final map = <String, dynamic>{};

      final settings = LoadingSettings.fromMap(map);

      expect(settings.showSkeleton, isTrue);
      expect(settings.spinnerType, equals('circular'));
      expect(settings.timeoutSeconds, equals(30));
    });
  });

  group('Complex Configuration', () {
    test('should parse complete YAML configuration', () {
      const yamlString = '''
app:
  name: Production App
  version: 3.2.1
  error_handling:
    show_error_details: false
    default_error_message: Please try again
    retry_enabled: true
  loading:
    show_skeleton: true
    spinner_type: circular
    timeout_seconds: 30

grist:
  base_url: https://grist.production.com
  api_key: prod-api-key-xyz
  document_id: prod-doc-123

auth:
  users_table: ApplicationUsers
  users_table_schema:
    email_field: email_address
    password_field: hashed_password
    role_field: user_role
    active_field: account_active
  session:
    timeout_minutes: 90
    remember_me: true
    auto_logout_on_timeout: true
  login_page:
    title: Enterprise Portal
    logo: assets/company_logo.png
    background_image: assets/login_bg.jpg
    welcome_text: Welcome to our enterprise portal

theme:
  primary_color: '#1976D2'
  secondary_color: '#FF5722'
  drawer_background: '#37474F'
  drawer_text_color: '#ECEFF1'
  error_color: '#D32F2F'
  success_color: '#388E3C'

navigation:
  drawer_header: Enterprise App
  drawer_image: assets/drawer_header.jpg

pages: []
''';

      final config = YamlConfigLoader.loadFromString(yamlString);

      // App settings
      expect(config.app.name, equals('Production App'));
      expect(config.app.version, equals('3.2.1'));
      expect(config.app.errorHandling!.showErrorDetails, isFalse);
      expect(config.app.loading!.spinnerType, equals('circular'));

      // Grist settings
      expect(config.grist.baseUrl, equals('https://grist.production.com'));
      expect(config.grist.apiKey, equals('prod-api-key-xyz'));
      expect(config.grist.documentId, equals('prod-doc-123'));

      // Auth settings
      expect(config.auth.usersTable, equals('ApplicationUsers'));
      expect(config.auth.usersTableSchema.emailField, equals('email_address'));
      expect(config.auth.session!.timeoutMinutes, equals(90));
      expect(config.auth.loginPage!.title, equals('Enterprise Portal'));

      // Theme settings
      expect(config.theme.primaryColor, equals('#1976D2'));
      expect(config.theme.errorColor, equals('#D32F2F'));
    });
  });
}
