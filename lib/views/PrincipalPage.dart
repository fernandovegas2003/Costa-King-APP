import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../componentes/navbar/navbar.dart';
import '../componentes/navbar/footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _showNavbar = true;
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _productos = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    fetchProductos(); // al iniciar carga todos
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showNavbar) setState(() => _showNavbar = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showNavbar) setState(() => _showNavbar = true);
    }
  }

  /// 🔹 Trae todos los productos
  Future<void> fetchProductos() async {
    try {
      final response = await http.get(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/producto/obtenervitrina"),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          _productos = _mapearProductos(data);
        });
      } else {
        print("❌ Error fetchProductos: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetchProductos: $e");
    }
  }

  /// 🔹 Buscar productos
  Future<void> buscarProductos(String query) async {
    if (query.isEmpty) {
      fetchProductos(); // si no hay búsqueda, traer todos
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/producto/buscar/$query"),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          _productos = _mapearProductos(data);
        });
      } else {
        print("❌ Error buscarProductos: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error buscarProductos: $e");
    }
  }

  List<Map<String, dynamic>> _mapearProductos(List data) {
    return data.map((e) {
      // 🔹 Soporta tanto "imgProducto" como "imagenProducto"
      String rawImage = e["imgProducto"] ?? e["imagenProducto"] ?? "";

      // 🔹 Reemplazar localhost con Render
      String fullImageUrl = rawImage.replaceFirst(
        "https://localhost:3000",
        "https://blesshealth24-7-backecommerce.onrender.com",
      );

      return {
        "id": e["idProducto"],
        "nombre": e["nombreProducto"] ?? "",
        "precio": e["precioProducto"] ?? "",
        "stock": e["stockProducto"] ?? 0,
        "imagen": fullImageUrl,
        "promo": e["enPromocion"].toString(), // lo paso a string para mostrar
      };
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Navbar animado
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _showNavbar ? null : 0,
              child: const CustomNavbar(),
            ),

            // 🔹 Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: "Busca aquí tus productos",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    buscarProductos(value);
                  },
                ),
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columnas
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _productos.length,
                    itemBuilder: (context, index) {
                      final producto = _productos[index];

                      return ProductCard(
                        imageUrl: producto["imagen"],
                        title: producto["nombre"],
                        description: producto["promo"],
                        price: producto["precio"].toString(),
                        onAdd: () {
                          print("🛒 Agregado: ${producto["nombre"]}");
                        },
                        onFavorite: () {
                          print("❤️ Favorito: ${producto["nombre"]}");
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Footer
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

/// --- Tarjeta del producto ---
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String price;
  final VoidCallback onAdd;
  final VoidCallback onFavorite;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.onAdd,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Expanded(
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                Text(price,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
