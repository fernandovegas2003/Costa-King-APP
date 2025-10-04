import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 🔹 Importa tus componentes personalizados
import '../componentes/widget/appScalfod.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';


class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimer();
    });
  }

  Future<void> _showDisclaimer() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Aviso importante"),
        content: const Text(
          "Este chat proporciona recomendaciones basadas en datos promedio de usuarios. "
              "No debes seguirlas al pie de la letra ni sustituir la consulta con un médico profesional. "
              "No nos hacemos responsables por el mal uso de esta información.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse("http://20.251.169.101:5000/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data["bot_response"] ?? "No tengo respuesta.";
        setState(() {
          _messages.add({"sender": "bot", "text": botResponse});
        });
      } else {
        setState(() {
          _messages.add({
            "sender": "bot",
            "text": "Error al conectar con el servidor."
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "No se pudo establecer conexión."
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FEFE),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Navbar arriba
            const CustomNavbar(),

            // 🔹 Contenido del chat
            Expanded(
              child: Column(
                children: [
                  // 🔹 Caja blanca con los mensajes
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg["sender"] == "user";
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints:
                              const BoxConstraints(maxWidth: 280),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color(0xFF006D73)
                                    : const Color(0xFFEFF9FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                msg["text"]!,
                                style: TextStyle(
                                  color:
                                  isUser ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 🔹 Input de mensaje
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    margin: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Escribe tu mensaje...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send,
                              color: Color(0xFF006D73)),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Footer abajo
            CustomFooterNav(
              currentIndex: 1,
              onTap: (index) {},
            ),
          ],
        ),
      ),
    );
  }
}
