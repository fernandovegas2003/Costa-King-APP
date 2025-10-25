import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PagoScreen extends StatefulWidget {
  final Map<String, dynamic> factura;
  final VoidCallback? onPagoExitoso;

  const PagoScreen({
    super.key,
    required this.factura,
    this.onPagoExitoso,
  });

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  bool _procesando = false;
  String? _metodoSeleccionado;
  String? numeroDocumento;

  // Controladores para PayPal
  final TextEditingController _emailPayPalController = TextEditingController();
  final TextEditingController _passwordPayPalController = TextEditingController();

  // Controladores para Tarjeta
  final TextEditingController _numeroTarjetaController = TextEditingController();
  final TextEditingController _fechaExpiracionController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nombreTitularController = TextEditingController();

  // Controladores para PSE
  final TextEditingController _emailPSEController = TextEditingController();
  final TextEditingController _numeroDocumentoPSEController = TextEditingController();

  String? _tipoPersonaPSE;
  String? _tipoDocumentoPSE;
  String? _bancoSeleccionadoPSE;

  final List<String> bancosPSE = [
    'Bancolombia',
    'Banco de Bogotá',
    'Davivienda',
    'BBVA',
    'Banco de Occidente',
    'Banco Popular',
    'Scotiabank Colpatria',
    'Citibank',
    'Itaú',
    'Banco Caja Social',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDocumento();
  }

  Future<void> _cargarDocumento() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      numeroDocumento = prefs.getString('numeroDocumento');
    });
    print("📄 Documento del usuario: $numeroDocumento");
  }

  @override
  void dispose() {
    _emailPayPalController.dispose();
    _passwordPayPalController.dispose();
    _numeroTarjetaController.dispose();
    _fechaExpiracionController.dispose();
    _cvvController.dispose();
    _nombreTitularController.dispose();
    _emailPSEController.dispose();
    _numeroDocumentoPSEController.dispose();
    super.dispose();
  }

  Future<void> _procesarPago() async {
    if (_metodoSeleccionado == null) {
      _mostrarError("Por favor selecciona un método de pago");
      return;
    }

    // Validar formularios según el método seleccionado
    if (!_validarFormulario()) {
      return;
    }

    setState(() => _procesando = true);

    try {
      // Simular procesamiento de pago
      await Future.delayed(const Duration(seconds: 3));

      // Simular diferentes resultados basados en el método de pago
      final randomValue = DateTime.now().millisecond % 10;
      bool exito = randomValue > 2; // 70% de éxito

      if (exito) {
        // Eliminar factura del backend
        final idFactura = widget.factura['idFactura'];
        final response = await http.delete(
          Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/facturas/$idFactura",
          ),
        );

        setState(() => _procesando = false);

        if (response.statusCode == 200) {
          _mostrarComprobanteExitoso();
        } else {
          _mostrarError("Error al eliminar factura: ${response.statusCode}");
        }
      } else {
        setState(() => _procesando = false);
        _mostrarErrorPagoFallido();
      }
    } catch (e) {
      setState(() => _procesando = false);
      _mostrarError("Error de conexión: $e");
    }
  }

  bool _validarFormulario() {
    switch (_metodoSeleccionado) {
      case 'PayPal':
        if (_emailPayPalController.text.isEmpty ||
            _passwordPayPalController.text.isEmpty) {
          _mostrarError("Por favor completa todos los campos de PayPal");
          return false;
        }
        if (!_emailPayPalController.text.contains('@')) {
          _mostrarError("Email de PayPal inválido");
          return false;
        }
        return true;

      case 'Tarjeta':
        if (_numeroTarjetaController.text.isEmpty ||
            _fechaExpiracionController.text.isEmpty ||
            _cvvController.text.isEmpty ||
            _nombreTitularController.text.isEmpty) {
          _mostrarError("Por favor completa todos los campos de la tarjeta");
          return false;
        }
        final cleanedCard = _numeroTarjetaController.text.replaceAll(RegExp(r'\s+'), '');
        if (cleanedCard.length != 16) {
          _mostrarError("Número de tarjeta inválido");
          return false;
        }
        if (_cvvController.text.length < 3) {
          _mostrarError("CVV inválido");
          return false;
        }
        return true;

      case 'PSE':
        if (_tipoPersonaPSE == null ||
            _tipoDocumentoPSE == null ||
            _numeroDocumentoPSEController.text.isEmpty ||
            _bancoSeleccionadoPSE == null ||
            _emailPSEController.text.isEmpty) {
          _mostrarError("Por favor completa todos los campos de PSE");
          return false;
        }
        return true;

      default:
        return false;
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarComprobanteExitoso() {
    final transactionId = '${_metodoSeleccionado!.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('¡Pago Exitoso!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComprobanteItem('Factura:', widget.factura['numeroFactura']),
              _buildComprobanteItem('Transacción:', transactionId),
              _buildComprobanteItem('Método:', _metodoSeleccionado!),
              _buildComprobanteItem('Total:', '\$${widget.factura['total']}'),
              _buildComprobanteItem('Fecha:', _formatearFecha(DateTime.now().toIso8601String())),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✅ La factura ha sido pagada exitosamente',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onPagoExitoso != null) widget.onPagoExitoso!();
              Navigator.pop(context, true);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _mostrarErrorPagoFallido() {
    String mensajeError;
    String sugerencia;

    switch (_metodoSeleccionado) {
      case 'PayPal':
        mensajeError = "Pago rechazado por PayPal";
        sugerencia = "Verifica el saldo de tu cuenta PayPal";
        break;
      case 'Tarjeta':
        mensajeError = "Tarjeta rechazada";
        sugerencia = "Intente con otra tarjeta o método de pago";
        break;
      case 'PSE':
        mensajeError = "Transacción PSE rechazada";
        sugerencia = "Intente nuevamente o use otro método de pago";
        break;
      default:
        mensajeError = "Error en el pago";
        sugerencia = "Intente nuevamente";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error en el Pago'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mensajeError),
            const SizedBox(height: 8),
            Text(sugerencia, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildComprobanteItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }

  Widget _buildFormularioPayPal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingresa a tu cuenta PayPal',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailPayPalController,
            decoration: const InputDecoration(
              labelText: 'Email de PayPal',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordPayPalController,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Datos de prueba: usuario@example.com / cualquier contraseña',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioTarjeta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de la Tarjeta',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _numeroTarjetaController,
            decoration: const InputDecoration(
              labelText: 'Número de Tarjeta',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(),
              hintText: '1234 5678 9012 3456',
            ),
            keyboardType: TextInputType.number,
            maxLength: 19,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _fechaExpiracionController,
                  decoration: const InputDecoration(
                    labelText: 'MM/AA',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                    hintText: '12/25',
                  ),
                  maxLength: 5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    hintText: '123',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nombreTitularController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Titular',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
              hintText: 'JUAN PEREZ',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.credit_card, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tarjeta de prueba: 4111 1111 1111 1111 / 12/25 / 123',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioPSE() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información para PSE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _tipoPersonaPSE,
            decoration: const InputDecoration(
              labelText: 'Tipo de Persona',
              border: OutlineInputBorder(),
            ),
            items: ['Natural', 'Jurídica'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _tipoPersonaPSE = value;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tipoDocumentoPSE,
            decoration: const InputDecoration(
              labelText: 'Tipo de Documento',
              border: OutlineInputBorder(),
            ),
            items: ['Cédula de Ciudadanía', 'Cédula de Extranjería', 'NIT', 'Pasaporte']
                .map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _tipoDocumentoPSE = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numeroDocumentoPSEController,
            decoration: const InputDecoration(
              labelText: 'Número de Documento',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _bancoSeleccionadoPSE,
            decoration: const InputDecoration(
              labelText: 'Selecciona tu Banco',
              border: OutlineInputBorder(),
            ),
            items: bancosPSE.map((String banco) {
              return DropdownMenuItem<String>(value: banco, child: Text(banco));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _bancoSeleccionadoPSE = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailPSEController,
            decoration: const InputDecoration(
              labelText: 'Email para confirmación',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioSeleccionado() {
    switch (_metodoSeleccionado) {
      case 'PayPal':
        return _buildFormularioPayPal();
      case 'Tarjeta':
        return _buildFormularioTarjeta();
      case 'PSE':
        return _buildFormularioPSE();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMetodoPagoOption(String metodo, IconData icono, Color color) {
    final activo = _metodoSeleccionado == metodo;
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icono, color: activo ? color : Colors.grey),
        title: Text(metodo, style: TextStyle(
          fontWeight: FontWeight.w600,
          color: activo ? color : Colors.black87,
        )),
        trailing: Radio<String>(
          value: metodo,
          groupValue: _metodoSeleccionado,
          onChanged: (value) => setState(() => _metodoSeleccionado = value),
          activeColor: color,
        ),
        onTap: () => setState(() => _metodoSeleccionado = metodo),
        tileColor: activo ? color.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: activo ? color : Colors.grey.shade300,
            width: activo ? 2 : 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final factura = widget.factura;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pago de Factura"),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen de Factura
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "RESUMEN DE FACTURA",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Número:', factura['numeroFactura'] ?? '---'),
                    _buildInfoRow('Concepto:', factura['concepto'] ?? '---'),
                    _buildInfoRow('Paciente:', factura['nombreCompletoPaciente'] ?? '---'),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'TOTAL A PAGAR:',
                      '\$${factura['total'] ?? '0'}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Selección de Método de Pago
            const Text(
              "SELECCIONA MÉTODO DE PAGO",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            _buildMetodoPagoOption("PayPal", Icons.account_balance_wallet, Colors.blue),
            const SizedBox(height: 8),
            _buildMetodoPagoOption("Tarjeta", Icons.credit_card, Colors.green),
            const SizedBox(height: 8),
            _buildMetodoPagoOption("PSE", Icons.account_balance, Colors.orange),

            // Formulario según método seleccionado
            if (_metodoSeleccionado != null) ...[
              const SizedBox(height: 24),
              _buildFormularioSeleccionado(),
            ],

            // Información de Sandbox
            if (_metodoSeleccionado != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'MODO PRUEBA ACTIVADO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('🔒 Este es un entorno seguro de pruebas'),
                    Text('💳 No se realizarán cargos reales'),
                    Text('✅ Usa datos de prueba para simular pagos'),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botón de Pago
            if (_procesando)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Procesando pago...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else if (_metodoSeleccionado != null)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _procesarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'PAGAR \$${factura['total'] ?? '0'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
                color: isTotal ? Colors.green : Colors.black,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}