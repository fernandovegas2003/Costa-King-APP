import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

class DiagnosticoSintomaPage extends StatefulWidget {
  final String sintoma;
  const DiagnosticoSintomaPage({super.key, required this.sintoma});

  @override
  State<DiagnosticoSintomaPage> createState() => _DiagnosticoSintomaPageState();
}

class _DiagnosticoSintomaPageState extends State<DiagnosticoSintomaPage> {
  Map<String, dynamic>? resultado;
  bool cargando = true;
  int _selectedIndex = 1;

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
      setState(() => cargando = false);
    }
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
                              "Diagnóstico Médico",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Síntoma: ${widget.sintoma}",
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
                      "Consulta Farmacéutica",
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
                      "Analizando diagnóstico...",
                      style: TextStyle(
                        color: Color(0xFF006D73),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 🔹 Tarjeta de advertencias
                    _buildAdvertenciasCard(),

                    const SizedBox(height: 16),

                    // 🔹 Tarjeta de emergencia
                    if (resultado!['emergencia'] != null)
                      _buildEmergenciaCard(),

                    const SizedBox(height: 16),

                    // 🔹 Tarjeta de enfermedades posibles
                    _buildEnfermedadesCard(),

                    const SizedBox(height: 20),

                    // 🔹 Título de medicamentos
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.medication,
                            color: Color(0xFF006D73),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Medicamentos Recomendados",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006D73),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Lista de medicamentos
                    ...((resultado!['medicamentos_recomendados'] as List).map((m) {
                      return _buildMedicamentoCard(m);
                    })),
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

  Widget _buildAdvertenciasCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEF3C7)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[800],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Advertencias Importantes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(resultado!['advertencias'] as List).map<Widget>((a) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: Colors.orange[800],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      a,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmergenciaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red[50]!,
            Colors.orange[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              resultado!['emergencia'],
              style: TextStyle(
                color: Colors.red[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnfermedadesCard() {
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
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: Color(0xFF006D73),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Enfermedades Posibles",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006D73),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ((resultado!['enfermedades_posibles'] as List).map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF006D73).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF006D73).withOpacity(0.3)),
                ),
                child: Text(
                  e,
                  style: TextStyle(
                    color: Color(0xFF006D73),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            })).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentoCard(Map<String, dynamic> medicamento) {
    final pos = medicamento['posologia'];
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
            Icons.medication_liquid,
            color: Color(0xFF006D73),
            size: 20,
          ),
        ),
        title: Text(
          medicamento['nombre'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF006D73),
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          medicamento['descripcion'],
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow("💊 Dosis", pos['dosis']),
                _buildInfoRow("📅 Frecuencia", pos['frecuencia']),
                _buildInfoRow("⏱️ Duración", pos['duracion']),
                _buildInfoRow("🔄 Vía de administración", pos['via_administracion']),
                if (pos['dosis_maxima_diaria'] != null)
                  _buildInfoRow("⚠️ Dosis máxima diaria", pos['dosis_maxima_diaria']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Color(0xFF006D73),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}