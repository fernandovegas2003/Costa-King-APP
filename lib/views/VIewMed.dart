import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
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
  int _cantidad = 1;

  // 🔹 Variables para el usuario
  int? _userId;
  String? _token;
  String? _userName;
  bool _isLoggedIn = false;

  // 🔹 TOKEN FIJO PARA PRUEBAS
  final String _fixedToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjQ4LCJyb2wiOiJ1c3VhcmlvIiwiY29ycmVvIjoianVhbm11bm96cm9qYXM5NEBnbWFpbC5jb20iLCJpYXQiOjE3NjExOTc0NDMsImV4cCI6NDkxNjk1NzQ0M30.IHCIWNpKs0OEmr8UMaw9Tbs6AHPlAjzLcOU-mZ4B85k";

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
        _token = _fixedToken; // 🔹 USAR TOKEN FIJO
        _userName = authService.userName;
        _isLoggedIn = true; // 🔹 FORZAR COMO LOGUEADO
      });

      print('👤 Usuario cargado: ID: $_userId');
      print('🔐 Token fijo cargado');

    } catch (e) {
      print('❌ Error cargando datos de usuario: $e');
    }
  }

  // 🔹 MÉTODO SIMPLIFICADO PARA AGREGAR AL CARRITO
  Future<void> _agregarAlCarrito() async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Debes iniciar sesión para agregar al carrito"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('🛒 Enviando solicitud al carrito...');
      print('📦 Datos: usuarioId: $_userId, productoId: ${widget.idProducto}, cantidad: $_cantidad');
      print('🔐 Token: ${_token!.substring(0, 50)}...');

      // 🔹 USAR SOLAMENTE LA ESTRUCTURA QUE FUNCIONA EN POSTMAN
      final response = await http.post(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/agregar"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // 🔹 TOKEN FIJO
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
            backgroundColor: Colors.green,
          ),
        );
        print('✅ Producto agregado al carrito - Usuario: $_userId, Producto: ${widget.idProducto}');
      } else {
        String errorMessage = "Error desconocido";
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? errorData['message'] ?? response.body;
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

  // 🔹 MÉTODO PARA IR AL LOGIN
  void _irALogin() {
    Navigator.pushNamed(context, '/login');
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
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.photo, size: 50, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nombre del producto
                      Text(
                        _producto!["nombreProducto"] ?? "Producto",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Descripción
                      Text(
                        _producto!["descripcionProducto"] ?? "Sin descripción",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // Precio
                      Text(
                        "Precio: \$${_producto!["precioProducto"] ?? "0.00"}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Stock
                      Text(
                        "Stock disponible: ${_producto!["stockProducto"] ?? 0}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Promoción
                      if (_producto!["promocion"] != null)
                        Text(
                          "Promoción: ${_producto!["promocion"]}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // 🔹 SELECTOR DE CANTIDAD
                      Row(
                        children: [
                          const Text(
                            "Cantidad:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: _cantidad > 1
                                      ? () => setState(() => _cantidad--)
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    '$_cantidad',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: _cantidad < (_producto!["stockProducto"] ?? 1)
                                      ? () => setState(() => _cantidad++)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // 🔹 BOTÓN MEJORADO
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoggedIn ? _agregarAlCarrito : _irALogin,
                              icon: Icon(_isLoggedIn ? Icons.add_shopping_cart : Icons.login),
                              label: Text(
                                _isLoggedIn
                                    ? "Agregar al carrito ($_cantidad)"
                                    : "Iniciar sesión para comprar",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isLoggedIn
                                    ? Colors.teal
                                    : Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 🔹 INFO DEL USUARIO
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isLoggedIn ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _isLoggedIn ? Colors.green[100]! : Colors.orange[100]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isLoggedIn ? Icons.person : Icons.warning,
                              color: _isLoggedIn ? Colors.green[700] : Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isLoggedIn
                                    ? "Conectado como: $_userName"
                                    : "Inicia sesión para agregar productos al carrito",
                                style: TextStyle(
                                  color: _isLoggedIn ? Colors.green[700] : Colors.orange[700],
                                  fontWeight: FontWeight.w500,
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