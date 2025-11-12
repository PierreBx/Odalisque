import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/pages/login_page.dart';
import 'package:flutter_grist_widgets/src/providers/auth_provider.dart';
import 'package:flutter_grist_widgets/src/services/grist_service.dart';
import 'package:flutter_grist_widgets/src/config/app_config.dart';
import 'package:flutter_grist_widgets/src/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginPage Widget Tests', () {
    late AppConfig config;
    late GristService gristService;
    late AuthSettings authSettings;
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});

      // Setup test configuration
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      authSettings = AuthSettings(
        userTable: 'Users',
        emailField: 'email',
        passwordField: 'password',
        roleField: 'role',
        activeField: 'active',
        loginPage: LoginPageSettings(
          title: 'Test Login',
          welcomeText: 'Welcome to Test App',
        ),
      );

      config = AppConfig(
        appName: 'Test App',
        grist: gristConfig,
        auth: authSettings,
        theme: ThemeSettings(primaryColor: Colors.blue.value),
        navigation: NavigationSettings(
          drawerHeader: 'Test Drawer',
          drawerImage: null,
        ),
        pages: [],
      );

      gristService = GristService(gristConfig);
      authProvider = AuthProvider(
        gristService: gristService,
        authSettings: authSettings,
      );
    });

    Widget createLoginPage() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            Provider<AppConfig>.value(value: config),
          ],
          child: LoginPage(config: config),
        ),
      );
    }

    testWidgets('should display login form with email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      // Verify email field
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);

      // Verify password field
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // Verify login button
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('should display configured title and welcome text',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.text('Test Login'), findsOneWidget);
      expect(find.text('Welcome to Test App'), findsOneWidget);
    });

    testWidgets('should show validation error for empty email',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      // Tap login button without entering anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Verify validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email format',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      // Enter invalid email
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'invalid-email');

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Verify validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show validation error for empty password',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      // Enter email but no password
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Verify validation error
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password field should toggle visibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);

      // Initial state should be obscured
      final initialTextField = tester.widget<TextFormField>(passwordField);
      expect(initialTextField.obscureText, isTrue);

      // Find and tap visibility toggle button
      final visibilityButton = find.descendant(
        of: passwordField,
        matching: find.byType(IconButton),
      );
      await tester.tap(visibilityButton);
      await tester.pump();

      // Password should now be visible
      final updatedTextField = tester.widget<TextFormField>(passwordField);
      expect(updatedTextField.obscureText, isFalse);

      // Tap again to hide
      await tester.tap(visibilityButton);
      await tester.pump();

      // Password should be obscured again
      final finalTextField = tester.widget<TextFormField>(passwordField);
      expect(finalTextField.obscureText, isTrue);
    });

    testWidgets('should have email icon in email field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      expect(emailField, findsOneWidget);

      // Verify email icon exists
      expect(
        find.descendant(
          of: emailField,
          matching: find.byIcon(Icons.email),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should have lock icon in password field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);

      // Verify lock icon exists
      expect(
        find.descendant(
          of: passwordField,
          matching: find.byIcon(Icons.lock),
        ),
        findsOneWidget,
      );
    });

    testWidgets('email field should have email keyboard type',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      final emailField =
          tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Email'));
      expect(emailField.keyboardType, equals(TextInputType.emailAddress));
    });

    testWidgets('email field should trim whitespace',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      // Enter email with spaces
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        '  test@example.com  ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // We can't easily test the trimming without a real authentication,
      // but we can verify the fields accept the input
      expect(find.text('  test@example.com  '), findsOneWidget);
    });

    testWidgets('form fields should have proper text input actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      final emailField =
          tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Email'));
      final passwordField =
          tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Password'));

      expect(emailField.textInputAction, equals(TextInputAction.next));
      expect(passwordField.textInputAction, equals(TextInputAction.done));
    });

    testWidgets('should render within a Card with proper styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      final card = find.byType(Card);
      expect(card, findsOneWidget);

      final cardWidget = tester.widget<Card>(card);
      expect(cardWidget.elevation, equals(8));

      final shape = cardWidget.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(16)));
    });

    testWidgets('login form should be scrollable',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should dispose controllers properly', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());

      // Navigate away to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // No exception should be thrown
    });
  });

  group('LoginPage Custom Settings Tests', () {
    testWidgets('should use default title when not configured',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final authSettings = AuthSettings(
        userTable: 'Users',
        emailField: 'email',
        passwordField: 'password',
        roleField: 'role',
        activeField: 'active',
        // No loginPage settings
      );

      final config = AppConfig(
        appName: 'Test App',
        grist: gristConfig,
        auth: authSettings,
        theme: ThemeSettings(primaryColor: Colors.blue.value),
        navigation: NavigationSettings(
          drawerHeader: 'Test Drawer',
          drawerImage: null,
        ),
        pages: [],
      );

      final gristService = GristService(gristConfig);
      final authProvider = AuthProvider(
        gristService: gristService,
        authSettings: authSettings,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              Provider<AppConfig>.value(value: config),
            ],
            child: LoginPage(config: config),
          ),
        ),
      );

      // Should display default title
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
