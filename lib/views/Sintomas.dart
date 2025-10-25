import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';
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
  int _selectedIndex = 1; // 🔹 Para controlar el footer

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
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FEFE),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Navbar arriba
            const CustomNavbar(),

            // 🔹 Título de la página
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Selección de Síntomas",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006D73),
                ),
              ),
            ),

            // 🔹 Contenido principal
            Expanded(
              child: cargando
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF006D73)),
                    SizedBox(height: 16),
                    Text(
                      "Cargando síntomas...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : Column(
                children: [
                  // 🔹 Mensaje de selección
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      color: Colors.blue[50],
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Selecciona un síntoma para obtener un diagnóstico",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Lista de síntomas
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      children: [
                        // 🔹 Cada categoría en una Card blanca
                        ...sintomas!.entries.map((entry) {
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: Icon(
                                Icons.medical_services,
                                color: Color(0xFF006D73),
                              ),
                              title: Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 21, 20, 21),
                                ),
                              ),
                              children: entry.value.map<Widget>((s) {
                                return RadioListTile<String>(
                                  title: Text(
                                    s,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  value: s,
                                  groupValue: sintomaSeleccionado,
                                  onChanged: (val) {
                                    setState(() => sintomaSeleccionado = val);
                                  },
                                  activeColor: Color(0xFF006D73),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 20),

                        // 🔹 Botón al final
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sintomaSeleccionado == null
                                  ? Colors.grey
                                  : const Color(0xFF006D73),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 3,
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
                            child: Text(
                              sintomaSeleccionado == null
                                  ? "Selecciona un síntoma"
                                  : "Consultar diagnóstico para: ${sintomaSeleccionado!}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Footer abajo
            CustomFooterNav(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
                // La navegación ya está manejada en el CustomFooterNav
              },
            ),
          ],
        ),
      ),
    );
  }
}