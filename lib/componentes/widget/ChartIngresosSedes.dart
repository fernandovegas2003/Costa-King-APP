import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ChartIngresosSedes extends StatelessWidget {
  final List<dynamic> ingresosSedeEspecialidad;

  const ChartIngresosSedes({super.key, required this.ingresosSedeEspecialidad});

  @override
  Widget build(BuildContext context) {
    if (ingresosSedeEspecialidad.isEmpty) {
      return const Center(child: Text("No hay datos disponibles"));
    }

 
    final Map<String, List<Map<String, dynamic>>> especialidadesMap = {};
    for (var item in ingresosSedeEspecialidad) {
      final especialidad = item["nombreEspecialidad"] ?? "Sin especialidad";
      especialidadesMap.putIfAbsent(especialidad, () => []);
      especialidadesMap[especialidad]!.add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: especialidadesMap.entries.map((entry) {
        final especialidad = entry.key;
        final data = entry.value;

        final Map<String, double> ingresosPorSede = {};
        for (var e in data) {
          final sede = e["nombreSede"] ?? "Desconocida";
          final total = double.tryParse(e["total_ingresos"].toString()) ?? 0;
          ingresosPorSede[sede] = (ingresosPorSede[sede] ?? 0) + total;
        }

        final sedes = ingresosPorSede.keys.toList();
        final valores = ingresosPorSede.values.toList();

        final maxY = valores.isEmpty
            ? 10.0
            : valores.reduce(max) / 1000; 

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
     
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  especialidad,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF006D73),
                  ),
                ),
              ),

              SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(enabled: false),
                    gridData: FlGridData(show: true, horizontalInterval: 50),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 50,
                          getTitlesWidget: (value, meta) => Text(
                            "${value.toInt()}k",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < sedes.length) {
                              final sede = sedes[value.toInt()]
                                  .replaceAll("BlessHealth24/7 ", "");
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  sede,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    maxY: maxY + 50,
                    barGroups: List.generate(sedes.length, (i) {
                      final ingreso = valores[i] / 1000; // es
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: ingreso,
                            color: const Color(0xFF00A5A5),
                            width: 20,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }),
                  ),
                  swapAnimationDuration: Duration.zero,
                ),
              ),

              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: List.generate(sedes.length, (i) {
                  final sede = sedes[i].replaceAll("BlessHealth24/7 ", "");
                  final miles = (valores[i] / 1000).toStringAsFixed(1);
                  return Text(
                    "$sede: $miles",
                    style: const TextStyle(fontSize: 12),
                  );
                }),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
