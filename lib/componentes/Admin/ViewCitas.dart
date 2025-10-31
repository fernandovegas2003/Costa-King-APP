import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


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
    color: AppColors.paynesGray, //
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray, //
    fontSize: 14,
    fontFamily: _fontFamily,
  );
}

class VerCitasAdminPage extends StatefulWidget {
  const VerCitasAdminPage({Key? key}) : super(key: key);

  @override
  State<VerCitasAdminPage> createState() => _VerCitasAdminPageState();
}

class _VerCitasAdminPageState extends State<VerCitasAdminPage> {
  List<dynamic> citas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerCitas();
  }

  Future<void> obtenerCitas() async {
    final url = Uri.parse(
      'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas',
    );
    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        setState(() {
          citas = data["data"];
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      if (mounted) setState(() => cargando = false);
    }
  }


  void mostrarDetallesCita(Map<String, dynamic> cita) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white, // 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Cita #${cita['idCita']}",
          style: AppTextStyles.headline.copyWith(
            color: AppColors.keppel,
            fontSize: 20,
          ), // 
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _estadoChip(cita['estadoCita']), 
              const SizedBox(height: 10),
              _infoItem("👩‍⚕️ Médico:", cita['nombreMedico']),
              _infoItem("🧍 Paciente:", cita['nombrePaciente']),
              _infoItem("💬 Motivo:", cita['motivo']),
              _infoItem("🤒 Síntomas:", cita['sintomas']),
              if (cita['observaciones'] != null)
                _infoItem("📝 Observaciones:", cita['observaciones']),
              const Divider(height: 20),
              _infoItem("🏥 Servicio:", cita['nombreServicio']),
              _infoItem("📚 Especialidad:", cita['nombreEspecialidad']),
              _infoItem("📍 Sede:", cita['nombreSede']),
              const Divider(height: 20),
              _infoItem(
                "📅 Fecha:",
                cita['fechaHora'].toString().split('T')[0],
              ),
              _infoItem(
                "⏰ Hora:",
                cita['fechaHora'].toString().split('T')[1].substring(0, 5),
              ),
              _infoItem(
                "🕓 Creada el:",
                cita['fechaCreacion'].toString().split('T')[0],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, // 🎨 Color
              foregroundColor: AppColors.paynesGray, // 🎨 Color
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cerrar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.body.copyWith(fontSize: 14), // 
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }


  Widget _estadoChip(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'pendiente':
        color = Colors.orange;
        break;
      case 'completada':
        color = Colors.green;
        break;
      case 'cancelada':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        estado,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste, //
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ), //
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Todas las Citas",
          style: AppTextStyles.headline.copyWith(fontSize: 20), 
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
    
          child: cargando
              ? Center(
                  
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.aquamarine),
                      SizedBox(height: 16),
                      Text(
                        "Cargando todas las citas...",
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                )
              : citas.isEmpty
              ? Center(
               
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 60,
                        color: AppColors.paynesGray.withOpacity(0.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No hay citas registradas",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.paynesGray.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: citas.length,
                  itemBuilder: (context, i) {
                    final cita = citas[i];
                    
                    return Card(
                      color: AppColors.white.withOpacity(0.7), // 🎨 Color
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.keppel.withOpacity(
                            0.1,
                          ), 
                          child: Text(
                            cita['nombrePaciente'][0],
                            style: const TextStyle(
                              color: AppColors.keppel,
                              fontWeight: FontWeight.bold,
                            ), 
                          ),
                        ),
                        title: Text(
                          cita['nombrePaciente'],
                          style: AppTextStyles.cardTitle.copyWith(
                            color: AppColors.paynesGray,
                          ), 
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Médico: ${cita['nombreMedico']}",
                              style: AppTextStyles.cardDescription,
                            ), 
                            Text(
                              "Servicio: ${cita['nombreServicio']}",
                              style: AppTextStyles.cardDescription,
                            ), 
                            Row(
                              children: [
                                Text(
                                  "Estado: ",
                                  style: AppTextStyles.cardDescription,
                                ), 
                                _estadoChip(cita['estadoCita']),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: AppColors.keppel,
                        ), 
                        onTap: () => mostrarDetallesCita(cita),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
