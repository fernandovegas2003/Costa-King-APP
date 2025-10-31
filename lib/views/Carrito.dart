import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

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
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.keppel,
    fontSize: 12,
    fontFamily: _fontFamily,
  );
}

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  List<Map<String, dynamic>> _carritoItems = [];
  int _selectedIndex = 1;
  bool _cargando = true;

  final String _fixedToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjQ4LCJyb2wiOiJ1c3VhcmlvIiwiY29ycmVvIjoianVhbm11bm96cm9qYXM5NEBnbWFpbC5jb20iLCJpYXQiOjE3NjExOTc0NDMsImV4cCI6NDkxNjk1NzQ0M30.IHCIWNpKs0OEmr8UMaw9Tbs6AHPlAjzLcOU-mZ4B85k";
  final int _fixedUserId = 48;

  @override
  void initState() {
    super.initState();
    _fetchCarrito();
  }

  Future<void> _fetchCarrito() async {
    try {
      print('🛒 Obteniendo carrito para usuario: $_fixedUserId');
      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backecommerce.onrender.com/carrito/$_fixedUserId",
        ),
        headers: {'Authorization': 'Bearer $_fixedToken'},
      );
      print('📡 Respuesta carrito: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _carritoItems = _convertNewApiResponseToUiFormat(data);
        setState(() => _cargando = false);
      } else if (response.statusCode == 404) {
        _carritoItems = [];
        setState(() => _cargando = false);
      } else {
        print('❌ Error obteniendo carrito: ${response.body}');
        setState(() => _cargando = false);
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      setState(() => _cargando = false);
    }
  }

  List<Map<String, dynamic>> _convertNewApiResponseToUiFormat(dynamic apiData) {
    if (apiData is List) {
      return apiData.map((item) {
        return {
          'id': item['idProducto'] ?? 0,
          'nombre': item['Producto'] ?? 'Producto',
          'precio':
              double.tryParse(item['PrecioUnitario']?.toString() ?? '0') ?? 0.0,
          'cantidad': item['Cantidad'] ?? 1,
          'imagen': item['Imagen'] ?? 'https://via.placeholder.com/80',
          'categoria': item['Talla'] ?? 'General',
          'marca': item['Marca'] ?? '',
          'subtotal':
              double.tryParse(item['Subtotal']?.toString() ?? '0') ?? 0.0,
        };
      }).toList();
    }
    return [];
  }

  Future<void> _aumentarCantidad(int index) async {
    final item = _carritoItems[index];
    try {
      print('➕ Aumentando cantidad para producto: ${item['id']}');
      final response = await http.put(
        Uri.parse(
          "https://blesshealth24-7-backecommerce.onrender.com/carrito/aumentar",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_fixedToken',
        },
        body: jsonEncode({"usuarioId": _fixedUserId, "productoId": item['id']}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _carritoItems[index]['cantidad'] += 1;
          _carritoItems[index]['subtotal'] =
              _carritoItems[index]['precio'] * _carritoItems[index]['cantidad'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cantidad aumentada'),
            backgroundColor: AppColors.keppel,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al aumentar cantidad'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disminuirCantidad(int index) async {
    final item = _carritoItems[index];
    if (item['cantidad'] <= 1) {
      _eliminarItem(index);
      return;
    }
    try {
      final response = await http.put(
        Uri.parse(
          "https://blesshealth24-7-backecommerce.onrender.com/carrito/disminuir",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_fixedToken',
        },
        body: jsonEncode({"usuarioId": _fixedUserId, "productoId": item['id']}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _carritoItems[index]['cantidad'] -= 1;
          _carritoItems[index]['subtotal'] =
              _carritoItems[index]['precio'] * _carritoItems[index]['cantidad'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cantidad disminuida'),
            backgroundColor: AppColors.keppel,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al disminuir cantidad'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarItem(int index) async {
    final item = _carritoItems[index];
    final itemEliminado = Map<String, dynamic>.from(_carritoItems[index]);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            Text(
              'Eliminar Producto',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${item['nombre']}" del carrito?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.paynesGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _carritoItems.removeAt(index);
    });

    try {
      final response = await http.delete(
        Uri.parse(
          "https://blesshealth24-7-backecommerce.onrender.com/carrito/eliminar",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_fixedToken',
        },
        body: jsonEncode({"usuarioId": _fixedUserId, "productoId": item['id']}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item['nombre']}" eliminado del carrito'),
            backgroundColor: AppColors.keppel,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Deshacer',
              textColor: AppColors.white,
              onPressed: () => _agregarProducto(itemEliminado),
            ),
          ),
        );
      } else {
        setState(() {
          _carritoItems.insert(index, itemEliminado);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _carritoItems.insert(index, itemEliminado);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al eliminar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarTodoElCarrito() async {
    if (_carritoItems.isEmpty) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.remove_shopping_cart, color: Colors.red[700]),
            const SizedBox(width: 8),
            Text(
              'Vaciar Carrito',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar todos los productos (${_carritoItems.length}) del carrito?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.paynesGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Vaciar Todo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    final itemsEliminados = List<Map<String, dynamic>>.from(_carritoItems);
    setState(() {
      _carritoItems.clear();
    });
    try {
      int eliminadosExitosos = 0;
      for (final item in itemsEliminados) {
        final response = await http.delete(
          Uri.parse(
            "https://blesshealth24-7-backecommerce.onrender.com/carrito/eliminar",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_fixedToken',
          },
          body: jsonEncode({
            "usuarioId": _fixedUserId,
            "productoId": item['id'],
          }),
        );
        if (response.statusCode == 200) {
          eliminadosExitosos++;
        }
      }
      if (eliminadosExitosos == itemsEliminados.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Carrito vaciado correctamente'),
            backgroundColor: AppColors.keppel,
          ),
        );
      } else {
        setState(() {
          _carritoItems.addAll(itemsEliminados);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al vaciar algunos productos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _carritoItems.addAll(itemsEliminados);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al vaciar carrito'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _agregarProducto(Map<String, dynamic> producto) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://blesshealth24-7-backecommerce.onrender.com/carrito/agregar",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_fixedToken',
        },
        body: jsonEncode({
          "usuarioId": _fixedUserId,
          "productoId": producto['id'],
          "cantidad": producto['cantidad'],
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _carritoItems.add(producto);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto restaurado'),
            backgroundColor: AppColors.keppel,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al restaurar producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al restaurar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _procederPago() {
    if (_carritoItems.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.shopping_bag, color: AppColors.keppel),
            const SizedBox(width: 8),
            Text(
              'Confirmar Pedido',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subtotal: \$${_subtotal.toStringAsFixed(2)}',
              style: AppTextStyles.body,
            ),
            Text(
              'Envío: \$${_envio.toStringAsFixed(2)}',
              style: AppTextStyles.body,
            ),
            Text(
              'Total: \$${_total.toStringAsFixed(2)}',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_carritoItems.length} productos en el carrito',
              style: AppTextStyles.cardDescription,
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Deseas proceder con el pago?',
              style: AppTextStyles.body,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.paynesGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.paynesGray,
            ),
            onPressed: () {
              Navigator.pop(context);
              _realizarPedido();
            },
            child: const Text(
              'Confirmar Pedido',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _realizarPedido() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Pedido realizado con éxito!'),
          backgroundColor: AppColors.keppel,
          duration: Duration(seconds: 3),
        ),
      );
      await _limpiarCarrito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _limpiarCarrito() async {
    try {
      for (var item in List.from(_carritoItems)) {
        await http.delete(
          Uri.parse(
            "https://blesshealth24-7-backecommerce.onrender.com/carrito/eliminar",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_fixedToken',
          },
          body: jsonEncode({
            "usuarioId": _fixedUserId,
            "productoId": item['id'],
          }),
        );
      }
      setState(() {
        _carritoItems.clear();
      });
    } catch (e) {
      print('❌ Error limpiando carrito: $e');
    }
  }

  double get _subtotal {
    return _carritoItems.fold(
      0,
      (sum, item) => sum + (item['precio'] * item['cantidad']),
    );
  }

  double get _envio {
    return _carritoItems.isEmpty ? 0 : 2.99;
  }

  double get _total {
    return _subtotal + _envio;
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
          child: Column(
            children: [
              const CustomNavbar(),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.keppel, AppColors.paynesGray],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: AppColors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mi Carrito",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                _cargando
                                    ? "Cargando..."
                                    : "Gestiona tus productos seleccionados",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white.withOpacity(
                                    0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_cargando && _carritoItems.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_sweep,
                              color: AppColors.white,
                            ),
                            onPressed: _eliminarTodoElCarrito,
                            tooltip: 'Vaciar carrito',
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!_cargando)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${_carritoItems.length} ${_carritoItems.length == 1 ? 'producto' : 'productos'} - Total: \$${_total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: _cargando
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.aquamarine,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Cargando carrito...",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _carritoItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: AppColors.paynesGray.withOpacity(
                                0.3,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Tu carrito está vacío",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray.withOpacity(
                                  0.7,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Agrega productos para verlos aquí",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _carritoItems.length,
                              itemBuilder: (context, index) {
                                final item = _carritoItems[index];
                                return _buildItemCarrito(
                                  item,
                                  index,
                                );
                              },
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(
                                0.7,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.paynesGray.withOpacity(
                                    0.1,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildLineaResumen(
                                  'Subtotal',
                                  _subtotal,
                                ),
                                _buildLineaResumen(
                                  'Envío',
                                  _envio,
                                ),
                                const Divider(
                                  color: AppColors.keppel,
                                ),
                                _buildLineaResumen(
                                  'Total',
                                  _total,
                                  isTotal: true,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.payment, size: 20),
                                    onPressed: _procederPago,
                                    label: Text(
                                      "Proceder al Pago",
                                      style: AppTextStyles.button,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.aquamarine,
                                      foregroundColor:
                                          AppColors.paynesGray,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      elevation: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              CustomFooterNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCarrito(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.paynesGray.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.iceBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['imagen'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.iceBlue,
                    child: Icon(
                      Icons.photo,
                      color: AppColors.keppel,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nombre'],
                  style: AppTextStyles.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item['marca'] != null && item['marca'].isNotEmpty)
                  Text(
                    'Marca: ${item['marca']}',
                    style: AppTextStyles.cardDescription,
                  ),
                Text(
                  'Talla: ${item['categoria']}',
                  style: AppTextStyles.cardDescription,
                ),
                const SizedBox(height: 8),
                Text(
                  'Precio: \$${item['precio']} c/u',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Subtotal: \$${(item['precio'] * item['cantidad']).toStringAsFixed(2)}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.keppel,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.iceBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 18,
                        color: AppColors.paynesGray,
                      ),
                      onPressed: () => _disminuirCantidad(index),
                    ),
                    Text(
                      '${item['cantidad']}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.paynesGray,
                      ),
                      onPressed: () => _aumentarCantidad(index),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: () => _eliminarItem(index),
                tooltip: 'Eliminar producto',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineaResumen(
    String label,
    double valor, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )
                : AppTextStyles.body.copyWith(
                    color: AppColors.paynesGray.withOpacity(0.8),
                  ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: isTotal
                ? AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )
                : AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ],
      ),
    );
  }
}