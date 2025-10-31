import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    height: 1.4,
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

class DiagnosticoAlternativaPage extends StatefulWidget {
  final List<String> sintomas;
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
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _mostrarAdvertenciaInicial();
  }

  void _mostrarAdvertenciaInicial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[800],
              ),
              const SizedBox(width: 8),
              Text(
                "Aviso Importante",
                style: AppTextStyles.headline.copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            "Este diagnóstico es orientativo y no sustituye la valoración médica profesional. "
            "Si los síntomas persisten o empeoran, consulta a un especialista.",
            style: AppTextStyles.body.copyWith(fontSize: 15),
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
                backgroundColor: AppColors.aquamarine,
                foregroundColor: AppColors.paynesGray,
              ),
              onPressed: () {
                Navigator.pop(context);
                _consultarDiagnostico();
              },
              child: const Text(
                "Entendido",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    });
  }

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
        SnackBar(
          content: Text("Error al consultar el diagnóstico: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => cargando = false);
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
                            Icons.eco,
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
                                "Diagnóstico Natural",
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Remedios basados en medicina alternativa",
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
                        "Medicina Tradicional y Natural",
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

              if (mostrarContenido && diagnostico != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.keppel.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: AppColors.keppel,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Análisis completado",
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.keppel,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${widget.sintomas.length} síntomas • ${widget.duracionDias} días",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.keppel,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: cargando
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.aquamarine,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Analizando tus síntomas...",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : !mostrarContenido
                    ? Center(
                        child: Text(
                          "Preparando diagnóstico...",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.paynesGray.withOpacity(0.7),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
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
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),

              CustomFooterNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvertencias() {
    final advertencias = List<String>.from(
      diagnostico?["advertencias_importantes"] ?? [],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEF3C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[800],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Advertencias Importantes",
                style: AppTextStyles.headline.copyWith(
                  color: Colors.orange[800],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...advertencias
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 6, color: Colors.orange[800]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.orange[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Color _getUrgenciaColor(String? nivel) {
    switch (nivel?.toLowerCase()) {
      case 'alto':
        return Colors.red;
      case 'medio':
        return Colors.orange;
      case 'bajo':
        return AppColors.keppel;
      default:
        return AppColors.paynesGray;
    }
  }

  IconData _getUrgenciaIcon(String? nivel) {
    switch (nivel?.toLowerCase()) {
      case 'alto':
        return Icons.priority_high;
      case 'medio':
        return Icons.warning;
      case 'bajo':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Widget _buildEvaluacionInicial() {
    final evaluacion = diagnostico?["evaluacion_inicial"] ?? {};
    final sintomas = List<String>.from(evaluacion["sintomas_analizados"] ?? []);
    final urgencia = evaluacion["urgencia_medica"] ?? {};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: AppColors.keppel,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Evaluación Inicial",
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow("📅 Duración", "${evaluacion["duracion_dias"]} días"),
          const SizedBox(height: 8),
          _buildInfoRow("🔍 Síntomas", sintomas.join(", ")),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getUrgenciaColor(
                urgencia["nivel"]?.toString(),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _getUrgenciaIcon(urgencia["nivel"]?.toString()),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nivel de urgencia: ${urgencia["nivel"]?.toString().toUpperCase()}",
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                      if (urgencia["mensaje"] != null)
                        Text(
                          urgencia["mensaje"],
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.paynesGray.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.paynesGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemediosPrincipales() {
    final plan = diagnostico?["plan_tratamiento"] ?? {};
    final principales = List<Map<String, dynamic>>.from(
      plan["remedios_principales"] ?? [],
    );
    final complementarios = List<Map<String, dynamic>>.from(
      plan["remedios_complementarios"] ?? [],
    );

    return Column(
      children: [
        _buildSeccionTitulo(
          icon: Icons.eco,
          title: "Remedios Principales",
          subtitle: "Tratamientos naturales más efectivos",
        ),
        const SizedBox(height: 16),
        ...principales.map((r) => _buildRemedioCard(r, isPrincipal: true)),

        if (complementarios.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSeccionTitulo(
            icon: Icons.spa,
            title: "Remedios Complementarios",
            subtitle: "Apoyo adicional para tu tratamiento",
          ),
          const SizedBox(height: 16),
          ...complementarios.map(
            (r) => _buildRemedioCard(r, isPrincipal: false),
          ),
        ],
      ],
    );
  }

  Widget _buildSeccionTitulo({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.keppel, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.cardDescription.copyWith(
                    color: AppColors.paynesGray.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemedioCard(
    Map<String, dynamic> remedio, {
    bool isPrincipal = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isPrincipal
            ? AppColors.white.withOpacity(0.9)
            : AppColors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrincipal
              ? AppColors.keppel.withOpacity(0.3)
              : AppColors.iceBlue,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.keppel.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco,
                    color: AppColors.keppel,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    remedio["nombre"] ?? "Remedio Natural",
                    style: AppTextStyles.cardTitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  "🎯 ${remedio["efectividad"] ?? 'N/A'}",
                  AppColors.keppel,
                ),
                _buildInfoChip(
                  "⏱️ ${remedio["tiempo_efecto"] ?? 'N/A'}",
                  AppColors.paynesGray,
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildInfoSection(
              "🧪 Ingredientes",
              List<String>.from(remedio["ingredientes"] ?? []),
            ),
            const SizedBox(height: 12),
            _buildInfoSection("📝 Preparación", [
              remedio["preparacion"] ?? "",
            ], isSingle: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    List<String> items, {
    bool isSingle = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.keppel,
          ),
        ),
        const SizedBox(height: 6),
        if (isSingle)
          Text(
            items.first,
            style: AppTextStyles.body.copyWith(
              color: AppColors.paynesGray.withOpacity(0.8),
            ),
          )
        else
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• ",
                        style: TextStyle(
                          color: AppColors.paynesGray.withOpacity(0.8),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.paynesGray.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
      ],
    );
  }

  Widget _buildRecomendacionesGenerales() {
    final rec = diagnostico?["recomendaciones_generales"] ?? {};
    final alimentos = List<String>.from(rec["alimentos_beneficiosos"] ?? []);
    final estilo = List<String>.from(rec["estilo_vida"] ?? []);
    final evitar = List<String>.from(rec["habitos_evitar"] ?? []);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: AppColors.keppel,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Recomendaciones Generales",
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoriaRecomendacion(
            "🍎 Alimentos beneficiosos",
            Icons.restaurant,
            AppColors.keppel,
            alimentos,
          ),
          const SizedBox(height: 16),
          _buildCategoriaRecomendacion(
            "💪 Estilo de vida",
            Icons.fitness_center,
            AppColors.paynesGray,
            estilo,
          ),
          const SizedBox(height: 16),
          _buildCategoriaRecomendacion(
            "🚫 Hábitos a evitar",
            Icons.block,
            Colors.red,
            evitar,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaRecomendacion(
    String titulo,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 6, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.paynesGray.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildSeguimiento() {
    final seg = diagnostico?["seguimiento"] ?? {};
    final cuando = List<String>.from(seg["cuando_buscar_ayuda"] ?? []);
    final indicadores = List<String>.from(seg["indicadores_mejoria"] ?? []);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppColors.keppel,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Seguimiento y Evaluación",
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (seg["duracion_tratamiento_sugerida"] != null)
                _buildInfoChip(
                  "📅 ${seg["duracion_tratamiento_sugerida"]}",
                  AppColors.paynesGray,
                ),
              if (seg["frecuencia_evaluacion"] != null)
                _buildInfoChip(
                  "🔄 ${seg["frecuencia_evaluacion"]}",
                  AppColors.keppel,
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCategoriaRecomendacion(
            "🚨 Cuándo buscar ayuda",
            Icons.emergency,
            Colors.red,
            cuando,
          ),
          const SizedBox(height: 16),
          _buildCategoriaRecomendacion(
            "📈 Indicadores de mejoría",
            Icons.trending_up,
            AppColors.keppel,
            indicadores,
          ),
        ],
      ),
    );
  }
}