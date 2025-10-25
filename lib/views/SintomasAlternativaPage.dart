import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';
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
  double duracionDias = 1;
  int _selectedIndex = 1;

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
                    duracionDias: duracionDias.toInt(),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFE),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Navbar
            const CustomNavbar(),

            // 🔹 Header con estilo farmacia
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF006D73),
                    const Color(0xFF00A5A5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Medicina Alternativa",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Selecciona tus síntomas para diagnóstico natural",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Diagnóstico con Remedios Naturales",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Contenido principal
            Expanded(
              child: cargando
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006D73)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Cargando síntomas disponibles...",
                      style: TextStyle(
                        color: Color(0xFF006D73),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  : sintomasPorCategoria.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No se encontraron síntomas disponibles.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 🔹 Selector de duración
                    _buildDuracionCard(),

                    const SizedBox(height: 20),

                    // 🔹 Contador de síntomas seleccionados
                    _buildContadorSintomas(),

                    const SizedBox(height: 16),

                    // 🔹 Lista de categorías de síntomas
                    ...sintomasPorCategoria.entries.map((entry) {
                      return _buildCategoriaCard(entry.key, entry.value);
                    }),

                    const SizedBox(height: 20),

                    // 🔹 Botón de acción
                    _buildBotonDiagnostico(),
                  ],
                ),
              ),
            ),

            // 🔹 Footer
            CustomFooterNav(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuracionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF006D73), size: 24),
              const SizedBox(width: 12),
              Text(
                "Duración de los Síntomas",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006D73),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            min: 1,
            max: 14,
            divisions: 13,
            value: duracionDias,
            activeColor: const Color(0xFF00A5A5),
            inactiveColor: Colors.grey[300],
            label: "${duracionDias.toInt()} días",
            onChanged: (val) {
              setState(() => duracionDias = val);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "1 día",
                style: TextStyle(color: Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF006D73),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${duracionDias.toInt()} días seleccionados",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                "14 días",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContadorSintomas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sintomasSeleccionados.isEmpty ? Colors.grey[100] : Color(0xFFE6F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sintomasSeleccionados.isEmpty ? Colors.grey[300]! : Color(0xFF00A5A5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Síntomas seleccionados",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: sintomasSeleccionados.isEmpty ? Colors.grey : Color(0xFF006D73),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: sintomasSeleccionados.isEmpty ? Colors.grey : Color(0xFF006D73),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${sintomasSeleccionados.length}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaCard(String categoria, List<String> sintomas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF006D73).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medical_services,
            color: Color(0xFF006D73),
            size: 20,
          ),
        ),
        title: Text(
          categoria.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF006D73),
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          "${sintomas.length} síntomas disponibles",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        children: sintomas.map((sintoma) {
          final seleccionado = sintomasSeleccionados.contains(sintoma);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: seleccionado ? Color(0xFFE6F9FA) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CheckboxListTile(
              title: Text(
                sintoma,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              activeColor: const Color(0xFF006D73),
              checkColor: Colors.white,
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
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBotonDiagnostico() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.search,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          sintomasSeleccionados.isEmpty
              ? "Selecciona al menos un síntoma"
              : "Consultar Diagnóstico Natural (${sintomasSeleccionados.length})",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: sintomasSeleccionados.isEmpty
              ? Colors.grey
              : const Color(0xFF006D73),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 3,
        ),
        onPressed: sintomasSeleccionados.isEmpty
            ? null
            : () => _mostrarAdvertencia(),
      ),
    );
  }
}