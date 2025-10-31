import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'signature_pad.dart';
import 'archivos_local_helper.dart';

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
  
  static const TextStyle bodySubdued = TextStyle( 
    color: AppColors.keppel,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
  );
}


class MedicinaPage extends StatefulWidget {
  final int idHistoriaClinica;
  final String nombreDoctor;

  const MedicinaPage({
    super.key,
    required this.idHistoriaClinica,
    required this.nombreDoctor,
  });

  @override
  State<MedicinaPage> createState() =>
      _MedicinaPageState();
}

class _MedicinaPageState extends State<MedicinaPage> {
  final TextEditingController _medicamentosController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic> _historia = {};
  Map<String, dynamic> _historialCompleto = {};
  final GlobalKey<SignaturePadState> _firmaKey = GlobalKey<SignaturePadState>();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _medicamentosController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getJson(Uri url) async {
    final resp = await http.get(url);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map && decoded['data'] != null) {
        final data = decoded['data'];
        if (data is List) {
          return data.isNotEmpty ? Map<String, dynamic>.from(data.first) : null;
        } else if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      if (decoded is List) {
        return decoded.isNotEmpty
            ? Map<String, dynamic>.from(decoded.first)
            : null;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getHistoriaById(int idHistoria) async {
    final url = Uri.parse(
      'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/$idHistoria',
    );
    return _getJson(url);
  }

  Future<Map<String, dynamic>?> _getHistorialCompletoByPaciente(
    int idPaciente,
  ) async {
    final url = Uri.parse(
      'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/historial-completo/$idPaciente',
    );
    return _getJson(url);
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final historia = await _getHistoriaById(widget.idHistoriaClinica);
      if (!mounted) return;

      if (historia == null) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'No se encontró la historia clínica #${widget.idHistoriaClinica}.';
          _isLoading = false;
        });
        return;
      }

      _historia = historia;
      _medicamentosController.text = (_historia['medicamentos'] ?? '').toString();

      final idPaciente =
          _historia['idPaciente'] ??
          (_historia['paciente'] is Map
              ? _historia['paciente']['idUsuario']
              : null);

