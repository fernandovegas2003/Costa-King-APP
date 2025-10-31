import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Medicamentos.dart';
import 'Remedios.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

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
    fontSize: 20,
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
    color: AppColors.keppel,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 13,
    fontFamily: _fontFamily,
  );
}

class PresionPage extends StatefulWidget {
  const PresionPage({super.key});

  @override
  State<PresionPage> createState() => _PresionPageState();
}

class _PresionPageState extends State<PresionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _edadCtrl = TextEditingController();
  final TextEditingController _sistolicaCtrl = TextEditingController();
  final TextEditingController _diastolicaCtrl = TextEditingController();
  String _genero = "hombre";
  Map<String, dynamic>? _resultado;
  bool _cargando = false;
  int _selectedIndex = 1;

  Future<void> _analizar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      final response = await http.post(
        Uri.parse("http://20.251.169.101:5006/api/analisis-tension"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "edad": int.parse(_edadCtrl.text),
          "genero": _genero,
          "presion_sistolica": int.parse(_sistolicaCtrl.text),
          "presion_diastolica": int.parse(_diastolicaCtrl.text),
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _resultado = jsonDecode(response.body));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo analizar la presión."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al analizar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste,
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
              const CustomNavbar(),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.keppel,
                      AppColors.paynesGray,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.monitor_heart_outlined,
                            color: AppColors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Análisis de Presión Arterial",
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Evalúa tu presión y obtén recomendaciones",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Control Cardiovascular",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _resultado == null
                      ? _buildFormulario()
                      : _buildResultado(),
                ),
              ),

              CustomFooterNav(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.keppel.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.keppel.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.keppel,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ingresa tus datos para un análisis preciso",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.keppel,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _inputField(
                    "Edad",
                    _edadCtrl,
                    "Ingrese su edad",
                    Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 20),
                  _dropdownGenero(),
                  const SizedBox(height: 20),
                  _inputField(
                    "Presión Sistólica (Ej: 120)",
                    _sistolicaCtrl,
                    "Ingrese presión sistólica",
                    Icons.favorite_border,
                  ),
                  const SizedBox(height: 20),
                  _inputField(
                    "Presión Diastólica (Ej: 80)",
                    _diastolicaCtrl,
                    "Ingrese presión diastólica",
                    Icons.favorite_border,
                  ),
                  const SizedBox(height: 28),
                  _cargando
                      ? Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.aquamarine,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Analizando tu presión...",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray,
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.monitor_heart_outlined,
                              size: 20,
                            ),
                            onPressed: _analizar,
                            label: Text(
                              "Analizar Presión Arterial",
                              style: AppTextStyles.button,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.aquamarine,
                              foregroundColor: AppColors.paynesGray,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  30,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    String validatorMsg,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(
          color: AppColors.paynesGray.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.paynesGray,
          size: 20,
        ),
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
      keyboardType: TextInputType.number,
      validator: (v) => v!.isEmpty ? validatorMsg : null,
    );
  }

  Widget _dropdownGenero() {
    return DropdownButtonFormField<String>(
      value: _genero,
      style: AppTextStyles.body,
      items: const [
        DropdownMenuItem(value: "hombre", child: Text("Hombre")),
        DropdownMenuItem(value: "mujer", child: Text("Mujer")),
      ],
      onChanged: (v) => setState(() => _genero = v!),
      decoration: InputDecoration(
        labelText: "Género",
        labelStyle: AppTextStyles.body.copyWith(
          color: AppColors.paynesGray.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          Icons.person_outline,
          color: AppColors.paynesGray,
          size: 20,
        ),
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
    );
  }

  Widget _buildResultado() {
    final data = _resultado!['data'];
    final colorNivel = _getColorByNivel(data['clasificacion']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorNivel.withOpacity(0.9), colorNivel],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorNivel.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconByNivel(data['clasificacion']),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data['clasificacion'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildResultInfo(
                  "📊 Presión",
                  "${data['valores']['sistolica']} / ${data['valores']['diastolica']}",
                ),
                _buildResultInfo("👤 Edad", "${data['valores']['edad']} años"),
                _buildResultInfo(
                  "⚧ Género",
                  data['valores']['genero'] == "hombre" ? "Hombre" : "Mujer",
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white),
            ),
            child: Column(
              children: [
                Text(
                  "Opciones de Tratamiento",
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  "💊 Ver Medicamentos",
                  Icons.medical_services_outlined,
                  AppColors.aquamarine,
                  AppColors.paynesGray,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicamentosPage(
                        medicamentos: data['informacion_medicamentos'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  "🌿 Ver Remedios Caseros",
                  Icons.spa_outlined,
                  AppColors.keppel,
                  AppColors.white,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RemediosPage(remedios: data['remedios_caseros']),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.keppel.withOpacity(0.5)),
                const SizedBox(height: 8),
                _buildActionButton(
                  "🔄 Realizar Nuevo Análisis",
                  Icons.refresh,
                  AppColors.paynesGray,
                  AppColors.white,
                  () => setState(() => _resultado = null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String texto,
    IconData icono,
    Color backgroundColor,
    Color foregroundColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono, size: 20),
        label: const Text(
          "Ver Remedios Caseros",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          alignment: Alignment.centerLeft,
        ),
        
      ),
    );
  }

  Color _getColorByNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case "normal":
        return Colors.green;
      case "alta":
      case "hipertensión leve":
        return Colors.orange;
      case "hipertensión grave":
        return Colors.red;
      default:
        return AppColors.paynesGray;
    }
  }

  IconData _getIconByNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case "normal":
        return Icons.check_circle;
      case "alta":
      case "hipertensión leve":
        return Icons.warning;
      case "hipertensión grave":
        return Icons.error;
      default:
        return Icons.monitor_heart;
    }
  }
}