import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Citas/AgendarCita.dart';
import '../Citas/CancelarCita.dart';
import '../Citas/VerCitas.dart';
import 'OrdenesMedicas.dart';
import './Factura/Factura.dart';
import 'NPL.dart';

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
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonPrimary = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonSecondary = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class MenuCitasPage extends StatelessWidget {
  const MenuCitasPage({Key? key}) : super(key: key);

  Widget _botonMenu(
    BuildContext context,
    String texto,
    VoidCallback onTap,
    IconData icon, {
    bool isPrimary = false,
  }) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? AppColors.aquamarine : AppColors.keppel,
      foregroundColor: isPrimary ? AppColors.paynesGray : AppColors.white,
      minimumSize: const Size(double.infinity, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 3,
    );

    return ElevatedButton.icon(
      onPressed: onTap,
      style: style,
      icon: Icon(icon, size: 20),
      label: Text(
        texto,
        style: isPrimary
            ? AppTextStyles.buttonPrimary
            : AppTextStyles.buttonSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final botones = [
      {
        "texto": "Agendar Cita Médica",
        "icon": Icons.add_circle_outline,
        "isPrimary": true,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AgendarCitaPage()),
        ),
      },
      {
        "texto": "Ver Citas",
        "icon": Icons.calendar_today_outlined,
        "isPrimary": false,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VerCitasScreen()),
        ),
      },
      {
        "texto": "Cancelar Cita",
        "icon": Icons.cancel_outlined,
        "isPrimary": false,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CancelarCitaPage()),
        ),
      },
      {
        "texto": "Ver Órdenes Médicas",
        "icon": Icons.receipt_long_outlined,
        "isPrimary": false,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VerOrdenesMedicasPage(),
          ),
        ),
      },
      {
        "texto": "Ver Facturas",
        "icon": Icons.receipt_outlined,
        "isPrimary": false,
        "onTap": () async {
          final prefs = await SharedPreferences.getInstance();
          final cedula = prefs.getString("numeroDocumento") ?? "";
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FacturasScreen(cedula: cedula),
              ),
            );
          }
        },
      },
      {
        "texto": "NPL - Procesar Archivo",
        "icon": Icons.analytics_outlined,
        "isPrimary": false,
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NPLScreen()),
        ),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.celeste,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.paynesGray),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Gestión de Citas", style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < botones.length; i++) ...[
                    _botonMenu(
                      context,
                      botones[i]['texto'] as String,
                      botones[i]['onTap'] as VoidCallback,
                      botones[i]['icon'] as IconData,
                      isPrimary: botones[i]['isPrimary'] as bool,
                    ),
                    if (i != botones.length - 1) const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
