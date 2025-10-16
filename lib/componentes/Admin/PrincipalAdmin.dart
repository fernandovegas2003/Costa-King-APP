import 'package:flutter/material.dart';
import 'VerUsers.dart';
import 'ViewCitas.dart';
import 'HClinica.dart';

class MenuAdminPage extends StatelessWidget {
  const MenuAdminPage({Key? key}) : super(key: key);

  Widget _botonMenu(BuildContext context, String texto, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF01A4B2),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 5,
        shadowColor: Colors.black38,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final botones = [
      {
        'texto': "Ver Todos los Usuarios",
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VerUsuariosPage()),
          );
        }
      },
      {
        'texto': "Ver Todas las Citas",
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VerCitasAdminPage()),
          );
        }
      },
      {
        'texto': "Historias Clínicas",
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VerHistoriasClinicasPage(),
            ),
          );
        }
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Panel de Administración",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// 🌅 Fondo
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 📦 Contenido centrado
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.93),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Opciones de Gestión",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF01A4B2),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ...botones.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _botonMenu(context, b['texto'] as String, b['onTap'] as VoidCallback),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
