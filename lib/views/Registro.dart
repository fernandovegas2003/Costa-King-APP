import 'package:flutter/material.dart';
import '../componentes/buttons/Button1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController tipoDocController = TextEditingController();
  final TextEditingController numeroDocController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  bool loading = false;

  Future<void> _registrar() async {
    setState(() {
      loading = true;
    });

    try {
      final url = Uri.parse("https://tu-backend.com/api/registro");
      final body = {
        "nombre": nombreController.text,
        "apellido": apellidoController.text,
        "fechaNacimiento": fechaController.text,
        "tipoDocumento": tipoDocController.text,
        "numeroDocumento": numeroDocController.text,
        "contrasena": contrasenaController.text,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print("Registro exitoso: ${response.body}");
        Navigator.pop(context);
      } else {
        print("Error en registro: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error de conexión: $e");
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
          // 🔹 Parte superior con fondo turquesa
          Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Fondo.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/Logo1.png',
                            width: 100,
                          ),
                          const SizedBox(height: 30),
                          _buildTextField(nombreController, "Nombres"),
                          const SizedBox(height: 10),
                          _buildTextField(apellidoController, "Apellidos"),
                          const SizedBox(height: 10),
                          _buildTextField(fechaController, "Fecha de nacimiento"),
                          const SizedBox(height: 10),
                          _buildTextField(tipoDocController, "Tipo de documento"),
                          const SizedBox(height: 10),
                          _buildTextField(numeroDocController, "Número de documento"),
                          const SizedBox(height: 10),
                          _buildTextField(contrasenaController, "Contraseña", obscure: true),
                        ],
                      ),
                    ),
                  ),
                ),
                // 🔹 Botón "Registrarse" pegado abajo
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
                    onPressed: loading ? null : _registrar,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text(
                      "Registrarse",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Botón inferior "Iniciar sesión"
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomButton(
                  text: "INICIAR SESIÓN",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
