import 'package:flutter/material.dart';

class ResultadoScreen extends StatelessWidget {
  final Map<String, dynamic> resultado;
  const ResultadoScreen({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final data = resultado["data"] ?? {};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Resultados del Análisis",
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
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
              ...List<String>.from(data["analisis_imc"]?["recomendaciones"] ?? []),
            ]),

            _buildCard("Seguros", [
              "Primas estimadas:",
              "  Vida: ${data["analisis_seguros"]?["primas_estimadas"]?["vida"]}",
              "  Salud: ${data["analisis_seguros"]?["primas_estimadas"]?["salud_complementario"]}",
              "  Funerario: ${data["analisis_seguros"]?["primas_estimadas"]?["funerario"]}",
              "  Terreno: ${data["analisis_seguros"]?["primas_estimadas"]?["terreno"]}",
              "  Total mensual: ${data["analisis_seguros"]?["primas_estimadas"]?["total_mensual"]}",
              "Nivel de riesgo: ${data["analisis_seguros"]?["riesgo"]?["nivel"]}",
            ]),

            _buildCard("Edad Biológica", [
              "Edad biológica: ${data["edad_biologica"]?["edad_biologica"] ?? ''}",
              "Esperanza de vida actual: ${data["esperanza_vida"]?["esperanza_actual"] ?? ''} años",
            ]),

            _buildCard("Plan de Acción", [
              "Objetivos clave:",
              ...List<String>.from(data["plan_accion"]?["objetivos_clave"] ?? []),
              "Próximos pasos:",
              ...List<String>.from(data["plan_accion"]?["proximos_pasos"] ?? []),
              "Recomendaciones específicas:",
              ...List<String>.from(data["plan_accion"]?["recomendaciones_especificas"] ?? []),
            ]),

            _buildCard("Plan de Ejercicio", [
              "Nivel inicial: ${data["plan_ejercicio"]?["nivel_inicial"] ?? ''}",
              "Fases de entrenamiento:",
              ...data["plan_ejercicio"]?["fases"]?.entries.map((fase) =>
                  "${fase.key}: Intensidad ${fase.value["intensidad"]}, Duración ${fase.value["duracion"]} min").toList() ?? [],
            ]),

            _buildCard("Plan Nutricional", [
              "Objetivo calorías: ${data["plan_nutricional"]?["objetivo_calorias"] ?? ''}",
              "Macronutrientes:",
              "  Carbohidratos: ${data["plan_nutricional"]?["macros"]?["carbohidratos"]} g",
              "  Proteína: ${data["plan_nutricional"]?["macros"]?["proteina"]} g",
              "  Grasas: ${data["plan_nutricional"]?["macros"]?["grasas"]} g",
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 10),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(e, style: const TextStyle(fontSize: 15)),
                )),
          ],
        ),
      ),
    );
  }
}
