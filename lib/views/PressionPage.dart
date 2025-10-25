import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Medicamentos.dart';
import 'Remedios.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

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
          const SnackBar(content: Text("No se pudo analizar la presión.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al analizar: $e")),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFE),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Navbar
            const CustomNavbar(),

            // 🔹 Header elegante
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF006D73),
                    const Color(0xFF00A5A5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
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
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monitor_heart,
                          color: Colors.white,
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Evalúa tu presión y obtén recomendaciones médicas",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Control Cardiovascular",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Contenido principal
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _resultado == null
                    ? _buildFormulario()
                    : _buildResultado(),
              ),
            ),

            // 🔹 Footer
            CustomFooterNav(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ],
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
            // 🔹 Tarjeta informativa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ingresa tus datos para un análisis preciso de tu presión arterial",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Formulario
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF006D73).withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _inputField(
                        "Edad",
                        _edadCtrl,
                        "Ingrese su edad",
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 20),
                      _dropdownGenero(),
                      const SizedBox(height: 20),
                      _inputField(
                        "Presión Sistólica",
                        _sistolicaCtrl,
                        "Ingrese presión sistólica (Ej: 120)",
                        Icons.favorite,
                      ),
                      const SizedBox(height: 20),
                      _inputField(
                        "Presión Diastólica",
                        _diastolicaCtrl,
                        "Ingrese presión diastólica (Ej: 80)",
                        Icons.favorite_border,
                      ),
                      const SizedBox(height: 28),
                      _cargando
                          ? const Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006D73)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Analizando tu presión...",
                            style: TextStyle(
                              color: Color(0xFF006D73),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.monitor_heart_outlined, size: 20),
                          onPressed: _analizar,
                          label: const Text(
                            "Analizar Presión Arterial",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006D73),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF006D73)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006D73), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.number,
      validator: (v) => v!.isEmpty ? validatorMsg : null,
    );
  }

  Widget _dropdownGenero() {
    return DropdownButtonFormField<String>(
      value: _genero,
      items: const [
        DropdownMenuItem(
          value: "hombre",
          child: Text("Hombre"),
        ),
        DropdownMenuItem(
          value: "mujer",
          child: Text("Mujer"),
        ),
      ],
      onChanged: (v) => setState(() => _genero = v!),
      decoration: InputDecoration(
        labelText: "Género",
        prefixIcon: const Icon(Icons.person, color: Color(0xFF006D73)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006D73), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
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
          // 🔹 Tarjeta de resultado principal
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
                _buildResultInfo("📊 Presión", "${data['valores']['sistolica']} / ${data['valores']['diastolica']}"),
                _buildResultInfo("👤 Edad", "${data['valores']['edad']} años"),
                _buildResultInfo("⚧ Género", data['valores']['genero'] == "hombre" ? "Hombre" : "Mujer"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🔹 Tarjeta de acciones
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Column(
              children: [
                Text(
                  "Opciones de Tratamiento",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006D73),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  "💊 Ver Medicamentos Recomendados",
                  Icons.medical_services,
                  const Color(0xFF006D73),
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicamentosPage(medicamentos: data['informacion_medicamentos']),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  "🌿 Ver Remedios Caseros",
                  Icons.spa,
                  Colors.green,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RemediosPage(remedios: data['remedios_caseros']),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 8),
                _buildActionButton(
                  "🔄 Realizar Nuevo Análisis",
                  Icons.refresh,
                  Colors.blueGrey,
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
      Color color,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono, size: 20),
        label: Text(
          texto,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          elevation: 3,
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
        return const Color(0xFF006D73);
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