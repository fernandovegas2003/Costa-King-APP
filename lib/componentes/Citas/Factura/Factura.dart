import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'pago_screen.dart';
import '../loginCitas.dart';

// 🎨 TU PALETA DE COLORES PROFESIONAL
class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

// 🖋️ TUS ESTILOS DE TEXTO PROFESIONALES
class AppTextStyles {
  static const String _fontFamily =
      'TuFuenteApp'; // Asegúrate de tener esta fuente

  static const TextStyle headline = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel, // 🎨 Color
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray, // 🎨 Color
    fontSize: 15,
    fontFamily: _fontFamily,
  );
}

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

  // --- (TODA TU LÓGICA DE API SE MANTIENE EXACTAMENTE IGUAL) ---
  Future<void> _cargarFacturas() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/facturas/por-cedula/${widget.cedula}',
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          facturas = data['data'] ?? [];
          loading = false;
        });
      } else {
        setState(() => loading = false);
        _showSnack("Error al cargar facturas", isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        _showSnack("Error de conexión: $e", isError: true);
      }
    }
  }

  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : AppColors.keppel,
      ),
    );
  }

  // 🎨 --- BUILD METHOD REDISEÑADO --- 🎨
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste, // 🎨 Color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 🎨 Color
        elevation: 0,
        leading: IconButton(
          // 🎨 Añadido botón de atrás
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.paynesGray),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Facturas - ${widget.cedula}",
          style: AppTextStyles.headline.copyWith(fontSize: 20), // 🎨 Estilo
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppColors.keppel,
            ), // 🎨 Color
            onPressed: _cargarFacturas,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.red[700]), // Semántico
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Container(
        // 🎨 GRADIENTE DE FONDO
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          // 🎨 Contenido principal
          child: loading
              ? Center(
                  // 🎨 Loading rediseñado
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.aquamarine,
                      ), // 🎨 Color
                      SizedBox(height: 16),
                      Text(
                        "Cargando facturas...",
                        style: AppTextStyles.body,
                      ), // 🎨 Estilo
                    ],
                  ),
                )
              : facturas.isEmpty
              ? Center(
                  // 🎨 Empty state rediseñado
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 60,
                        color: AppColors.paynesGray.withOpacity(0.3),
                      ), // 🎨 Color
                      SizedBox(height: 16),
                      Text(
                        "No hay facturas registradas.",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.paynesGray.withOpacity(0.7),
                        ), // 🎨 Estilo
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: facturas.length,
                  itemBuilder: (context, i) {
                    final factura = facturas[i];
                    // 🎨 TARJETA REDISEÑADA
                    return Card(
                      color: AppColors.white.withOpacity(0.7), // 🎨 Color
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Factura N° ${factura['numeroFactura'] ?? '---'}",
                                  style: AppTextStyles.cardTitle, // 🎨 Estilo
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.keppel.withOpacity(
                                      0.1,
                                    ), // 🎨 Color
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.keppel.withOpacity(0.3),
                                    ), // 🎨 Color
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    "Pendiente", // Asumo que todas están pendientes
                                    style: TextStyle(
                                      color: AppColors.keppel, // 🎨 Color
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: AppColors.keppel.withOpacity(0.5),
                              height: 20,
                              thickness: 1,
                            ), // 🎨 Color
                            Text(
                              "Concepto: ${factura['concepto'] ?? 'Consulta médica'}",
                              style: AppTextStyles.cardDescription, // 🎨 Estilo
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Total: \$${factura['total'] ?? '0'}",
                              style: AppTextStyles.cardDescription.copyWith(
                                // 🎨 Estilo
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 🎨 Botón Eliminar (semántico)
                                TextButton.icon(
                                  onPressed: () async {
                                    final idFactura = factura['idFactura'];
                                    if (idFactura != null) {
                                      final resp = await http.delete(
                                        Uri.parse(
                                          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/facturas/$idFactura",
                                        ),
                                      );
                                      if (resp.statusCode == 200) {
                                        _showSnack(
                                          "Factura eliminada correctamente.",
                                        );
                                        _cargarFacturas();
                                      } else {
                                        _showSnack(
                                          "Error al eliminar",
                                          isError: true,
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[700],
                                  ),
                                  label: Text(
                                    "Eliminar",
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // 🎨 Botón Pagar (CTA)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PagoScreen(
                                          factura: factura,
                                          onPagoExitoso: _cargarFacturas,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.aquamarine, // 🎨 Color
                                    foregroundColor:
                                        AppColors.paynesGray, // 🎨 Color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ), // 🎨 Redondeado
                                  ),
                                  icon: const Icon(Icons.payment, size: 20),
                                  label: Text(
                                    "Pagar",
                                    style: AppTextStyles.button.copyWith(
                                      fontSize: 14,
                                    ), // 🎨 Estilo
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
    );
  }
}
