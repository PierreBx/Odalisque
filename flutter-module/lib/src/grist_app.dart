import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'config/yaml_loader.dart';
import 'services/grist_service.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'utils/theme_utils.dart';
import 'utils/app_router.dart';

/// Main application widget generated from YAML configuration.
class GristApp extends StatelessWidget {
  final AppConfig config;

  const GristApp({
    super.key,
    required this.config,
  });

  /// Creates a GristApp from a YAML asset file.
  static Future<GristApp> fromYaml(String assetPath) async {
    final config = await YamlConfigLoader.loadFromAsset(assetPath);
    return GristApp(config: config);
  }

  @override
  Widget build(BuildContext context) {
    final gristService = GristService(config.grist);
    final appRouter = AppRouter(config: config);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            gristService: gristService,
            authSettings: config.auth,
          )..init(),
        ),
        Provider<AppConfig>.value(value: config),
        Provider<GristService>.value(value: gristService),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show loading screen during initialization
          if (authProvider.isLoading) {
            return MaterialApp(
              title: config.app.name,
              theme: ThemeUtils.createTheme(config.theme),
              home: const LoadingScreen(),
              debugShowCheckedModeBanner: false,
            );
          }

          // Use router for navigation with deep linking support
          return MaterialApp.router(
            title: config.app.name,
            theme: ThemeUtils.createTheme(config.theme),
            routerConfig: appRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

/// Loading screen shown during initialization.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
