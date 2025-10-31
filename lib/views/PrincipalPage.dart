import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../componentes/navbar/navbar.dart';
import '../componentes/navbar/footer.dart';
import '../views/ViewMed.dart';

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily = 'TuFuenteApp';

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.keppel,
    fontSize: 12,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardPrice = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}


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
  bool _showModal = true;

  List<Map<String, dynamic>> _productos = [];
  Map<String, dynamic>? _versiculoDelDia;
  Map<String, dynamic>? _lecturasDiarias;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    fetchProductos();
    _fetchVersiculoDelDia();
    _fetchLecturasDiarias();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_versiculoDelDia == null && _lecturasDiarias == null) {
        setState(() => _showModal = true);
      }
    });
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

  Future<void> fetchProductos() async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://blesshealth24-7-backecommerce.onrender.com/producto/obtenervitrina"),
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

  Future<void> _fetchVersiculoDelDia() async {
    try {
      final response = await http.get(
        Uri.parse("https://api-noticias-lecturas.onrender.com/versiculo-aleatorio"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _versiculoDelDia = data;
        });
      } else {
        print("❌ Error _fetchVersiculoDelDia: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error _fetchVersiculoDelDia: $e");
    }
  }

  Future<void> _fetchLecturasDiarias() async {
    try {
      final response = await http.get(
        Uri.parse("https://api-noticias-lecturas.onrender.com/lecturas-diarias"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _lecturasDiarias = data;
        });
      } else {
        print("❌ Error _fetchLecturasDiarias: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error _fetchLecturasDiarias: $e");
    }
  }

  Future<void> buscarProductos(String query) async {
    if (query.isEmpty) {
      fetchProductos();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            "https://blesshealth24-7-backecommerce.onrender.com/producto/buscar/$query"),
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
      String rawImage = e["imgProducto"] ?? e["imagenProducto"] ?? "";
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
        "promo": e["enPromocion"].toString(),
      };
    }).toList();
  }

  Widget _buildLecturasModal() {
    return Dialog(
      backgroundColor: AppColors.paynesGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "📖 Palabra del Día",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.iceBlue,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.iceBlue),
                        onPressed: () => setState(() => _showModal = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_versiculoDelDia != null) ...[
                  _buildSeccion(
                    titulo: "🌟 Versículo del Día",
                    contenido: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_versiculoDelDia!['versiculo_principal'] != null)
                          _buildVersiculo(
                            referencia: _versiculoDelDia!['versiculo_principal']['referencia'] ?? '',
                            texto: _versiculoDelDia!['versiculo_principal']['texto'] ?? '',
                            traduccion: _versiculoDelDia!['versiculo_principal']['traduccion'] ?? '',
                          ),
                        if (_versiculoDelDia!['versiculo_del_dia'] != null)
                          _buildVersiculo(
                            referencia: _versiculoDelDia!['versiculo_del_dia']['referencia'] ?? '',
                            texto: _versiculoDelDia!['versiculo_del_dia']['texto'] ?? '',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (_lecturasDiarias != null) ...[
                  if (_lecturasDiarias!['primera_lectura'] != null)
                    _buildSeccion(
                      titulo: "📖 Primera Lectura",
                      contenido: _buildLectura(_lecturasDiarias!['primera_lectura']),
                    ),
                  const SizedBox(height: 20),

                  if (_lecturasDiarias!['salmo'] != null)
                    _buildSeccion(
                      titulo: "🎵 Salmo Responsorial",
                      contenido: _buildLectura(_lecturasDiarias!['salmo']),
                    ),
                  const SizedBox(height: 20),

                  if (_lecturasDiarias!['evangelio'] != null)
                    _buildSeccion(
                      titulo: "✝️ Evangelio",
                      contenido: _buildLectura(_lecturasDiarias!['evangelio']),
                    ),
                ],

                if (_versiculoDelDia == null && _lecturasDiarias == null)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.aquamarine),
                    ),
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.aquamarine,
                      foregroundColor: AppColors.paynesGray,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 3,
                    ),
                    onPressed: () => setState(() => _showModal = false),
                    child: const Text(
                      "Continuar a la Tienda",
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion({required String titulo, required Widget contenido}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.aquamarine,
          ),
        ),
        const SizedBox(height: 10),
        contenido,
      ],
    );
  }

  Widget _buildVersiculo({required String referencia, required String texto, String traduccion = ''}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.keppel.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texto,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            referencia + (traduccion.isNotEmpty ? ' ($traduccion)' : ''),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.iceBlue.withOpacity(0.7),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildLectura(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.keppel.withOpacity(0.3)),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.white,
          height: 1.4,
        ),
      ),
    );
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
      backgroundColor: AppColors.celeste,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _showNavbar ? null : 0,
                    child: const CustomNavbar(),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: AppColors.paynesGray),
                          hintText: "Busca aquí tus productos",
                          hintStyle: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withOpacity(0.7)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                        onChanged: (value) => buscarProductos(value),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductoDetallePage(
                                      idProducto: producto["id"],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_showModal) _buildLecturasModal(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        bottom: true,
        child: CustomFooterNav(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String price;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        color: AppColors.white.withOpacity(0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.keppel),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined, color: AppColors.paynesGray),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.cardDescription,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\$$price",
                    style: AppTextStyles.cardPrice,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}