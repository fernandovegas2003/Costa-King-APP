import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../componentes/navbar/navbar.dart';
import '../componentes/navbar/footer.dart';

class ProductoDetallePage extends StatefulWidget {
  final int idProducto;

  const ProductoDetallePage({super.key, required this.idProducto});

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  Map<String, dynamic>? _producto;
  bool _cargando = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducto();
  }

  Future<void> _fetchProducto() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backecommerce.onrender.com/producto/id/${widget.idProducto}",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _producto = json.decode(response.body);
          _cargando = false;
        });
      } else {
        print("❌ Error: ${response.statusCode}");
        setState(() => _cargando = false);
      }
    } catch (e) {
      print("❌ Error al obtener producto: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _producto == null
            ? const Center(child: Text("No se encontró el producto"))
            : Column(
          children: [
            const CustomNavbar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _producto!["imgProducto"],
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nombre del producto
                      Text(
                        _producto!["nombreProducto"],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Descripción
                      Text(
                        _producto!["descripcionProducto"],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // Precio
                      Text(
                        "Precio: ${_producto!["precioProducto"]}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Stock
                      Text(
                        "Stock disponible: ${_producto!["stockProducto"]}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Promoción
                      Text(
                        "Promoción: ${_producto!["promocion"]}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ✅ Botón de acción con color teal
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("🛒 Agregado al carrito"),
                                ));
                              },
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text(
                                "Agregar al carrito",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal, // ✅ color corregido
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: CustomFooterNav(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}
