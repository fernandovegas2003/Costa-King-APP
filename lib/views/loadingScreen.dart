import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool checking = true;

  @override
  void initState() {
    super.initState();
    _checkInternetAndNavigate();
  }

  Future<void> _checkInternetAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Tiempo de splash

    bool hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
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
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
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
              'assets/images/Logo1.png',
              width: 200,
            ),
            const SizedBox(height: 20),
            if (checking)
              const CircularProgressIndicator(color: Color(0xFF006D73)),
          ],
        ),
      ),
    );
  }
}
