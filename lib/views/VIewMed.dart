import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../componentes/navbar/navbar.dart';
import '../componentes/navbar/footer.dart';

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily =
      'TuFuenteApp';

  static const TextStyle headline = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle detailPrice = TextStyle(
    color: AppColors.keppel,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

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
  int _cantidad = 1;

  int? _userId;
  String? _token;
  String? _userName;
  bool _isLoggedIn = false;

  final String _fixedToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjQ4LCJyb2wiOiJ1c3VhcmlvIiwiY29ycmVvIjoianVhbm11bm96cm9qYXM5NEBnbWFpbC5jb20iLCJpYXQiOjE3NjExOTc0NDMsImV4cCI6NDkxNjk1NzQ0M30.IHCIWNpKs0OEmr8UMaw9Tbs6AHPlAjzLcOU-mZ4B85k";

  @override
  void initState() {
    super.initState();
    _fetchProducto();
    _loadUserDataFromAuth();
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

  Future<void> _loadUserDataFromAuth() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      setState(() {
        _userId = authService.userId;
        _token = _fixedToken;
        _userName = authService.userName;
        _isLoggedIn = true;
      });

      print('👤 Usuario cargado: ID: $_userId');
      print('🔐 Token fijo cargado');
    } catch (e) {
      print('❌ Error cargando datos de usuario: $e');
    }
  }

  Future<void> _agregarAlCarrito() async {
    if (!_isLoggedIn || _token == null || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "❌ Error de autenticación. Intenta iniciar sesión de nuevo.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('🛒 Enviando solicitud al carrito...');
      print(
        '📦 Datos: usuarioId: $_userId, productoId: ${widget.idProducto}, cantidad: $_cantidad',
      );
      print('🔐 Token: ${_token!.substring(0, 50)}...');

      final response = await http.post(
        Uri.parse(
          "https://blesshealth24-7-backecommerce.onrender.com/carrito/agregar",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "usuarioId": _userId,
          "productoId": widget.idProducto,
          "cantidad": _cantidad,
        }),
      );

      print('📡 Respuesta del servidor: ${response.statusCode}');
      print('📄 Body de respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Producto agregado al carrito"),
            backgroundColor: AppColors.keppel,
          ),
        );
        print(
          '✅ Producto agregado al carrito - Usuario: $_userId, Producto: ${widget.idProducto}',
        );
      } else {
        String errorMessage = "Error desconocido";
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['error'] ?? errorData['message'] ?? response.body;
        } catch (e) {
          errorMessage = response.body;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: $errorMessage"),
            backgroundColor: Colors.red,
          ),
        );
        print('❌ Error del servidor: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error de conexión: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print('❌ Error de conexión: $e');
    }
  }

  void _irALogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.paynesGray),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: _cargando
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.aquamarine,
                    ),
                  ),
                )
              : _producto == null
              ? const Center(
                  child: Text(
                    "No se encontró el producto",
                    style: AppTextStyles.body,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    color: AppColors.white.withOpacity(0.5),
                                    child: Image.network(
                                      _producto!["imgProducto"],
                                      height: 300,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 300,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: AppColors.white
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.broken_image_outlined,
                                            size: 60,
                                            color: AppColors.paynesGray,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                _producto!["nombreProducto"] ?? "Producto",
                                style: AppTextStyles.headline,
                              ),
                              const SizedBox(height: 12),

                              Text(
                                "\$${_producto!["precioProducto"] ?? "0.00"}",
                                style: AppTextStyles
                                    .detailPrice,
                              ),
                              const SizedBox(height: 20),

                              Text(
                                _producto!["descripcionProducto"] ??
                                    "Sin descripción",
                                style: AppTextStyles.body,
                              ),
                              const SizedBox(height: 16),

                              Text(
                                "Stock disponible: ${_producto!["stockProducto"] ?? 0}",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.paynesGray.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 10),

                              if (_producto!["promocion"] != null)
                                Text(
                                  "Promoción: ${_producto!["promocion"]}",
                                  style: AppTextStyles.body.copyWith(
                                    color:
                                        AppColors.keppel,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              const SizedBox(height: 24),
                              const Divider(color: AppColors.keppel),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Cantidad:",
                                    style: AppTextStyles.button,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            color: AppColors.paynesGray,
                                          ),
                                          onPressed: _cantidad > 1
                                              ? () =>
                                                  setState(() => _cantidad--)
                                              : null,
                                        ),
                                        Text(
                                          '$_cantidad',
                                          style: AppTextStyles.button,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: AppColors.paynesGray,
                                          ),
                                          onPressed:
                                              _cantidad <
                                                  (_producto!["stockProducto"] ??
                                                      1)
                                                  ? () =>
                                                      setState(() => _cantidad++)
                                                  : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoggedIn
                                      ? _agregarAlCarrito
                                      : _irALogin,
                                  icon: Icon(
                                    _isLoggedIn
                                        ? Icons.add_shopping_cart
                                        : Icons.login,
                                  ),
                                  label: Text(
                                    _isLoggedIn
                                        ? "Agregar al carrito ($_cantidad)"
                                        : "Iniciar sesión para comprar",
                                    style: AppTextStyles.button,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isLoggedIn
                                        ? AppColors.aquamarine
                                        : AppColors.keppel,
                                    foregroundColor: _isLoggedIn
                                        ? AppColors.paynesGray
                                        : AppColors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isLoggedIn
                                      ? AppColors.keppel.withOpacity(0.1)
                                      : AppColors.paynesGray.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isLoggedIn
                                        ? AppColors.keppel.withOpacity(0.3)
                                        : AppColors.paynesGray.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isLoggedIn
                                          ? Icons.person_pin
                                          : Icons.info_outline,
                                      color: _isLoggedIn
                                          ? AppColors.keppel
                                          : AppColors.paynesGray,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _isLoggedIn
                                            ? "Conectado como: $_userName"
                                            : "Inicia sesión para agregar productos.",
                                        style: AppTextStyles.body.copyWith(
                                          color: _isLoggedIn
                                              ? AppColors.keppel
                                              : AppColors.paynesGray,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
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