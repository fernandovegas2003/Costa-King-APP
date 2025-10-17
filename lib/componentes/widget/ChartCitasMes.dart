import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ChartCitasMes extends StatefulWidget {
  final List<dynamic> citasPorMes;

  const ChartCitasMes({super.key, required this.citasPorMes});

  @override
  State<ChartCitasMes> createState() => _ChartCitasMesState();
}

class _ChartCitasMesState extends State<ChartCitasMes> {
  late List<int> anios;
  int anioSeleccionado = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    anios = widget.citasPorMes
        .map((e) => int.tryParse(e["mes"].toString().split("-")[0]) ?? 0)
        .toSet()
        .toList()
      ..sort();
    anioSeleccionado = anios.last;
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Filtrar por año
    final data = widget.citasPorMes
        .where((e) => e["mes"].toString().startsWith(anioSeleccionado.toString()))
        .toList()
      ..sort((a, b) => a["mes"].compareTo(b["mes"]));

    final maxY = data.isEmpty
        ? 10.0
        : data.map((e) => int.parse(e["total_citas"].toString())).reduce(max).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Fila con título y selector de año
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Citas por mes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              DropdownButton<int>(
                value: anioSeleccionado,
                underline: const SizedBox(),
                items: anios
                    .map((a) => DropdownMenuItem(value: a, child: Text("$a")))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => anioSeleccionado = val);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 🔹 Contenedor principal (card única)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            
          ),
          child: SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(show: true, horizontalInterval: 2),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final mes = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            mes.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                maxY: maxY + 2,
                barGroups: List.generate(data.length, (i) {
                  final total = int.parse(data[i]["total_citas"].toString());
                  final mes = int.parse(data[i]["mes"].toString().split("-")[1]);
                  return BarChartGroupData(
                    x: mes,
                    barRods: [
                      BarChartRodData(
                        toY: total.toDouble(),
                        color: const Color(0xFF00A5A5),
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  );
                }),
              ),
              swapAnimationDuration: Duration.zero, // 👈 Evita lag y freezing
            ),
          ),
        ),

        // 🔹 Etiquetas de valores sobre cada barra
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: data.map((e) {
            final mes = e["mes"].toString().split("-")[1];
            final total = e["total_citas"];
            return Text("$mes: $total", style: const TextStyle(fontSize: 12));
          }).toList(),
        ),
      ],
    );
  }
}
