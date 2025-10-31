import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'Archivos.dart';

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
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonPrimary = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonSecondary = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class AtenderPacientePage extends StatefulWidget {
  final Map<String, dynamic> cita;
  final String nombrePaciente;

  const AtenderPacientePage({
    Key? key,
    required this.cita,
    required this.nombrePaciente,
  }) : super(key: key);

  @override
  State<AtenderPacientePage> createState() => _AtenderPacientePageState();
}

class _AtenderPacientePageState extends State<AtenderPacientePage> {
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _sintomasController = TextEditingController();
  final TextEditingController _presionArterialController =
      TextEditingController();
  final TextEditingController _frecuenciaCardiacaController =
      TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  bool _guardando = false;
  int? _idRegistroConsulta;
  final DateTime _fechaConsulta = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateFormat('dd/MM/yy HH:mm').format(_fechaConsulta);
    _cargarRegistroExistente();
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _motivoController.dispose();
    _sintomasController.dispose();
    _presionArterialController.dispose();
    _frecuenciaCardiacaController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  Future<void> _cargarRegistroExistente() async {
    try {
      final idCita = widget.cita['idCita'];
      final res = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/registros-consultas/cita/$idCita",
        ),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["data"] != null && data["data"].isNotEmpty) {
          final r = data["data"][0];
          setState(() {
            _idRegistroConsulta = r['idRegistroConsulta'];
            _motivoController.text = r['motivoConsulta'] ?? '';
            _sintomasController.text = r['sintomas'] ?? '';
            _presionArterialController.text = r['presionArterial'] ?? '';
            _frecuenciaCardiacaController.text = r['frecuenciaCardiaca'] ?? '';
            _pesoController.text = r['peso']?.toString() ?? '';
            _alturaController.text = r['altura']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      _showSnack("Error al cargar registro: $e", isError: true);
    }
  }

  Future<void> _guardarRegistro() async {
    setState(() => _guardando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? idMedicoParsed = prefs.getInt("idDoctor");

      if (idMedicoParsed == null || idMedicoParsed <= 0) {
        setState(() => _guardando = false);
        _showSnack(
          "No se encontró un médico válido. Inicie sesión nuevamente.",
          isError: true,
        );
        return;
      }

      if (_motivoController.text.trim().isEmpty) {
        setState(() => _guardando = false);
        _showSnack("Debe ingresar un motivo de consulta.", isError: true);
        return;
      }

      final double? peso = double.tryParse(_pesoController.text.trim());
      final double? altura = double.tryParse(_alturaController.text.trim());

      final body = {
        "idHistoriaClinica": 21,
        "idMedico": idMedicoParsed,
        "idCita": widget.cita['idCita'],
        "fechaConsulta": DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(_fechaConsulta),
        "motivoConsulta": _motivoController.text.trim(),
        "sintomas": _sintomasController.text.trim(),
        "presionArterial": _presionArterialController.text.trim(),
        "frecuenciaCardiaca": _frecuenciaCardiacaController.text.trim(),
        "peso": peso,
        "altura": altura,
      };

      debugPrint("Enviando body: ${jsonEncode(body)}");

      final uri = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/registros-consultas",
      );

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return;
      setState(() => _guardando = false);

      if (res.statusCode == 201 || res.statusCode == 200) {
        _showSnack("Registro de cita creado correctamente ✅");
        Navigator.pop(context, true);
      } else {
        debugPrint("Error en el guardado:");
        debugPrint("Status code: ${res.statusCode}");
        debugPrint("Respuesta del servidor: ${res.body}");
        String mensajeError;
        try {
          final data = jsonDecode(res.body);
          mensajeError =
              data['message'] ?? data['mensaje'] ?? data['error'] ?? res.body;
        } catch (_) {
          mensajeError = res.body;
        }
        _showSnack("Error del servidor: $mensajeError", isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        _showSnack("Error al guardar registro: $e", isError: true);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : AppColors.keppel,
      ),
    );
  }

  Widget _buildFrostTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.body,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body.copyWith(
            color: AppColors.paynesGray.withOpacity(0.7),
          ),
          prefixIcon: Icon(icon, color: AppColors.paynesGray, size: 20),
          filled: true,
          fillColor: AppColors.white.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.keppel, width: 2),
          ),
          errorStyle: TextStyle(
            color: Colors.red[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
          "Registro de Consulta",
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.keppel, AppColors.paynesGray],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Text(
                  widget.nombrePaciente.toUpperCase(),
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.white,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Datos de la Consulta",
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 20),

                      _buildFrostTextField(
                        label: "Fecha de consulta",
                        controller: _fechaController,
                        readOnly: true,
                        icon: Icons.calendar_today_outlined,
                      ),
                      _buildFrostTextField(
                        label: "Motivo de consulta",
                        controller: _motivoController,
                        maxLines: 2,
                        icon: Icons.notes_outlined,
                      ),
                      _buildFrostTextField(
                        label: "Síntomas",
                        controller: _sintomasController,
                        maxLines: 3,
                        icon: Icons.medical_information_outlined,
                      ),
                      _buildFrostTextField(
                        label: "Presión arterial",
                        controller: _presionArterialController,
                        icon: Icons.monitor_heart_outlined,
                      ),
                      _buildFrostTextField(
                        label: "Frecuencia cardíaca",
                        controller: _frecuenciaCardiacaController,
                        icon: Icons.favorite_border,
                      ),
                      _buildFrostTextField(
                        label: "Peso (kg)",
                        controller: _pesoController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        icon: Icons.monitor_weight_outlined,
                      ),
                      _buildFrostTextField(
                        label: "Altura (m)",
                        controller: _alturaController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        icon: Icons.height_outlined,
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArchivosPage(
                                  cita: widget.cita,
                                  nombrePaciente: widget.nombrePaciente,
                                  idRegistroConsulta: _idRegistroConsulta,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.keppel,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          icon: Icon(Icons.attach_file_outlined),
                          label: Text(
                            "Ver Archivos Adjuntos",
                            style: AppTextStyles.buttonSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.aquamarine,
                            foregroundColor: AppColors.paynesGray,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _guardando
                              ? const CircularProgressIndicator(
                                  color: AppColors.paynesGray,
                                )
                              : Text(
                                  "Guardar Registro",
                                  style: AppTextStyles.buttonPrimary,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
