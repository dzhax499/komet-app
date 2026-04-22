import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/kelas/presentation/bloc/kelas_bloc.dart';

void main() async {
  // WAJIB: harus dipanggil sebelum apapun yang async/plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi semua dependency: Hive, GetIt, dll
  await setupServiceLocator();

  runApp(const MyApp());
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
