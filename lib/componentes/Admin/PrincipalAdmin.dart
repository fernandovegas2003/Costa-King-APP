import 'package:flutter/material.dart';
import 'VerUsers.dart';
import 'ViewCitas.dart';
import 'HClinica.dart';
import 'DashboardAdminPage.dart';
import 'package:shared_preferences/shared_preferences.dart'; 


class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class MenuAdminPage extends StatelessWidget {
  const MenuAdminPage({Key? key}) : super(key: key);

  Widget _botonMenu(BuildContext context, String texto, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.keppel, 
        foregroundColor: AppColors.white, 
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 5,
        shadowColor: AppColors.paynesGray.withOpacity(0.3),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: AppColors.white,
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
        },
      },
      {
        'texto': "Ver Todas las Citas",
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VerCitasAdminPage()),
          );
        },
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
        },
      },
      {
        'texto': "Ver estadisticas",
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardAdminPage()),
          );
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white, // 🎨 Color
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.paynesGray), // 🎨 Color
        title: const Text(
          "Panel de Administración",
          style: TextStyle(
            color: AppColors.paynesGray, // 🎨 Color
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          
          Positioned.fill(
            child: Image.asset("assets/images/Fondo.png", fit: BoxFit.cover),
          ),

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.93), // 
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.paynesGray.withOpacity(0.15), // 
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
                    Text(
                      "Opciones de Gestión",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.keppel, // 🎨 Color
                      ),
                    ),
                    const SizedBox(height: 30),
                    ...botones.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _botonMenu(
                          context,
                          b['texto'] as String,
                          b['onTap'] as VoidCallback,
                        ),
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
