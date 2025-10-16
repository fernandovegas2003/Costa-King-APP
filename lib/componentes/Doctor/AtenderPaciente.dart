import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'Archivos.dart';

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
  // Controladores
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _sintomasController = TextEditingController();
  final TextEditingController _presionArterialController = TextEditingController();
  final TextEditingController _frecuenciaCardiacaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  bool _guardando = false;
  int? _idRegistroConsulta;
  DateTime _fechaConsulta = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 🔹 Fecha fija (solo visible, no editable)
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

  // 🔹 Cargar registro existente (si ya fue creado)
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al cargar registro: $e")));
    }
  }

  Future<void> _guardarRegistro() async {
    setState(() => _guardando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? idMedicoParsed = prefs.getInt("idDoctor"); // ✅ obtenido del login

      if (idMedicoParsed == null || idMedicoParsed <= 0) {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se encontró un médico válido. Inicie sesión nuevamente.")),
        );
        return;
      }

      // Validar motivoConsulta (es obligatorio)
      if (_motivoController.text.trim().isEmpty) {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debe ingresar un motivo de consulta.")),
        );
        return;
      }

      final double? peso = double.tryParse(_pesoController.text.trim());
      final double? altura = double.tryParse(_alturaController.text.trim());

      // 🔹 Body fijo con idHistoriaClinica = 2
      final body = {
        "idHistoriaClinica": 21, // ✅ siempre 2
        "idMedico": idMedicoParsed, // ✅ funciona desde SharedPreferences
        "idCita": widget.cita['idCita'], // viene de la cita seleccionada
        "fechaConsulta": DateFormat('yyyy-MM-dd HH:mm:ss').format(_fechaConsulta), // ✅ fecha actual
        "motivoConsulta": _motivoController.text.trim(), // ✅ obligatorio
        "sintomas": _sintomasController.text.trim(),
        "presionArterial": _presionArterialController.text.trim(),
        "frecuenciaCardiaca": _frecuenciaCardiacaController.text.trim(),
        "peso": peso,
        "altura": altura
      };

      debugPrint("📤 Enviando body: ${jsonEncode(body)}");

      final uri = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/registros-consultas",
      );

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      setState(() => _guardando = false);

      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro de cita creado correctamente ✅")),
        );
        Navigator.pop(context, true);
      } else {
        debugPrint("❌ Error en el guardado:");
        debugPrint("Status code: ${res.statusCode}");
        debugPrint("Respuesta del servidor: ${res.body}");

        String mensajeError;
        try {
          final data = jsonDecode(res.body);
          mensajeError = data['message'] ?? data['mensaje'] ?? data['error'] ?? res.body;
        } catch (_) {
          mensajeError = res.body;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error del servidor: $mensajeError")),
        );
      }

    } catch (e) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al guardar registro: $e")));
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
          "Registro de Consulta",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/Fondo.png", fit: BoxFit.cover),
          ),
          Column(
            children: [
              Container(
                color: const Color(0xFF00BCD4),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.nombrePaciente.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                      const Text("Datos de la Consulta",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      _campo("Fecha de consulta", _fechaController, readOnly: true),
                      _campo("Motivo de consulta", _motivoController, maxLines: 2),
                      _campo("Síntomas", _sintomasController, maxLines: 3),
                      _campo("Presión arterial", _presionArterialController),
                      _campo("Frecuencia cardíaca", _frecuenciaCardiacaController),
                      _campo("Peso (kg)", _pesoController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                      _campo("Altura (m)", _alturaController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: _guardando
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Guardar Registro", style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _campo(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
        bool readOnly = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
