import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../views/Account.dart';
import '../../views/Carrito.dart';

class AppColors {
  static const Color celeste = Color.fromARGB(255, 95, 151, 149);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily = 'TuFuenteApp';

  static const TextStyle navbarTitle = TextStyle(
    color: AppColors.paynesGray,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    fontFamily: _fontFamily,
  );
}

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  int _cantidadCarrito = 0;

  @override
  void initState() {
    super.initState();
    _cargarCantidadCarrito();
  }

  Future<void> _cargarCantidadCarrito() async {
    try {
      final String token =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjQ4LCJyb2wiOiJ1c3VhcmlvIiwiY29ycmVvIjoianVhbm11bm96cm9qYXM5NEBnbWFpbC5jb20iLCJpYXQiOjE3NjExOTc0NDMsImV4cCI6NDkxNjk1NzQ0M30.IHCIWNpKs0OEmr8UMaw9Tbs6AHPlAjzLcOU-mZ4B85k";
      final int userId = 48;

      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backecommerce.onrender.com/carrito/$userId",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          int total = 0;
          for (var item in data) {
            final cantidad = item['Cantidad'];
            if (cantidad is int) {
              total += cantidad;
            } else if (cantidad is double) {
              total += cantidad.toInt();
            } else {
              total += 0;
            }
          }
          if (mounted) {
            setState(() {
              _cantidadCarrito = total;
            });
          }
        }
      } else if (response.statusCode == 404) {
        if (mounted) {
          setState(() {
            _cantidadCarrito = 0;
          });
        }
      }
    } catch (e) {
      print('❌ Error cargando cantidad del carrito: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.celeste,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavIcon(
            icon: Icons.person_outline,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MiCuentaPage()),
              );
            },
          ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.paynesGray.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset('assets/images/Logo2.png', height: 32),
              ),
              const SizedBox(width: 8),
              const Text("Costa King App", style: AppTextStyles.navbarTitle),
            ],
          ),

          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildNavIcon(
                icon: Icons.shopping_cart_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarritoPage(),
                    ),
                  ).then((_) {
                    _cargarCantidadCarrito();
                  });
                },
              ),

              if (_cantidadCarrito > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _cantidadCarrito > 99
                          ? '99+'
                          : _cantidadCarrito.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.paynesGray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.paynesGray, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}