      if (idPaciente is int) {
        final hc = await _getHistorialCompletoByPaciente(idPaciente);
        if (hc != null) {
          _historialCompleto = hc;
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error de conexión: $e';
      });
    }
  }

  Future<void> _guardarMedicamentos() async {
    final firmaState = _firmaKey.currentState;
    if (firmaState == null || firmaState.isEmpty) {
      _showSnack('Por favor firma la orden antes de guardar', isError: true);
      return;
    }

    final firmaBytes = await firmaState.toPngBytes();
    if (firmaBytes == null || firmaBytes.isEmpty) {
      _showSnack('No se pudo capturar la firma, intenta nuevamente', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final medicamentosTexto = _medicamentosController.text.trim();

    try {
      final existente = await _getHistoriaById(widget.idHistoriaClinica);
      Map<String, dynamic> body;

      if (existente != null && existente.isNotEmpty) {
        body = {
          if (existente['idPaciente'] != null)
            'idPaciente': existente['idPaciente'],
          'tipoSangre': existente['tipoSangre'],
          'alergias': existente['alergias'],
          'enfermedadesCronicas': existente['enfermedadesCronicas'],
          'medicamentos': medicamentosTexto,
          'antecedentesFamiliares': existente['antecedentesFamiliares'],
          'observaciones': existente['observaciones'],
        };
      } else {
        body = {'medicamentos': medicamentosTexto};
      }

      final resp = await http.put(
        Uri.parse(
          'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/${widget.idHistoriaClinica}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        await _guardarResumenMedicamentos(
          medicamentos: medicamentosTexto,
          firmaPng: firmaBytes.toList(),
        );
        await _mostrarResumenMedicamentos(
          medicamentos: medicamentosTexto,
          firmaBytes: firmaBytes,
        );
        firmaState.clear();
        _historia['medicamentos'] = medicamentosTexto;
        _showSnack('Medicamentos actualizados con exito');
        if (mounted) Navigator.pop(context, true);
      } else {
        String msg = 'Error al guardar (${resp.statusCode})';
        try {
          final err = jsonDecode(resp.body);
          if (err is Map && err['message'] != null) {
            msg = 'Error: ${err['message']}';
          }
        } catch (_) {}
        _showSnack(msg, isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnack('Error al guardar medicamentos: $e', isError: true);
      }
    }
  }

  Future<void> _guardarResumenMedicamentos({
    required String medicamentos,
    required List<int> firmaPng,
  }) async {
    final now = DateTime.now();
    final resumen = _construirResumenMedicamentos(medicamentos, now);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);

    await ArchivosLocalHelper.addBytes(
      idHistoriaClinica: widget.idHistoriaClinica,
      nombre: 'Receta medicamentos $timestamp',
      mimeType: 'text/plain',
      bytes: utf8.encode(resumen),
    );

    if (firmaPng.isNotEmpty) {
      await ArchivosLocalHelper.addBytes(
        idHistoriaClinica: widget.idHistoriaClinica,
        nombre: 'Firma receta $timestamp',
        mimeType: 'image/png',
        bytes: firmaPng,
      );
    }
  }

  String _construirResumenMedicamentos(String medicamentos, DateTime fecha) {
    final paciente =
        (_historialCompleto['paciente'] as Map?) ??
        (_historia['paciente'] as Map?) ??
        {};
    final nombre =
        ('${paciente['nombreUsuario'] ?? paciente['nombre'] ?? ''} '
                '${paciente['apellidoUsuario'] ?? paciente['apellido'] ?? ''}')
            .trim();
    final documento =
        (paciente['numeroDocumento'] ?? paciente['documento'] ?? 'N/A')
            .toString();
    final contenido = medicamentos.isEmpty ? '- Sin especificar' : medicamentos;
    final fechaTexto = DateFormat('yyyy-MM-dd HH:mm').format(fecha);

    final buffer = StringBuffer()
      ..writeln('Receta de medicamentos')
      ..writeln('Doctor: ${widget.nombreDoctor}')
      ..writeln('Paciente: ${nombre.isEmpty ? 'N/A' : nombre}')
      ..writeln('Documento: $documento')
      ..writeln('Medicamentos indicados:')
      ..writeln(contenido)
      ..writeln('Generada: $fechaTexto');

    return buffer.toString();
  }

  String _calcularEdad(String? fechaNacimiento) {
    try {
      if (fechaNacimiento == null || fechaNacimiento.isEmpty) return 'N/A';
      final fn = DateTime.parse(fechaNacimiento);
      final hoy = DateTime.now();
      int edad = hoy.year - fn.year;
      if (hoy.month < fn.month || (hoy.month == fn.month && hoy.day < fn.day)) {
        edad--;
      }
      return edad.toString();
    } catch (_) {
      return 'N/A';
    }
  }

  String _extraerCiudad(String? direccion) {
    if (direccion == null || direccion.isEmpty) return 'N/A';
    try {
      final partes = direccion.split(',');
      return partes.length > 1 ? partes.last.trim() : direccion;
    } catch (_) {
      return direccion;
    }
  }
  
  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red[700] : AppColors.keppel,
    ));
  }

  Future<void> _mostrarResumenMedicamentos({
    required String medicamentos,
    required Uint8List firmaBytes,
  }) async {
    final resumen = _construirResumenMedicamentos(medicamentos, DateTime.now());

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Resumen de la receta', style: AppTextStyles.headline.copyWith(fontSize: 20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(resumen, style: AppTextStyles.body),
              const SizedBox(height: 12),
              Text(
                'Firma',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.keppel),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Image.memory(firmaBytes, height: 150, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.paynesGray,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Medicinas',
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.aquamarine))
            : _hasError
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: AppTextStyles.body.copyWith(color: Colors.red[700]),
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
      final paciente =
        (_historialCompleto['paciente'] as Map?) ??
        (_historia['paciente'] as Map?) ??
        {};
        
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.keppel, AppColors.paynesGray],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.nombreDoctor.toUpperCase(),
            style: AppTextStyles.headline.copyWith(color: AppColors.white, fontSize: 20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perfil del Paciente:',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 8),
              Text(
                '${(paciente['nombreUsuario'] ?? '')} ${(paciente['apellidoUsuario'] ?? '')}'
                    .trim(),
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 16),

              Text(
                'Información Personal:',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Documento:',
                '${paciente['numeroDocumento'] ?? 'N/A'}',
              ),
              _buildInfoRow(
                'Edad:',
                _calcularEdad(paciente['fechaNacimiento']?.toString()),
              ),
              _buildInfoRow('Género:', '${paciente['genero'] ?? 'N/A'}'),
              _buildInfoRow(
                'Teléfono:',
                '${paciente['telefonoUsuario'] ?? 'N/A'}',
              ),
              _buildInfoRow(
                'Ciudad:',
                _extraerCiudad(paciente['direccionUsuario']?.toString()),
              ),
              Divider(color: AppColors.keppel.withOpacity(0.5), height: 24, thickness: 1),

              Text(
                'Medicamentos:',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 8),

              Stack(
                children: [
                  TextField(
                    controller: _medicamentosController,
                    style: AppTextStyles.body,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.keppel.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.keppel, width: 2),
                      ),
                      hintText: 'Ingrese los medicamentos del paciente',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withOpacity(0.5)),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: AppColors.aquamarine,
                      foregroundColor: AppColors.paynesGray,
                      elevation: 2,
                      child: const Icon(Icons.add),
                      onPressed: () {
                        final current = _medicamentosController.text;
                        final newline = current.isEmpty
                            ? '- '
                            : '$current\n- ';
                        _medicamentosController.text = newline;
                        _medicamentosController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                            offset: _medicamentosController.text.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Firma del médico',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.keppel),
                ),
                child: SignaturePad(
                  key: _firmaKey,
                  penColor: AppColors.paynesGray,
                  strokeWidth: 2.0,
                  controller: SignaturePadController(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _firmaKey.currentState?.clear(),
                  icon: Icon(Icons.cleaning_services_outlined, color: AppColors.paynesGray, size: 20),
                  label: Text('Limpiar firma', style: AppTextStyles.body.copyWith(color: AppColors.paynesGray, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarMedicamentos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.aquamarine,
                    foregroundColor: AppColors.paynesGray,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.paynesGray,
                              strokeWidth: 2,
                            ),
                          )
                      : Text(
                            'Guardar',
                            style: AppTextStyles.button.copyWith(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.bodySubdued,
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}