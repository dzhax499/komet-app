import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'core/local_storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

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

    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(AuthCheckStatusRequested()),
      child: MaterialApp.router(
        title: 'KOMET — Media Pembelajaran Kreativitas Digital',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
