import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/widget/appScalfod.dart';

class DiagnosticoAlternativaPage extends StatefulWidget {
  final List<String> sintomas; // ✅ lista de síntomas
  final int duracionDias;
  const DiagnosticoAlternativaPage({
    super.key,
    required this.sintomas,
    required this.duracionDias,
  });

  @override
  State<DiagnosticoAlternativaPage> createState() =>
      _DiagnosticoAlternativaPageState();
}

class _DiagnosticoAlternativaPageState
    extends State<DiagnosticoAlternativaPage> {
  Map<String, dynamic>? diagnostico;
  bool cargando = false;
  bool mostrarContenido = false;

  @override
  void initState() {
    super.initState();
    _mostrarAdvertenciaInicial();
  }

  /// 🔹 Mostrar advertencia médica antes de iniciar
  void _mostrarAdvertenciaInicial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFDAA520)),
              SizedBox(width: 8),
              Text(
                "Aviso Importante",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Este diagnóstico es orientativo y no sustituye la valoración médica profesional. "
            "Si los síntomas persisten o empeoran, consulta a un especialista.",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D73),
              ),
              onPressed: () {
                Navigator.pop(context);
                _consultarDiagnostico();
              },
              child: const Text("Entendido"),
            ),
          ],
        ),
      );
    });
  }

  /// 🔹 Consulta el diagnóstico con la API
  Future<void> _consultarDiagnostico() async {
    setState(() {
      cargando = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://20.251.169.101:5007/api/medicina-alternativa"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sintomas": widget.sintomas,
          "duracion_dias": widget.duracionDias,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["data"] != null) {
          setState(() {
            diagnostico = data["data"];
            mostrarContenido = true;
          });
        }
      } else {
        throw Exception("Error HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error en diagnóstico: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al consultar el diagnóstico: $e")),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Diagnóstico Alternativo",
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00A5A5)),
            )
          : !mostrarContenido
          ? const Center(
              child: Text(
                "Preparando diagnóstico...",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdvertencias(),
                  const SizedBox(height: 20),
                  _buildEvaluacionInicial(),
                  const SizedBox(height: 20),
                  _buildRemediosPrincipales(),
                  const SizedBox(height: 20),
                  _buildRecomendacionesGenerales(),
                  const SizedBox(height: 20),
                  _buildSeguimiento(),
                ],
              ),
            ),
    );
  }

  /// 🔹 Bloque de advertencias importantes
  Widget _buildAdvertencias() {
    final advertencias = List<String>.from(
      diagnostico?["advertencias_importantes"] ?? [],
    );
    return Card(
      color: const Color(0xFFFFF3CD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ Advertencias Importantes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...advertencias.map((e) => Text("• $e")).toList(),
          ],
        ),
      ),
    );
  }

  /// 🔹 Bloque de evaluación inicial
  Widget _buildEvaluacionInicial() {
    final evaluacion = diagnostico?["evaluacion_inicial"] ?? {};
    final sintomas = List<String>.from(evaluacion["sintomas_analizados"] ?? []);
    final urgencia = evaluacion["urgencia_medica"] ?? {};
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🩺 Evaluación Inicial",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("Duración de síntomas: ${evaluacion["duracion_dias"]} días"),
            const SizedBox(height: 5),
            Text("Síntomas analizados: ${sintomas.join(", ")}"),
            const SizedBox(height: 5),
            Text(
              "Nivel de urgencia: ${urgencia["nivel"]?.toString().toUpperCase()}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (urgencia["mensaje"] != null)
              Text("Mensaje: ${urgencia["mensaje"]}"),
          ],
        ),
      ),
    );
  }

  /// 🔹 Remedios principales y complementarios
  Widget _buildRemediosPrincipales() {
    final plan = diagnostico?["plan_tratamiento"] ?? {};
    final principales = List<Map<String, dynamic>>.from(
      plan["remedios_principales"] ?? [],
    );
    final complementarios = List<Map<String, dynamic>>.from(
      plan["remedios_complementarios"] ?? [],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🌿 Remedios Naturales",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...principales
            .map((r) => _remedioCard(r, color: Colors.green[50]))
            .toList(),
        const SizedBox(height: 10),
        const Text(
          "💧 Remedios Complementarios",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ...complementarios
            .map((r) => _remedioCard(r, color: Colors.teal[50]))
            .toList(),
      ],
    );
  }

  Widget _remedioCard(Map<String, dynamic> r, {Color? color}) {
    return Card(
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r["nombre"] ?? "Remedio",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text("Efectividad: ${r["efectividad"] ?? 'N/A'}"),
            Text("Tiempo de efecto: ${r["tiempo_efecto"] ?? 'N/A'}"),
            const SizedBox(height: 5),
            Text(
              "Ingredientes:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...List<String>.from(
              r["ingredientes"] ?? [],
            ).map((i) => Text("- $i")),
            const SizedBox(height: 5),
            Text(
              "Preparación:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(r["preparacion"] ?? ""),
          ],
        ),
      ),
    );
  }

  /// 🔹 Recomendaciones generales
  Widget _buildRecomendacionesGenerales() {
    final rec = diagnostico?["recomendaciones_generales"] ?? {};
    final alimentos = List<String>.from(rec["alimentos_beneficiosos"] ?? []);
    final estilo = List<String>.from(rec["estilo_vida"] ?? []);
    final evitar = List<String>.from(rec["habitos_evitar"] ?? []);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🍎 Recomendaciones Generales",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "✅ Alimentos beneficiosos:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...alimentos.map((a) => Text("- $a")),
            const SizedBox(height: 8),
            const Text(
              "💪 Estilo de vida:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...estilo.map((e) => Text("- $e")),
            const SizedBox(height: 8),
            const Text(
              "🚫 Hábitos a evitar:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            ...evitar.map((e) => Text("- $e")),
          ],
        ),
      ),
    );
  }

  /// 🔹 Seguimiento
  Widget _buildSeguimiento() {
    final seg = diagnostico?["seguimiento"] ?? {};
    final cuando = List<String>.from(seg["cuando_buscar_ayuda"] ?? []);
    final indicadores = List<String>.from(seg["indicadores_mejoria"] ?? []);
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📅 Seguimiento y Evaluación",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Duración sugerida: ${seg["duracion_tratamiento_sugerida"] ?? 'N/A'}",
            ),
            Text(
              "Frecuencia evaluación: ${seg["frecuencia_evaluacion"] ?? 'N/A'}",
            ),
            const SizedBox(height: 8),
            const Text(
              "🚨 Cuándo buscar ayuda:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...cuando.map((c) => Text("- $c")),
            const SizedBox(height: 8),
            const Text(
              "📈 Indicadores de mejoría:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...indicadores.map((i) => Text("- $i")),
          ],
        ),
      ),
    );
  }
}
