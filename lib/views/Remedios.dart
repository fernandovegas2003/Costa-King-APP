import 'package:flutter/material.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

class RemediosPage extends StatelessWidget {
  final Map<String, dynamic> remedios;
  final int _selectedIndex = 1;

  const RemediosPage({super.key, required this.remedios});

  @override
  Widget build(BuildContext context) {
    final List lista = remedios['remedios'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFE),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Navbar
            const CustomNavbar(),

            // 🔹 Header con estilo farmacia natural
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2E7D32),
                    const Color(0xFF4CAF50),
                  ],
                ),
                borderRadius: const BorderRadius.only(
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
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Tratamientos caseros y medicina alternativa",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Medicina Natural y Tradicional",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 🔹 Tarjeta de advertencia
                    if (remedios['advertencia'] != null)
                      _buildAdvertenciaCard(),

                    const SizedBox(height: 20),

                    // 🔹 Sección de remedios
                    if (lista.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSeccionTitulo(
                            icon: Icons.spa,
                            title: "Remedios Caseros Recomendados",
                            subtitle: "Tratamientos naturales basados en evidencia",
                          ),
                          const SizedBox(height: 16),
                          ...lista.map((item) => _buildRemedioCard(item)),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // 🔹 Footer
            CustomFooterNav(
              currentIndex: _selectedIndex,
              onTap: (index) {
                // La navegación ya está manejada en el CustomFooterNav
              },
            ),
          ],
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
            decoration: BoxDecoration(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFF2E7D32),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF4CAF50).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.eco,
            color: Color(0xFF2E7D32),
            size: 20,
          ),
        ),
        title: Text(
          item['nombre'] ?? "Remedio Natural",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['evidencia'] != null)
              Text(
                item['evidencia'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
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
              color: Color(0xFFE8F5E8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // 🔹 Cómo usar
                _buildInfoSection(
                  icon: Icons.help,
                  title: "📝 Cómo usar",
                  content: item['como_usar'] ?? "",
                ),

                const SizedBox(height: 12),

                // 🔹 Dosis recomendada
                _buildInfoSection(
                  icon: Icons.science,
                  title: "💊 Dosis recomendada",
                  content: item['dosis_recomendada'] ?? "",
                ),

                const SizedBox(height: 12),

                // 🔹 Mecanismo de acción
                _buildInfoSection(
                  icon: Icons.psychology,
                  title: "🔬 Mecanismo de acción",
                  content: item['mecanismo'] ?? "",
                ),

                const SizedBox(height: 12),

                // 🔹 Precauciones
                _buildInfoSection(
                  icon: Icons.warning,
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
      chipColor = Colors.grey;
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWarning ? Colors.orange[100]! : Colors.green[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isWarning ? Colors.orange : Color(0xFF2E7D32),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isWarning ? Colors.orange[800] : Color(0xFF2E7D32),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              color: isWarning ? Colors.orange[700] : Colors.grey[700],
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}