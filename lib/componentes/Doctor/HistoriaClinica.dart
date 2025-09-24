import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Archivos.dart';

class HistoriaClinicaPage extends StatefulWidget {
  const HistoriaClinicaPage({super.key});

  @override
  State<HistoriaClinicaPage> createState() => _HistoriaClinicaPageState();
}

class _HistoriaClinicaPageState extends State<HistoriaClinicaPage> {
  final TextEditingController _documentoController = TextEditingController();
  Map<String, dynamic>? _historiaClinica;
  bool _cargando = false;
  bool _error = false;
  String _mensajeError = '';
  bool _mostrarArchivos = false;
  String _nombrePaciente = '';
  Map<String, dynamic> _datosPaciente = {};

  List<dynamic> _extraerLista(dynamic source) {
    if (source is List) return source;
    if (source is Map && source['data'] is List) {
      return List<dynamic>.from(source['data']);
    }
    return const [];
  }

  @override
  void dispose() {
    _documentoController.dispose();
    super.dispose();
  }

  // Buscar historia clínica por documento
  Future<void> _buscarHistoriaClinica() async {
    final documento = _documentoController.text.trim();
    if (documento.isEmpty) {
      setState(() {
        _error = true;
        _mensajeError = 'Por favor ingrese un numero de documento';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = false;
      _historiaClinica = null;
      _mostrarArchivos = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/documento/$documento",
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final lista = _extraerLista(decoded);
        if (lista.isNotEmpty) {
          final historia = Map<String, dynamic>.from(
            lista.first as Map<dynamic, dynamic>,
          );
          final paciente = Map<String, dynamic>.from(
            (historia['paciente'] as Map<dynamic, dynamic>? ?? {}),
          );
          final registros = _extraerLista(historia['registrosConsultas'])
              .map<Map<String, dynamic>>(
                (registro) => Map<String, dynamic>.from(
                  registro as Map<dynamic, dynamic>,
                ),
              )
              .toList();
          historia['registrosConsultas'] = registros;
          setState(() {
            _historiaClinica = historia;
            _nombrePaciente =
                "${paciente['nombreUsuario'] ?? ''} ${paciente['apellidoUsuario'] ?? ''}"
                    .trim();
            _datosPaciente = {
              'idPaciente': paciente['idUsuario'],
              'cedula': paciente['numeroDocumento'],
              'nombres': paciente['nombreUsuario'],
              'apellidos': paciente['apellidoUsuario'],
            };
          });
        } else {
          setState(() {
            _error = true;
            _mensajeError =
                'No se encontró historia clínica para este documento';
          });
        }
      } else {
        setState(() {
          _error = true;
          _mensajeError =
              'Error al buscar historia clínica: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = true;
        _mensajeError = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  // Mostrar sección de archivos
  void _verArchivos() {
    setState(() {
      _mostrarArchivos = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> registrosConsultas =
        ((_historiaClinica?['registrosConsultas'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList());
    final Map<String, dynamic>? primerRegistro = registrosConsultas.isNotEmpty
        ? registrosConsultas.first
        : null;
    final int? idRegistroConsulta =
        primerRegistro != null && primerRegistro['idRegistroConsulta'] is int
        ? primerRegistro['idRegistroConsulta'] as int
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Interpretación de la historia clínica",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00BCD4),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/Fondo.png", fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buscador de historia clínica
                if (!_mostrarArchivos) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Buscar Historia Clínica",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _documentoController,
                            decoration: InputDecoration(
                              labelText: "Número de Documento",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _cargando
                                  ? null
                                  : _buscarHistoriaClinica,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7FDCDC),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: _cargando
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Buscar",
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (_error) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _mensajeError,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Resultados de la búsqueda
                if (_historiaClinica != null && !_mostrarArchivos) ...[
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Información del Paciente",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                onPressed: _verArchivos,
                                tooltip: "Ver archivos",
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildInfoRow("Nombre", _nombrePaciente),
                          _buildInfoRow(
                            "Documento",
                            _historiaClinica!['paciente']['numeroDocumento'],
                          ),
                          _buildInfoRow(
                            "Fecha de creación",
                            _historiaClinica!['fechaCreacion'],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Información Médica",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            "Tipo de Sangre",
                            _historiaClinica!['tipoSangre'] ?? 'No registrado',
                          ),
                          _buildInfoRow(
                            "Alergias",
                            _historiaClinica!['alergias'] ?? 'Ninguna',
                          ),
                          _buildInfoRow(
                            "Enfermedades Crónicas",
                            _historiaClinica!['enfermedadesCronicas'] ??
                                'Ninguna',
                          ),
                          _buildInfoRow(
                            "Medicamentos",
                            _historiaClinica!['medicamentos'] ?? 'Ninguno',
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Diagnósticos",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (registrosConsultas.isNotEmpty)
                            ...registrosConsultas
                                .map<Widget>(
                                  (registro) => _buildDiagnosticoItem(registro),
                                )
                                .toList()
                          else
                            const Text("No hay diagnósticos registrados"),
                        ],
                      ),
                    ),
                  ),
                ],

                // Sección de archivos
                if (_mostrarArchivos) ...[
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00BCD4),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              _nombrePaciente.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: _historiaClinica == null
                                ? const Center(
                                    child: Text(
                                      "No hay historia clínica seleccionada",
                                    ),
                                  )
                                : ArchivosPage(
                                    cita: {
                                      'idPaciente':
                                          _datosPaciente['idPaciente'],
                                      'idHistoriaClinica':
                                          _historiaClinica?['idHistoriaClinica'],
                                    },
                                    nombrePaciente: _nombrePaciente,
                                    idRegistroConsulta: idRegistroConsulta,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar información en filas
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Widget para mostrar diagnósticos
  Widget _buildDiagnosticoItem(Map<String, dynamic> registro) {
    final descripcion =
        registro['diagnostico']?.toString() ?? 'Sin diagnóstico';
    final fecha =
        registro['fechaConsulta']?.toString() ?? 'Fecha no registrada';
    final tratamiento = registro['tratamiento']?.toString();
    final observaciones = registro['observaciones']?.toString();
    final presion = registro['presionArterial']?.toString();
    final frecuencia = registro['frecuenciaCardiaca']?.toString();
    final temperatura = registro['temperatura']?.toString();
    final peso = registro['peso'];
    final altura = registro['altura'];
    final imc = registro['imc'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descripcion,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Fecha: $fecha'),
            if (tratamiento != null && tratamiento.isNotEmpty)
              Text('Tratamiento: $tratamiento'),
            if (observaciones != null && observaciones.isNotEmpty)
              Text('Observaciones: $observaciones'),
            if ((presion != null && presion.isNotEmpty) ||
                (frecuencia != null && frecuencia.isNotEmpty) ||
                (temperatura != null && temperatura.isNotEmpty) ||
                peso != null)
              const SizedBox(height: 4),
            if (presion != null && presion.isNotEmpty)
              Text('Presión Arterial: $presion'),
            if (frecuencia != null && frecuencia.isNotEmpty)
              Text('Frecuencia Cardíaca: $frecuencia'),
            if (temperatura != null && temperatura.isNotEmpty)
              Text('Temperatura: $temperatura'),
            if (peso != null) Text('Peso: $peso kg'),
            if (altura != null) Text('Altura: $altura m'),
            if (imc != null) Text('IMC: $imc'),
          ],
        ),
      ),
    );
  }
}
