import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';
import 'DiagnosticoAlternativa.dart';

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
    fontSize: 20,
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
    color: AppColors.keppel,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 12,
    fontFamily: _fontFamily,
  );
}

class SintomasAlternativaPage extends StatefulWidget {
  const SintomasAlternativaPage({super.key});

  @override
  State<SintomasAlternativaPage> createState() =>
      _SintomasAlternativaPageState();
}

class _SintomasAlternativaPageState extends State<SintomasAlternativaPage> {
  Map<String, List<String>> sintomasPorCategoria = {};
  final Set<String> sintomasSeleccionados = {};
  bool cargando = true;
  double duracionDias = 1;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _cargarSintomas();
  }

  Future<void> _cargarSintomas() async {
    try {
      final response = await http.get(
        Uri.parse("http://20.251.169.101:5007/api/sintomas-disponibles"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sintomas = data["sintomas_disponibles"] as Map<String, dynamic>;

        final Map<String, List<String>> agrupados = {};
        sintomas.forEach((key, value) {
          final categoria = value["categoria"] ?? "General";
          final nombre = value["nombre"] ?? key;
          agrupados.putIfAbsent(categoria, () => []);
          agrupados[categoria]!.add(nombre);
        });

        setState(() {
          sintomasPorCategoria = agrupados;
          cargando = false;
        });
      } else {
        throw Exception("Error HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error cargando síntomas: $e");
      setState(() => cargando = false);
    }
  }

  void _mostrarAdvertencia() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[800],
            ),
            const SizedBox(width: 8),
            Text(
              "Aviso Médico",
              style: AppTextStyles.headline.copyWith(fontSize: 20),
            ),
          ],
        ),
        content: Text(
          "Los resultados son orientativos y no reemplazan una evaluación médica profesional.\n\n"
          "Si los síntomas persisten o empeoran, acude a consulta con un especialista.",
          style: AppTextStyles.body.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.paynesGray,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiagnosticoAlternativaPage(
                    sintomas: sintomasSeleccionados.toList(),
                    duracionDias: duracionDias.toInt(),
                  ),
                ),
              );
            },
            child: const Text(
              "Continuar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.keppel,
                      AppColors.paynesGray,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco_outlined,
                            color: AppColors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Medicina Alternativa",
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Diagnóstico con remedios naturales",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Selección Múltiple de Síntomas",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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
                              "Cargando síntomas disponibles...",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : sintomasPorCategoria.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 50,
                              color: AppColors.paynesGray.withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No se encontraron síntomas disponibles.",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDuracionCard(),
                            const SizedBox(height: 20),

                            _buildContadorSintomas(),
                            const SizedBox(height: 16),

                            ...sintomasPorCategoria.entries.map((entry) {
                              return _buildCategoriaCard(
                                entry.key,
                                entry.value,
                              );
                            }),
                            const SizedBox(height: 20),

                            _buildBotonDiagnostico(),
                          ],
                        ),
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

  Widget _buildDuracionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: AppColors.keppel,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Duración de los Síntomas",
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            min: 1,
            max: 14,
            divisions: 13,
            value: duracionDias,
            activeColor: AppColors.aquamarine,
            inactiveColor: AppColors.keppel.withOpacity(0.3),
            label: "${duracionDias.toInt()} días",
            onChanged: (val) {
              setState(() => duracionDias = val);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "1 día",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.paynesGray.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.keppel,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${duracionDias.toInt()} ${duracionDias.toInt() == 1 ? 'día' : 'días'} seleccionados",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                "14 días",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.paynesGray.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContadorSintomas() {
    bool isEmpty = sintomasSeleccionados.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmpty
            ? AppColors.white.withOpacity(0.3)
            : AppColors.iceBlue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEmpty
              ? AppColors.paynesGray.withOpacity(0.3)
              : AppColors.keppel,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Síntomas seleccionados",
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: isEmpty
                  ? AppColors.paynesGray.withOpacity(0.7)
                  : AppColors.keppel,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isEmpty
                  ? AppColors.paynesGray.withOpacity(0.7)
                  : AppColors.aquamarine,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${sintomasSeleccionados.length}",
              style: TextStyle(
                color: isEmpty
                    ? AppColors.white
                    : AppColors.paynesGray,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaCard(String categoria, List<String> sintomas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.keppel.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.medical_services_outlined,
            color: AppColors.keppel,
            size: 20,
          ),
        ),
        title: Text(
          categoria.toUpperCase(),
          style: AppTextStyles.cardTitle,
        ),
        subtitle: Text(
          "${sintomas.length} síntomas disponibles",
          style: AppTextStyles.cardDescription.copyWith(
            color: AppColors.paynesGray.withOpacity(0.7),
          ),
        ),
        iconColor: AppColors.keppel,
        collapsedIconColor: AppColors.keppel,
        children: sintomas.map((sintoma) {
          final seleccionado = sintomasSeleccionados.contains(sintoma);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: seleccionado
                  ? AppColors.aquamarine.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CheckboxListTile(
              title: Text(
                sintoma,
                style: AppTextStyles.body.copyWith(
                  fontWeight: seleccionado
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              activeColor: AppColors.keppel,
              checkColor: AppColors.white,
              value: seleccionado,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    sintomasSeleccionados.add(sintoma);
                  } else {
                    sintomasSeleccionados.remove(sintoma);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBotonDiagnostico() {
    bool isDisabled = sintomasSeleccionados.isEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.search,
          color: isDisabled
              ? AppColors.paynesGray.withOpacity(0.7)
              : AppColors.paynesGray,
          size: 20,
        ),
        label: Text(
          isDisabled
              ? "Selecciona al menos un síntoma"
              : "Consultar Diagnóstico Natural (${sintomasSeleccionados.length})",
          style: AppTextStyles.button.copyWith(
            color: isDisabled
                ? AppColors.paynesGray.withOpacity(0.7)
                : AppColors.paynesGray,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.paynesGray.withOpacity(0.2)
              : AppColors.aquamarine,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 3,
        ),
        onPressed: isDisabled ? null : () => _mostrarAdvertencia(),
      ),
    );
  }
}