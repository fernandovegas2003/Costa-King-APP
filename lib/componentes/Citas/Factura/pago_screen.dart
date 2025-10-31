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
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel, // 🎨 Color
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle total = TextStyle(
    color: AppColors.keppel, // 🎨 Color
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class PagoScreen extends StatefulWidget {
  final Map<String, dynamic> factura;
  final VoidCallback? onPagoExitoso;

  const PagoScreen({super.key, required this.factura, this.onPagoExitoso});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  bool _procesando = false;
  String? _metodoSeleccionado;
  String? numeroDocumento;

  // Controladores para PayPal
  final TextEditingController _emailPayPalController = TextEditingController();
  final TextEditingController _passwordPayPalController =
      TextEditingController();

  // Controladores para Tarjeta
  final TextEditingController _numeroTarjetaController =
      TextEditingController();
  final TextEditingController _fechaExpiracionController =
      TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nombreTitularController =
      TextEditingController();

  // Controladores para PSE
  final TextEditingController _emailPSEController = TextEditingController();
  final TextEditingController _numeroDocumentoPSEController =
      TextEditingController();

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

  // --- (TODA TU LÓGICA DE API, VALIDACIÓN Y PAGO SE MANTIENE EXACTAMENTE IGUAL) ---
  Future<void> _cargarDocumento() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      numeroDocumento = prefs.getString('numeroDocumento');
    });
    print("📄 Documento del usuario: $numeroDocumento");
  }

  Future<void> _procesarPago() async {
    if (_metodoSeleccionado == null) {
      _mostrarError("Por favor selecciona un método de pago");
      return;
    }
    if (!_validarFormulario()) {
      return;
    }
    setState(() => _procesando = true);
    try {
      await Future.delayed(const Duration(seconds: 3));
      final randomValue = DateTime.now().millisecond % 10;
      bool exito = randomValue > 2; // 70% de éxito

      if (exito) {
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
        final cleanedCard = _numeroTarjetaController.text.replaceAll(
          RegExp(r'\s+'),
          '',
        );
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
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red[700]),
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

  // --- (FIN DE LA LÓGICA) ---

  // 🎨 --- DIÁLOGOS REDISEÑADOS --- 🎨
  void _mostrarComprobanteExitoso() {
    final transactionId =
        '${_metodoSeleccionado!.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white, // 🎨 Color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.keppel), // 🎨 Color
            SizedBox(width: 8),
            Text(
              '¡Pago Exitoso!',
              style: AppTextStyles.headline.copyWith(
                fontSize: 20,
                color: AppColors.keppel,
              ),
            ), // 🎨 Estilo
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComprobanteItem(
                'Factura:',
                widget.factura['numeroFactura'],
              ),
              _buildComprobanteItem('Transacción:', transactionId),
              _buildComprobanteItem('Método:', _metodoSeleccionado!),
              _buildComprobanteItem(
                'Total:',
                '\$${widget.factura['total']}',
                isTotal: true,
              ), // 🎨 Estilo
              _buildComprobanteItem(
                'Fecha:',
                _formatearFecha(DateTime.now().toIso8601String()),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.keppel.withOpacity(0.1), // 🎨 Color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✅ La factura ha sido pagada exitosamente',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.keppel,
                    fontSize: 14,
                  ), // 🎨 Estilo
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, // 🎨 Color
              foregroundColor: AppColors.paynesGray, // 🎨 Color
            ),
            onPressed: () {
              Navigator.pop(context);
              if (widget.onPagoExitoso != null) widget.onPagoExitoso!();
              Navigator.pop(context, true);
            },
            child: const Text(
              'Continuar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarErrorPagoFallido() {
    String mensajeError;
    String sugerencia;
    // ... (lógica de mensajes sin cambios)
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
        backgroundColor: AppColors.white, // 🎨 Color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]), // Semántico
            SizedBox(width: 8),
            Text(
              'Error en el Pago',
              style: AppTextStyles.headline.copyWith(
                fontSize: 20,
                color: Colors.red[700],
              ),
            ), // 🎨 Estilo
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mensajeError, style: AppTextStyles.body), // 🎨 Estilo
            const SizedBox(height: 8),
            Text(
              sugerencia,
              style: AppTextStyles.body.copyWith(
                color: AppColors.paynesGray.withOpacity(0.7),
                fontSize: 14,
              ),
            ), // 🎨 Estilo
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, // 🎨 Color
              foregroundColor: AppColors.paynesGray, // 🎨 Color
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Reintentar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 WIDGET HELPER REDISEÑADO
  Widget _buildComprobanteItem(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal
                    ? AppColors.keppel
                    : AppColors.paynesGray.withOpacity(0.7), // 🎨 Color
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isTotal
                  ? AppTextStyles.total
                  : AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ), // 🎨 Estilo
        ],
      ),
    );
  }

  // 🎨 Estilo de decoración base para los campos
  InputDecoration _formFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.paynesGray.withOpacity(0.7),
      ),
      prefixIcon: Icon(icon, color: AppColors.paynesGray, size: 20),
      filled: true,
      fillColor:
          AppColors.white, // Ligeramente diferente para formularios de pago
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // 🎨 Bordes más definidos
        borderSide: BorderSide(color: AppColors.iceBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.keppel, width: 2),
      ),
      errorStyle: TextStyle(
        color: Colors.red[700],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // 🎨 FORMULARIOS REDISEÑADOS
  Widget _buildFormularioPayPal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7), // 🎨 Color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresa a tu cuenta PayPal',
            style: AppTextStyles.cardTitle,
          ), // 🎨 Estilo
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailPayPalController,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration(
              'Email de PayPal',
              Icons.email_outlined,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordPayPalController,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration('Contraseña', Icons.lock_outline),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.iceBlue.withOpacity(0.5), // 🎨 Color
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.keppel,
                  size: 16,
                ), // 🎨 Color
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Datos de prueba: usuario@example.com / cualquier contraseña',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: AppColors.keppel,
                    ), // 🎨 Estilo
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
        color: AppColors.white.withOpacity(0.7), // 🎨 Color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de la Tarjeta',
            style: AppTextStyles.cardTitle,
          ), // 🎨 Estilo
          const SizedBox(height: 16),
          TextFormField(
            controller: _numeroTarjetaController,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration(
              'Número de Tarjeta',
              Icons.credit_card_outlined,
            ).copyWith(hintText: '1234 5678 9012 3456'),
            keyboardType: TextInputType.number,
            maxLength: 19,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _fechaExpiracionController,
                  style: AppTextStyles.body,
                  decoration: _formFieldDecoration(
                    'MM/AA',
                    Icons.calendar_today_outlined,
                  ).copyWith(hintText: '12/25'),
                  maxLength: 5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  style: AppTextStyles.body,
                  decoration: _formFieldDecoration(
                    'CVV',
                    Icons.lock_outline,
                  ).copyWith(hintText: '123'),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nombreTitularController,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration(
              'Nombre del Titular',
              Icons.person_outline,
            ).copyWith(hintText: 'JUAN PEREZ'),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.iceBlue.withOpacity(0.5), // 🎨 Color
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: AppColors.keppel,
                  size: 16,
                ), // 🎨 Color
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tarjeta de prueba: 4111 1111 1111 1111 / 12/25 / 123',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: AppColors.keppel,
                    ), // 🎨 Estilo
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
        color: AppColors.white.withOpacity(0.7), // 🎨 Color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información para PSE',
            style: AppTextStyles.cardTitle,
          ), // 🎨 Estilo
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _tipoPersonaPSE,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration(
              'Tipo de Persona',
              Icons.person_search_outlined,
            ),
            items: ['Natural', 'Jurídica'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) => setState(() => _tipoPersonaPSE = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tipoDocumentoPSE,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration(
              'Tipo de Documento',
              Icons.badge_outlined,
            ),
            items:
                [
                  'Cédula de Ciudadanía',
                  'Cédula de Extranjería',
                  'NIT',
                  'Pasaporte',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _tipoDocumentoPSE = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numeroDocumentoPSEController,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration(
              'Número de Documento',
              Icons.badge_outlined,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _bancoSeleccionadoPSE,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration(
              'Selecciona tu Banco',
              Icons.account_balance_outlined,
            ),
            items: bancosPSE.map((String banco) {
              return DropdownMenuItem<String>(value: banco, child: Text(banco));
            }).toList(),
            onChanged: (value) => setState(() => _bancoSeleccionadoPSE = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailPSEController,
            style: AppTextStyles.body,
            decoration: _formFieldDecoration(
              'Email para confirmación',
              Icons.email_outlined,
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

  // 🎨 MÉTODO DE PAGO REDISEÑADO
  Widget _buildMetodoPagoOption(String metodo, IconData icono, Color color) {
    final activo = _metodoSeleccionado == metodo;
    return Card(
      elevation: 2,
      color: activo
          ? AppColors.aquamarine.withOpacity(0.3)
          : AppColors.white.withOpacity(0.7), // 🎨 Color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: activo ? AppColors.aquamarine : AppColors.white, // 🎨 Color
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icono,
          color: activo ? AppColors.keppel : AppColors.paynesGray,
        ), // 🎨 Color
        title: Text(
          metodo,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: activo ? AppColors.keppel : AppColors.paynesGray, // 🎨 Color
          ),
        ),
        trailing: Radio<String>(
          value: metodo,
          groupValue: _metodoSeleccionado,
          onChanged: (value) => setState(() => _metodoSeleccionado = value),
          activeColor: AppColors.keppel, // 🎨 Color
        ),
        onTap: () => setState(() => _metodoSeleccionado = metodo),
      ),
    );
  }

  // 🎨 --- BUILD METHOD REDISEÑADO --- 🎨
  @override
  Widget build(BuildContext context) {
    final factura = widget.factura;

    return Scaffold(
      backgroundColor: AppColors.celeste, // 🎨 Color
      appBar: AppBar(
        title: Text(
          "Pago de Factura",
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ), // 🎨 Estilo
        backgroundColor: Colors.transparent, // 🎨 Color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ), // 🎨 Color
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de Factura (Rediseñado)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.7), // 🎨 Color
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.white), // 🎨 Color
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RESUMEN DE FACTURA",
                      style: AppTextStyles.cardTitle, // 🎨 Estilo
                    ),
                    Divider(
                      color: AppColors.keppel.withOpacity(0.5),
                      height: 20,
                      thickness: 1,
                    ), // 🎨 Color
                    _buildInfoRow('Número:', factura['numeroFactura'] ?? '---'),
                    _buildInfoRow('Concepto:', factura['concepto'] ?? '---'),
                    _buildInfoRow(
                      'Paciente:',
                      factura['nombreCompletoPaciente'] ?? '---',
                    ),
                    Divider(
                      color: AppColors.keppel.withOpacity(0.5),
                      height: 24,
                    ), // 🎨 Color
                    _buildInfoRow(
                      'TOTAL A PAGAR:',
                      '\$${factura['total'] ?? '0'}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Selección de Método de Pago
              Text(
                "SELECCIONA MÉTODO DE PAGO",
                style: AppTextStyles.cardTitle, // 🎨 Estilo
              ),
              const SizedBox(height: 12),

              _buildMetodoPagoOption(
                "PayPal",
                Icons.account_balance_wallet_outlined,
                AppColors.paynesGray,
              ),
              const SizedBox(height: 8),
              _buildMetodoPagoOption(
                "Tarjeta",
                Icons.credit_card_outlined,
                AppColors.paynesGray,
              ),
              const SizedBox(height: 8),
              _buildMetodoPagoOption(
                "PSE",
                Icons.account_balance_outlined,
                AppColors.paynesGray,
              ),

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
                    color: AppColors.keppel.withOpacity(0.1), // 🎨 Color
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.keppel.withOpacity(0.3),
                    ), // 🎨 Color
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: AppColors.keppel,
                            size: 18,
                          ), // 🎨 Color
                          SizedBox(width: 8),
                          Text(
                            'MODO PRUEBA ACTIVADO',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.keppel,
                              fontSize: 14,
                            ), // 🎨 Estilo
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '🔒 Este es un entorno seguro de pruebas',
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                      ), // 🎨 Estilo
                      Text(
                        '💳 No se realizarán cargos reales',
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                      ), // 🎨 Estilo
                      Text(
                        '✅ Usa datos de prueba para simular pagos',
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                      ), // 🎨 Estilo
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botón de Pago (Rediseñado)
              if (_procesando)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.aquamarine,
                      ), // 🎨 Color
                      SizedBox(height: 16),
                      Text(
                        'Procesando pago...',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.paynesGray,
                        ), // 🎨 Estilo
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
                      backgroundColor: AppColors.aquamarine, // 🎨 Color
                      foregroundColor: AppColors.paynesGray, // 🎨 Color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // 🎨 Redondeado
                      ),
                    ),
                    child: Text(
                      'PAGAR \$${factura['total'] ?? '0'}',
                      style: AppTextStyles.button, // 🎨 Estilo
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 WIDGET HELPER REDISEÑADO
  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              // 🎨 Estilo
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? AppColors.paynesGray
                  : AppColors.paynesGray.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isTotal
                  ? AppTextStyles.total
                  : AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ), // 🎨 Estilo
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
