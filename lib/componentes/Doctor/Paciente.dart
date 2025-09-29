import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'Archivos.dart';
import 'HistoriaClinica.dart';
import 'Medicina.dart';
import 'Remitir.dart';

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

  // Datos normalizados
  Map<String, dynamic> datosUsuario = {};
  Map<String, dynamic> historiaClinica = {};

  static const String baseUrl =
      'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchPacienteData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ----------------- Helpers de parseo seguros -----------------
  Map<String, dynamic>? _firstMap(dynamic decoded) {
    // Acepta {data: {...}}, {data: [...]}, [...], {...}
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

  // ----------------- Lógica principal -----------------
  Future<void> fetchPacienteData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 1) Usuario por documento
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

      // Normaliza: esperamos nombres según BD
      final int? idPaciente = (usuario['idUsuario'] is int)
          ? usuario['idUsuario'] as int
          : int.tryParse('${usuario['idUsuario']}');

      setState(() {
        datosUsuario = usuario;
      });

      // 2) Historias por idPaciente (fallback por documento)
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
            // Fallback: por documento
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
          // Fallback directo si 4xx/5xx
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

  // ----------------- Utilidades de UI -----------------
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

  @override
  Widget build(BuildContext context) {
    final nombre = _nombreCompleto(datosUsuario).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B0BD),
        title: const Text('Agenda de citas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : Column(
              children: [
                Container(
                  color: const Color(0xFF00B0BD),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Datos'),
                    Tab(text: 'Diagnostico'),
                    Tab(text: 'Archivos'),
                  ],
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF00B0BD),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDatosTab(),
                      _buildDiagnosticoTab(),
                      _buildNotasTab(),
                      _buildArchivosTab(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        'Consultar Historia',
                        _abrirHistoriaClinica,
                        const Color(0xFF7DD1D8),
                      ),
                      _buildActionButton(
                        'Remitir',
                        _abrirRemitir,
                        const Color(0xFF00B0BD),
                      ),
                      _buildActionButton(
                        'Medicina',
                        () => _abrirMedicina(),
                        const Color(0xFF00B0BD),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HistoriaClinicaPage()));
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

  Widget _buildDiagnosticoTab() {
    final registros = _registrosConsultas;
    if (registros.isEmpty) {
      return const Center(child: Text('Sin diagnosticos registrados'));
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
        final tratamiento = (registro['tratamiento'] ?? '').toString().trim();
        final observaciones = (registro['observaciones'] ?? '')
            .toString()
            .trim();
        final sintomas = (registro['sintomas'] ?? '').toString().trim();
        final presion = (registro['presionArterial'] ?? '').toString().trim();
        final frecuencia = (registro['frecuenciaCardiaca'] ?? '')
            .toString()
            .trim();
        final peso = registro['peso'];
        final altura = registro['altura'];
        final imc = registro['imc'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diagnostico,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fecha: $fecha',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (sintomas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Sintomas: $sintomas'),
                ],
                if (tratamiento.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Tratamiento: $tratamiento'),
                ],
                if (observaciones.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Observaciones: $observaciones'),
                ],
                if (presion.isNotEmpty ||
                    frecuencia.isNotEmpty ||
                    peso != null ||
                    altura != null ||
                    imc != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (presion.isNotEmpty) Text('Presion: $presion'),
                      if (frecuencia.isNotEmpty)
                        Text('Frecuencia: $frecuencia'),
                      if (peso != null) Text('Peso: ${peso.toString()}'),
                      if (altura != null) Text('Altura: ${altura.toString()}'),
                      if (imc != null) Text('IMC: ${imc.toString()}'),
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
      return const Center(child: Text('Sin notas registradas'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (antecedentes.isNotEmpty) ...[
            const Text(
              'Antecedentes familiares',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(antecedentes),
            const SizedBox(height: 16),
          ],
          if (observaciones.isNotEmpty) ...[
            const Text(
              'Observaciones',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(observaciones),
          ],
        ],
      ),
    );
  }

  Widget _buildArchivosTab() {
    final idPaciente = _idPaciente;
    if (idPaciente == null) {
      return const Center(child: Text('Sin informacion del paciente'));
    }

    final registros = _registrosConsultas;
    final nombrePaciente = _nombreCompleto(datosUsuario);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestiona los archivos clinicos del paciente. Puedes revisarlos en una pantalla dedicada.',
            style: TextStyle(fontWeight: FontWeight.w500),
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
            icon: const Icon(Icons.folder_open),
            label: const Text('Abrir Archivos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B0BD),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          if (registros.isEmpty)
            const Text('No hay registros asociados para mostrar.')
          else
            Expanded(
              child: ListView.builder(
                itemCount: registros.length,
                itemBuilder: (context, index) {
                  final registro = registros[index];
                  final descripcion =
                      (registro['motivoConsulta'] ??
                              registro['diagnostico'] ??
                              'Registro ${index + 1}')
                          .toString();
                  final fecha = (registro['fechaConsulta'] ?? '').toString();
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file_outlined),
                    title: Text(descripcion),
                    subtitle: fecha.isEmpty ? null : Text(fecha),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatosTab() {
    // Campos según BD USUARIOS
    final numeroDoc = '${datosUsuario['numeroDocumento'] ?? ''}';
    final fechaNac = '${datosUsuario['fechaNacimiento'] ?? ''}';
    final edad = _calcEdad(datosUsuario['fechaNacimiento']?.toString());
    final genero = '${datosUsuario['genero'] ?? ''}';
    final direccion = '${datosUsuario['direccionUsuario'] ?? ''}';
    final telefono = '${datosUsuario['telefonoUsuario'] ?? ''}';
    final correo = '${datosUsuario['emailUsuario'] ?? ''}';
    final tipoDocId = '${datosUsuario['tipoDocumento'] ?? ''}'; // id numérico

    // Campos de HISTORIAS_CLINICAS
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
          const Divider(height: 24),
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      child: Text(text),
    );
  }
}
