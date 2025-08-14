import 'package:flutter/material.dart';
import 'dart:io';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool checking = true; // Para mostrar que está verificando

  @override
  void initState() {
    super.initState();
    _checkInternetAndNavigate();
  }

  Future<void> _checkInternetAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Tiempo del splash

    bool hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NextScreen()),
      );
    } else {
      setState(() {
        checking = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Sin conexión'),
          content: const Text(
            'No se detectó conexión a Internet. Verifica tu conexión y reintenta.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  checking = true;
                });
                _checkInternetAndNavigate(); // Reintentar
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '../../images/logo1.png', // Asegúrate de que la ruta sea correcta
              width: 200,
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            if (checking)
              const CircularProgressIndicator(color: Color(0xFF006D73)),
          ],
        ),
      ),
    );
  }
}

// Pantalla de ejemplo para cuando haya internet
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Pantalla principal')));
  }
}
