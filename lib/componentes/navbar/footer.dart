import 'package:flutter/material.dart';
import '../Citas/LoginCitas.dart'; // Pantalla de citas
import '../../views/Noticias.dart';    // Pantalla de noticias
import '../../views/PrincipalPage.dart'; // Pantalla principal
import '../../views/chats.dart'; // 👈 Cambia esta importación

class CustomFooterNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFooterNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8FDFE), // Fondo celeste
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            Icons.home,
            "Inicio",
            0,
            isInicio: true,
          ),
          _buildNavItem(
            context,
            Icons.chat,
            "Chat",
            1,
            isChat: true,
          ),
          _buildNavItem(
            context,
            Icons.article,
            "Noticias",
            2,
            isNoticias: true,
          ),
          _buildNavItem(
            context,
            Icons.calendar_month,
            "Citas Médicas",
            3,
            isCitas: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      IconData icon,
      String label,
      int index, {
        bool isCitas = false,
        bool isNoticias = false,
        bool isInicio = false,
        bool isChat = false,
      }) {
    return GestureDetector(
      onTap: () {
        if (isCitas) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        else if (isChat) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatOptionsPage()), // 👈 Cambiado aquí
          );
        } else if (isNoticias) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoticiasScreen()),
          );
        } else if (isInicio) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          onTap(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}