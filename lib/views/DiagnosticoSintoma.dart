import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily =
      'TuFuenteApp';

  static const TextStyle headline = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 13,
    fontFamily: _fontFamily,
  );
}

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
      backgroundColor: AppColors.celeste,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomNavbar(),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.keppel,
                      AppColors.paynesGray,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
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
                            color: AppColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            color: AppColors.white,
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
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Síntoma: ${widget.sintoma}",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Consulta Farmacéutica",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: cargando
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.aquamarine,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Analizando diagnóstico...",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : resultado ==
                          null
                    ? Center(
                        child: Text(
                          "Error al cargar el diagnóstico.",
                          style: AppTextStyles.body.copyWith(
                            color: Colors.red[700],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildAdvertenciasCard(),
                            const SizedBox(height: 16),

                            if (resultado!['emergencia'] != null)
                              _buildEmergenciaCard(),
                            const SizedBox(height: 16),

                            _buildEnfermedadesCard(),
                            const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(
                                  0.7,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.white,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.medication,
                                    color: AppColors.keppel,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Medicamentos Recomendados",
                                    style: AppTextStyles.cardTitle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            ...((resultado!['medicamentos_recomendados']
                                    as List)
                                .map((m) {
                                  return _buildMedicamentoCard(m);
                                })),
                          ],
                        ),
                      ),
              ),

              CustomFooterNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),
            ],
          ),
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
                  Icon(Icons.circle, size: 6, color: Colors.orange[800]),
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
          colors: [Colors.red[50]!, Colors.orange[50]!],
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
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 24),
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
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: AppColors.keppel,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Enfermedades Posibles",
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ((resultado!['enfermedades_posibles'] as List).map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.keppel.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.keppel.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  e,
                  style: TextStyle(
                    color: AppColors.keppel,
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
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white),
      ),
      child: ExpansionTile(
        iconColor: AppColors.keppel,
        collapsedIconColor: AppColors.keppel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.keppel.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medication_liquid,
            color: AppColors.keppel,
            size: 20,
          ),
        ),
        title: Text(
          medicamento['nombre'],
          style: AppTextStyles.headline.copyWith(fontSize: 16),
        ),
        subtitle: Text(
          medicamento['descripcion'],
          style: AppTextStyles.cardDescription.copyWith(
            color: AppColors.paynesGray.withOpacity(0.7),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.iceBlue.withOpacity(0.3),
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
                _buildInfoRow(
                  "🔄 Vía de administración",
                  pos['via_administracion'],
                ),
                if (pos['dosis_maxima_diaria'] != null)
                  _buildInfoRow(
                    "⚠️ Dosis máxima diaria",
                    pos['dosis_maxima_diaria'],
                  ),
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
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.paynesGray.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.paynesGray,
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