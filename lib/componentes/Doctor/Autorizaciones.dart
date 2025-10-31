import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    height: 1.4,
    fontFamily: _fontFamily,
  );
}

class VerAutorizacionesPage extends StatefulWidget {
  const VerAutorizacionesPage({Key? key}) : super(key: key);

  @override
  State<VerAutorizacionesPage> createState() => _VerAutorizacionesPageState();
}

class _VerAutorizacionesPageState extends State<VerAutorizacionesPage> {
  List<dynamic> ordenes = [];
  bool cargando = true;
  int? idPaciente;
  int? idDoctor;

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    final prefs = await SharedPreferences.getInstance();
    idPaciente = prefs.getInt('idPacienteSeleccionado');
    idDoctor = prefs.getInt('idDoctor');

    if (idPaciente == null) {
      _showSnack("No se encontró el ID del paciente", isError: true);
      setState(() => cargando = false);
      return;
    }

    try {
      final url = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/ordenes-medicas/paciente/$idPaciente",
      );
      final respuesta = await http.get(url);

      if (!mounted) return;
      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        setState(() {
          ordenes = (data["data"] ?? [])
              .where(
                (o) =>
                    o["estadoOrden"] == null ||
                    o["estadoOrden"].toString().toLowerCase() != "aprobada",
              )
              .toList();
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
        _showSnack("Error al cargar órdenes: ${respuesta.body}", isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => cargando = false);
        _showSnack("Error de conexión: $e", isError: true);
      }
    }
  }

  Future<void> _aprobarAutorizacion(int idOrden) async {
    if (idDoctor == null) {
      _showSnack("No se encontró el ID del doctor", isError: true);
      return;
    }

    try {
      final url = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/autorizaciones",
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idOrdenMedica": idOrden,
          "idAutorizador": idDoctor,
          "estadoAutorizacion": "Aprobada",
          "observaciones": "Autorización aprobada por el doctor",
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack("Autorización aprobada con éxito ✅");
        setState(() {
          ordenes.removeWhere((o) => o["idOrdenMedica"] == idOrden);
        });
      } else {
        _showSnack("Error al aprobar: ${response.body}", isError: true);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : AppColors.keppel,
      ),
    );
  }

  void mostrarDetallesOrden(Map<String, dynamic> orden) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Detalles de la Orden",
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("🆔 ID Orden:", "${orden['idOrdenMedica']}"),
            _buildInfoRow("🩺 Tipo:", "${orden['tipoOrden']}"),
            _buildInfoRow("📄 Descripción:", "${orden['descripcion']}"),
            _buildInfoRow(
              "📅 Emitida:",
              _formatearFecha(orden['fechaEmision']),
            ),
            _buildInfoRow(
              "⏰ Vence:",
              _formatearFecha(orden['fechaVencimiento']),
            ),
            _buildInfoRow(
              "📌 Estado:",
              "${orden['estadoOrden'] ?? 'Pendiente'}",
            ),
            _buildInfoRow(
              "🧑‍⚕️ Médico:",
              "${orden['nombreMedico'] ?? 'Desconocido'}",
            ),
            _buildInfoRow(
              "🏥 Especialidad:",
              "${orden['especialidad'] ?? 'N/A'}",
            ),
            _buildInfoRow(
              "💬 Observaciones:",
              "${orden['observaciones'] ?? 'N/A'}",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cerrar",
              style: TextStyle(color: AppColors.paynesGray),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.paynesGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _aprobarAutorizacion(orden['idOrdenMedica']);
            },
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text(
              "Aprobar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.body.copyWith(fontSize: 14),
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return "No disponible";
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return fecha;
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Autorizaciones Pendientes",
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
          child: cargando
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.aquamarine),
                      SizedBox(height: 16),
                      Text("Cargando órdenes...", style: AppTextStyles.body),
                    ],
                  ),
                )
              : ordenes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: AppColors.paynesGray.withOpacity(0.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No hay órdenes pendientes para este paciente 🩺",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.paynesGray.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordenes.length,
                  itemBuilder: (context, index) {
                    final o = ordenes[index];
                    return Card(
                      color: AppColors.white.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.keppel.withOpacity(
                            0.1,
                          ),
                          child: Icon(
                            Icons.assignment_outlined,
                            color: AppColors.keppel,
                          ),
                        ),
                        title: Text(
                          "${o['tipoOrden'] ?? 'Orden'}: ${o['descripcion'] ?? 'Sin descripción'}",
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "Estado: ${o['estadoOrden'] ?? 'Pendiente'}",
                          style: AppTextStyles.cardDescription.copyWith(
                            color: AppColors.paynesGray.withOpacity(0.8),
                          ),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.aquamarine,
                            foregroundColor: AppColors.paynesGray,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await _aprobarAutorizacion(o['idOrdenMedica']);
                          },
                          child: const Text(
                            "Aprobar",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () => mostrarDetallesOrden(o),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}