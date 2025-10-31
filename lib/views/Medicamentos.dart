import 'package:flutter/material.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

class MedicamentosPage extends StatelessWidget {
  final Map<String, dynamic> medicamentos;
  final int _selectedIndex = 1;

  const MedicamentosPage({super.key, required this.medicamentos});

  @override
  Widget build(BuildContext context) {
    final List comparativa = medicamentos['comparativa'] ?? [];
    final List recomendados = medicamentos['medicamentos_recomendados'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFE),
      body: SafeArea(
        child: Column(
          children: [
            const CustomNavbar(),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF006D73),
                    const Color(0xFF00A5A5),
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
                          Icons.medication,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Medicamentos Recomendados",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Análisis comparativo y opciones de tratamiento",
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
                    child: const Text(
                      "Consulta Farmacéutica Especializada",
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (medicamentos['advertencia'] != null)
                      _buildAdvertenciaCard(),

                    const SizedBox(height: 20),

                    if (comparativa.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSeccionTitulo(
                            icon: Icons.compare,
                            title: "Comparativa de Medicamentos",
                            subtitle: "Análisis detallado por clases terapéuticas",
                          ),
                          const SizedBox(height: 16),
                          ...comparativa.map((item) => _buildComparativaCard(item)),
                        ],
                      ),

                    const SizedBox(height: 20),

                    if (recomendados.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSeccionTitulo(
                            icon: Icons.recommend,
                            title: "Opciones de Tratamiento",
                            subtitle: "Medicamentos recomendados y combinaciones",
                          ),
                          const SizedBox(height: 16),
                          ...recomendados.map((item) => _buildRecomendadoCard(item)),
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
              medicamentos['advertencia'] ?? "",
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
          const Icon(
            Icons.compare,
            color: Color(0xFF006D73),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006D73),
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

  Widget _buildComparativaCard(Map<String, dynamic> item) {
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
            color: const Color(0xFF006D73).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.analytics,
            color: Color(0xFF006D73),
            size: 20,
          ),
        ),
        title: Text(
          item['clase'] ?? "Clase terapéutica",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF006D73),
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          item['comparacion'] ?? "",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("🔬 Mecanismo de acción", item['mecanismo'] ?? ""),
                const SizedBox(height: 12),
                _buildInfoRow("⚠️ Efectos secundarios", item['efectos_secundarios'] ?? ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendadoCard(Map<String, dynamic> item) {
    final ejemplos = (item['ejemplos'] as List?) ?? [];
    final combinaciones = (item['opciones_combinaciones'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF006D73).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_liquid,
                  color: Color(0xFF006D73),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['clase'] ?? "Medicamento",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006D73),
                  ),
                ),
              ),
            ],
          ),

          if (item['nota'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['nota'],
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (combinaciones.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "💊 Opciones de Combinación",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF006D73),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: combinaciones.map((c) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A5A5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00A5A5).withOpacity(0.3)),
                  ),
                  child: Text(
                    c,
                    style: const TextStyle(
                      color: Color(0xFF006D73),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          if (ejemplos.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "📋 Ejemplos Comerciales",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF006D73),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            ...ejemplos.map((e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, color: Color(0xFF006D73), size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['nombre'] ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF006D73),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            e['dosis'] ?? "",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF006D73),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}