import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'RegisterCitas.dart';
import '../Citas/PrincipalCitas.dart'; // 👈 Paciente
import '../Admin/PrincipalAdmin.dart'; // 👈 Administrador
import '../Doctor/AgendaDoctor.dart';  // 👈 Doctor

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/auth/login",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "emailUsuario": _emailController.text.trim(),
          "pwdUsuario": _pwdController.text.trim(),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          final token = data["data"]["token"];
          final refreshToken = data["data"]["refreshToken"];
          final usuario = data["data"]["usuario"];
          final idUsuario = usuario["idUsuario"];
          final idRol = usuario["idRol"];
          final rol = usuario["nombreRol"];
          final numeroDocumento = usuario["numeroDocumento"]; // 👈 Extraemos el número

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);
          await prefs.setString("refreshToken", refreshToken);

          if (idUsuario != null) {
            await prefs.setInt("idPaciente", idUsuario);
          }

          // 🩵 Guardar también el idDoctor si el rol corresponde
          if (rol.toString().toLowerCase() == "doctor" || idRol == 2) {
            await prefs.setInt("idDoctor", idUsuario);
            print("✅ idDoctor guardado: $idUsuario");
          }

          // 🆕 Guardar el número de documento del usuario
          if (numeroDocumento != null && numeroDocumento.toString().isNotEmpty) {
            await prefs.setString("numeroDocumento", numeroDocumento.toString());
            print("✅ númeroDocumento guardado: $numeroDocumento");
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bienvenido ${usuario["nombreUsuario"]}")),
          );

          // 🔄 Redirección según el rol
          Future.delayed(const Duration(milliseconds: 500), () {
            if (idRol == 1 || rol == "Paciente") {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MenuCitasPage()),
              );
            } else if (idRol == 2 || rol == "Doctor") {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AgendaDoctorPage()),
              );
            } else if (idRol == 3 || rol == "Administrador") {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MenuAdminPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Rol no autorizado o sin acceso definido."),
                ),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error API: ${data["message"]}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${response.statusCode}: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  Widget _botonLogin(String texto) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF01A4B2),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _botonRegistrarse() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "Registrarse",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/Fondo.png", fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pwdController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _botonLogin("Ingresar"),
                  const SizedBox(height: 10),
                  _botonRegistrarse(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
