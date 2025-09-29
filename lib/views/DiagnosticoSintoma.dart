import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/widget/appScalfod.dart';

class DiagnosticoSintomaPage extends StatefulWidget {
  final String sintoma;
  const DiagnosticoSintomaPage({super.key, required this.sintoma});

  @override
  State<DiagnosticoSintomaPage> createState() => _DiagnosticoSintomaPageState();
}

class _DiagnosticoSintomaPageState extends State<DiagnosticoSintomaPage> {
  Map<String, dynamic>? resultado;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _consultarDiagnostico();
  }

  Future<void> _consultarDiagnostico() async {
    try {
      final response = await http.post(
        Uri.parse("http://20.251.169.101:5002/diagnostico"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"sintoma": widget.sintoma}),
      );
      if (response.statusCode == 200) {
        setState(() {
          resultado = jsonDecode(response.body);
          cargando = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Diagnóstico",
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Advertencias
                  Card(
                    color: Colors.yellow[50],
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      children: (resultado!['advertencias'] as List).map<Widget>((a) {
                        return ListTile(
                          leading: const Icon(Icons.warning, color: Colors.orange),
                          title: Text(a),
                        );
                      }).toList(),
                    ),
                  ),
                  // Emergencia
                  if (resultado!['emergencia'] != null)
                    Card(
                      color: Colors.red[50],
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.emergency, color: Colors.red),
                        title: Text(resultado!['emergencia']),
                      ),
                    ),
                  // Enfermedades posibles
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Enfermedades posibles:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...((resultado!['enfermedades_posibles'] as List)
                              .map((e) => Text("• $e"))),
                        ],
                      ),
                    ),
                  ),
                  // Medicamentos recomendados
                  ...((resultado!['medicamentos_recomendados'] as List).map((m) {
                    final pos = m['posologia'];
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(m['nombre'],
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(m['descripcion']),
                        children: [
                          ListTile(title: Text("Dosis: ${pos['dosis']}")),
                          ListTile(title: Text("Máxima diaria: ${pos['dosis_maxima_diaria']}")),
                          ListTile(title: Text("Frecuencia: ${pos['frecuencia']}")),
                          ListTile(title: Text("Duración: ${pos['duracion']}")),
                          ListTile(title: Text("Vía: ${pos['via_administracion']}")),
                        ],
                      )
                    );
                  })),
                ],
              ),
            ),
    );
  }
}
