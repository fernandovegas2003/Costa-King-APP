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
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró información del doctor")),
      );
    }
  }

  Future<void> _cargarCitasPorFecha() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/doctor/$_cedulaMedico"),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _citasPendientes = decoded["data"] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _citasPendientes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _citasPendientes = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _finalizarCita(int idCita) async {
    try {
      final response = await http.put(
        Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/$idCita/finalizar"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        // ✅ Cita finalizada con éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cita finalizada con éxito")),
        );

        // 🔹 Ahora generamos la factura desde la cita
        try {
          final facturaResponse = await http.post(
            Uri.parse(
                "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/facturas/generar-desde-cita/$idCita"),
            headers: {"Content-Type": "application/json"},
          );

          if (facturaResponse.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Factura generada correctamente")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Error al generar factura: ${facturaResponse.body}")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al generar factura: $e")),
          );
        }

        // 🔁 Recargar citas
        _cargarCitasPorFecha();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al finalizar cita: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al finalizar cita: $e")));
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cita cancelada con éxito")),
        );
        _cargarCitasPorFecha();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cancelar cita: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al cancelar cita: $e")));
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
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
      'idPaciente',
      'documentoPaciente',
      'numeroDocumentoPaciente',
      'cedulaPaciente',
      'cedula',
      'documento'
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró documento del paciente.')),
      );
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
        builder: (context) => const OrdenMedicaPage(), // ✅ sin parámetros
      ),
    );

    if (resultado == true) _cargarCitasPorFecha();
  }


  void _verHistoriaClinica(Map<String, dynamic> cita) async {
    final idCita = cita['idCita'];
    if (idCita == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró ID de la cita.")),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/$idCita",
        ),
      );

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se encontró el paciente en la cita.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al obtener la cita: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
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
          "Agenda de citas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _seleccionarFecha,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/Fondo.png", fit: BoxFit.cover),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _seleccionarFecha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                      ),
                      child: const Text("Cambiar"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _citasPendientes.isEmpty
                      ? const Center(
                    child: Text(
                      "No hay citas pendientes para esta fecha",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _citasPendientes.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> cita =
                      Map<String, dynamic>.from(_citasPendientes[index]);

                      return Card(
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
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Servicio: ${cita['servicio'] ?? 'No especificado'}",
                                style:
                                const TextStyle(color: Colors.grey),
                              ),
                              const Divider(),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                alignment: WrapAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _navegarAAtencion(cita),
                                    icon: const Icon(Icons.healing_outlined, color: Colors.orange),
                                    label: const Text(
                                      "Atender",
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _finalizarCita(cita['idCita']),
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                    label: const Text(
                                      "Finalizar",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _cancelarCita(cita['idCita']),
                                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                    label: const Text(
                                      "Cancelar",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _navegarAOrdenMedica(cita),
                                    icon: const Icon(Icons.assignment_add, color: Colors.blue),
                                    label: const Text(
                                      "Orden Médica",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _verHistoriaClinica(cita),
                                    icon: const Icon(Icons.history_edu, color: Colors.purple),
                                    label: const Text(
                                      "Ver historia",
                                      style: TextStyle(color: Colors.purple),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final idCita = cita['idCita'];

                                      if (idCita == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("No se encontró el ID de la cita.")),
                                        );
                                        return;
                                      }

                                      try {
                                        // 🔹 Llamada al endpoint /api/citas/{idCita}
                                        final response = await http.get(
                                          Uri.parse("https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas/$idCita"),
                                        );

                                        if (response.statusCode == 200) {
                                          final data = jsonDecode(response.body);

                                          // 🔹 Intentamos obtener el idPaciente o idUsuarioCC
                                          final idPaciente = data['data']?['idPaciente'] ?? data['data']?['idUsuarioCC'];

                                          if (idPaciente != null) {
                                            // 🔹 Guardamos el ID en SharedPreferences
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setInt('idPacienteSeleccionado', int.tryParse(idPaciente.toString()) ?? 0);

                                            // 🔹 Navegamos a la página de Autorizaciones
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const VerAutorizacionesPage(),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("No se encontró el paciente en la cita.")),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Error al obtener datos de la cita: ${response.body}")),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error de conexión: $e")),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.verified_user_outlined, color: Colors.teal),
                                    label: const Text(
                                      "Autorizaciones",
                                      style: TextStyle(color: Colors.teal),
                                    ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
