import 'package:flutter/material.dart';
import '../componentes/widget/appScalfod.dart';

class MedicamentosPage extends StatelessWidget {
  final Map<String, dynamic> medicamentos;

  const MedicamentosPage({super.key, required this.medicamentos});

  @override
  Widget build(BuildContext context) {
    final List comparativa = medicamentos['comparativa'] ?? [];
    final List recomendados = medicamentos['medicamentos_recomendados'] ?? [];

    return AppScaffold(
      title: "Medicamentos",
      body: ListView(
        children: [
          Card(
            color: Colors.red[50],
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                medicamentos['advertencia'] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...comparativa.map((item) => ExpansionTile(
                title: Text(item['clase']),
                subtitle: Text(item['comparacion']),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Efectos secundarios: ${item['efectos_secundarios']}"),
                        Text("Mecanismo: ${item['mecanismo']}"),
                      ],
                    ),
                  ),
                ],
              )),
          ...recomendados.map((item) {
            final ejemplos = (item['ejemplos'] as List?) ?? [];
            final combinaciones = (item['opciones_combinaciones'] as List?) ?? [];
            return Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['clase'] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (item['nota'] != null) Text(item['nota']),
                    const SizedBox(height: 8),
                    const Text("Opciones de combinaciones:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...combinaciones.map((c) => Text("• $c")),
                    const SizedBox(height: 8),
                    const Text("Ejemplos:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...ejemplos.map((e) => Text("• ${e['nombre']} - ${e['dosis']}")),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
