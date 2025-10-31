import 'package:flutter/material.dart'; 
import '../widget/appScalfod.dart'; 
import 'DashboardService.dart';
import '../widget/StatsCard.dart';
import '../widget/ChartCitasMes.dart';
import '../widget/ChartEspecialidades.dart';
import '../widget/ChartIngresosSedes.dart';


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
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel, // 🎨 Color
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray, // 🎨 Color
    fontSize: 14,
    fontFamily: _fontFamily,
  );
}

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
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white), 
        boxShadow: [
          BoxShadow(
            color: AppColors.paynesGray.withOpacity(0.1), 
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
          if (snapshot.connectionState == ConnectionState.waiting) {
           
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.aquamarine,
                  ), // 🎨 Color
                  SizedBox(height: 16),
                  Text(
                    "Cargando Dashboard...",
                    style: AppTextStyles.body,
                  ), // 🎨 Estilo
                ],
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
          
            return Center(
              child: Text(
                "Error al cargar el dashboard: ${snapshot.error}",
                style: AppTextStyles.body.copyWith(
                  color: Colors.red[700],
                ), 
              ),
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
              const SizedBox(height: 12), 
          
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ), 
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.5), 
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.keppel,
                  unselectedLabelColor: AppColors.paynesGray.withOpacity(
                    0.7,
                  ), 
                  indicatorColor: AppColors.keppel, 
                  indicatorWeight: 3,
                  labelStyle: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ), 
                  unselectedLabelStyle: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
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
                          icon: Icons.people_outline,
                        ),
                        StatsCard(
                          title: "Pacientes",
                          value: "${general["total_pacientes"]}",
                          icon: Icons.personal_injury_outlined,
                        ),
                        StatsCard(
                          title: "Médicos activos",
                          value: "${general["total_medicos_activos"]}",
                          icon: Icons.local_hospital_outlined,
                        ),
                        StatsCard(
                          title: "Ingresos del mes",
                          value: "\$${general["ingresos_mes_actual"]}",
                          icon: Icons.attach_money_outlined,
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
                              Text(
                                "Citas por Mes",
                                style: AppTextStyles.cardTitle,
                              ), 
                              const SizedBox(height: 10),
                              ChartCitasMes(citasPorMes: citasPorMes),
                            ],
                          ),
                        ),
                        _whiteCard(
                         
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ranking de especialidades",
                                style: AppTextStyles.cardTitle, // 
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
                              Text(
                                "Ingresos por sede (en miles)",
                                style: AppTextStyles.cardTitle, 
                              ),
                              const SizedBox(height: 10),
                              ChartIngresosSedes(
                                ingresosSedeEspecialidad: ingresos,
                              ),
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
                            color: AppColors.white.withOpacity(0.7), // 
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.white,
                            ), // 
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Icon(
                              Icons.person_outline,
                              color: AppColors.keppel, //
                            ),
                            title: Text(
                              m["nombre_completo"],
                              style: AppTextStyles.cardDescription.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ), // 
                            subtitle: Text(
                              "Especialidad: ${m["nombreEspecialidad"]}",
                              style: AppTextStyles.cardDescription.copyWith(
                                color: AppColors.paynesGray.withOpacity(0.8),
                              ), // 
                            ),
                            trailing: Text(
                              "Tasa: ${m["tasa_completacion"] ?? 0}%",
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 14,
                              ), //
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
