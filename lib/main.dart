import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'core/local_storage/hive_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Service Locator
  await setupServiceLocator();

  // Initialize Hive
  await sl<HiveService>().init();

  runApp(const KometApp());
}

class KometApp extends StatelessWidget {
  const KometApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<GoRouter>();

    return MaterialApp.router(
      title: 'KOMET — Media Pembelajaran Kreativitas Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
