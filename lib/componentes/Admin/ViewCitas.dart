import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    final url = Uri.parse('https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas');
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
      setState(() => cargando = false);
    }
  }

  void mostrarDetallesCita(Map<String, dynamic> cita) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Cita #${cita['idCita']} - ${cita['estadoCita']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("👩‍⚕️ Médico: ${cita['nombreMedico']}"),
              Text("🧍 Paciente: ${cita['nombrePaciente']}"),
              Text("💬 Motivo: ${cita['motivo']}"),
              Text("🤒 Síntomas: ${cita['sintomas']}"),
              if (cita['observaciones'] != null)
                Text("📝 Observaciones: ${cita['observaciones']}"),
              const SizedBox(height: 10),
              Text("🏥 Servicio: ${cita['nombreServicio']}"),
              Text("📚 Especialidad: ${cita['nombreEspecialidad']}"),
              Text("📍 Sede: ${cita['nombreSede']}"),
              const SizedBox(height: 10),
              Text("📅 Fecha: ${cita['fechaHora'].toString().split('T')[0]}"),
              Text("⏰ Hora: ${cita['fechaHora'].toString().split('T')[1].substring(0,5)}"),
              const SizedBox(height: 10),
              Text("🕓 Creada el: ${cita['fechaCreacion'].toString().split('T')[0]}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Colors.teal)),
          ),
        ],
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
      label: Text(estado, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Todas las Citas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // 📌 Fondo con imagen
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          // 📌 Contenido principal
          cargando
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF01A4B2)))
              : citas.isEmpty
              ? const Center(
            child: Text(
              "No hay citas registradas",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          )
              : Column(
            children: [
              const SizedBox(height: 160),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -50),
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
                    child: ListView.builder(
                      itemCount: citas.length,
                      itemBuilder: (context, index) {
                        final cita = citas[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF01A4B2),
                              child: Text(
                                cita['nombrePaciente'][0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              cita['nombrePaciente'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Médico: ${cita['nombreMedico']}"),
                                Text("Servicio: ${cita['nombreServicio']}"),
                                Row(
                                  children: [
                                    const Text("Estado: "),
                                    _estadoChip(cita['estadoCita']),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () => mostrarDetallesCita(cita),
                          ),
                        );
                      },
                    ),
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
