import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> _cargarOrdenes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idPaciente = prefs.getInt('idPaciente'); // 👈 se guarda al iniciar sesión

      if (idPaciente == null) {
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
          'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/ordenes-medicas/paciente/$idPaciente');
      final response = await http.get(url);

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
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error de conexión con el servidor."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Órdenes Médicas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          // Contenido
          cargando
              ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF01A4B2)))
              : ordenes.isEmpty
              ? const Center(
            child: Text(
              "No hay órdenes médicas registradas.",
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              final orden = ordenes[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
                color: Colors.white.withOpacity(0.95),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orden['tipoOrden'] ?? 'Tipo desconocido',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF01A4B2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Descripción: ${orden['descripcion'] ?? 'Sin descripción'}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Estado: ${orden['estadoOrden'] ?? 'Sin estado'}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Fecha emisión: ${_formatearFecha(orden['fechaEmision'])}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Vence: ${_formatearFecha(orden['fechaVencimiento'])}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Médico: ${orden['nombreMedico'] ?? 'No especificado'}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Especialidad: ${orden['especialidad'] ?? 'No especificada'}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      if (orden['observaciones'] != null &&
                          orden['observaciones'].toString().isNotEmpty)
                        Text(
                          "Observaciones: ${orden['observaciones']}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Función auxiliar para formatear fecha (YYYY-MM-DD → DD/MM/YYYY)
  String _formatearFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return "No disponible";
    try {
      final date = DateTime.parse(fecha);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return fecha;
    }
  }
}
