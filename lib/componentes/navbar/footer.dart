import 'package:flutter/material.dart';
import '../Citas/LoginCitas.dart';
import '../../views/Noticias.dart';
import '../../views/PrincipalPage.dart';
import '../../views/chats.dart';

class AppColors {
  static const Color celeste = Color.fromARGB(255, 95, 151, 149);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF6ABEA7);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily = 'TuFuenteApp';

  static const TextStyle footerLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
  );
}


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
      color: AppColors.celeste,
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
    final bool isSelected = currentIndex == index;

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
            MaterialPageRoute(builder: (_) => const ChatOptionsPage()),
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
              color: isSelected ? AppColors.aquamarine : AppColors.iceBlue,
              borderRadius: BorderRadius.circular(30),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.aquamarine.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4)
                )
              ] : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.paynesGray : AppColors.paynesGray.withOpacity(0.7),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.footerLabel.copyWith(
              color: isSelected ? AppColors.keppel : AppColors.paynesGray.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}