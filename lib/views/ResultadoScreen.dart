import 'dart:convert';
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
    fontSize: 15,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class ResultadoScreen extends StatelessWidget {
  final Map<String, dynamic> resultado;
  const ResultadoScreen({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final data = resultado["data"] ?? {};

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
        title: const Text(
          "Resultados del Análisis",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard("Datos Básicos", [
                "Nombre: ${data["datos_basicos"]?["nombre"] ?? ''}",
                "Edad: ${data["datos_basicos"]?["edad"] ?? ''}",
                "Género: ${data["datos_basicos"]?["genero"] ?? ''}",
                "Altura: ${data["datos_basicos"]?["altura"] ?? ''} m",
                "Peso actual: ${data["datos_basicos"]?["peso_actual"] ?? ''} kg",
                "Peso objetivo: ${data["datos_basicos"]?["peso_objetivo"] ?? ''} kg",
                "Tipo de sangre: ${data["datos_basicos"]?["tipo_sangre"] ?? ''}",
                "Presión arterial: ${data["datos_basicos"]?["presion_arterial"]?["sistolica"]}/${data["datos_basicos"]?["presion_arterial"]?["diastolica"]} mmHg",
              ]),

              _buildCard("Análisis IMC", [
                "Clasificación: ${data["analisis_imc"]?["clasificacion"] ?? ''}",
                "IMC actual: ${data["analisis_imc"]?["imc_actual"] ?? ''}",
                "IMC objetivo: ${data["analisis_imc"]?["imc_objetivo"] ?? ''}",
                "Rango ideal: ${(data["analisis_imc"]?["rango_ideal"] ?? []).join(' - ')}",
                "Riesgo: ${data["analisis_imc"]?["riesgo"] ?? ''}",
                "Recomendaciones:",
                ...List<String>.from(
                  data["analisis_imc"]?["recomendaciones"] ?? [],
                ).map((e) => "• $e"),
              ]),

              _buildCard("Seguros", [
                "Primas estimadas:",
                "  Vida: ${data["analisis_seguros"]?["primas_estimadas"]?["vida"]}",
                "  Salud: ${data["analisis_seguros"]?["primas_estimadas"]?["salud_complementario"]}",
                "  Funerario: ${data["analisis_seguros"]?["primas_estimadas"]?["funerario"]}",
                "  Terreno: ${data["analisis_seguros"]?["primas_estimadas"]?["terreno"]}",
                "  Total mensual: ${data["analisis_seguros"]?["primas_estimadas"]?["total_mensual"]}",
                "Nivel de riesgo: ${data["analisis_seguros"]?["riesgo"]?["nivel"]}",
              ]),

              _buildCard("Edad Biológica", [
                "Edad biológica: ${data["edad_biologica"]?["edad_biologica"] ?? ''}",
                "Esperanza de vida actual: ${data["esperanza_vida"]?["esperanza_actual"] ?? ''} años",
              ]),

              _buildCard("Plan de Acción", [
                "Objetivos clave:",
                ...List<String>.from(
                  data["plan_accion"]?["objetivos_clave"] ?? [],
                ).map((e) => "• $e"),
                "Próximos pasos:",
                ...List<String>.from(
                  data["plan_accion"]?["proximos_pasos"] ?? [],
                ).map((e) => "• $e"),
                "Recomendaciones específicas:",
                ...List<String>.from(
                  data["plan_accion"]?["recomendaciones_especificas"] ?? [],
                ).map((e) => "• $e"),
              ]),

              _buildCard("Plan de Ejercicio", [
                "Nivel inicial: ${data["plan_ejercicio"]?["nivel_inicial"] ?? ''}",
                "Fases de entrenamiento:",
                ...data["plan_ejercicio"]?["fases"]?.entries
                        .map(
                          (fase) =>
                              "  ${fase.key}: Intensidad ${fase.value["intensidad"]}, Duración ${fase.value["duracion"]} min",
                        )
                        .toList() ??
                    [],
              ]),

              _buildCard("Plan Nutricional", [
                "Objetivo calorías: ${data["plan_nutricional"]?["objetivo_calorias"] ?? ''}",
                "Macronutrientes:",
                "  Carbohidratos: ${data["plan_nutricional"]?["macros"]?["carbohidratos"]} g",
                "  Proteína: ${data["plan_nutricional"]?["macros"]?["proteina"]} g",
                "  Grasas: ${data["plan_nutricional"]?["macros"]?["grasas"]} g",
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<String> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle),
          Divider(
            color: AppColors.keppel.withOpacity(0.5),
            height: 20,
            thickness: 1,
          ),
          ...items.map((item) {
            bool isIndented = item.trim().startsWith(' ');
            bool isHeader = item.endsWith(':');

            TextStyle style = AppTextStyles.body;
            EdgeInsets padding = const EdgeInsets.only(bottom: 6);

            if (isIndented) {
              style = AppTextStyles.body.copyWith(
                color: AppColors.paynesGray.withOpacity(0.9),
              );
              padding = const EdgeInsets.only(left: 16.0, bottom: 6.0);
            }

            if (isHeader) {
              style = AppTextStyles.body.copyWith(fontWeight: FontWeight.bold);
              padding = const EdgeInsets.only(bottom: 4, top: 8);
            }

            return Padding(
              padding: padding,
              child: Text(item.trim(), style: style),
            );
          }),
        ],
      ),
    );
  }
}