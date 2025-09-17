import 'package:flutter/material.dart';

class PresionChatBotPage extends StatefulWidget {
  const PresionChatBotPage({super.key});

  @override
  State<PresionChatBotPage> createState() => _PresionChatBotPageState();
}

class _PresionChatBotPageState extends State<PresionChatBotPage> {
  final TextEditingController sistolicaController = TextEditingController();
  final TextEditingController diastolicaController = TextEditingController();
  final TextEditingController sintomaController = TextEditingController();

  String? recomendacion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Imagen azul de fondo arriba
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Image.asset(
              "assets/images/bg_top.png", // <-- pon tu imagen azul
              fit: BoxFit.cover,
            ),
          ),

          // Flecha + título encima de la imagen
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "ChatBot",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Contenedor blanco flotante
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Inputs presión
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: sistolicaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Sistólica",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: diastolicaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Diastólica",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Síntoma
                    TextField(
                      controller: sintomaController,
                      decoration: const InputDecoration(
                        labelText: "Describe tu síntoma",
                        prefixIcon: Icon(Icons.chat_bubble_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Si existe recomendación, mostrarla
                    if (recomendacion != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF9FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen doctor
                            Image.asset(
                              "assets/images/doctor.png",
                              width: 50,
                              height: 50,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recomendacion!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Botón enviar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF007EA7),
                          side: const BorderSide(color: Color(0xFF007EA7)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          setState(() {
                            recomendacion =
                                "Presión arterial baja\nTu presión arterial es baja. "
                                "Puedes tomar más líquidos, comer alimentos salados y usar medias de compresión.";
                          });
                        },
                        child: const Text(
                          "Enviar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
