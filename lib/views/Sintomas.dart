import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';
import 'DiagnosticoSintoma.dart';

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
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class SintomasPage extends StatefulWidget {
  const SintomasPage({super.key});

  @override
  State<SintomasPage> createState() => _SintomasPageState();
}

class _SintomasPageState extends State<SintomasPage> {
  Map<String, dynamic>? sintomas;
  String? sintomaSeleccionado;
  bool cargando = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _cargarSintomas();
  }

  Future<void> _cargarSintomas() async {
    try {
      final response = await http.get(
        Uri.parse("http://20.251.169.101:5002/sintomas"),
      );
      if (response.statusCode == 200) {
        setState(() {
          sintomas = jsonDecode(response.body)["sintomas_por_categoria"];
          cargando = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando síntomas: $e");
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

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Selección de Síntomas",
                  style: AppTextStyles.headline,
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
                              "Cargando síntomas...",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Card(
                              color: AppColors.keppel.withOpacity(
                                0.1,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.keppel.withOpacity(0.3),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppColors.keppel,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Selecciona un síntoma para obtener un diagnóstico",
                                        style: AppTextStyles.body.copyWith(
                                          fontSize: 14,
                                          color: AppColors.keppel,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              children: [
                                ...sintomas!.entries.map((entry) {
                                  return Card(
                                    color: AppColors.white.withOpacity(
                                      0.7,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 2,
                                    child: ExpansionTile(
                                      leading: Icon(
                                        Icons.medical_services_outlined,
                                        color: AppColors.keppel,
                                      ),
                                      title: Text(
                                        entry.key.toUpperCase(),
                                        style: AppTextStyles
                                            .cardTitle,
                                      ),
                                      iconColor: AppColors.keppel,
                                      collapsedIconColor:
                                          AppColors.keppel,
                                      children: entry.value.map<Widget>((s) {
                                        return RadioListTile<String>(
                                          title: Text(
                                            s,
                                            style: AppTextStyles.body.copyWith(
                                              fontSize: 14,
                                            ),
                                          ),
                                          value: s,
                                          groupValue: sintomaSeleccionado,
                                          onChanged: (val) {
                                            setState(
                                              () => sintomaSeleccionado = val,
                                            );
                                          },
                                          activeColor:
                                              AppColors.keppel,
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }).toList(),

                                const SizedBox(height: 20),

                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          sintomaSeleccionado == null
                                              ? AppColors.paynesGray.withOpacity(
                                                  0.3,
                                                )
                                              : AppColors
                                                    .aquamarine,
                                      foregroundColor:
                                          AppColors.paynesGray,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      elevation: 3,
                                    ),
                                    onPressed: sintomaSeleccionado == null
                                        ? null
                                        : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      DiagnosticoSintomaPage(
                                                        sintoma:
                                                            sintomaSeleccionado!,
                                                      ),
                                                ),
                                              );
                                          },
                                    child: Text(
                                      sintomaSeleccionado == null
                                          ? "Selecciona un síntoma"
                                          : "Consultar diagnóstico",
                                      style: AppTextStyles.button,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
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
}