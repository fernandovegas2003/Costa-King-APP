import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'AtenderPaciente.dart';
import 'OrdenM.dart';
import 'Paciente.dart';
import 'HistoriaClinica.dart';
import 'Autorizaciones.dart';

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


class AgendaDoctorPage extends StatefulWidget {
  const AgendaDoctorPage({Key? key}) : super(key: key);

  @override
  State<AgendaDoctorPage> createState() => _AgendaDoctorPageState();
}

class _AgendaDoctorPageState extends State<AgendaDoctorPage> {
  List<dynamic> _citasPendientes = [];
  bool _isLoading = true;
  DateTime _fechaSeleccionada = DateTime.now();
  String? _cedulaMedico;

  @override
  void initState() {
    super.initState();
    _cargarDatosMedico();
  }

  Future<void> _cargarDatosMedico() async {
    final prefs = await SharedPreferences.getInstance();
    final idDoctor = prefs.getInt("idDoctor");

    if (idDoctor != null) {
      setState(() {
        _cedulaMedico = idDoctor.toString();
      });
      _cargarCitasPorFecha();
    } else {
      setState(() => _isLoading = false);
      _showSnack("No se encontró información del doctor", isError: true);
    }
  }

  Future<void> _cargarCitasPorFecha() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/doctor/$_cedulaMedico"),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          final String fechaFiltro = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);
          _citasPendientes = (decoded["data"] ?? []).where((cita) {
            final fechaCita = cita["fechaHora"]?.substring(0, 10);
            return fechaCita == fechaFiltro;
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _citasPendientes = [];
          _isLoading = false;
        });
        _showSnack("Error al cargar citas: ${response.body}", isError: true);
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _citasPendientes = [];
          _isLoading = false;
        });
        _showSnack("Error de conexión: $e", isError: true);
      }
    }
  }

  Future<void> _finalizarCita(int idCita) async {
    try {
      final response = await http.put(
        Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/$idCita/finalizar"),
        headers: {"Content-Type": "application/json"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnack("Cita finalizada con éxito");

        try {
          final facturaResponse = await http.post(
            Uri.parse(
                "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/facturas/generar-desde-cita/$idCita"),
            headers: {"Content-Type": "application/json"},
          );
          if (facturaResponse.statusCode == 200) {
            _showSnack("Factura generada correctamente");
          } else {
            _showSnack("Error al generar factura: ${facturaResponse.body}", isError: true);
          }
        } catch (e) {
          _showSnack("Error al generar factura: $e", isError: true);
        }
        _cargarCitasPorFecha();
      } else {
        _showSnack("Error al finalizar cita: ${response.body}", isError: true);
      }
    } catch (e) {
      _showSnack("Error al finalizar cita: $e", isError: true);
    }
  }

  Future<void> _cancelarCita(int idCita) async {
    try {
      final response = await http.put(
        Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/$idCita/cancelar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"motivoCancelacion": "Cancelada por el médico"}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _showSnack("Cita cancelada con éxito");
        _cargarCitasPorFecha();
      } else {
        _showSnack("Error al cancelar cita: ${response.body}", isError: true);
      }
    } catch (e) {
      _showSnack("Error al cancelar cita: $e", isError: true);
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
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
      setState(() {
        _fechaSeleccionada = fecha;
      });
      _cargarCitasPorFecha();
    }
  }

  String? _obtenerDocumentoPaciente(Map<String, dynamic> cita) {
    const posibles = [
      'idPaciente', 'documentoPaciente', 'numeroDocumentoPaciente',
      'cedulaPaciente', 'cedula', 'documento'
    ];
    for (final key in posibles) {
      final value = cita[key];
      if (value != null && value.toString().isNotEmpty) return value.toString();
    }
    return null;
  }

  Future<void> _navegarAAtencion(Map<String, dynamic> cita) async {
    final prefs = await SharedPreferences.getInstance();
    if (cita['idCita'] != null) {
      await prefs.setInt('idCita', cita['idCita']);
    }
    final nombreCompleto =
        "${cita['nombrePaciente'] ?? 'Paciente'} ${cita['apellidoPaciente'] ?? ''}".trim();
    
    if(!mounted) return;
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AtenderPacientePage(
          cita: cita,
          nombrePaciente: nombreCompleto,
        ),
      ),
    );
    if (resultado == true) _cargarCitasPorFecha();
  }

  void _navegarAPaciente(Map<String, dynamic> cita) {
    final documento = _obtenerDocumentoPaciente(cita);
    if (documento == null) {
      _showSnack('No se encontró documento del paciente.', isError: true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Paciente(documentoId: documento)),
    );
  }

  void _navegarAOrdenMedica(Map<String, dynamic> cita) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrdenMedicaPage(),
      ),
    );
    if (resultado == true) _cargarCitasPorFecha();
  }

  void _verHistoriaClinica(Map<String, dynamic> cita) async {
    final idCita = cita['idCita'];
    if (idCita == null) {
      _showSnack("No se encontró ID de la cita.", isError: true);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/$idCita",
        ),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final idPaciente = data['data']?['idUsuarioCC'] ?? data['data']?['idPaciente'];
        if (idPaciente != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoriaClinicaPage(
                idPaciente: int.tryParse(idPaciente.toString()) ?? 0,
              ),
            ),
          );
        } else {
          _showSnack("No se encontró el paciente en la cita.", isError: true);
        }
      } else {
        _showSnack("Error al obtener la cita: ${response.body}", isError: true);
      }
    } catch (e) {
      _showSnack("Error de conexión: $e", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : AppColors.keppel,
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
          "Agenda de citas",
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppColors.paynesGray),
            onPressed: _seleccionarFecha,
          ),
        ],
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
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                      style: AppTextStyles.headline.copyWith(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: _seleccionarFecha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.aquamarine,
                        foregroundColor: AppColors.paynesGray,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text("Cambiar", style: AppTextStyles.button.copyWith(fontSize: 14)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.aquamarine))
                    : _citasPendientes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month_outlined, size: 60, color: AppColors.paynesGray.withOpacity(0.3)),
                                SizedBox(height: 16),
                                Text(
                                  "No hay citas pendientes para esta fecha",
                                  style: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _citasPendientes.length,
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> cita =
                                  Map<String, dynamic>.from(_citasPendientes[index]);
                              
                              return Card(
                                color: AppColors.white.withOpacity(0.7),
                                margin: const EdgeInsets.only(bottom: 15),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${cita['nombrePaciente'] ?? 'N/A'}",
                                        style: AppTextStyles.cardTitle,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Servicio: ${cita['servicio'] ?? 'No especificado'}",
                                        style: AppTextStyles.cardDescription.copyWith(color: AppColors.paynesGray.withOpacity(0.7)),
                                      ),
                                      Text(
                                        "Hora: ${DateFormat('hh:mm a').format(DateTime.parse(cita['fechaHora']))}",
                                        style: AppTextStyles.cardDescription,
                                      ),
                                      Divider(color: AppColors.keppel.withOpacity(0.5), height: 20),
                                      
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        alignment: WrapAlignment.start,
                                        children: [
                                          _buildActionButton(
                                            "Atender",
                                            Icons.healing_outlined,
                                            Colors.orange[800]!,
                                            () => _navegarAAtencion(cita)
                                          ),
                                          _buildActionButton(
                                            "Finalizar",
                                            Icons.check_circle_outline,
                                            Colors.green[700]!,
                                            () => _finalizarCita(cita['idCita'])
                                          ),
                                          _buildActionButton(
                                            "Cancelar",
                                            Icons.cancel_outlined,
                                            Colors.red[700]!,
                                            () => _cancelarCita(cita['idCita'])
                                          ),
                                          _buildActionButton(
                                            "Orden Médica",
                                            Icons.assignment_add,
                                            AppColors.keppel,
                                            () => _navegarAOrdenMedica(cita)
                                          ),
                                          _buildActionButton(
                                            "Ver historia",
                                            Icons.history_edu_outlined,
                                            AppColors.paynesGray,
                                            () => _verHistoriaClinica(cita)
                                          ),
                                          _buildActionButton(
                                            "Autorizaciones",
                                            Icons.verified_user_outlined,
                                            AppColors.keppel,
                                            () async {
                                              final idCita = cita['idCita'];
                                              if (idCita == null) {
                                                _showSnack("No se encontró el ID de la cita.", isError: true);
                                                return;
                                              }
                                              try {
                                                final response = await http.get(
                                                  Uri.parse("https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/$idCita"),
                                                );
                                                if (response.statusCode == 200) {
                                                  final data = jsonDecode(response.body);
                                                  final idPaciente = data['data']?['idPaciente'] ?? data['data']?['idUsuarioCC'];
                                                  if (idPaciente != null) {
                                                    final prefs = await SharedPreferences.getInstance();
                                                    await prefs.setInt('idPacienteSeleccionado', int.tryParse(idPaciente.toString()) ?? 0);
                                                    if(mounted) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => const VerAutorizacionesPage(),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    _showSnack("No se encontró el paciente en la cita.", isError: true);
                                                  }
                                                } else {
                                                  _showSnack("Error al obtener datos de la cita: ${response.body}", isError: true);
                                                }
                                              } catch (e) {
                                                _showSnack("Error de conexión: $e", isError: true);
                                              }
                                            }
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: AppTextStyles.body.copyWith(color: color, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}