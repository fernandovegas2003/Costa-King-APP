import 'package:flutter/material.dart';
import '../Citas/AgendarCita.dart';
import '../Citas/CancelarCita.dart';
import '../Citas/VerCitas.dart';
import 'OrdenesMedicas.dart'; // ✅ Asegúrate de tener esta pantalla creada
// import 'PagarCita.dart'; // ✅ (Cuando tengas la pantalla lista, descomenta esto)

class MenuCitasPage extends StatelessWidget {
  const MenuCitasPage({Key? key}) : super(key: key);

  Widget _botonMenu(BuildContext context, String texto, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF01A4B2),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final botones = [
      {
        "texto": "Agendar Cita Médica",
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AgendarCitaPage()),
        )
      },
      {
        "texto": "Cancelar Cita",
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CancelarCitaPage()),
        )
      },
      {
        "texto": "Ver Citas",
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VerCitasScreen()),
        )
      },
      {
        "texto": "Ver Órdenes Médicas",
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VerOrdenesMedicasPage()),
        )
      },
      {
        "texto": "Pagar Cita", // 💳 Nuevo botón agregado
        "onTap": () {
          // Cuando tengas la vista de pago, reemplaza este print
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const PagarCitaPage()));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Funcionalidad de pago próximamente disponible."),
              backgroundColor: Color(0xFF01A4B2),
            ),
          );
        }
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Gestión de Citas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // 📸 Fondo de pantalla
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          // 📦 Contenedor centrado con los botones
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 👈 Ajusta altura al contenido
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < botones.length; i++) ...[
                    _botonMenu(
                      context,
                      botones[i]['texto'] as String,
                      botones[i]['onTap'] as VoidCallback,
                    ),
                    if (i != botones.length - 1)
                      const SizedBox(height: 20), // Espacio entre botones
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
