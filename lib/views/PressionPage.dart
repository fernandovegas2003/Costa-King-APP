import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/widget/appScalfod.dart';
import  'Medicamentos.dart';
import 'Remedios.dart';

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
        setState(() {
          _resultado = jsonDecode(response.body);
        });
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
    return AppScaffold(
      title: "Análisis de Presión",
      body: _resultado == null ? _buildFormulario() : _buildResultado(),
    );
  }

  Widget _buildFormulario() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _edadCtrl,
                  decoration: const InputDecoration(labelText: "Edad"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Ingrese la edad" : null,
                ),
                DropdownButtonFormField<String>(
                  value: _genero,
                  items: const [
                    DropdownMenuItem(value: "hombre", child: Text("Hombre")),
                    DropdownMenuItem(value: "mujer", child: Text("Mujer")),
                  ],
                  onChanged: (v) => setState(() => _genero = v!),
                  decoration: const InputDecoration(labelText: "Género"),
                ),
                TextFormField(
                  controller: _sistolicaCtrl,
                  decoration: const InputDecoration(labelText: "Presión Sistólica"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _diastolicaCtrl,
                  decoration: const InputDecoration(labelText: "Presión Diastólica"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _cargando
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006D73),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _analizar,
                        child: const Text("Analizar", style: const TextStyle(
                          fontWeight: FontWeight.bold,color: Colors.white)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultado() {
    final data = _resultado!['data'];
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Clasificación: ${data['clasificacion']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                  Text("Valores: ${data['valores']['sistolica']} / ${data['valores']['diastolica']}"),
                  Text("Edad: ${data['valores']['edad']} - Género: ${data['valores']['genero']}"),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicamentosPage(medicamentos: data['informacion_medicamentos']),
              ),
            ),
            icon: const Icon(Icons.medical_services),
            label: const Text("Ver Medicamentos"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RemediosPage(remedios: data['remedios_caseros']),
              ),
            ),
            icon: const Icon(Icons.spa),
            label: const Text("Ver Remedios Caseros"),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => setState(() => _resultado = null),
            icon: const Icon(Icons.refresh),
            label: const Text("Nuevo análisis"),
          ),
        ],
      ),
    );
  }
}
