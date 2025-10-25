import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerAutorizacionesPage extends StatefulWidget {
  const VerAutorizacionesPage({Key? key}) : super(key: key);

  @override
  State<VerAutorizacionesPage> createState() => _VerAutorizacionesPageState();
}

class _VerAutorizacionesPageState extends State<VerAutorizacionesPage> {
  List<dynamic> ordenes = [];
  bool cargando = true;
  int? idPaciente;
  int? idDoctor;

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    final prefs = await SharedPreferences.getInstance();
    idPaciente = prefs.getInt('idPacienteSeleccionado');
    idDoctor = prefs.getInt('idDoctor');

    if (idPaciente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró el ID del paciente")),
      );
      setState(() => cargando = false);
      return;
    }

    try {
      final url = Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/ordenes-medicas/paciente/$idPaciente");
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        setState(() {
          ordenes = (data["data"] ?? [])
              .where((o) =>
          o["estadoOrden"] == null ||
              o["estadoOrden"].toString().toLowerCase() != "aprobada")
              .toList();
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> _aprobarAutorizacion(int idOrden) async {
    if (idDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró el ID del doctor")),
      );
      return;
    }

    try {
      final url = Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/autorizaciones");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idOrdenMedica": idOrden,
          "idAutorizador": idDoctor,
          "estadoAutorizacion": "Aprobada",
          "observaciones": "Autorización aprobada por el doctor"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Autorización aprobada con éxito ✅")),
        );
        // ✅ Refrescar lista sin necesidad de recargar la pantalla completa
        setState(() {
          ordenes.removeWhere((o) => o["idOrdenMedica"] == idOrden);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al aprobar: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void mostrarDetallesOrden(Map<String, dynamic> orden) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Detalles de la Orden Médica",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🆔 ID Orden: ${orden['idOrdenMedica']}"),
            Text("🩺 Tipo: ${orden['tipoOrden']}"),
            Text("📄 Descripción: ${orden['descripcion']}"),
            Text(
                "📅 Emitida: ${orden['fechaEmision']?.toString().split('T')[0] ?? 'N/A'}"),
            Text(
                "⏰ Vence: ${orden['fechaVencimiento']?.toString().split('T')[0] ?? 'N/A'}"),
            Text("📌 Estado: ${orden['estadoOrden'] ?? 'Pendiente'}"),
            Text("🧑‍⚕️ Médico: ${orden['nombreMedico'] ?? 'Desconocido'}"),
            Text("🏥 Especialidad: ${orden['especialidad'] ?? 'N/A'}"),
            Text("💬 Observaciones: ${orden['observaciones'] ?? 'N/A'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Colors.teal)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _aprobarAutorizacion(orden['idOrdenMedica']);
            },
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: const Text("Aprobar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Órdenes Médicas del Paciente",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/Fondo.png", fit: BoxFit.cover),
          ),
          cargando
              ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF01A4B2)),
          )
              : Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
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
                  child: ordenes.isEmpty
                      ? const Center(
                    child: Text(
                      "No hay órdenes médicas pendientes para este paciente 🩺",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black54, fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    itemCount: ordenes.length,
                    itemBuilder: (context, index) {
                      final o = ordenes[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        margin:
                        const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF01A4B2),
                            child: Icon(Icons.assignment,
                                color: Colors.white),
                          ),
                          title: Text(
                            "${o['tipoOrden'] ?? 'Orden'}: ${o['descripcion'] ?? 'Sin descripción'}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "Estado: ${o['estadoOrden'] ?? 'Pendiente'}"),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await _aprobarAutorizacion(
                                  o['idOrdenMedica']);
                            },
                            child: const Text(
                              "Aprobar",
                              style:
                              TextStyle(color: Colors.white),
                            ),
                          ),
                          onTap: () => mostrarDetallesOrden(o),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
