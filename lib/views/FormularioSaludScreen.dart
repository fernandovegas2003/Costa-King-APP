import 'dart:convert';
import 'package:bless_health24/views/ResultadoScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class FormularioSaludScreen extends StatefulWidget {
  const FormularioSaludScreen({super.key});

  @override
  State<FormularioSaludScreen> createState() => _FormularioSaludScreenState();
}

class _FormularioSaludScreenState extends State<FormularioSaludScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final fechaNacimientoCtrl = TextEditingController();
  final alturaCtrl = TextEditingController();
  final pesoActualCtrl = TextEditingController();
  final pesoObjetivoCtrl = TextEditingController();
  final presionSistolicaCtrl = TextEditingController();
  final presionDiastolicaCtrl = TextEditingController();
  final ejercicioDiasCtrl = TextEditingController();
  final minutosEjercicioCtrl = TextEditingController();
  final horasSuenoCtrl = TextEditingController();
  final anosFumandoCtrl = TextEditingController();
  final anosConsumoCtrl = TextEditingController();
  final ingresosMensualesCtrl = TextEditingController();
  final coberturaDeseadaCtrl = TextEditingController();

  String? genero;
  String? tipoSangre;
  String? contextura;
  String? nivelActividad;
  String? nivelEstres;
  String? fuma;
  String? drogas;

  List<String> tipoEjercicio = [];
  List<String> tipoDrogas = [];
  List<String> condiciones = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarAdvertencia());
  }

  void _mostrarAdvertencia() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[800],
            ),
            const SizedBox(width: 8),
            Text(
              "Aviso Importante",
              style: AppTextStyles.headline.copyWith(fontSize: 20),
            ),
          ],
        ),
        content: Text(
          "Esto no reemplaza una cita médica.\n"
          "Son solo recomendaciones.\n\n"
          "No nos hacemos responsables por el mal uso del mismo.",
          style: AppTextStyles.body.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.paynesGray,
            ),
            child: const Text(
              "Entiendo y Acepto",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "nombre": nombreCtrl.text,
      "fecha_nacimiento": fechaNacimientoCtrl.text,
      "genero": genero,
      "tipo_sangre": tipoSangre,
      "altura": double.tryParse(alturaCtrl.text),
      "peso_actual": double.tryParse(pesoActualCtrl.text),
      "peso_objetivo": double.tryParse(pesoObjetivoCtrl.text),
      "contextura": contextura,
      "presion_sistolica": int.tryParse(presionSistolicaCtrl.text),
      "presion_diastolica": int.tryParse(presionDiastolicaCtrl.text),
      "nivel_actividad": nivelActividad,
      "ejercicio_dias": int.tryParse(ejercicioDiasCtrl.text),
      "minutos_ejercicio": int.tryParse(minutosEjercicioCtrl.text),
      "tipo_ejercicio": tipoEjercicio,
      "horas_sueno": double.tryParse(horasSuenoCtrl.text),
      "nivel_estres": nivelEstres,
      "fuma": fuma,
      "anos_fumando": int.tryParse(anosFumandoCtrl.text),
      "drogas": drogas,
      "anos_consumo": int.tryParse(anosConsumoCtrl.text),
      "tipo_drogas": tipoDrogas,
      "condiciones": condiciones,
      "ingresos_mensuales": int.tryParse(ingresosMensualesCtrl.text),
      "cobertura_deseada": int.tryParse(coberturaDeseadaCtrl.text),
    };

    try {
      final res = await http.post(
        Uri.parse("http://20.251.169.101:5003/api/analisis-salud-integral"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultadoScreen(resultado: body)),
        );
      } else {
        _showSnack("Error en el servidor: ${res.statusCode}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
    );
  }

  InputDecoration _formFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.paynesGray.withOpacity(0.7),
      ),
      filled: true,
      fillColor: AppColors.white.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> opciones,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        style: AppTextStyles.body,
        decoration: _formFieldDecoration(label),
        items: opciones
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Requerido" : null,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
    bool requerido = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        style: AppTextStyles.body,
        keyboardType: type,
        decoration: _formFieldDecoration(label),
        validator: (v) =>
            (requerido && (v == null || v.isEmpty)) ? "Requerido" : null,
      ),
    );
  }

  Widget _buildSelectorDialog({
    required String label,
    required List<String> opciones,
    required List<String> seleccionados,
    bool multiSelect = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          List<String> tempSeleccionados = List.from(seleccionados);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'Seleccionar $label',
                      style: AppTextStyles.headline.copyWith(fontSize: 20),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: opciones.map((opcion) {
                          if (multiSelect) {
                            return CheckboxListTile(
                              title: Text(
                                opcion,
                                style: AppTextStyles.body,
                              ),
                              value: tempSeleccionados.contains(opcion),
                              activeColor: AppColors.keppel,
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    tempSeleccionados.add(opcion);
                                  } else {
                                    tempSeleccionados.remove(opcion);
                                  }
                                });
                              },
                            );
                          } else {
                            return RadioListTile<String>(
                              title: Text(
                                opcion,
                                style: AppTextStyles.body,
                              ),
                              value: opcion,
                              activeColor: AppColors.keppel,
                              groupValue: tempSeleccionados.isNotEmpty
                                  ? tempSeleccionados.first
                                  : null,
                              onChanged: (String? value) {
                                setDialogState(() {
                                  tempSeleccionados.clear();
                                  if (value != null) {
                                    tempSeleccionados.add(value);
                                  }
                                });
                              },
                            );
                          }
                        }).toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.paynesGray),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.aquamarine,
                          foregroundColor: AppColors.paynesGray,
                        ),
                        onPressed: () {
                          setState(() {
                            seleccionados.clear();
                            seleccionados.addAll(tempSeleccionados);
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  seleccionados.isEmpty
                      ? "Seleccionar $label"
                      : "$label: ${seleccionados.join(', ')}",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.paynesGray.withOpacity(
                      seleccionados.isEmpty ? 0.7 : 1.0,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: AppColors.paynesGray,
              ),
            ],
          ),
        ),
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Formulario de Salud",
          style: AppTextStyles.headline,
        ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField("Nombre", nombreCtrl),
                  _buildTextField(
                    "Fecha de nacimiento (YYYY-MM-DD)",
                    fechaNacimientoCtrl,
                  ),
                  _buildDropdown(
                    label: "Género",
                    value: genero,
                    opciones: ["Masculino", "Femenino"],
                    onChanged: (v) => setState(() => genero = v),
                  ),
                  _buildDropdown(
                    label: "Tipo de Sangre",
                    value: tipoSangre,
                    opciones: [
                      "O+",
                      "O-",
                      "A+",
                      "A-",
                      "B+",
                      "B-",
                      "AB+",
                      "AB-",
                    ],
                    onChanged: (v) => setState(() => tipoSangre = v),
                  ),
                  _buildTextField(
                    "Altura (m)",
                    alturaCtrl,
                    type: TextInputType.number,
                  ),
                  _buildTextField(
                    "Peso actual (kg)",
                    pesoActualCtrl,
                    type: TextInputType.number,
                  ),
                  _buildTextField(
                    "Peso objetivo (kg)",
                    pesoObjetivoCtrl,
                    type: TextInputType.number,
                  ),
                  _buildDropdown(
                    label: "Contextura",
                    value: contextura,
                    opciones: ["pequeña", "mediana", "grande"],
                    onChanged: (v) => setState(() => contextura = v),
                  ),
                  _buildTextField(
                    "Presión sistólica",
                    presionSistolicaCtrl,
                    type: TextInputType.number,
                  ),
                  _buildTextField(
                    "Presión diastólica",
                    presionDiastolicaCtrl,
                    type: TextInputType.number,
                  ),
                  _buildDropdown(
                    label: "Nivel de Actividad",
                    value: nivelActividad,
                    opciones: [
                      "Sedentario",
                      "Ligero",
                      "Moderado",
                      "Intenso",
                      "Atleta",
                    ],
                    onChanged: (v) => setState(() => nivelActividad = v),
                  ),
                  _buildTextField(
                    "Ejercicio (días/semana)",
                    ejercicioDiasCtrl,
                    type: TextInputType.number,
                  ),
                  _buildTextField(
                    "Minutos por sesión",
                    minutosEjercicioCtrl,
                    type: TextInputType.number,
                  ),
                  _buildSelectorDialog(
                    label: "Tipo de ejercicio",
                    opciones: ["cardio", "fuerza"],
                    seleccionados: tipoEjercicio,
                  ),
                  _buildTextField(
                    "Horas de sueño",
                    horasSuenoCtrl,
                    type: TextInputType.number,
                  ),
                  _buildDropdown(
                    label: "Nivel de Estrés",
                    value: nivelEstres,
                    opciones: [
                      "Muy bajo",
                      "Bajo",
                      "Moderado",
                      "Alto",
                      "Muy alto",
                    ],
                    onChanged: (v) => setState(() => nivelEstres = v),
                  ),
                  _buildDropdown(
                    label: "Fuma",
                    value: fuma,
                    opciones: [
                      "No",
                      "Fumador ocasional",
                      "Fumador regular",
                      "Ex-fumador",
                    ],
                    onChanged: (v) => setState(() => fuma = v),
                  ),
                  _buildTextField(
                    "Años fumando",
                    anosFumandoCtrl,
                    type: TextInputType.number,
                    requerido: false,
                  ),
                  _buildDropdown(
                    label: "Drogas",
                    value: drogas,
                    opciones: ["No", "Ocasionalmente", "Regularmente"],
                    onChanged: (v) => setState(() => drogas = v),
                  ),
                  _buildTextField(
                    "Años consumo drogas",
                    anosConsumoCtrl,
                    type: TextInputType.number,
                    requerido: false,
                  ),
                  _buildSelectorDialog(
                    label: "Tipo de drogas",
                    opciones: ["Marihuana", "Cocaína"],
                    seleccionados: tipoDrogas,
                  ),
                  _buildSelectorDialog(
                    label: "Condiciones médicas",
                    opciones: ["Diabetes", "Hipertensión", "Otra"],
                    seleccionados: condiciones,
                  ),
                  _buildTextField(
                    "Ingresos mensuales (COP)",
                    ingresosMensualesCtrl,
                    type: TextInputType.number,
                  ),
                  _buildTextField(
                    "Cobertura deseada (COP)",
                    coberturaDeseadaCtrl,
                    type: TextInputType.number,
                    requerido: false,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _enviarFormulario,
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
                    child: Text(
                      "Enviar",
                      style: AppTextStyles.button,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}