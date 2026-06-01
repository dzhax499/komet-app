import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/kelas/presentation/bloc/kelas_bloc.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await setupServiceLocator();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Text('Gagal inisialisasi aplikasi:\n$e\n$stackTrace', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthBloc diambil dari GetIt (sudah terdaftar di service_locator.dart)
        // Langsung dispatch CheckStatus agar SplashScreen bisa cek login
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckStatusRequested()),
        ),
        // KelasBloc juga dari GetIt
        BlocProvider<KelasBloc>(create: (_) => sl<KelasBloc>()),
      ],
      // Gunakan MaterialApp.router + GoRouter — BUKAN MaterialApp biasa
      // karena LoginPage, Dashboard, dll sudah pakai context.go() dari GoRouter
      child: MaterialApp.router(
        title: 'Komet App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        // Ambil GoRouter yang sudah dikonfigurasi di app_router.dart via GetIt
        routerConfig: sl<GoRouter>(),
      ),
    );
  }
}
