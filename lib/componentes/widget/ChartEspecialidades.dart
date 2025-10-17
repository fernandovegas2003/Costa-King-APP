import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartEspecialidades extends StatelessWidget {
  final List<dynamic> rankingEspecialidades;

  const ChartEspecialidades({super.key, required this.rankingEspecialidades});

  @override
  Widget build(BuildContext context) {
    final top = rankingEspecialidades.take(5).toList();
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: top.map((e) {
            final total =
                double.tryParse(e["total_citas"].toString()) ?? 0.0;
            return PieChartSectionData(
              value: total,
              title: e["nombreEspecialidad"],
              color: Colors.primaries[top.indexOf(e) % Colors.primaries.length],
              radius: 60,
              titleStyle:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            );
          }).toList(),
        ),
      ),
    );
  }
}
