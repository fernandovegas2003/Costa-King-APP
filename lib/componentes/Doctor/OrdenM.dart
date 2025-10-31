import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
}

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

      if (!mounted) return;

      if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
        _showSnack("✅ Orden médica registrada correctamente.");
        _formKey.currentState!.reset();
        _tipoOrdenController.clear();
        _descripcionController.clear();
        _fechaVencimientoController.clear();
        _observacionesController.clear();
      } else {
        _showSnack(
          "⚠️ Error al registrar: ${respuesta.body}",
          isError: true,
        );
      }
    } catch (e) {
      _showSnack(
        "❌ Error de conexión con el servidor.",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : AppColors.keppel,
      ),
    );
  }

  InputDecoration _formFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.paynesGray.withOpacity(0.7),
      ),
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
      errorStyle: TextStyle(
        color: Colors.red[700],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFrostTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    String? validatorMsg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.body,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: _formFieldDecoration(label, icon),
        onTap: onTap,
        validator: (v) => (v == null || v.isEmpty)
            ? (validatorMsg ?? "Este campo es requerido")
            : null,
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
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
      _fechaVencimientoController.text = fecha.toIso8601String().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Crear Orden Médica",
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Container(
                width: size.width * 0.9,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.white),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.paynesGray.withOpacity(0.1),
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
                      Text(
                        "Registrar Nueva Orden",
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.keppel,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildFrostTextField(
                        label: "Tipo de Orden",
                        controller: _tipoOrdenController,
                        icon: Icons.receipt_long_outlined,
                        validatorMsg: "Ingrese el tipo de orden",
                      ),

                      _buildFrostTextField(
                        label: "Descripción",
                        controller: _descripcionController,
                        icon: Icons.description_outlined,
                        validatorMsg: "Ingrese una descripción",
                      ),

                      _buildFrostTextField(
                        label: "Fecha de Vencimiento",
                        controller: _fechaVencimientoController,
                        readOnly: true,
                        icon: Icons.calendar_today_outlined,
                        onTap: _seleccionarFecha,
                        validatorMsg: "Seleccione una fecha",
                      ),

                      _buildFrostTextField(
                        label: "Observaciones",
                        controller: _observacionesController,
                        icon: Icons.comment_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: cargando ? null : crearOrdenMedica,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.aquamarine,
                            foregroundColor: AppColors.paynesGray,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ),
                            ),
                            elevation: 4,
                          ),
                          child: cargando
                              ? const CircularProgressIndicator(
                                    color: AppColors.paynesGray,
                                )
                              : Text(
                                    "Guardar Orden Médica",
                                    style: AppTextStyles.button,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}