import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../views/Account.dart';
import '../../views/Carrito.dart';

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

  // 🔹 CARGAR CANTIDAD DEL CARRITO
  Future<void> _cargarCantidadCarrito() async {
    try {
      // Usar el mismo token estático y user ID
      final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjQ4LCJyb2wiOiJ1c3VhcmlvIiwiY29ycmVvIjoianVhbm11bm96cm9qYXM5NEBnbWFpbC5jb20iLCJpYXQiOjE3NjExOTc0NDMsImV4cCI6NDkxNjk1NzQ0M30.IHCIWNpKs0OEmr8UMaw9Tbs6AHPlAjzLcOU-mZ4B85k";
      final int userId = 48;

      final response = await http.get(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/$userId"),
        headers: {
          'Authorization': 'Bearer $token',
        },
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
      }
 else if (response.statusCode == 404) {
        // Carrito vacío
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
    return Column(
      children: [
        Container(
          color: const Color(0xFFE6F9FA),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔹 Botón de cuenta
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.person, color: Color(0xFF006D73), size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MiCuentaPage(),
                      ),
                    );
                  },
                ),
              ),

              // 🔹 Logo y nombre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/Logo2.png',
                      height: 32,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "BlessHealth24",
                    style: TextStyle(
                      color: Color(0xFF006D73),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              // 🔹 Ícono de carrito con badge dinámico
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Color(0xFF006D73), size: 24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CarritoPage(),
                          ),
                        ).then((_) {
                          // 🔹 ACTUALIZAR CANTIDAD AL VOLVER DEL CARRITO
                          _cargarCantidadCarrito();
                        });
                      },
                    ),
                  ),

                  // 🔹 BADGE DINÁMICO DEL CARRITO
                  if (_cantidadCarrito > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _cantidadCarrito > 99 ? '99+' : _cantidadCarrito.toString(),
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
        ),
      ],
    );
  }
}