import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'views/loadingScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final authService = Provider.of<AuthService>(context, listen: false);

    switch (state) {
      case AppLifecycleState.paused:
      // App en segundo plano
        print('⏸️ App en background');
        break;

      case AppLifecycleState.resumed:
      // App en primer plano
        print('▶️ App en foreground');
        break;

      case AppLifecycleState.detached:
      // App completamente cerrada - LIMPIAR SESIÓN
        print('🚪 App cerrada - Limpiando sesión...');
        authService.clearSessionOnExit();
        break;

      case AppLifecycleState.inactive:
      // App inactiva temporalmente
        break;

      case AppLifecycleState.hidden:
      // App oculta (nueva en Flutter 3.22+)
        print('🙈 App oculta pero aún activa');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BlessHealth24',
      home: const SplashScreen(),
    );
  }
}