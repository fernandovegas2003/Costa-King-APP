import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'Registro.dart';
import 'package:flutter/foundation.dart';
import 'PrincipalPage.dart';

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily = 'TuFuenteApp';

  static const TextStyle headline = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle link = TextStyle(
    color: AppColors.keppel,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool _isPasswordVisible = false;

  void _debugToken(String token) {
    if (kDebugMode) {
      print('🔐 TOKEN RECIBIDO:');
      print('📏 Longitud: ${token.length}');
      final parts = token.split('.');
      print('🔢 Partes del token: ${parts.length}');
      if (parts.length == 3) {
        print('✅ Token tiene formato JWT válido');
        try {
          final payload = parts[1];
          String normalized = base64.normalize(payload);
          String decoded = utf8.decode(base64.decode(normalized));
          final payloadMap = json.decode(decoded);
          print('👤 User ID en token: ${payloadMap['userId']}');
          print('⏰ Expiración: ${payloadMap['exp']}');
        } catch (e) {
          print('❌ Error decodificando token: $e');
        }
      } else {
        print('❌ ERROR: Token no tiene formato JWT válido');
      }
    }
  }

  Future<void> _login() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      final uri = Uri.parse(
        'https://blesshealth24-7-backecommerce.onrender.com/auth/iniciar-sesion',
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "correoUsuario": emailController.text.trim(),
          "contrasenaUsuario": passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["token"] != null &&
            data["token"] != "NULL_TOKEN" &&
            data["usuario"] != null &&
            data["usuario"]["id"] != 0) {
          print("✅ Login exitoso: $data");
          _debugToken(data["token"]);
          final authService = Provider.of<AuthService>(context, listen: false);
          await authService.login(data);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          print("❌ Error en credenciales: $data");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Correo o contraseña incorrectos")),
          );
        }
      } else {
        print("❌ Error: ${response.statusCode}");
        print("❌ Respuesta: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      print("❌ Error de conexión: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de conexión con el servidor")),
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/Logo1.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 40),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      labelStyle: AppTextStyles.body.copyWith(
                        color: AppColors.paynesGray.withOpacity(0.7),
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.paynesGray,
                      ),
                      filled: true,
                      fillColor: AppColors.white.withOpacity(
                        0.5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText:
                        !_isPasswordVisible,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: AppTextStyles.body.copyWith(
                        color: AppColors.paynesGray.withOpacity(0.7),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.paynesGray,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.paynesGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: AppColors.white.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.aquamarine,
                      foregroundColor: AppColors.paynesGray,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: loading ? null : _login,
                    child: loading
                        ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.paynesGray,
                              ),
                            )
                        : const Text(
                              "Iniciar Sesión",
                              style: AppTextStyles.button,
                            ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta?',
                        style: AppTextStyles.body,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistroPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Regístrate',
                          style: AppTextStyles.link,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}