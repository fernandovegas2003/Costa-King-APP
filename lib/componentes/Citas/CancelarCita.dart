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
  static const String _fontFamily = 'TuFuenteApp'; // Asegúrate de tener esta fuente

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
  
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel, // 🎨 Color
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray, // 🎨 Color
    fontSize: 14,
    height: 1.4,
    fontFamily: _fontFamily,
  );
}


class CancelarCitaPage extends StatefulWidget {
  @override
  _CancelarCitaPageState createState() => _CancelarCitaPageState();
}

class _CancelarCitaPageState extends State<CancelarCitaPage> {
  List<dynamic> citas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCitas();
  }

  // --- (TODA TU LÓGICA DE API SE MANTIENE EXACTAMENTE IGUAL) ---
  Future<void> fetchCitas() async {
    final prefs = await SharedPreferences.getInstance();
    final idPaciente = prefs.getInt("idPaciente");

    if (idPaciente == null) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se encontró el usuario en sesión"), backgroundColor: Colors.red),
        );
        setState(() => isLoading = false);
      }
      return;
    }

    final response = await http.get(Uri.parse(
      "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/paciente/$idPaciente",
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          citas = data["data"]
              .where((cita) => cita["estado"] == "Pendiente")
              .toList();
          isLoading = false;
        });
      }
    } else {
      if(mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  Future<void> cancelarCita(int idCita, String motivo) async {
    final url = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/$idCita/cancelar");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"motivoCancelacion": motivo}),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      fetchCitas(); // refrescar citas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cita cancelada correctamente"), backgroundColor: AppColors.keppel), // 🎨 Color
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al cancelar la cita"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🎨 DIÁLOGO REDISEÑADO
  void mostrarDialogoMotivo(int idCita, String fechaHora) {
    final motivoController = TextEditingController();

    final fechaCita = DateTime.parse(fechaHora);
    final ahora = DateTime.now();
    final diferencia = fechaCita.difference(ahora);

    if (diferencia.inHours < 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se puede cancelar una cita con menos de 24 horas de anticipación"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white, // 🎨 Color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Motivo de cancelación", style: AppTextStyles.headline.copyWith(fontSize: 20)), // 🎨 Estilo
        content: TextField(
          controller: motivoController,
          style: AppTextStyles.body, // 🎨 Estilo
          decoration: InputDecoration( // 🎨 Estilo
            hintText: "Escribe el motivo",
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withAlpha(128)), // 0.5 opacity
            filled: true,
            fillColor: AppColors.iceBlue.withAlpha(128), // 0.5 opacity
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none
            )
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cerrar", style: TextStyle(color: AppColors.paynesGray)), // 🎨 Color
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, // 🎨 Color
              foregroundColor: AppColors.paynesGray, // 🎨 Color
            ),
            child: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              final motivo = motivoController.text.trim();
              if (motivo.isNotEmpty) {
                Navigator.pop(context);
                cancelarCita(idCita, motivo);
              }
            },
          ),
        ],
      ),
    );
  }

  // 🎨 --- BUILD METHOD REDISEÑADO --- 🎨
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste, // 🎨 Color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 🎨 Color
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.paynesGray), // 🎨 Color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Cancelar Cita",
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
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.aquamarine)) // 🎨 Color
                    : citas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 60, color: AppColors.paynesGray.withAlpha(77)), // 0.3 opacity
                                const SizedBox(height: 16),
                                Text(
                                  "No tienes citas pendientes",
                                  style: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withAlpha(179)), // 0.7 opacity
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: citas.length,
                            itemBuilder: (context, index) {
                              final cita = citas[index];
                              // 🎨 TARJETA DE CITA REDISEÑADA
                              return Card(
                                color: AppColors.white.withAlpha(179), // 0.7 opacity
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Médico: ${cita["nombreMedico"]}",
                                          style: AppTextStyles.cardTitle), // 🎨 Estilo
                                      const SizedBox(height: 4),
                                      Text("Especialidad: ${cita["especialidad"]}", style: AppTextStyles.cardDescription), // 🎨 Estilo
                                      Text("Servicio: ${cita["servicio"]}", style: AppTextStyles.cardDescription), // 🎨 Estilo
                                      Text("Fecha: ${cita["fechaHora"]}", style: AppTextStyles.cardDescription), // 🎨 Estilo
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => mostrarDialogoMotivo(
                                            cita["idCita"], cita["fechaHora"]),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[700], // Color semántico
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 45),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30), // 🎨 Redondeado
                                          ),
                                        ),
                                        child: const Text("Cancelar Cita", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}