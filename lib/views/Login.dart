import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../componentes/buttons/Button1.dart';
import 'Registro.dart';
import 'package:flutter/foundation.dart';
import 'PrincipalPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  // 🔹 FUNCIÓN PARA DEBUGUEAR EL TOKEN
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
          // Normalizar base64
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
    setState(() {
      loading = true;
    });

    try {
      final uri = Uri.parse(
          'https://blesshealth24-7-backecommerce.onrender.com/auth/iniciar-sesion');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "correoUsuario": emailController.text.trim(),
          "contrasenaUsuario": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["token"] != null &&
            data["token"] != "NULL_TOKEN" &&
            data["usuario"] != null &&
            data["usuario"]["id"] != 0) {

          print("✅ Login exitoso: $data");

          // 🔹 DEBUG DEL TOKEN
          _debugToken(data["token"]);

          // 🔹 GUARDAR DATOS DEL USUARIO
          final authService = Provider.of<AuthService>(context, listen: false);
          await authService.login(data);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      print("❌ Error de conexión: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor")),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage('assets/images/Fondo.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            child: Column(
              children: [
                const Spacer(flex: 1),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/Logo1.png', width: 120),
                      const SizedBox(height: 40),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Correo Electrónico",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00A6B2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: loading ? null : _login,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text(
                      "Iniciar Sesión",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomButton(
                  text: "REGISTRARSE",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}