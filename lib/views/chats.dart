import 'package:flutter/material.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';
import 'ChatBotPage_view.dart';
import 'PressionPage.dart';
import 'Sintomas.dart'; // 🔹 Cambiada la importación
import 'SintomasAlternativaPage.dart';

class ChatOptionsPage extends StatefulWidget {
  const ChatOptionsPage({super.key});

  @override
  State<ChatOptionsPage> createState() => _ChatOptionsPageState();
}

class _ChatOptionsPageState extends State<ChatOptionsPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FEFE),
      body: SafeArea(
        child: Column(
          children: [
            const CustomNavbar(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Asistente de Salud",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006D73),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 50,
                              color: Color(0xFF006D73),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Selecciona el tipo de asistencia que necesitas",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🔹 Opción 1: Chat General
                    _buildChatOption(
                      icon: Icons.chat,
                      title: "Chat General de Salud",
                      description: "Conversa con nuestro asistente sobre cualquier tema de salud, síntomas, recomendaciones generales y dudas médicas.",
                      color: Color(0xFF006D73),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatBotPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Opción 2: Análisis de Presión
                    _buildChatOption(
                      icon: Icons.monitor_heart,
                      title: "Análisis de Presión Arterial",
                      description: "Analiza tus valores de presión arterial y obtén recomendaciones personalizadas, medicamentos y remedios caseros.",
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PresionPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Opción 3: Diagnóstico por Síntomas (ACTUALIZADA)
                    _buildChatOption(
                      icon: Icons.medical_services,
                      title: "Diagnóstico por Síntomas",
                      description: "Selecciona tus síntomas y obtén un diagnóstico preliminar con recomendaciones médicas personalizadas.",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SintomasPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

// 🔹 Opción 4: Medicina Alternativa (NUEVA)
                    _buildChatOption(
                      icon: Icons.eco,
                      title: "Medicina Alternativa",
                      description: "Diagnóstico con remedios naturales basado en tus síntomas y duración.",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SintomasAlternativaPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
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
    );
  }

  Widget _buildChatOption({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Próximamente", style: TextStyle(color: Color(0xFF006D73))),
        content: Text("Esta funcionalidad estará disponible muy pronto."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Entendido", style: TextStyle(color: Color(0xFF006D73))),
          ),
        ],
      ),
    );
  }
}