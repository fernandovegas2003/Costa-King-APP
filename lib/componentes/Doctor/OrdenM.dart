import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdenMedicaPage extends StatefulWidget {
  const OrdenMedicaPage({Key? key}) : super(key: key);

  @override
  State<OrdenMedicaPage> createState() => _OrdenMedicaPageState();
}

class _OrdenMedicaPageState extends State<OrdenMedicaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tipoOrdenController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaVencimientoController =
  TextEditingController();
  final TextEditingController _observacionesController =
  TextEditingController();

  bool cargando = false;

  Future<void> crearOrdenMedica() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => cargando = true);

    final url = Uri.parse(
      'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/ordenes-medicas',
    );

    final body = {
      "idRegistroConsulta": 23,
      "tipoOrden": _tipoOrdenController.text,
      "descripcion": _descripcionController.text,
      "fechaVencimiento": _fechaVencimientoController.text,
      "observaciones": _observacionesController.text,
    };

    try {
      final respuesta = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Orden médica registrada correctamente."),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        _tipoOrdenController.clear();
        _descripcionController.clear();
        _fechaVencimientoController.clear();
        _observacionesController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ Error al registrar: ${respuesta.body}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error de conexión con el servidor."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Crear Orden Médica",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Stack(
        children: [
          /// 🌅 Fondo completo
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 📋 Contenedor centrado completamente
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Container(
                width: size.width * 0.9,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.93),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Registrar Nueva Orden Médica",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF01A4B2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Tipo de orden
                      TextFormField(
                        controller: _tipoOrdenController,
                        decoration: _inputDecoration("Tipo de Orden"),
                        validator: (value) =>
                        value!.isEmpty ? "Ingrese el tipo de orden" : null,
                      ),
                      const SizedBox(height: 15),

                      /// Descripción
                      TextFormField(
                        controller: _descripcionController,
                        decoration: _inputDecoration("Descripción"),
                        validator: (value) =>
                        value!.isEmpty ? "Ingrese una descripción" : null,
                      ),
                      const SizedBox(height: 15),

                      /// Fecha de vencimiento
                      TextFormField(
                        controller: _fechaVencimientoController,
                        readOnly: true,
                        decoration: _inputDecoration("Fecha de Vencimiento"),
                        onTap: () async {
                          DateTime? fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (fecha != null) {
                            _fechaVencimientoController.text =
                            fecha.toIso8601String().split('T')[0];
                          }
                        },
                        validator: (value) =>
                        value!.isEmpty ? "Seleccione una fecha" : null,
                      ),
                      const SizedBox(height: 15),

                      /// Observaciones
                      TextFormField(
                        controller: _observacionesController,
                        decoration: _inputDecoration("Observaciones"),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),

                      /// Botón de guardar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: cargando ? null : crearOrdenMedica,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01A4B2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: cargando
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Guardar Orden Médica",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///  Estilo base para los TextFields
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF01A4B2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF01A4B2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF01A4B2), width: 2),
      ),
    );
  }
}
