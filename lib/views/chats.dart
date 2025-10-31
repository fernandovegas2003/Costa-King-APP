import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';
import 'ChatBotPage_view.dart';
import 'PressionPage.dart';
import 'Sintomas.dart';
import 'SintomasAlternativaPage.dart';

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily = 'TuFuenteApp';

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
  
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    height: 1.4,
    fontFamily: _fontFamily,
  );
}


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
                  "Asistente de Salud",
                  style: AppTextStyles.headline,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.medical_services,
                                size: 50,
                                color: AppColors.aquamarine,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Selecciona el tipo de asistencia que necesitas",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.paynesGray.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      _buildChatOption(
                        icon: Icons.chat,
                        title: "Chat General de Salud",
                        description: "Conversa con nuestro asistente sobre cualquier tema de salud, síntomas, recomendaciones generales y dudas médicas.",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatBotPage()),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildChatOption(
                        icon: Icons.monitor_heart,
                        title: "Análisis de Presión Arterial",
                        description: "Analiza tus valores de presión arterial y obtén recomendaciones personalizadas, medicamentos y remedios caseros.",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PresionPage()),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildChatOption(
                        icon: Icons.medical_services,
                        title: "Diagnóstico por Síntomas",
                        description: "Selecciona tus síntomas y obtén un diagnóstico preliminar con recomendaciones médicas personalizadas.",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SintomasPage()),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildChatOption(
                        icon: Icons.eco,
                        title: "Medicina Alternativa",
                        description: "Diagnóstico con remedios naturales basado en tus síntomas y duración.",
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
      ),
    );
  }

  Widget _buildChatOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      color: AppColors.white.withOpacity(0.8),
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
                  color: AppColors.keppel.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColors.keppel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.cardDescription.copyWith(
                        color: AppColors.paynesGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.keppel.withOpacity(0.7),
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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Próximamente", style: AppTextStyles.headline.copyWith(fontSize: 20)),
        content: Text("Esta funcionalidad estará disponible muy pronto.", style: AppTextStyles.body),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.paynesGray,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Entendido", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}