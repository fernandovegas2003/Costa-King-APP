import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/widget/appScalfod.dart';
import 'DiagnosticoSintoma.dart';

class SintomasPage extends StatefulWidget {
  const SintomasPage({super.key});

  @override
  State<SintomasPage> createState() => _SintomasPageState();
}

class _SintomasPageState extends State<SintomasPage> {
  Map<String, dynamic>? sintomas;
  String? sintomaSeleccionado;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarSintomas();
  }

  Future<void> _cargarSintomas() async {
    try {
      final response = await http.get(
        Uri.parse("http://20.251.169.101:5002/sintomas"),
      );
      if (response.statusCode == 200) {
        setState(() {
          sintomas = jsonDecode(response.body)["sintomas_por_categoria"];
          cargando = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando síntomas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Síntomas",
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ), // 🔹 espacio bajo header
              children: [
                // 🔹 Cada categoría en una Card blanca
                ...sintomas!.entries.map((entry) {
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 21, 20, 21),
                        ),
                      ),
                      children: entry.value.map<Widget>((s) {
                        return RadioListTile<String>(
                          title: Text(s),
                          value: s,
                          groupValue: sintomaSeleccionado,
                          onChanged: (val) {
                            setState(() => sintomaSeleccionado = val);
                          },
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),

                // 🔹 Botón al final
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006D73),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: sintomaSeleccionado == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DiagnosticoSintomaPage(
                                  sintoma: sintomaSeleccionado!,
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      "Consultar diagnóstico",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
