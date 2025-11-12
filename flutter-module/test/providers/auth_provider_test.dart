import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/providers/auth_provider.dart';
import 'package:flutter_grist_widgets/src/models/user_model.dart';
import 'package:flutter_grist_widgets/src/services/grist_service.dart';
import 'package:flutter_grist_widgets/src/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider', () {
    late GristService mockGristService;
    late AuthSettings authSettings;

    setUp(() {
      // Setup mock GristSettings
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );
      mockGristService = GristService(gristConfig);

      // Setup AuthSettings
      authSettings = AuthSettings(
        userTable: 'Users',
        emailField: 'email',
        passwordField: 'password',
        roleField: 'role',
        activeField: 'active',
        session: SessionSettings(
          timeoutMinutes: 30,
          autoLogoutOnTimeout: true,
        ),
      );

      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state should be unauthenticated', () {
      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.error, isNull);
    });

    test('logout should clear user and session', () async {
      SharedPreferences.setMockInitialValues({
        'user': '{"email":"test@example.com","role":"admin","active":true}',
        'last_activity': DateTime.now().toIso8601String(),
      });

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      await authProvider.init();
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);

      // Verify SharedPreferences cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user'), isNull);
      expect(prefs.getString('last_activity'), isNull);
    });

    test('logout with timeout should set error message', () async {
      SharedPreferences.setMockInitialValues({
        'user': '{"email":"test@example.com","role":"admin","active":true}',
        'last_activity': DateTime.now().toIso8601String(),
      });

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      await authProvider.init();
      await authProvider.logout(timedOut: true);

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.error, equals('Session expired due to inactivity'));
    });

    test('init should restore user from SharedPreferences', () async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'user':
            '{"email":"test@example.com","role":"admin","active":true,"additionalFields":{}}',
        'last_activity': now.toIso8601String(),
      });

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      await authProvider.init();

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.email, equals('test@example.com'));
      expect(authProvider.user!.role, equals('admin'));
      expect(authProvider.user!.active, isTrue);
      expect(authProvider.isLoading, isFalse);
    });

    test('init should handle missing session gracefully', () async {
      SharedPreferences.setMockInitialValues({});

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      await authProvider.init();

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
      expect(authProvider.isLoading, isFalse);
    });

    test('init should handle corrupted session data', () async {
      SharedPreferences.setMockInitialValues({
        'user': 'invalid-json',
      });

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      await authProvider.init();

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.error, isNotNull);
      expect(authProvider.error, contains('Failed to restore session'));
    });

    test('recordActivity should update last activity time', () async {
      final oldTime = DateTime.now().subtract(const Duration(minutes: 10));
      SharedPreferences.setMockInitialValues({
        'user': '{"email":"test@example.com","role":"admin","active":true}',
        'last_activity': oldTime.toIso8601String(),
      });

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      await authProvider.init();

      // Wait a bit to ensure time difference
      await Future.delayed(const Duration(milliseconds: 10));
      authProvider.recordActivity();

      // Activity should be recorded (we can't directly test the private field,
      // but we can verify the session doesn't timeout)
      expect(authProvider.isAuthenticated, isTrue);
    });

    test('clearError should clear error message', () async {
      SharedPreferences.setMockInitialValues({});

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      await authProvider.logout(timedOut: true);
      expect(authProvider.error, isNotNull);

      authProvider.clearError();
      expect(authProvider.error, isNull);
    });

    test('init should logout if session has timed out', () async {
      // Set last activity to 1 hour ago
      final oldTime = DateTime.now().subtract(const Duration(hours: 1));
      SharedPreferences.setMockInitialValues({
        'user': '{"email":"test@example.com","role":"admin","active":true}',
        'last_activity': oldTime.toIso8601String(),
      });

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      await authProvider.init();

      // Session should be cleared due to timeout
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('session monitoring should not start if autoLogoutOnTimeout is false',
        () {
      final authSettingsNoTimeout = AuthSettings(
        userTable: 'Users',
        emailField: 'email',
        passwordField: 'password',
        roleField: 'role',
        activeField: 'active',
        session: SessionSettings(
          timeoutMinutes: 30,
          autoLogoutOnTimeout: false,
        ),
      );

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettingsNoTimeout,
      );

      // No exception should be thrown
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('session monitoring should not start if session is null', () {
      final authSettingsNoSession = AuthSettings(
        userTable: 'Users',
        emailField: 'email',
        passwordField: 'password',
        roleField: 'role',
        activeField: 'active',
      );

      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettingsNoSession,
      );

      // No exception should be thrown
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('dispose should cancel session timer', () {
      final authProvider = AuthProvider(
        gristService: mockGristService,
        authSettings: authSettings,
      );

      // Should not throw
      authProvider.dispose();
    });
  });

  group('User model', () {
    test('User.fromGristRecord should parse correctly', () {
      final record = {
        'id': 1,
        'fields': {
          'email': 'test@example.com',
          'role': 'admin',
          'active': true,
          'name': 'Test User',
        }
      };

      final user =
          User.fromGristRecord(record, 'email', 'role', 'active');

      expect(user.email, equals('test@example.com'));
      expect(user.role, equals('admin'));
      expect(user.active, isTrue);
      expect(user.additionalFields['name'], equals('Test User'));
    });

    test('User.fromGristRecord should handle numeric active field', () {
      final record = {
        'id': 1,
        'fields': {
          'email': 'test@example.com',
          'role': 'user',
          'active': 1,
        }
      };

      final user =
          User.fromGristRecord(record, 'email', 'role', 'active');

      expect(user.active, isTrue);
    });

    test('User.fromGristRecord should default inactive when false', () {
      final record = {
        'id': 1,
        'fields': {
          'email': 'test@example.com',
          'role': 'user',
          'active': false,
        }
      };

      final user =
          User.fromGristRecord(record, 'email', 'role', 'active');

      expect(user.active, isFalse);
    });

    test('User.getField should retrieve correct values', () {
      const user = User(
        email: 'test@example.com',
        role: 'admin',
        active: true,
        additionalFields: {'name': 'Test User'},
      );

      expect(user.getField('email'), equals('test@example.com'));
      expect(user.getField('role'), equals('admin'));
      expect(user.getField('active'), isTrue);
      expect(user.getField('name'), equals('Test User'));
    });

    test('User.toJson should serialize correctly', () {
      const user = User(
        email: 'test@example.com',
        role: 'admin',
        active: true,
        additionalFields: {'name': 'Test User'},
      );

      final json = user.toJson();

      expect(json['email'], equals('test@example.com'));
      expect(json['role'], equals('admin'));
      expect(json['active'], isTrue);
      expect(json['name'], equals('Test User'));
    });
  });
}
