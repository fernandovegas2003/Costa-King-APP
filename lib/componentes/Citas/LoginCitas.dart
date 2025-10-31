import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'RegisterCitas.dart';
import '../Citas/PrincipalCitas.dart'; 
import '../Admin/PrincipalAdmin.dart'; 
import '../Doctor/AgendaDoctor.dart'; 

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily =
      'TuFuenteApp'; 

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
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; 

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

      if (!mounted) return; 

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
          final numeroDocumento = usuario["numeroDocumento"];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);
          await prefs.setString("refreshToken", refreshToken);

          if (idUsuario != null) {
            await prefs.setInt("idPaciente", idUsuario);
          }

          if (rol.toString().toLowerCase() == "doctor" || idRol == 2) {
            await prefs.setInt("idDoctor", idUsuario);
            print("✅ idDoctor guardado: $idUsuario");
          }

          if (numeroDocumento != null &&
              numeroDocumento.toString().isNotEmpty) {
            await prefs.setString(
              "numeroDocumento",
              numeroDocumento.toString(),
            );
            print("✅ númeroDocumento guardado: $numeroDocumento");
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Bienvenido ${usuario["nombreUsuario"]}"),
              backgroundColor: AppColors.keppel, 
            ),
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
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
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error API: ${data["message"]}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error ${response.statusCode}: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de conexión: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.5), 
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.paynesGray.withOpacity(
                            0.1,
                          ), 
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Iniciar Sesión",
                          style: AppTextStyles.headline, 
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
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
                            fillColor: AppColors.white.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _pwdController,
                          obscureText: !_isPasswordVisible, 
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
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.aquamarine, 
                              foregroundColor: AppColors.paynesGray, 
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.paynesGray,
                                    ),
                                  )
                                : Text(
                                    "Ingresar",
                                    style: AppTextStyles.button, 
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta?',
                        style: AppTextStyles.body, 
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
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