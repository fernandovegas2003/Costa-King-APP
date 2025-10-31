import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'Login.dart';

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
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class MiCuentaPage extends StatelessWidget {
  const MiCuentaPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    void _cerrarSesion() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Cerrar Sesión', style: AppTextStyles.headline.copyWith(fontSize: 20)),
          content: Text('¿Estás seguro de que quieres cerrar sesión?', style: AppTextStyles.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar', style: TextStyle(color: AppColors.paynesGray)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.keppel,
                foregroundColor: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      
      if (confirmar != true) return;
      
      if (context.mounted) {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.logout();
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.celeste,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.paynesGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mi cuenta",
          style: AppTextStyles.headline,
        ),
        centerTitle: true,
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildOpcionTile(
                        icon: Icons.person_outline,
                        titulo: "Datos Personales",
                        onTap: () {
                          // TODO: Navegar a la página de datos personales
                        },
                      ),
                      Divider(color: AppColors.keppel.withOpacity(0.5), height: 1),
                      _buildOpcionTile(
                        icon: Icons.lock_outline,
                        titulo: "Recuperar contraseña",
                        onTap: () {
                          // TODO: Navegar a la página de recuperar contraseña
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                Image.asset(
                  'assets/images/Logo1.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                
                const Spacer(),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Cerrar Sesión", style: AppTextStyles.button),
                    onPressed: _cerrarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.aquamarine,
                      foregroundColor: AppColors.paynesGray,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionTile({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.paynesGray),
      title: Text(titulo, style: AppTextStyles.body),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.keppel, size: 16),
      onTap: onTap,
    );
  }
}