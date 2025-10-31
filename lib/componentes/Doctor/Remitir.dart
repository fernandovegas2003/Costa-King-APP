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
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    fontFamily: _fontFamily,
  );
}

class RemitirPage extends StatefulWidget {
  final int idPaciente;
  final int idRegistroConsulta;
  final String nombrePaciente;

  const RemitirPage({
    super.key,
    required this.idPaciente,
    required this.idRegistroConsulta,
    required this.nombrePaciente,
  });

  @override
  State<RemitirPage> createState() => _RemitirPageState();
}

class _RemitirPageState extends State<RemitirPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  DateTime _fechaVencimiento = DateTime.now().add(const Duration(days: 30));
  bool _cargando = true;
  bool _guardando = false;

  Map<String, dynamic> _pacienteUI = {};

  @override
  void initState() {
    super.initState();
    _cargarDatosPaciente();
  }

  @override
  void dispose() {
    _diagnosticoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  String _calcularEdad(String? fechaNacimiento) {
    if (fechaNacimiento == null || fechaNacimiento.isEmpty) return 'N/A';
    try {
      final fn = DateTime.parse(fechaNacimiento);
      final hoy = DateTime.now();
      int edad = hoy.year - fn.year;
      if (hoy.month < fn.month || (hoy.month == fn.month && hoy.day < fn.day)) {
        edad--;
      }
      return '$edad';
    } catch (_) {
      return 'N/A';
    }
  }

  String _soloCiudad(String? direccion) {
    if (direccion == null || direccion.trim().isEmpty) return 'N/A';
    final partes = direccion.split(',');
    return partes.isNotEmpty ? partes.last.trim() : direccion.trim();
  }

  Future<void> _cargarDatosPaciente() async {
    setState(() => _cargando = true);
    try {
      final url = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/historial-completo/${widget.idPaciente}",
      );

      final resp = await http.get(url);
      if (!mounted) return;

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final data = (decoded is Map && decoded['data'] is Map)
            ? Map<String, dynamic>.from(decoded['data'])
            : <String, dynamic>{};

        final rawPaciente = (data['paciente'] is Map)
            ? Map<String, dynamic>.from(data['paciente'])
            : (data['usuario'] is Map)
            ? Map<String, dynamic>.from(data['usuario'])
            : <String, dynamic>{};

        final nombre =
            rawPaciente['nombreUsuario'] ?? rawPaciente['nombre'] ?? '';
        final apellido =
            rawPaciente['apellidoUsuario'] ?? rawPaciente['apellido'] ?? '';
        final numeroDocumento =
            rawPaciente['numeroDocumento'] ?? rawPaciente['documento'] ?? '';
        final telefono =
            rawPaciente['telefonoUsuario'] ?? rawPaciente['telefono'] ?? '';
        final direccion =
            rawPaciente['direccionUsuario'] ?? rawPaciente['direccion'] ?? '';
        final genero = (rawPaciente['genero'] ?? '').toString();
        final fechaNac = rawPaciente['fechaNacimiento']?.toString();

        setState(() {
          _pacienteUI = {
            'nombreCompleto': ('$nombre $apellido').trim(),
            'documento': numeroDocumento,
            'edad': _calcularEdad(fechaNac),
            'genero': genero.isEmpty ? 'N/A' : genero,
            'telefono': telefono.isEmpty ? 'N/A' : telefono,
            'direccion': direccion.isEmpty ? 'N/A' : direccion,
            'ciudad': _soloCiudad(direccion),
            'idHistoriaClinica': data['idHistoriaClinica']?.toString() ?? '',
            'tipoSangre': data['tipoSangre']?.toString() ?? 'N/A',
            'fechaCreacion': data['fechaCreacion']?.toString() ?? '',
          };
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
        _showSnack('Error al cargar datos: ${resp.statusCode}', isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _showSnack('Error: $e', isError: true);
      }
    }
  }

  Future<void> _guardarOrdenMedica() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final body = {
        "idRegistroConsulta": widget.idRegistroConsulta,
        "tipoOrden": "Examen",
        "descripcion": _diagnosticoController.text.trim(),
        "fechaVencimiento": _fechaVencimiento.toString().split(' ').first,
        "observaciones": _observacionesController.text.trim(),
      };

      final resp = await http.post(
        Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/ordenes-medicas",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return;
      setState(() => _guardando = false);

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        _showSnack('Remisión guardada con exito');
        Navigator.pop(context, true);
      } else {
        String msg = 'Error desconocido';
        try {
          final e = jsonDecode(resp.body);
          msg = (e is Map && e['message'] != null)
              ? e['message'].toString()
              : msg;
        } catch (_) {}
        _showSnack('Error: $msg', isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        _showSnack('Error al guardar remision: $e', isError: true);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red[700]
            : AppColors.keppel,
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.keppel,
              onPrimary: AppColors.white,
              onSurface: AppColors.paynesGray,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.keppel,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (fecha != null) {
      setState(() => _fechaVencimiento = fecha);
    }
  }

  InputDecoration _formFieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.paynesGray.withAlpha(179),
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.paynesGray, size: 20)
          : null,
      filled: true,
      fillColor: AppColors.white.withAlpha(204),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: AppColors.keppel.withAlpha(128),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: AppColors.keppel.withAlpha(128),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.keppel,
          width: 2,
        ),
      ),
      errorStyle: TextStyle(
        color: Colors.red[700],
        fontWeight: FontWeight.bold,
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Remitir",
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
        child: _cargando
            ? Center(
                child: CircularProgressIndicator(color: AppColors.aquamarine),
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.keppel,
                          AppColors.paynesGray,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.nombrePaciente.toUpperCase(),
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.white,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.white),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Perfil del Paciente:",
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 6),
                          _buildInfoRow(
                            "Documento:",
                            "CC ${_pacienteUI['documento'] ?? ''}",
                          ),
                          _buildInfoRow(
                            "Edad:",
                            "${_pacienteUI['edad'] ?? 'N/A'} años",
                          ),
                          _buildInfoRow(
                            "Género:",
                            _pacienteUI['genero'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            "Teléfono:",
                            _pacienteUI['telefono'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            "Ciudad:",
                            _pacienteUI['ciudad'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            "Historia No:",
                            _pacienteUI['idHistoriaClinica'],
                          ),
                          _buildInfoRow(
                            "Tipo Sangre:",
                            _pacienteUI['tipoSangre'],
                          ),

                          Divider(
                            color: AppColors.keppel.withOpacity(0.5),
                            height: 24,
                            thickness: 1,
                          ),

                          Text(
                            "Remisión / Orden:",
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _diagnosticoController,
                            style: AppTextStyles.body,
                            maxLines: 3,
                            decoration: _formFieldDecoration(
                              "Descripción (diagnóstico / motivo)",
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? "Requerido" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _observacionesController,
                            style: AppTextStyles.body,
                            maxLines: 2,
                            decoration: _formFieldDecoration(
                              "Observaciones (opcional)",
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: TextEditingController(
                              text: DateFormat(
                                'dd/MM/yyyy',
                              ).format(_fechaVencimiento),
                            ),
                            readOnly: true,
                            style: AppTextStyles.body,
                            decoration:
                                _formFieldDecoration(
                                  "Fecha de Vencimiento",
                                ).copyWith(
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.paynesGray,
                                    size: 20,
                                  ),
                                ),
                            onTap: _seleccionarFecha,
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _guardando
                                  ? null
                                  : _guardarOrdenMedica,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.aquamarine,
                                foregroundColor:
                                    AppColors.paynesGray,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    30,
                                  ),
                                ),
                              ),
                              child: _guardando
                                  ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.paynesGray,
                                          strokeWidth: 3,
                                        ),
                                      )
                                  : Text(
                                        "Guardar",
                                        style: AppTextStyles.button,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.paynesGray.withAlpha(204),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}