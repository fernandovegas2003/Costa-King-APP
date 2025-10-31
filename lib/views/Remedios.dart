import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

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
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 13,
    fontFamily: _fontFamily,
  );
}

class RemediosPage extends StatelessWidget {
  final Map<String, dynamic> remedios;
  final int _selectedIndex =
      1;

  const RemediosPage({super.key, required this.remedios});

  @override
  Widget build(BuildContext context) {
    final List lista = remedios['remedios'] ?? [];

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
                            Icons.eco,
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
                                "Remedios Naturales",
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Tratamientos caseros y medicina alternativa",
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
                        "Medicina Natural y Tradicional",
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (remedios['advertencia'] != null)
                        _buildAdvertenciaCard(),

                      const SizedBox(height: 20),

                      if (lista.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSeccionTitulo(
                              icon: Icons.spa,
                              title: "Remedios Caseros Recomendados",
                              subtitle:
                                  "Tratamientos naturales basados en evidencia",
                            ),
                            const SizedBox(height: 16),
                            ...lista.map((item) => _buildRemedioCard(item)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              CustomFooterNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvertenciaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEF3C7)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              remedios['advertencia'] ?? "",
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTitulo({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.aquamarine,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.cardDescription.copyWith(
                    color: AppColors.paynesGray.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemedioCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white),
      ),
      child: ExpansionTile(
        iconColor: AppColors.keppel,
        collapsedIconColor: AppColors.keppel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.keppel.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco,
            color: AppColors.keppel,
            size: 20,
          ),
        ),
        title: Text(
          item['nombre'] ?? "Remedio Natural",
          style: AppTextStyles.headline.copyWith(fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['evidencia'] != null)
              Text(
                item['evidencia'],
                style: AppTextStyles.cardDescription.copyWith(
                  color: AppColors.paynesGray.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            _buildEvidenciaChip(item['evidencia'] ?? ""),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.iceBlue.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                _buildInfoSection(
                  icon: Icons.help_outline,
                  title: "📝 Cómo usar",
                  content: item['como_usar'] ?? "",
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  icon: Icons.science_outlined,
                  title: "💊 Dosis recomendada",
                  content: item['dosis_recomendada'] ?? "",
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  icon: Icons.psychology_outlined,
                  title: "🔬 Mecanismo de acción",
                  content: item['mecanismo'] ?? "",
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  icon: Icons.warning_amber_rounded,
                  title: "⚠️ Precauciones",
                  content: item['precauciones'] ?? "",
                  isWarning: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenciaChip(String evidencia) {
    Color chipColor;
    String chipText;

    if (evidencia.toLowerCase().contains('alta') ||
        evidencia.toLowerCase().contains('fuerte')) {
      chipColor = Colors.green;
      chipText = "Evidencia Alta";
    } else if (evidencia.toLowerCase().contains('media') ||
        evidencia.toLowerCase().contains('moderada')) {
      chipColor = Colors.orange;
      chipText = "Evidencia Media";
    } else if (evidencia.toLowerCase().contains('baja') ||
        evidencia.toLowerCase().contains('tradicional')) {
      chipColor = Colors.blue;
      chipText = "Evidencia Tradicional";
    } else {
      chipColor = AppColors.paynesGray;
      chipText = "Evidencia";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    bool isWarning = false,
  }) {
    final Color color = isWarning
        ? Colors.orange[800]!
        : AppColors.keppel;
    final Color bgColor = isWarning
        ? Colors.orange[50]!
        : AppColors.white.withOpacity(0.7);
    final Color borderColor = isWarning
        ? Colors.orange[100]!
        : AppColors.keppel.withOpacity(0.3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              color: isWarning
                  ? Colors.orange[700]
                  : AppColors.paynesGray,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}