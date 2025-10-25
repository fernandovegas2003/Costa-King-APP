import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../componentes/navbar/footer.dart';
import '../componentes/navbar/navbar.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  List<Map<String, dynamic>> _carritoItems = [];
  int _selectedIndex = 1;
  bool _cargando = true;

  // 🔹 TOKEN ESTÁTICO Y USER ID FIJO
  final String _fixedToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjQ4LCJyb2wiOiJ1c3VhcmlvIiwiY29ycmVvIjoianVhbm11bm96cm9qYXM5NEBnbWFpbC5jb20iLCJpYXQiOjE3NjExOTc0NDMsImV4cCI6NDkxNjk1NzQ0M30.IHCIWNpKs0OEmr8UMaw9Tbs6AHPlAjzLcOU-mZ4B85k";
  final int _fixedUserId = 48;

  @override
  void initState() {
    super.initState();
    _fetchCarrito();
  }

  // 🔹 OBTENER CARRITO DESDE LA NUEVA API
  Future<void> _fetchCarrito() async {
    try {
      print('🛒 Obteniendo carrito para usuario: $_fixedUserId');

      final response = await http.get(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/$_fixedUserId"),
        headers: {
          'Authorization': 'Bearer $_fixedToken',
        },
      );

      print('📡 Respuesta carrito: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 Datos del carrito: $data');

        // Convertir la respuesta de la nueva API al formato de UI
        _carritoItems = _convertNewApiResponseToUiFormat(data);
        setState(() => _cargando = false);

      } else if (response.statusCode == 404) {
        // Carrito vacío
        print('🛒 Carrito vacío');
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

  // 🔹 CONVERTIR NUEVA RESPUESTA DE API AL FORMATO DE UI
  List<Map<String, dynamic>> _convertNewApiResponseToUiFormat(dynamic apiData) {
    if (apiData is List) {
      return apiData.map((item) {
        return {
          'id': item['idProducto'] ?? 0,
          'nombre': item['Producto'] ?? 'Producto',
          'precio': double.tryParse(item['PrecioUnitario']?.toString() ?? '0') ?? 0.0,
          'cantidad': item['Cantidad'] ?? 1,
          'imagen': item['Imagen'] ?? 'https://via.placeholder.com/80',
          'categoria': item['Talla'] ?? 'General',
          'marca': item['Marca'] ?? '',
          'subtotal': double.tryParse(item['Subtotal']?.toString() ?? '0') ?? 0.0,
        };
      }).toList();
    }
    return [];
  }

  // 🔹 AUMENTAR CANTIDAD CON NUEVO ENDPOINT
  Future<void> _aumentarCantidad(int index) async {
    final item = _carritoItems[index];

    try {
      print('➕ Aumentando cantidad para producto: ${item['id']}');

      final response = await http.put(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/aumentar"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_fixedToken',
        },
        body: jsonEncode({
          "usuarioId": _fixedUserId,
          "productoId": item['id'],
        }),
      );

      print('📡 Respuesta aumentar: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        // Actualizar UI inmediatamente
        setState(() {
          _carritoItems[index]['cantidad'] += 1;
          _carritoItems[index]['subtotal'] = _carritoItems[index]['precio'] * _carritoItems[index]['cantidad'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cantidad aumentada'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        print('❌ Error aumentando cantidad: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al aumentar cantidad'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error de conexión al aumentar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 DISMINUIR CANTIDAD CON NUEVO ENDPOINT
  Future<void> _disminuirCantidad(int index) async {
    final item = _carritoItems[index];

    if (item['cantidad'] <= 1) {
      // Si la cantidad es 1, eliminar el producto
      _eliminarItem(index);
      return;
    }

    try {
      print('➖ Disminuyendo cantidad para producto: ${item['id']}');

      final response = await http.put(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/disminuir"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_fixedToken',
        },
        body: jsonEncode({
          "usuarioId": _fixedUserId,
          "productoId": item['id'],
        }),
      );

      print('📡 Respuesta disminuir: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        // Actualizar UI inmediatamente
        setState(() {
          _carritoItems[index]['cantidad'] -= 1;
          _carritoItems[index]['subtotal'] = _carritoItems[index]['precio'] * _carritoItems[index]['cantidad'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cantidad disminuida'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        print('❌ Error disminuyendo cantidad: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al disminuir cantidad'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error de conexión al disminuir: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 ELIMINAR ITEM DEL CARRITO - MEJORADO
  Future<void> _eliminarItem(int index) async {
    final item = _carritoItems[index];
    final itemEliminado = Map<String, dynamic>.from(_carritoItems[index]);

    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Producto'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${item['nombre']}" del carrito?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Eliminación inmediata para mejor UX
    setState(() {
      _carritoItems.removeAt(index);
    });

    try {
      print('🗑️ Eliminando producto: ${item['id']}');

      final response = await http.delete(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/eliminar"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_fixedToken',
        },
        body: jsonEncode({
          "usuarioId": _fixedUserId,
          "productoId": item['id'],
        }),
      );

      print('📡 Respuesta eliminar: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item['nombre']}" eliminado del carrito'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Deshacer',
              textColor: Colors.white,
              onPressed: () => _agregarProducto(itemEliminado),
            ),
          ),
        );
      } else {
        // Si falla, revertir la eliminación
        setState(() {
          _carritoItems.insert(index, itemEliminado);
        });
        print('❌ Error eliminando item: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Revertir en caso de error de conexión
      setState(() {
        _carritoItems.insert(index, itemEliminado);
      });
      print('❌ Error de conexión al eliminar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al eliminar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 ELIMINAR TODOS LOS PRODUCTOS DEL CARRITO
  Future<void> _eliminarTodoElCarrito() async {
    if (_carritoItems.isEmpty) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.remove_shopping_cart, color: Colors.red),
            SizedBox(width: 8),
            Text('Vaciar Carrito'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar todos los productos (${_carritoItems.length}) del carrito?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vaciar Todo'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final itemsEliminados = List<Map<String, dynamic>>.from(_carritoItems);

    // Eliminación inmediata
    setState(() {
      _carritoItems.clear();
    });

    try {
      // Eliminar cada producto individualmente
      int eliminadosExitosos = 0;

      for (final item in itemsEliminados) {
        final response = await http.delete(
          Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/eliminar"),
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
          const SnackBar(
            content: Text('Carrito vaciado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Revertir si no se pudieron eliminar todos
        setState(() {
          _carritoItems.addAll(itemsEliminados);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al vaciar algunos productos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Revertir en caso de error
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

  // 🔹 AGREGAR PRODUCTO (PARA DESHACER ELIMINACIÓN)
  Future<void> _agregarProducto(Map<String, dynamic> producto) async {
    try {
      final response = await http.post(
        Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/agregar"),
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
          const SnackBar(
            content: Text('Producto restaurado'),
            backgroundColor: Colors.green,
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
      print('❌ Error restaurando producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al restaurar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 PROCEDER AL PAGO
  void _procederPago() {
    if (_carritoItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shopping_bag, color: Color(0xFF006D73)),
            SizedBox(width: 8),
            Text('Confirmar Pedido'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subtotal: \$${_subtotal.toStringAsFixed(2)}'),
            Text('Envío: \$${_envio.toStringAsFixed(2)}'),
            Text('Total: \$${_total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('${_carritoItems.length} productos en el carrito'),
            const SizedBox(height: 8),
            const Text('¿Deseas proceder con el pago?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D73),
            ),
            onPressed: () {
              Navigator.pop(context);
              _realizarPedido();
            },
            child: const Text('Confirmar Pedido'),
          ),
        ],
      ),
    );
  }

  // 🔹 REALIZAR PEDIDO
  Future<void> _realizarPedido() async {
    try {
      // Aquí iría la lógica para crear el pedido
      // Por ahora solo mostramos éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido realizado con éxito!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Limpiar carrito después del pedido
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

  // 🔹 LIMPIAR CARRITO
  Future<void> _limpiarCarrito() async {
    try {
      // Para cada producto en el carrito, eliminarlo
      for (var item in List.from(_carritoItems)) {
        await http.delete(
          Uri.parse("https://blesshealth24-7-backecommerce.onrender.com/carrito/eliminar"),
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
    return _carritoItems.fold(0, (sum, item) => sum + (item['precio'] * item['cantidad']));
  }

  double get _envio {
    return _carritoItems.isEmpty ? 0 : 2.99; // Envío fijo solo si hay productos
  }

  double get _total {
    return _subtotal + _envio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFE),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Navbar
            const CustomNavbar(),

            // 🔹 Header elegante
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF006D73),
                    Color(0xFF00A5A5),
                  ],
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
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
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
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _cargando ? "Cargando..." : "Gestiona tus productos seleccionados",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_cargando && _carritoItems.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.white),
                          onPressed: _eliminarTodoElCarrito,
                          tooltip: 'Vaciar carrito',
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (!_cargando)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_carritoItems.length} ${_carritoItems.length == 1 ? 'producto' : 'productos'} - Total: \$${_total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 🔹 Contenido principal
            Expanded(
              child: _cargando
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF006D73)),
                    SizedBox(height: 16),
                    Text(
                      "Cargando carrito...",
                      style: TextStyle(
                        color: Color(0xFF006D73),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : _carritoItems.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Color(0xFFCCCCCC),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Tu carrito está vacío",
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Agrega productos para verlos aquí",
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : Column(
                children: [
                  // 🔹 Lista de productos
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _carritoItems.length,
                      itemBuilder: (context, index) {
                        final item = _carritoItems[index];
                        return _buildItemCarrito(item, index);
                      },
                    ),
                  ),

                  // 🔹 Resumen del pedido
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildLineaResumen('Subtotal', _subtotal),
                        _buildLineaResumen('Envío', _envio),
                        const Divider(),
                        _buildLineaResumen('Total', _total, isTotal: true),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.payment, size: 20),
                            onPressed: _procederPago,
                            label: const Text(
                              "Proceder al Pago",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006D73),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
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

            // 🔹 Footer
            CustomFooterNav(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCarrito(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Imagen del producto
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['imagen'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE6F9FA),
                    child: const Icon(Icons.photo, color: Color(0xFF006D73), size: 40),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 🔹 Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nombre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF006D73),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item['marca'] != null && item['marca'].isNotEmpty)
                  Text(
                    'Marca: ${item['marca']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                Text(
                  'Talla: ${item['categoria']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Precio: \$${item['precio']} c/u',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF006D73),
                  ),
                ),
                Text(
                  'Subtotal: \$${(item['precio'] * item['cantidad']).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Controles de cantidad y eliminar
          Column(
            children: [
              // 🔹 Contador de cantidad
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () => _disminuirCantidad(index),
                    ),
                    Text(
                      '${item['cantidad']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => _aumentarCantidad(index),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 🔹 Botón eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _eliminarItem(index),
                tooltip: 'Eliminar producto',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineaResumen(String label, double valor, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF006D73) : Colors.black87,
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF006D73) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}