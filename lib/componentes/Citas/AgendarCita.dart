import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// PALETA DE COLORES
class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

// ESTILOS DE TEXTO
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
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.paynesGray,
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


class AgendarCitaPage extends StatefulWidget {
  const AgendarCitaPage({Key? key}) : super(key: key);

  @override
  State<AgendarCitaPage> createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends State<AgendarCitaPage> {
  List<dynamic> _sedes = [];
  String? _sedeSeleccionada;

  List<dynamic> _servicios = [];
  String? _servicioSeleccionado;

  List<dynamic> _medicos = [];

  bool _cargando = true;
  bool _cargandoMedicos = false;

  @override
  void initState() {
    super.initState();
    _cargarSedes();
    _cargarServicios();
  }

  Future<void> _cargarSedes() async {
    try {
      final response = await http.get(
        Uri.parse("https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/sedes"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _sedes = List<Map<String, dynamic>>.from(data["data"]);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar sedes: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cargarServicios() async {
    try {
      final response = await http.get(
        Uri.parse("https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/servicios/"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _servicios = List<Map<String, dynamic>>.from(data["data"]);
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar servicios: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cargarMedicos(int idEspecialidad) async {
    setState(() {
      _cargandoMedicos = true;
      _medicos = [];
    });
    try {
      final response = await http.get(
        Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/medicos/especialidad/$idEspecialidad"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _medicos = List<Map<String, dynamic>>.from(data["data"])
              .where((medico) => medico["nombreSede"] == _sedeSeleccionada)
              .toList();
          _cargandoMedicos = false;
        });
      }
    } catch (e) {
      setState(() => _cargandoMedicos = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar médicos: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withOpacity(0.7)),
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
        ),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }

  Widget _medicoCard(dynamic medico) {
    final Map<String, dynamic> data = medico as Map<String, dynamic>;

    return Card(
      color: AppColors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.keppel.withOpacity(0.1),
          child: Icon(Icons.person_outline, color: AppColors.keppel),
        ),
        title: Text(
          "${data['nombreUsuario']} ${data['apellidoUsuario']}",
          style: AppTextStyles.cardTitle,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Especialidad: ${data['nombreEspecialidad']}", style: AppTextStyles.cardDescription),
            Text("Sede: ${data['nombreSede']}", style: AppTextStyles.cardDescription),
            Text("Tel: ${data['telefonoUsuario']}", style: AppTextStyles.cardDescription),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.keppel),
        onTap: () {
          final idMedico = data["idMedico"];
          final idServicio = _servicios
              .firstWhere((s) => s["nombreServicio"] == _servicioSeleccionado)["idServicio"];
          final idSede = _sedes
              .firstWhere((s) => s["nombreSede"] == _sedeSeleccionada)["idSede"];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgendarCitaFormPage(
                idMedico: idMedico,
                idServicio: idServicio,
                idSede: idSede,
              ),
            ),
          );
        },
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
          "Agendar Cita",
          style: AppTextStyles.headline,
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
          child: _cargando
              ? Center(child: CircularProgressIndicator(color: AppColors.aquamarine))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _dropdownField(
                      label: "Selecciona la ciudad:",
                      icon: Icons.location_city_outlined,
                      value: _sedeSeleccionada,
                      items: _sedes
                          .map<DropdownMenuItem<String>>((sede) {
                        return DropdownMenuItem<String>(
                          value: sede["nombreSede"],
                          child: Text(sede["ciudadSede"]),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        setState(() {
                          _sedeSeleccionada = valor;
                          _medicos = []; 
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    _dropdownField(
                      label: "Selecciona un servicio:",
                      icon: Icons.medical_services_outlined,
                      value: _servicioSeleccionado,
                      items: _servicios
                          .map<DropdownMenuItem<String>>((servicio) {
                        return DropdownMenuItem<String>(
                          value: servicio["nombreServicio"],
                          child: Text(servicio["nombreServicio"]),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        if (_sedeSeleccionada == null) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text("Por favor, selecciona una ciudad primero"), backgroundColor: Colors.red),
                           );
                           return;
                        }
                        setState(() {
                          _servicioSeleccionado = valor;
                        });

                        final servicio = _servicios.firstWhere(
                            (s) => s["nombreServicio"] == valor);
                        final idEspecialidad = servicio["idServicio"];
                        _cargarMedicos(idEspecialidad);
                      },
                    ),
                    const SizedBox(height: 30),

                    if (_cargandoMedicos)
                      const Center(child: CircularProgressIndicator(color: AppColors.aquamarine))
                    else if (_medicos.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "Médicos disponibles:",
                            style: AppTextStyles.headline.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          ..._medicos.map(_medicoCard),
                        ],
                      )
                    else if (_sedeSeleccionada != null &&
                        _servicioSeleccionado != null)
                       Center(
                         child: Text(
                          "No hay médicos disponibles en esta sede para ese servicio.",
                          style: AppTextStyles.body.copyWith(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                                           ),
                       ),
                  ],
                ),
        ),
      ),
    );
  }
}


class AgendarCitaFormPage extends StatefulWidget {
  final int idMedico;
  final int idServicio;
  final int idSede;

  const AgendarCitaFormPage({
    Key? key,
    required this.idMedico,
    required this.idServicio,
    required this.idSede,
  }) : super(key: key);

  @override
  State<AgendarCitaFormPage> createState() => _AgendarCitaFormPageState();
}

class _AgendarCitaFormPageState extends State<AgendarCitaFormPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _fechaHora;
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _sintomasController = TextEditingController();

  bool _enviando = false;

  Future<void> _agendarCita() async {
    if (!_formKey.currentState!.validate() || _fechaHora == null) {
      if(_fechaHora == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, selecciona una fecha y hora"), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _enviando = true);

    final prefs = await SharedPreferences.getInstance();
    final idPaciente = prefs.getInt("idPaciente"); 

    if (idPaciente == null) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de autenticación. No se encontró idPaciente."), backgroundColor: Colors.red),
        );
       setState(() => _enviando = false);
       return;
    }

    final body = {
      "idPaciente": idPaciente,
      "idServicio": widget.idServicio,
      "idSede": widget.idSede,
      "fechaHora": _fechaHora!
          .toIso8601String()
          .replaceFirst("T", " ")
          .substring(0, 19),
      "motivo": _motivoController.text,
      "sintomas": _sintomasController.text,
      "idMedico": widget.idMedico,
    };

    try {
      final response = await http.post(
        Uri.parse("https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/citas"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Cita agendada con éxito ✅"), backgroundColor: AppColors.keppel),
        );
        Navigator.pop(context); 
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al agendar cita: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  Future<void> _seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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
      final hora = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
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

      if (hora != null) {
        setState(() {
          _fechaHora = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }
  
  Widget _buildFrostTextField(String label, TextEditingController controller, IconData icon) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.body, 
        maxLines: null, 
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withOpacity(0.7)),
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
        ),
        validator: (v) => (v == null || v.isEmpty) ? "Requerido" : null,
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
          "Completar Cita",
          style: AppTextStyles.headline, 
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.5), 
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.paynesGray.withOpacity(0.1), 
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.calendar_today_outlined, size: 20),
                      onPressed: _seleccionarFechaHora,
                      label: Text(
                        _fechaHora == null
                            ? "Seleccionar fecha y hora"
                            : "${_fechaHora!.toLocal().toString().substring(0, 16)}", 
                        style: AppTextStyles.button, 
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.aquamarine, 
                        foregroundColor: AppColors.paynesGray, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFrostTextField(
                      "Motivo de la cita",
                       _motivoController,
                       Icons.notes_outlined
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFrostTextField(
                      "Síntomas actuales",
                      _sintomasController,
                      Icons.medical_information_outlined
                    ),
                    const SizedBox(height: 30),
                    
                    _enviando
                        ? Center(child: CircularProgressIndicator(color: AppColors.aquamarine)) 
                        : ElevatedButton(
                            onPressed: _agendarCita,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.aquamarine, 
                              foregroundColor: AppColors.paynesGray, 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text("Agendar Cita", style: AppTextStyles.button), 
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}