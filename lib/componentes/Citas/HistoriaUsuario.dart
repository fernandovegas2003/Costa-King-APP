import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      setState(() {
        historia = data["data"];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al obtener la historia clínica."),
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
          "Detalle Historia Clínica",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fondo decorativo
          Positioned.fill(
            child: Image.asset("assets/images/Fondo.png", fit: BoxFit.cover),
          ),

          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : historia == null
                ? const Center(child: Text("No se encontraron datos."))
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 40),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Historia #${historia!["idHistoriaClinica"]}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow("Nombre del Paciente",
                        "${historia!["nombreUsuario"] ?? ''} ${historia!["apellidoUsuario"] ?? ''}"),
                    _buildInfoRow("Documento",
                        historia!["numeroDocumento"] ?? "N/A"),
                    const Divider(height: 30, thickness: 1.2),
                    _buildInfoRow(
                        "Tipo de Sangre", historia!["tipoSangre"]),
                    _buildInfoRow(
                        "Alergias", historia!["alergias"] ?? "N/A"),
                    _buildInfoRow("Enfermedades Crónicas",
                        historia!["enfermedadesCronicas"] ?? "N/A"),
                    _buildInfoRow(
                        "Medicamentos", historia!["medicamentos"]),
                    _buildInfoRow("Antecedentes Familiares",
                        historia!["antecedentesFamiliares"]),
                    _buildInfoRow(
                        "Observaciones", historia!["observaciones"]),
                    const Divider(height: 30, thickness: 1.2),
                    _buildInfoRow("Actividad Física",
                        historia!["actividadFisica"]),
                    _buildInfoRow("Alimentación Diaria",
                        historia!["alimentacionDiaria"]),
                    _buildInfoRow(
                        "Sueño", historia!["suenio"] ?? "N/A"),
                    _buildInfoRow(
                        "Alcohol", historia!["alcohol"] ?? "N/A"),
                    _buildInfoRow("Sustancias Psicoactivas",
                        historia!["sustanciasPsicoactivas"]),
                    const Divider(height: 30, thickness: 1.2),
                    _buildInfoRow("Diagnósticos Principales",
                        historia!["diagnosticosPrincipales"]),
                    _buildInfoRow("Plan de Manejo",
                        historia!["planManejo"]),
                    _buildInfoRow("Conducta o Tratamiento",
                        historia!["conductaTratamiento"]),
                    _buildInfoRow("Remisiones",
                        historia!["remisiones"] ?? "N/A"),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Creada el ${historia!["fechaCreacion"].toString().split('T')[0]}",
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Volver",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              valor?.toString() == "null" || valor == null
                  ? "No registrado"
                  : valor.toString(),
              style: const TextStyle(
                color: Colors.black87,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
