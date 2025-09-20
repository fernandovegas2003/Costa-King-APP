import 'package:flutter/material.dart';
import '../componentes/widget/appScalfod.dart';

class RemediosPage extends StatelessWidget {
  final Map<String, dynamic> remedios;

  const RemediosPage({super.key, required this.remedios});

  @override
  Widget build(BuildContext context) {
    final List lista = remedios['remedios'] ?? [];

    return AppScaffold(
      title: "Remedios Caseros",
      body: ListView(
        children: [
          Card(
            color: Colors.yellow[50],
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                remedios['advertencia'] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...lista.map((item) => ExpansionTile(
                title: Text(item['nombre']),
                subtitle: Text(item['evidencia'] ?? ""),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cómo usar: ${item['como_usar']}"),
                        Text("Dosis recomendada: ${item['dosis_recomendada']}"),
                        Text("Mecanismo: ${item['mecanismo']}"),
                        Text("Precauciones: ${item['precauciones']}"),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
