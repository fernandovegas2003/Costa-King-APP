import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // ✅ ¡IMPORTACIÓN AÑADIDA!

// 🎨 TU PALETA DE COLORES PROFESIONAL
class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

// 🖋️ TUS ESTILOS DE TEXTO PROFESIONALES
class AppTextStyles {
  static const String _fontFamily =
      'TuFuenteApp'; // Asegúrate de tener esta fuente

  static const TextStyle headline = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 15,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel, // 🎨 Color
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray, // 🎨 Color
    fontSize: 15, // Manteniendo tu tamaño de 15
    height: 1.4,
    fontFamily: _fontFamily,
  );
}

class VerOrdenesMedicasPage extends StatefulWidget {
  const VerOrdenesMedicasPage({Key? key}) : super(key: key);

  @override
  State<VerOrdenesMedicasPage> createState() => _VerOrdenesMedicasPageState();
}

class _VerOrdenesMedicasPageState extends State<VerOrdenesMedicasPage> {
  bool cargando = true;
  List<dynamic> ordenes = [];

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  // --- (TODA TU LÓGICA DE API SE MANTIENE EXACTAMENTE IGUAL) ---
  Future<void> _cargarOrdenes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idPaciente = prefs.getInt('idPaciente');

      if (idPaciente == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se encontró el ID del paciente."),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => cargando = false);
        return;
      }

      final url = Uri.parse(
        'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/ordenes-medicas/paciente/$idPaciente',
      );
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ordenes = data['data'] ?? [];
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al obtener órdenes: ${response.body}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error de conexión con el servidor."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // --- (Función de formateo SIN CAMBIOS) ---
  String _formatearFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return "No disponible";
    try {
      final date = DateTime.parse(fecha);
      // ✅ AHORA FUNCIONA GRACIAS A LA IMPORTACIÓN
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return fecha;
    }
  }

  // 🎨 --- BUILD METHOD REDISEÑADO --- 🎨
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste, // 🎨 Color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 🎨 Color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ), // 🎨 Color
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Órdenes Médicas",
          style: AppTextStyles.headline.copyWith(fontSize: 20), // 🎨 Estilo
        ),
        centerTitle: true,
      ),
      body: Container(
        // 🎨 GRADIENTE DE FONDO
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          // 🎨 Contenido
          child: cargando
              ? Center(
                  // 🎨 Loading rediseñado
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.aquamarine,
                      ), // 🎨 Color
                      SizedBox(height: 16),
                      Text(
                        "Cargando órdenes...",
                        style: AppTextStyles.body,
                      ), // 🎨 Estilo
                    ],
                  ),
                )
              : ordenes.isEmpty
              ? Center(
                  // 🎨 Empty state rediseñado
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 60,
                        color: AppColors.paynesGray.withAlpha(77),
                      ), // 0.3 opacity
                      SizedBox(height: 16),
                      Text(
                        "No hay órdenes médicas registradas.",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.paynesGray.withAlpha(179),
                        ), // 0.7 opacity
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordenes.length,
                  itemBuilder: (context, index) {
                    final orden = ordenes[index];
                    // 🎨 TARJETA REDISEÑADA
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha(179), // 0.7 opacity
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.white), // 🎨 Borde
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.paynesGray.withAlpha(
                              26,
                            ), // 0.1 opacity
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orden['tipoOrden'] ?? 'Tipo desconocido',
                            style: AppTextStyles.cardTitle, // 🎨 Estilo
                          ),
                          Divider(
                            color: AppColors.keppel.withAlpha(128),
                            height: 20,
                            thickness: 1,
                          ), // 0.5 opacity

                          Text(
                            "Descripción: ${orden['descripcion'] ?? 'Sin descripción'}",
                            style: AppTextStyles.cardDescription, // 🎨 Estilo
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Estado: ${orden['estadoOrden'] ?? 'Sin estado'}",
                            style: AppTextStyles.cardDescription, // 🎨 Estilo
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Fecha emisión: ${_formatearFecha(orden['fechaEmision'])}",
                            style: AppTextStyles.cardDescription, // 🎨 Estilo
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Vence: ${_formatearFecha(orden['fechaVencimiento'])}",
                            style: AppTextStyles.cardDescription, // 🎨 Estilo
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Médico: ${orden['nombreMedico'] ?? 'No especificado'}",
                            style: AppTextStyles.cardDescription, // 🎨 Estilo
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Especialidad: ${orden['especialidad'] ?? 'No especificada'}",
                            style: AppTextStyles.cardDescription, // 🎨 Estilo
                          ),
                          const SizedBox(height: 8),
                          if (orden['observaciones'] != null &&
                              orden['observaciones'].toString().isNotEmpty)
                            Text(
                              "Observaciones: ${orden['observaciones']}",
                              style: AppTextStyles.cardDescription.copyWith(
                                // 🎨 Estilo
                                fontStyle: FontStyle.italic,
                                color: AppColors.paynesGray.withAlpha(
                                  204,
                                ), // 0.8 opacity
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
