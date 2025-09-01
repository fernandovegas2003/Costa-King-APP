import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFE6F9FA),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              IconButton(
                icon: const Icon(Icons.person, color: Colors.teal, size: 30),
                onPressed: () {

                },
              ),

              Row(
                children: [
                  Image.asset(
                    'assets/images/Logo2.png',
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "BlessHealth24",
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              // Ícono de carrito
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.teal, size: 28),
                onPressed: () {
                  // Acción al presionar
                },
              ),
            ],
          ),
        ),

      ],
    );
  }
}
