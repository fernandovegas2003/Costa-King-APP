import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VerAutorizacionesPage extends StatefulWidget {
  const VerAutorizacionesPage({Key? key}) : super(key: key);

  @override
  State<VerAutorizacionesPage> createState() => _VerAutorizacionesPageState();
}

class _VerAutorizacionesPageState extends State<VerAutorizacionesPage> {
  List<dynamic> autorizaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerAutorizaciones();
  }

  Future<void> obtenerAutorizaciones() async {
    final url = Uri.parse(
        'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/autorizaciones');
    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        setState(() {
          autorizaciones = data["data"] ?? [];
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  void mostrarDetallesAutorizacion(Map<String, dynamic> autorizacion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Detalles de la Autorización",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🆔 ID Orden Médica: ${autorizacion['idOrdenMedica']}"),
            Text("👨‍⚕️ ID Autorizador: ${autorizacion['idAutorizador']}"),
            Text("📅 Estado: ${autorizacion['estadoAutorizacion']}"),
            Text("📝 Observaciones: ${autorizacion['observaciones'] ?? 'N/A'}"),
            if (autorizacion['fechaAutorizacion'] != null)
              Text("⏰ Fecha: ${autorizacion['fechaAutorizacion'].toString().split('T')[0]}"),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Autorizaciones Médicas",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        // 🔹 Se eliminó el botón de crear
      ),
      body: Stack(
        children: [
          // 🌅 Fondo
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          cargando
              ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF01A4B2)),
          )
              : Column(
            children: [
              const SizedBox(height: 25),

              // 📦 Contenedor principal centrado
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.only(bottom: 20),
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
                    child: autorizaciones.isEmpty
                        ? const Center(
                      child: Text(
                        "No hay autorizaciones registradas",
                        style: TextStyle(
                            color: Colors.black54, fontSize: 16),
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: autorizaciones.length,
                      itemBuilder: (context, index) {
                        final a = autorizaciones[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF01A4B2),
                              child: Icon(
                                  Icons.assignment_turned_in,
                                  color: Colors.white),
                            ),
                            title: Text(
                              "Orden Médica #${a['idOrdenMedica']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "Estado: ${a['estadoAutorizacion'] ?? 'Desconocido'}"),
                            trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18),
                            onTap: () =>
                                mostrarDetallesAutorizacion(a),
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
