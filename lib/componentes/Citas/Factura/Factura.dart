import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'pago_screen.dart';
import '../loginCitas.dart';

class FacturasScreen extends StatefulWidget {
  final String cedula;
  const FacturasScreen({super.key, required this.cedula});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  List<dynamic> facturas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _cargarFacturas();
  }

  Future<void> _cargarFacturas() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/facturas/por-cedula/${widget.cedula}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          facturas = data['data'] ?? [];
          loading = false;
        });
      } else {
        throw Exception('Error al cargar facturas');
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar facturas: $e")),
      );
    }
  }

  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Facturas - ${widget.cedula}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal),
            onPressed: _cargarFacturas,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Container(
              padding: const EdgeInsets.all(20),
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
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : facturas.isEmpty
                  ? const Center(
                child: Text(
                  "No hay facturas registradas.",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
                  : ListView.builder(
                itemCount: facturas.length,
                itemBuilder: (context, i) {
                  final factura = facturas[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Factura N° ${factura['numeroFactura'] ?? '---'}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: const Text(
                                  "Pendiente",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Concepto: ${factura['concepto'] ?? 'Consulta médica'}",
                            style:
                            const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            "Total: \$${factura['total'] ?? '0'}",
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PagoScreen(
                                        factura: factura,
                                        onPagoExitoso:
                                        _cargarFacturas,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.payment,
                                    color: Colors.green),
                                label: const Text(
                                  "Pagar",
                                  style:
                                  TextStyle(color: Colors.green),
                                ),
                              ),
                              const SizedBox(width: 10),
                              TextButton.icon(
                                onPressed: () async {
                                  final idFactura =
                                  factura['idFactura'];
                                  if (idFactura != null) {
                                    final resp = await http.delete(
                                      Uri.parse(
                                        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/facturas/$idFactura",
                                      ),
                                    );
                                    if (resp.statusCode == 200) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Factura eliminada correctamente."),
                                        ),
                                      );
                                      _cargarFacturas();
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                label: const Text(
                                  "Eliminar",
                                  style:
                                  TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
