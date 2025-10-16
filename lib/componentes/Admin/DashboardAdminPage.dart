import 'package:flutter/material.dart';
import '../widget/appScalfod.dart';
import 'DashboardService.dart';
import '../widget/StatsCard.dart';
import '../widget/ChartCitasMes.dart';
import '../widget/ChartEspecialidades.dart';
import '../widget/ChartIngresosSedes.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> dashboardFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    dashboardFuture = DashboardService.fetchDashboard();
    _tabController = TabController(length: 4, vsync: this);
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Dashboard Administrativo",
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00A5A5)),
            );
          }

          final data = snapshot.data!;
          final general = data["estadisticasGenerales"][0];
          final citasPorMes = data["citasPorMes"];
          final especialidades = data["rankingEspecialidades"];
          final ingresos = data["ingresosSedeEspecialidad"];
          final medicos = data["rankingMedicos"];

          return Column(
            children: [
              const SizedBox(height: 12), // 🔹 separa el Tab del header
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                    16,
                  ), // ← 🔹 Borde redondeado
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF00A5A5),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF00A5A5),
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: "General"),
                    Tab(text: "Citas"),
                    Tab(text: "Finanzas"),
                    Tab(text: "Médicos"),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 🔹 TAB 1: GENERAL
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        StatsCard(
                          title: "Usuarios activos",
                          value: "${general["total_usuarios_activos"]}",
                          icon: Icons.people,
                        ),
                        StatsCard(
                          title: "Pacientes",
                          value: "${general["total_pacientes"]}",
                          icon: Icons.personal_injury,
                        ),
                        StatsCard(
                          title: "Médicos activos",
                          value: "${general["total_medicos_activos"]}",
                          icon: Icons.local_hospital,
                        ),
                        StatsCard(
                          title: "Ingresos del mes",
                          value: "\$${general["ingresos_mes_actual"]}",
                          icon: Icons.attach_money,
                        ),
                      ],
                    ),

                    // 🔹 TAB 2: CITAS
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _whiteCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              ChartCitasMes(citasPorMes: citasPorMes),
                            ],
                          ),
                        ),
                        _whiteCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ranking de especialidades",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ChartEspecialidades(
                                rankingEspecialidades: especialidades,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 🔹 TAB 3: FINANZAS
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _whiteCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ingresos por sede (en miles)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ChartIngresosSedes( ingresosSedeEspecialidad: ingresos,),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 🔹 TAB 4: MÉDICOS
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: medicos.length,
                      itemBuilder: (context, i) {
                        final m = medicos[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Color(0xFF00A5A5),
                            ),
                            title: Text(m["nombre_completo"]),
                            subtitle: Text(
                              "Especialidad: ${m["nombreEspecialidad"]}",
                            ),
                            trailing: Text(
                              "Tasa: ${m["tasa_completacion"] ?? 0}%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
