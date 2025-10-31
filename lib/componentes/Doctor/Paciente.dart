import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'Archivos.dart';
import 'HistoriaClinica.dart';
import 'Medicina.dart';
import 'Remitir.dart';

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
    fontSize: 14,
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
    fontFamily: _fontFamily,
  );
}

class Paciente extends StatefulWidget {
  final String documentoId;

  const Paciente({super.key, required this.documentoId});

  @override
  State<Paciente> createState() => _PacienteState();
}

class _PacienteState extends State<Paciente>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String errorMessage = '';

  Map<String, dynamic> datosUsuario = {};
  Map<String, dynamic> historiaClinica = {};

  static const String baseUrl =
      'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api';

  @override
  void initState() {
    super.initState();
    _tabController = _tabController = TabController(length: 4, vsync: this);
    fetchPacienteData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _firstMap(dynamic decoded) {
    if (decoded is Map && decoded['data'] != null) {
      final d = decoded['data'];
      if (d is List) {
        return d.isNotEmpty ? Map<String, dynamic>.from(d.first) : null;
      }
      if (d is Map) {
        return Map<String, dynamic>.from(d);
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
    return null;
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic decoded) {
    if (decoded is Map && decoded['data'] is List) {
      return List<Map<String, dynamic>>.from(
        (decoded['data'] as List).whereType<Map>().map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );
    }
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(
        decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return const [];
  }

  Future<void> fetchPacienteData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final usuarioRes = await http.get(
        Uri.parse('$baseUrl/usuarios/documento/${widget.documentoId}'),
      );
      if (usuarioRes.statusCode != 200) {
        setState(() {
          errorMessage = 'Error al obtener usuario (${usuarioRes.statusCode}).';
          isLoading = false;
        });
        return;
      }
      final usuarioDecoded = json.decode(usuarioRes.body);
      final usuario = _firstMap(usuarioDecoded);
      if (usuario == null) {
        setState(() {
          errorMessage =
              'No se encontró el usuario con documento ${widget.documentoId}.';
          isLoading = false;
        });
        return;
      }
      final int? idPaciente = (usuario['idUsuario'] is int)
          ? usuario['idUsuario'] as int
          : int.tryParse('${usuario['idUsuario']}');

      setState(() {
        datosUsuario = usuario;
      });
      Map<String, dynamic> hcElegida = {};
      if (idPaciente != null) {
        final hcRes = await http.get(
          Uri.parse('$baseUrl/historias-clinicas/paciente/$idPaciente'),
        );
        if (hcRes.statusCode == 200) {
          final decoded = json.decode(hcRes.body);
          final lista = _asListOfMaps(decoded);
          if (lista.isNotEmpty) {
            hcElegida = lista.first;
          } else {
            final hcDocRes = await http.get(
              Uri.parse(
                '$baseUrl/historias-clinicas/documento/${widget.documentoId}',
              ),
            );
            if (hcDocRes.statusCode == 200) {
              final dec2 = json.decode(hcDocRes.body);
              hcElegida = _firstMap(dec2) ?? {};
            }
          }
        } else {
          final hcDocRes = await http.get(
            Uri.parse(
              '$baseUrl/historias-clinicas/documento/${widget.documentoId}',
            ),
          );
          if (hcDocRes.statusCode == 200) {
            final dec2 = json.decode(hcDocRes.body);
            hcElegida = _firstMap(dec2) ?? {};
          }
        }
      }
      setState(() {
        historiaClinica = hcElegida;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  String _nombreCompleto(Map<String, dynamic> u) {
    final n = (u['nombreUsuario'] ?? '').toString();
    final a = (u['apellidoUsuario'] ?? '').toString();
    final full = '$n $a'.trim();
    return full.isEmpty ? 'PACIENTE' : full;
  }

  String _calcEdad(String? fechaNac) {
    if (fechaNac == null || fechaNac.isEmpty) return '';
    try {
      final fn = DateTime.parse(fechaNac);
      final hoy = DateTime.now();
      var edad = hoy.year - fn.year;
      if (hoy.month < fn.month || (hoy.month == fn.month && hoy.day < fn.day)) {
        edad--;
      }
      return '$edad';
    } catch (_) {
      return '';
    }
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }

  int? get _idHistoriaClinica =>
      _parseInt(historiaClinica['idHistoriaClinica']);
  int? get _idPaciente =>
      _parseInt(datosUsuario['idUsuario'] ?? datosUsuario['idPaciente']);
  List<Map<String, dynamic>> get _registrosConsultas {
    final registros = historiaClinica['registrosConsultas'];
    if (registros is List) {
      return registros
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (registros is Map && registros['data'] is List) {
      return (registros['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? get _primerRegistroConsulta =>
      _registrosConsultas.isNotEmpty ? _registrosConsultas.first : null;
  int? get _idRegistroConsulta =>
      _parseInt(_primerRegistroConsulta?['idRegistroConsulta']);
  int? get _idCitaAsociada => _parseInt(_primerRegistroConsulta?['idCita']);

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.keppel),
    );
  }

  Future<String> _obtenerNombreDoctor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nombre =
          prefs.getString('nombreDoctor') ??
          prefs.getString('nombreMedico') ??
          prefs.getString('nombreUsuario') ??
          '';
      final apellido =
          prefs.getString('apellidoDoctor') ??
          prefs.getString('apellidoMedico') ??
          prefs.getString('apellidoUsuario') ??
          '';
      final completo = '$nombre $apellido'.trim();
      return completo.isEmpty ? 'Doctor' : completo;
    } catch (_) {
      return 'Doctor';
    }
  }

  void _abrirHistoriaClinica() {
    final idPaciente = _idPaciente;
    if (idPaciente == null) {
      _showMessage('No se encontró información del paciente.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoriaClinicaPage(idPaciente: idPaciente),
      ),
    );
  }

  void _abrirRemitir() {
    final idPaciente = _idPaciente;
    final idRegistro = _idRegistroConsulta;
    if (idPaciente == null) {
      _showMessage('No se encontro informacion del paciente.');
      return;
    }
    if (idRegistro == null) {
      _showMessage('El paciente no tiene registros disponibles para remitir.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RemitirPage(
          idPaciente: idPaciente,
          idRegistroConsulta: idRegistro,
          nombrePaciente: _nombreCompleto(datosUsuario),
        ),
      ),
    );
  }

  Future<void> _abrirMedicina() async {
    final idHistoria = _idHistoriaClinica;
    if (idHistoria == null) {
      _showMessage('No se encontro una historia clinica asociada.');
      return;
    }
    final nombreDoctor = await _obtenerNombreDoctor();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicinaPage(
          idHistoriaClinica: idHistoria,
          nombreDoctor: nombreDoctor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _nombreCompleto(datosUsuario).toUpperCase();

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
          'Agenda de citas',
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.aquamarine),
              )
            : errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  errorMessage,
                  style: AppTextStyles.body.copyWith(color: Colors.red[700]),
                ),
              )
            : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.keppel, AppColors.paynesGray],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        nombre,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    color: AppColors.white.withOpacity(0.5),
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Datos'),
                        Tab(text: 'Diagnostico'),
                        Tab(text: 'Archivos'),
                        Tab(text: 'Notas'),
                      ],
                      labelColor: AppColors.keppel,
                      unselectedLabelColor: AppColors.paynesGray.withOpacity(
                        0.7,
                      ),
                      indicatorColor: AppColors.keppel,
                      indicatorWeight: 3.0,
                      labelStyle: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDatosTab(),
                        _buildDiagnosticoTab(),
                        _buildArchivosTab(),
                        _buildNotasTab(),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.7),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.paynesGray.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          'Historia',
                          Icons.description_outlined,
                          _abrirHistoriaClinica,
                          AppColors.aquamarine,
                          AppColors.paynesGray,
                        ),
                        _buildActionButton(
                          'Remitir',
                          Icons.send_outlined,
                          _abrirRemitir,
                          AppColors.keppel,
                          AppColors.white,
                        ),
                        _buildActionButton(
                          'Medicina',
                          Icons.medication_outlined,
                          () => _abrirMedicina(),
                          AppColors.keppel,
                          AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDatosTab() {
    final numeroDoc = '${datosUsuario['numeroDocumento'] ?? ''}';
    final fechaNac = '${datosUsuario['fechaNacimiento'] ?? ''}';
    final edad = _calcEdad(datosUsuario['fechaNacimiento']?.toString());
    final genero = '${datosUsuario['genero'] ?? ''}';
    final direccion = '${datosUsuario['direccionUsuario'] ?? ''}';
    final telefono = '${datosUsuario['telefonoUsuario'] ?? ''}';
    final correo = '${datosUsuario['emailUsuario'] ?? ''}';
    final tipoDocId = '${datosUsuario['tipoDocumento'] ?? ''}';
    final alergias = '${historiaClinica['alergias'] ?? 'Ninguna'}';
    final enfCron = '${historiaClinica['enfermedadesCronicas'] ?? ''}';
    final meds = '${historiaClinica['medicamentos'] ?? ''}';
    final antFam = '${historiaClinica['antecedentesFamiliares'] ?? ''}';
    final obs = '${historiaClinica['observaciones'] ?? ''}';
    final fcrea = '${historiaClinica['fechaCreacion'] ?? ''}';
    final factual = '${historiaClinica['fechaUltimaActualizacion'] ?? ''}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Tipo de documento (id)', tipoDocId),
          _buildInfoRow('Número', numeroDoc),
          _buildInfoRow('Nombre', _nombreCompleto(datosUsuario)),
          _buildInfoRow('Fecha de nacimiento', fechaNac),
          _buildInfoRow('Edad', edad),
          _buildInfoRow('Género', genero),
          _buildInfoRow('Dirección', direccion),
          _buildInfoRow('Teléfono', telefono),
          _buildInfoRow('Correo', correo),
          Divider(
            color: AppColors.keppel.withOpacity(0.5),
            height: 24,
            thickness: 1,
          ),
          _buildInfoRow('Alergias', alergias),
          _buildInfoRow('Enfermedades crónicas', enfCron),
          _buildInfoRow('Medicamentos', meds),
          _buildInfoRow('Antecedentes familiares', antFam),
          _buildInfoRow('Observaciones', obs),
          _buildInfoRow('Fecha de creación', fcrea),
          _buildInfoRow('Última actualización', factual),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoTab() {
    final registros = _registrosConsultas;
    if (registros.isEmpty) {
      return Center(
        child: Text(
          'Sin diagnosticos registrados',
          style: AppTextStyles.body.copyWith(
            color: AppColors.paynesGray.withOpacity(0.7),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final registro = registros[index];
        final diagnostico =
            (registro['diagnostico'] ??
                    registro['motivoConsulta'] ??
                    'Sin diagnostico')
                .toString();
        final fecha = (registro['fechaConsulta'] ?? 'Fecha no disponible')
            .toString();
        final sintomas = (registro['sintomas'] ?? '').toString().trim();
        final presion = (registro['presionArterial'] ?? '').toString().trim();
        final frecuencia = (registro['frecuenciaCardiaca'] ?? '')
            .toString()
            .trim();
        final peso = registro['peso'];
        final altura = registro['altura'];
        final imc = registro['imc'];

        return Card(
          color: AppColors.white.withOpacity(0.7),
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(diagnostico, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(
                  'Fecha: $fecha',
                  style: AppTextStyles.cardDescription.copyWith(
                    fontSize: 12,
                    color: AppColors.paynesGray.withOpacity(0.7),
                  ),
                ),
                if (sintomas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Sintomas: $sintomas',
                    style: AppTextStyles.cardDescription,
                  ),
                ],
                if (presion.isNotEmpty ||
                    frecuencia.isNotEmpty ||
                    peso != null ||
                    altura != null ||
                    imc != null) ...[
                  Divider(color: AppColors.keppel.withOpacity(0.5), height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (presion.isNotEmpty)
                        Text(
                          'Presion: $presion',
                          style: AppTextStyles.cardDescription,
                        ),
                      if (frecuencia.isNotEmpty)
                        Text(
                          'Frecuencia: $frecuencia',
                          style: AppTextStyles.cardDescription,
                        ),
                      if (peso != null)
                        Text(
                          'Peso: ${peso.toString()}',
                          style: AppTextStyles.cardDescription,
                        ),
                      if (altura != null)
                        Text(
                          'Altura: ${altura.toString()}',
                          style: AppTextStyles.cardDescription,
                        ),
                      if (imc != null)
                        Text(
                          'IMC: ${imc.toString()}',
                          style: AppTextStyles.cardDescription,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotasTab() {
    final antecedentes = (historiaClinica['antecedentesFamiliares'] ?? '')
        .toString()
        .trim();
    final observaciones = (historiaClinica['observaciones'] ?? '')
        .toString()
        .trim();

    if (antecedentes.isEmpty && observaciones.isEmpty) {
      return Center(
        child: Text(
          'Sin notas registradas',
          style: AppTextStyles.body.copyWith(
            color: AppColors.paynesGray.withOpacity(0.7),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (antecedentes.isNotEmpty) ...[
            Text('Antecedentes familiares', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(antecedentes, style: AppTextStyles.body),
            const SizedBox(height: 16),
          ],
          if (observaciones.isNotEmpty) ...[
            Text('Observaciones', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(observaciones, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }

  Widget _buildArchivosTab() {
    final idPaciente = _idPaciente;
    if (idPaciente == null) {
      return Center(
        child: Text(
          'Sin informacion del paciente',
          style: AppTextStyles.body.copyWith(
            color: AppColors.paynesGray.withOpacity(0.7),
          ),
        ),
      );
    }

    final nombrePaciente = _nombreCompleto(datosUsuario);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestiona los archivos clinicos del paciente. Puedes revisarlos en una pantalla dedicada.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DefaultTabController(
                    length: 3,
                    child: ArchivosPage(
                      cita: {
                        'idPaciente': idPaciente,
                        'idHistoriaClinica': _idHistoriaClinica,
                        'idCita': _idCitaAsociada,
                      },
                      nombrePaciente: nombrePaciente,
                      idRegistroConsulta: _idRegistroConsulta,
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(
              'Abrir Gestor de Archivos',
              style: AppTextStyles.button,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.paynesGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.paynesGray.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    Color bgColor,
    Color fgColor,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 4),
          Text(
            text,
            style: AppTextStyles.button.copyWith(color: fgColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
