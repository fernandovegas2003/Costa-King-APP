import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily = 'TuFuenteApp'; 

  static const TextStyle headline = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 15,
    height: 1.4,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}


class DetalleHistoriaClinicaScreen extends StatefulWidget {
  final int idHistoriaClinica;

  const DetalleHistoriaClinicaScreen({
    Key? key,
    required this.idHistoriaClinica,
  }) : super(key: key);

  @override
  State<DetalleHistoriaClinicaScreen> createState() =>
      _DetalleHistoriaClinicaScreenState();
}

class _DetalleHistoriaClinicaScreenState
    extends State<DetalleHistoriaClinicaScreen> {
  Map<String, dynamic>? historia;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    final url =
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/${widget.idHistoriaClinica}";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body); 
      if (mounted) {
        setState(() {
          historia = data["data"];
          _loading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al obtener la historia clínica."), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.paynesGray), 
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detalle Historia Clínica",
          style: AppTextStyles.headline.copyWith(fontSize: 20), 
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: AppColors.aquamarine)) 
              : historia == null
                  ? Center(child: Text("No se encontraron datos.", style: AppTextStyles.body)) 
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20, 
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: AppColors.white.withAlpha(179), 
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.white), 
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.paynesGray.withAlpha(26), 
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "Historia #${historia!["idHistoriaClinica"]}",
                                style: AppTextStyles.headline.copyWith(color: AppColors.keppel), 
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildInfoRow(
                              "Nombre del Paciente",
                              "${historia!["nombreUsuario"] ?? ''} ${historia!["apellidoUsuario"] ?? ''}",
                            ),
                            _buildInfoRow(
                              "Documento",
                              historia!["numeroDocumento"] ?? "N/A",
                            ),
                            Divider(color: AppColors.keppel.withAlpha(128), height: 30, thickness: 1), 
                            _buildInfoRow(
                              "Tipo de Sangre",
                              historia!["tipoSangre"],
                            ),
                            _buildInfoRow(
                              "Alergias",
                              historia!["alergias"] ?? "N/A",
                            ),
                            _buildInfoRow(
                              "Enfermedades Crónicas",
                              historia!["enfermedadesCronicas"] ?? "N/A",
                            ),
                            _buildInfoRow(
                              "Medicamentos",
                              historia!["medicamentos"],
                            ),
                            _buildInfoRow(
                              "Antecedentes Familiares",
                              historia!["antecedentesFamiliares"],
                            ),
                            _buildInfoRow(
                              "Observaciones",
                              historia!["observaciones"],
                            ),
                            Divider(color: AppColors.keppel.withAlpha(128), height: 30, thickness: 1), 
                            _buildInfoRow(
                              "Actividad Física",
                              historia!["actividadFisica"],
                            ),
                            _buildInfoRow(
                              "Alimentación Diaria",
                              historia!["alimentacionDiaria"],
                            ),
                            _buildInfoRow("Sueño", historia!["suenio"] ?? "N/A"),
                            _buildInfoRow(
                              "Alcohol",
                              historia!["alcohol"] ?? "N/A",
                            ),
                            _buildInfoRow(
                              "Sustancias Psicoactivas",
                              historia!["sustanciasPsicoactivas"],
                            ),
                            Divider(color: AppColors.keppel.withAlpha(128), height: 30, thickness: 1), 
                            _buildInfoRow(
                              "Diagnósticos Principales",
                              historia!["diagnosticosPrincipales"],
                            ),
                            _buildInfoRow(
                              "Plan de Manejo",
                              historia!["planManejo"],
                            ),
                            _buildInfoRow(
                              "Conducta o Tratamiento",
                              historia!["conductaTratamiento"],
                            ),
                            _buildInfoRow(
                              "Remisiones",
                              historia!["remisiones"] ?? "N/A",
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                "Creada el ${historia!["fechaCreacion"].toString().split('T')[0]}",
                                style: AppTextStyles.body.copyWith( 
                                  color: AppColors.paynesGray.withAlpha(179), 
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.aquamarine, 
                                  foregroundColor: AppColors.paynesGray, 
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30), 
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Volver",
                                  style: AppTextStyles.button.copyWith(fontSize: 16), 
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String titulo, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$titulo:",
              style: AppTextStyles.body.copyWith( 
                fontWeight: FontWeight.bold,
                color: AppColors.paynesGray.withAlpha(204) 
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              valor?.toString() == "null" || valor == null
                  ? "No registrado"
                  : valor.toString(),
              style: AppTextStyles.body, 
            ),
          ),
        ],
      ),
    );
  }
}