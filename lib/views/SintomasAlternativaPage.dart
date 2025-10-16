import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/widget/appScalfod.dart';
import 'DiagnosticoAlternativa.dart';

class SintomasAlternativaPage extends StatefulWidget {
  const SintomasAlternativaPage({super.key});

  @override
  State<SintomasAlternativaPage> createState() => _SintomasAlternativaPageState();
}

class _SintomasAlternativaPageState extends State<SintomasAlternativaPage> {
  Map<String, List<String>> sintomasPorCategoria = {};
  final Set<String> sintomasSeleccionados = {};
  bool cargando = true;
  double duracionDias = 1; // 🔹 duración inicial (1 día)

  @override
  void initState() {
    super.initState();
    _cargarSintomas();
  }

  Future<void> _cargarSintomas() async {
    try {
      final response = await http.get(
        Uri.parse("http://20.251.169.101:5007/api/sintomas-disponibles"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sintomas = data["sintomas_disponibles"] as Map<String, dynamic>;

        final Map<String, List<String>> agrupados = {};
        sintomas.forEach((key, value) {
          final categoria = value["categoria"] ?? "General";
          final nombre = value["nombre"] ?? key;
          agrupados.putIfAbsent(categoria, () => []);
          agrupados[categoria]!.add(nombre);
        });

        setState(() {
          sintomasPorCategoria = agrupados;
          cargando = false;
        });
      } else {
        throw Exception("Error HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error cargando síntomas: $e");
      setState(() => cargando = false);
    }
  }

  /// 🔹 Muestra advertencia médica antes de ir al diagnóstico
  void _mostrarAdvertencia() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text("Aviso Médico"),
          ],
        ),
        content: const Text(
          "Los resultados son orientativos y no reemplazan una evaluación médica profesional.\n\n"
          "Si los síntomas persisten o empeoran, acude a consulta con un especialista.",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D73),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiagnosticoAlternativaPage(
                    sintomas: sintomasSeleccionados.toList(),
                    duracionDias: duracionDias.toInt(), // ✅ enviar duración
                  ),
                ),
              );
            },
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Síntomas Disponibles",
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A5A5)))
          : sintomasPorCategoria.isEmpty
              ? const Center(
                  child: Text(
                    "No se encontraron síntomas disponibles.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  children: [
                    // 🔹 Selector de duración
                    Card(
                      color: const Color(0xFFE6F9FA),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Duración de los síntomas (en días):",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Slider(
                              min: 1,
                              max: 14,
                              divisions: 13,
                              value: duracionDias,
                              activeColor: const Color(0xFF00A5A5),
                              label: "${duracionDias.toInt()} días",
                              onChanged: (val) {
                                setState(() => duracionDias = val);
                              },
                            ),
                            Text("Seleccionado: ${duracionDias.toInt()} día(s)",
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Cards de categorías
                    ...sintomasPorCategoria.entries.map((entry) {
                      return Card(
                        color: Colors.white,
                        elevation: 3,
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
                          children: entry.value.map((sintoma) {
                            final seleccionado = sintomasSeleccionados.contains(sintoma);
                            return CheckboxListTile(
                              title: Text(
                                sintoma,
                                style: const TextStyle(color: Colors.black87),
                              ),
                              activeColor: const Color(0xFF006D73),
                              value: seleccionado,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    sintomasSeleccionados.add(sintoma);
                                  } else {
                                    sintomasSeleccionados.remove(sintoma);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }),

                    // 🔹 Botón de acción
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text(
                          "Consultar diagnóstico",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006D73),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: sintomasSeleccionados.isEmpty
                            ? null
                            : () => _mostrarAdvertencia(),
                      ),
                    ),
                  ],
                ),
    );
  }
}
